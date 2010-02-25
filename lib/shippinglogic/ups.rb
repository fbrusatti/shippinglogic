require "shippinglogic/UPS/proxy"
require "shippinglogic/UPS/service"
require "shippinglogic/UPS/time_in_transit"
require "shippinglogic/UPS/track"

module Shippinglogic
  class UPS
    # A hash representing default the options. If you are using this in a Rails app the best place
    # to modify or change these options is either in an initializer or your specific environment file. Keep
    # in mind that these options can be modified on the instance level when creating an object. See #initialize
    # for more details.
    #
    # === Options
    #
    # * <tt>:test</tt> - this basically tells us which url to use. If set to true we will use the UPS test URL, if false we
    #   will use the production URL. If you are using this in a rails app, unless you are in your production environment, this
    #   will default to true automatically.
    # * <tt>:test_url</tt> - the test URL for UPS's webservices. (default: https://wwwcie.ups.com/webservices)
    # * <tt>:production_url</tt> - the production URL for UPS's webservices. (default: )
    def self.options
      @options ||= {
        :test => defined?(Rails) && !Rails.env.production?,
        # ToDo: maybe the production URL is different
        :production_url => "https://wwwcie.ups.com/ups.app/xml/TimeInTransit",
        :test_url => "https://wwwcie.ups.com/ups.app/xml/Track"
#        :test_url => "https://wwwcie.ups.com/ups.app/xml/TimeInTransit"
#        :test_url => "https://wwwcie.ups.com/webservices"
      }
    end
  
    attr_accessor :key, :password, :account, :options

    # Before you can use the FedEx web services you need to provide 3 credentials:
    #
    # 1. Your UPS API key
    # 2. Your UPS login
    # 3. Your UPS password 
    #
    # The last parameter allows you to modify the class options on an instance level. It accepts the
    # same options that the class level method #options accepts. If you don't want to change any of
    # them, don't supply this parameter.
    def initialize(key, password, account, options = {})
      self.key = key
      self.password = password
      self.account = account
      self.options = self.class.options.merge(options)
    end
    
#    def cancel(attributes = {})
#      @cancel ||= Cancel.new(self, attributes)
#    end
    
    def rate(attributes = {})
      @rate ||= Rate.new(self, attributes)
    end
    
#    def ship(attributes = {})
#      @ship ||= Ship.new(self, attributes)
#    end
    
#    def signature(attributes = {})
#      @signature ||= Signature.new(self, attributes)
#    end
    
      def time_in_transit(attributes = {})
        @time_in_transit ||= TimeInTransit.new(self, attributes)
      end

    def track(attributes = {})
      @track ||= Track.new(self, attributes)
    end
  end
end
