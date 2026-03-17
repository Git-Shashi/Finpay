module Api
  module V1
    class BaseController < ApplicationController
      before_action :set_secure_headers

      private

      def set_secure_headers
        response.set_header('X-Content-Type-Options', 'nosniff')
        response.set_header('X-Frame-Options', 'DENY')
        response.set_header('X-XSS-Protection', '1; mode=block')
        response.set_header('Strict-Transport-Security', 'max-age=31536000; includeSubDomains')
        response.set_header('Referrer-Policy', 'strict-origin-when-cross-origin')
        response.set_header('Cache-Control', 'no-store')
      end
    end
  end
end
