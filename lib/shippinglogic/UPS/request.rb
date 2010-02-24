module Shippinglogic
  class UPS
    module Request
      private
        # Convenience method for sending requests to FedEx
        def request(body)
          real_class.post(base.options[:test] ? base.options[:test_url] : base.options[:production_url], :body => body)
        end

        # Convenience method to create a builder object so that our builder options are consistent across
        # the various services.
        #
        # Ex: if I want to change the indent level to 3 it should change for all requests built.
        def builder
          b = Builder::XmlMarkup.new(:indent => 2)
          b.instruct!
          b
        end
        
        # A convenience method for building the authentication block in your XML request
        def build_authentication(b)
          b.AccessRequest do
            b.AccessLicenseNumber base.api_key
            b.UserId base.account
            b.Password base.password
          end
        end
    end
  end
end

