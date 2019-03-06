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
def request_finrem_status(url)
  uri = URI(url)

  result = Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri
    http.request request
  end

  if result
    return JSON.parse(result.body)
  end
  # If something wrong happened then tiles won't be refreshed.
  # puts 'An error occurred.'
  puts 'an error occurred'
  puts result.body
  # puts result
end

def process_request(service)
  test_runs = request_finrem_status(SERVICES[service])

  send_event("service_state_1", text: JSON.pretty_unparse(test_runs, { quirks_mode: true }))
  # send_event("service_details", text: test_runs['details'])
end
