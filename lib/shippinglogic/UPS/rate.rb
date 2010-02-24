require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    class Track
      include Attributes

      private
        def target
          @target ||= parse_response(request(build_request))
        end

        def build_request
          b = build
          build_authentication(b)
        end
    end
  end
end

