require "shippinglogic/UPS/attributes"
require "shippinglogic/UPS/request"

module Shippinglogic
  class UPS
    class Service < Proxy
      include Attributes
      include HTTParty
      include Request
      
      attr_accessor :base
      
      # Accepts the base service object as a single parameter so that we can access
      # authentication credentials and options.
      def initialize(base, attributes = {})
        self.base = base
        super
      end
      
      private
        # Allows the cached response to be reset, specifically when an attribute changes
        def reset_target
          @target = nil
        end
        
        # For each service you need to overwrite this method. This is where you make the call to UPS
        # and do your magic. See the child classes for examples on how to define this method. It is very
        # important that you cache the result into a variable to avoid uneccessary requests.
        def target
          raise ImplementationError.new("You need to implement a target method that the proxy class can delegate method calls to")
        end
    end
  end
end
