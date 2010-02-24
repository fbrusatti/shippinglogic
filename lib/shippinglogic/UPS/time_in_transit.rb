require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    class TimeInTransit < Service
      include Attributes

      private
        def target
          @target ||= parse_response(request(build_request))
        end

        def build_request
          b = builder
          build_authentication(b)
          b.instruct!
          b.TimeInTransitRequest do
            b.Request do
              b.TransactionReference do
                b.CustomerContext "TNT_D Origin Country Code"
                b.XpciVersion "1.0002"
              end
              b.RequestAction "TimeInTransit"	  	  
            end

	        	b.TransitFrom do
	        	  b.AddressArtifactFormat do
	        	    b.PoticalDivision2 'Victoria'
	        	    b.PoticalDivision1 'BC'
	        	    b.CountryCode 'CA'
	        	    b.PostcodePrimaryLow 'V8T4H2'
	        	  end
	        	end

            b.TransitTo do
              b.AddressArtifactFormat do
                b.PoliticalDivision2 'Toronto'
                b.PoliticalDivision1 'ON'
                b.CountryCode 'CA'
                b.PostcodePrimaryLow 'M5V2T6'
              end
            end

            b.ShipmentWeight do
              b.UnitOfMeasurement do
                b.Code "LBS"
                b.Description "Pounds"
              end
              b.Weight "30"
            end

            b.InvoiceLineTotal do
              b.CurrencyCode "USD" 
              b.MonetaryValue "250.00"
            end

            b.PickupDate '20100226'
            b.DocumentsOnlyIndicator
          end
        end

        def parse_response(response)
          puts "Response ----------------------"
          puts response
          puts "#################################"
        end

    end
  end
end

