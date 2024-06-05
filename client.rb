require 'openssl'
require 'faraday'
require 'async'
require 'async/semaphore'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def async_request(endpoint, value, semaphore)
  semaphore.async do
    puts "https://localhost:9292/#{endpoint}?value=#{value}"
    Faraday.get("https://localhost:9292/#{endpoint}?value=#{value}").body
  end
end

def collect_sorted(arr)
  arr.sort.join('-')
end

start = Time.now

Async do |task|
  sem_a = Async::Semaphore.new(3)
  sem_b = Async::Semaphore.new(2)
  sem_c = Async::Semaphore.new(1)

  # First batch of 'a' requests
  a11 = async_request('a', 11, sem_a)
  a12 = async_request('a', 12, sem_a)
  a13 = async_request('a', 13, sem_a)

  # Second batch of 'a' requests
  a21 = async_request('a', 21, sem_a)
  a22 = async_request('a', 22, sem_a)
  a23 = async_request('a', 23, sem_a)

  # Third batch of 'a' requests
  a31 = async_request('a', 31, sem_a)
  a32 = async_request('a', 32, sem_a)
  a33 = async_request('a', 33, sem_a)

  # Handle 'b' requests separately to maximize parallelism
  b1 = async_request('b', 1, sem_b)
  b2 = async_request('b', 2, sem_b)
  b3 = async_request('b', 3, sem_b)

  # Wait for all 'a' requests to complete and process 'ab' combinations
  ab1 = task.async { "#{collect_sorted([a11.wait, a12.wait, a13.wait])}-#{b1.wait}" }
  ab2 = task.async { "#{collect_sorted([a21.wait, a22.wait, a23.wait])}-#{b2.wait}" }
  ab3 = task.async { "#{collect_sorted([a31.wait, a32.wait, a33.wait])}-#{b3.wait}" }

  # Handle 'c' requests as soon as the corresponding 'ab' is ready
  c1 = task.async { async_request('c', ab1.wait, sem_c).wait }
  c2 = task.async { async_request('c', ab2.wait, sem_c).wait }
  c3 = task.async { async_request('c', ab3.wait, sem_c).wait }

  # Collect results of all 'c' requests
  c1 = c1.wait
  c2 = c2.wait
  c3 = c3.wait

  # Final 'a' request with sorted 'c' results
  c123 = collect_sorted([c1, c2, c3])
  result = async_request('a', c123, sem_a).wait

  puts "FINISHED in #{Time.now - start}s."
  puts "RESULT = #{result}"
end
