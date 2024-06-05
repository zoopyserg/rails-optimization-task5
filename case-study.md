## Case study:
1. Opening the task. Setting up Ruby, bundle, etc.
2. Starting the sinatra server app.
3. Running ruby client.rb to measure the current state.
FINISHED in 19.171187s.
4. Optimizing client.rb.
Using Async gem to make requests in parallel.
FINISHED in 8.103609s.
Task completed.

# Optimization Explanation

## Initial Version

### Initial Setup:
- We had three types of requests to the server: `a`, `b`, and `c`.
- Each type has a specific response time and concurrency limit:
  - `a`: 1 second, up to 3 requests simultaneously
  - `b`: 2 seconds, up to 2 requests simultaneously
  - `c`: 1 second, up to 1 request at a time

### Initial Client Code:
1. **Sequential Execution:**
   - The code was making requests in a sequential manner.
   - It was waiting for each set of requests to finish before starting the next.
   - For example, it would send three `a` requests, wait for all to finish, then send one `b` request, wait for it to finish, and so on.

2. **Order of Execution:**
   - First, send three `a` requests.
   - Wait for all three `a` requests to finish.
   - Send one `b` request.
   - Wait for the `b` request to finish.
   - Combine results and send a `c` request.
   - Repeat the process two more times for the remaining sets of requests.

### Problem:
- Because it was waiting for each set of requests to finish before starting the next, there was a lot of idle time.
- This resulted in a total execution time of about 19.5 seconds.

## Optimized Version

### Optimization Strategy:
1. **Parallel Execution:**
   - Instead of waiting for each set of requests to finish, we start the next set of requests as soon as possible.
   - This overlaps the waiting times and reduces idle time.

2. **Concurrency Control:**
   - We use semaphores to ensure we don’t exceed the server's concurrency limits.
   - Semaphores act as traffic lights, allowing only a certain number of requests to proceed simultaneously.

### Step-by-Step Changes:

1. **Using `async` and `Async::Semaphore`:**
   - We introduced the `async` library to manage parallel execution.
   - We used `Async::Semaphore` to control the number of concurrent requests.

2. **Batching Requests:**
   - We divided the requests into batches and allowed them to run concurrently.
   - For example, three `a` requests run simultaneously, followed by three more `a` requests, and so on.

3. **Parallel Handling of `b` Requests:**
   - We started `b` requests as soon as possible without waiting for all `a` requests to complete.
   - This ensured that the server was always working on something, reducing idle time.

4. **Handling `c` Requests Concurrently:**
   - We initiated `c` requests as soon as their corresponding results from `a` and `b` were available.
   - This further reduced waiting times.

### New Execution Order:

1. **First Batch:**
   - Send three `a` requests (`a11`, `a12`, `a13`) and one `b` request (`b1`) in parallel.
   - Combine results and send the first `c` request (`c1`).

2. **Second Batch:**
   - While waiting for the first batch to finish, send the next three `a` requests (`a21`, `a22`, `a23`) and one `b` request (`b2`) in parallel.
   - Combine results and send the second `c` request (`c2`).

3. **Third Batch:**
   - While waiting for the previous batches to finish, send the final three `a` requests (`a31`, `a32`, `a33`) and one `b` request (`b3`) in parallel.
   - Combine results and send the third `c` request (`c3`).

4. **Final Step:**
   - Collect results from all `c` requests, combine them, and send a final `a` request with the combined result.

### Outcome:
- By maximizing parallel execution and minimizing idle times, we reduced the total execution time to around 8 seconds.
- The optimized code makes better use of the server's capabilities, ensuring it is always working on something and reducing unnecessary waiting times.

### Summary:
- **Initial Version:** Sequential and inefficient, leading to long execution times.
- **Optimized Version:** Parallel and efficient, leveraging concurrency to reduce execution times significantly.





## Lecture notes:

