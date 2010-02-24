require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    class TimeInTransit < Service
      include Attributes

      attribute :customer_context,          :string,      :default => "TNT_D Origin Country Code"
      attribute :xpci_version,              :string,      :default => "1.0002"

      # Transit From
	    attribute :political_division_2,      :string,      :default => 'Victoria'
      attribute :political_division_1,      :string,      :default => 'BC'
      attribute :country_code,              :string,      :default => 'CA'
      attribute :post_code_primary_low,     :string,      :default => 'V8T4H2'

      # Transit To
	    attribute :political_division_2,      :string,      :default => 'Toronto'
      attribute :political_division_1,      :string,      :default => 'ON'
      attribute :country_code,              :string,      :default => 'CA'
      attribute :post_code_primary_low,     :string,      :default => 'M5V2T6'

      #
      attribute :weight,                    :string,      :default => 30

      #
      attribute :pickup_date,               :string,      :default => Date.today.strftime('%Y%m%d')

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
                b.CustomerContext customer_context
                b.XpciVersion xpci_version
              end
              b.RequestAction "TimeInTransit"	  	  
            end

	        	b.TransitFrom do
	        	  b.AddressArtifactFormat do
	        	    b.PoticalDivision2 political_division_2
	        	    b.PoticalDivision1 political_division_1
	        	    b.CountryCode country_code
	        	    b.PostcodePrimaryLow post_code_primary_low
	        	  end
	        	end

            b.TransitTo do
              b.AddressArtifactFormat do
                b.PoliticalDivision2 political_division_2
                b.PoliticalDivision1 political_division_1
                b.CountryCode country_code
                b.PostcodePrimaryLow post_code_primary_low
              end
            end

            b.ShipmentWeight do
              b.UnitOfMeasurement do
                b.Code "LBS"
                b.Description "Pounds"
              end
              b.Weight weight
            end

            b.InvoiceLineTotal do
              b.CurrencyCode "USD" 
              b.MonetaryValue "250.00"
            end

            b.PickupDate pickup_date
            b.DocumentsOnlyIndicator
          end
        end

        def parse_response(response)
          puts 'Response ----------------------------'
          puts response
          puts '######################################'
        end

    end
  end
end

