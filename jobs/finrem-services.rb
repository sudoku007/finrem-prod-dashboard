require 'net/http'
require 'json'

SERVICES = { "FR-COS" => "http://finrem-cos-prod.service.core-compute-prod.internal/health",
           "FR-NS" => "http://finrem-ns-prod.service.core-compute-prod.internal/health",
           "FR-DGCS" => "http://finrem-dgcs-prod.service.core-compute-prod.internal/health",
           "FR-EMCA" => "http://finrem-dgcs-prod.service.core-compute-prod.internal/health",
           "FR-PS" => "http://finrem-ps-prod.service.core-compute-prod.internal/health"
}

# That method will actually fetch the data from Hiptest
# and return an array of hashes containing test runs names and status
def request_hiptest_status(url)
  uri = URI(url)

  result = Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri
    http.request request
  end

  if result and result.is_a?(Net::HTTPOK)
    return JSON.parse(result.body)['status']
  else
    return 'DOWN'
  end

  # If something wrong happened then tiles won't be refreshed.
  # puts 'An error occurred.'
  puts result.body
  # puts result
end

# This method is in charge of returning the most
# valuable status for the given status.
#
# It's up to you to define here which status you want your
# dashboard to show depending the status of a test run
def get_status_text(status)
  return "Failed" if status.upcase == 'DOWN'
  return "Passed" if status.upcase == 'UP'

  return "Unknown"
end

# Every 30 seconds the dashboard will fetch status from Hiptest
# then refresh the tiles accordingly
SCHEDULER.every '120s' do\

  SERVICES.each do|name,url|
  test_runs = request_hiptest_status(url)

    if test_runs
      send_event(name, text: get_status_text(test_runs))
    end
  end
end