Perception:
100 ms - instant
100-300ms - ok but notised (OK for 3G)
300-1000ms - ok but slow
1 sec - will switch to one sec
10 sec - will think the site does not work

Being slow = losing money and clients

x2 Speed = x2 conversion (sales)

What to measure:
- Sales nodes
- Agony points
- Browsers
- Devices
- Slowest devices
- Screen sizes
- OS
- Do people use 3G (for a product used on-the-go)
- Aim 5sec load time on 3G

See NewRelic to track how fast is website in each country.

Gem Ahoy

Minimize (and compare this to compatitors):
- # of requests (images, css, js)
- Size of requests (under 200kb)
- Especially minimize mobile versions used on 3G (simulate 3G mobile app)

These factors affect Google rank too.

Performance and speed is a feature.
This includes design, etc.

Browser Calories
performancebudget.io

Budgets (when aiming 1sec load time on mobile):
3G:
DNS lookup: 200ms
TCP handshake: 200ms
TLS handshake: 200ms (optional)
HTTP request: 200ms
Leftover: 200-400ms

4G:
DNS lookup: 80ms
TCP handshake: 80ms
TLS handshake: 80ms (optional)
HTTP request: 80ms
Leftover: 500-760ms

Latency vs Bandwith:
Latency is "how long it takes to get a response"
Bandwith is "how much data can be sent at once"
Bandwith under 1mbps is instant and is very easy to improve.
Latency is the slower the better and is very hard to improve.

Latency bottleneck is the speed of light of optical fiber (or in case of 3G it's the slower less stable wireless networks)
So the only way to improve latency is:
- reduce distance between you and your target.
- pick servers in the locations where your clients are
- reduce round trips (get all packages at once)

TCP (1978) - lossless transfer in an unstable environment
3 way handshake
so if latency is 200ms then it's 600ms for 3 way handshake
so the connection has to remain open
Tries to pick the maximum number of packets above which they start getting lost.

HTTP 0.9 (1991) - GET (based on TCP)
HTTP 1.0 (1996) - GET, POST, HEAD, PUT, DELETE, codes 200, 404, 500 etc; Keep-Alive, cookies, caching, 6 connections per domain, no security, no compression
HTTP 1.1 (1999) - GET, POST, HEAD, PUT, DELETE, codes 200, 404, 500 etc; Keep-Alive, cookies, caching, 6 connections per domain, security, compression, pipelining, chunked transfer encoding, range requests, cache control, conditional requests, 100-continue, 8kb initial window size, 2-4 connections per domain
HTTP 2 (2015) - GET, POST, HEAD, PUT, DELETE, codes 200, 404, 500 etc; Keep-Alive, cookies, caching, 1 connection per domain, security, compression, multiplexing, server push, header compression, binary protocol (so can't read as text), prioritization, flow control, 64kb initial window size, 1 connection per domain

TLS (1999) - secure transfer - handshake, encryption, decryption, key exchange, certificate exchange, 2-4 round trips, 1-2 seconds, 1-2kb, 1-2 connections per domain
Identification - show passport
Authentication - check passport is not fake
Authorization - check if you are allowed to enter
TLS = TCP + 1-2 round trips
HSTS - HTTP Strict Transport Security - tells browser to always use HTTPS

nginx:
ssl http2 push on

Rails performance optimization:
Sprockets
Digest
CDN
Asset Host
Reduce Base64 usage (it increases size)
Force SSL
headers + content security policy
reduce amount of cookies

Caching:
304 Not Modified (response from server "use what you have")
If-Modified-Since (request from client "do you have something newer")
fresh_when
stale?
http_cache_forever
expires_in
expires_now
Rails can tell nginx to push assets via headers

Brotli - better than gzip

Web optimization tools:
WebPageTest.org - test website speed
requestmap
speed index (the smaller the area above the load time chart - the better)
Can optimize not only a single page visit, but also a script of navigating from one page to another.
