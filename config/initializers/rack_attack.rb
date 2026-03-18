module Rack
  class Attack
    # --- Throttle login attempts ---
    # 5 attempts per 20 seconds per IP on sign-in endpoint
    throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
      req.ip if req.path == '/api/v1/auth/sign_in' && req.post?
    end

    # --- Throttle general API traffic ---
    # 300 requests per 5 minutes per IP
    throttle('api/ip', limit: 300, period: 5.minutes) do |req|
      req.ip if req.path.start_with?('/api/')
    end

    # --- Throttle by authenticated user token ---
    # 100 requests per minute per token
    throttle('api/token', limit: 100, period: 1.minute) do |req|
      req.get_header('HTTP_ACCESS_TOKEN').presence
    end

    # --- Custom JSON response for throttled requests ---
    self.throttled_responder = lambda do |req|
      match_data  = req.env['rack.attack.match_data']
      now         = match_data[:epoch_time]
      retry_after = match_data[:period] - (now % match_data[:period])

      [
        429,
        {
          'Content-Type' => 'application/json',
          'Retry-After' => retry_after.to_s
        },
        [{ error: 'Too many requests. Please try again later.', retry_after: retry_after }.to_json]
      ]
    end
  end
end
