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
	        	    b.CountryCode 'V8T4H2'
	        	    b.PostcodePrimaryLow 'CA'
	        	  end
	        	end

            b.TransitTo do
              b.AddressArtifactFormat do
                b.PoliticalDivision2 'Toronto'
                b.PoliticalDivision1 'ON'
                b.CountryCode 'M5V2T6'
                b.PostcodePrimaryLow 'CA'
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

            b.PickupDate 'February 24'
            b.DocumentsOnlyIndicator
          end
        end

        def parse_response(response)
          puts response
        end

    end
  end
end

