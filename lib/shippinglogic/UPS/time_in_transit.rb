require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    class TimeInTransit < Service
      include Attributes

      attribute :customer_context,              :string,      :default => "TNT_D Origin Country Code"
      attribute :xpci_version,                  :string,      :default => "1.0002"

      # Transit From
	    attribute :from_political_division_2,     :string,      :default => 'Victoria'
      attribute :from_political_division_1,     :string,      :default => 'BC'
      attribute :from_country_code,             :string,      :default => 'CA'
      attribute :from_post_code_primary_low,    :string,      :default => 'V8T4H2'

      # Transit To
	    attribute :to_political_division_2,       :string,      :default => 'Toronto'
      attribute :to_political_division_1,       :string,      :default => 'ON'
      attribute :to_country_code,               :string,      :default => 'CA'
      attribute :to_post_code_primary_low,      :string,      :default => 'M5V2T6'

      attribute :weight,                        :string,      :default => 30
      attribute :currency_code                  :string,      :default => 'USD'
      attribute :monetary_value                 :string,      :default => '250.00'
      attribute :unit_of_measurement_code       :string,      :default => 'LBS'
      attribute :unit_of_measurement_desc       :string,      :default => 'Pounds'

      attribute :pickup_date,                   :string,      :default => Date.today.strftime('%Y%m%d')

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
	        	    b.PoticalDivision2 from_political_division_2
	        	    b.PoticalDivision1 from_political_division_1
	        	    b.CountryCode from_country_code
	        	    b.PostcodePrimaryLow from_post_code_primary_low
	        	  end
	        	end

            b.TransitTo do
              b.AddressArtifactFormat do
                b.PoliticalDivision2 to_political_division_2
                b.PoliticalDivision1 to_political_division_1
                b.CountryCode to_country_code
                b.PostcodePrimaryLow to_post_code_primary_low
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
              b.CurrencyCode currency_code
              b.MonetaryValue monetary_value
            end

            b.PickupDate pickup_date
            b.DocumentsOnlyIndicator
          end
        end

        # Returns an array of hash like the following one...
        # [{:total_days=>"1", :date=>"2010-02-26", :service_code=>"23", :label=>"UPS Express Plus"},
        #  {:total_days=>"1", :date=>"2010-02-26", :service_code=>"24", :label=>"UPS Express"},
        #  {:total_days=>"1", :date=>"2010-02-26", :service_code=>"20", :label=>"UPS Express Saver"},
        #  {:total_days=>"1", :date=>"2010-02-26", :service_code=>"19", :label=>"UPS Expedited"},
        #  {:total_days=>"1", :date=>"2010-02-26", :service_code=>"25", :label=>"UPS Standard"}]
        def parse_response(response)
          a = Array.new
          Hpricot(response).search('//servicesummary').collect do |tag|
	          h = Hash.new
            h[:service_code] = tag.at("service/code").inner_html
            h[:label] = tag.at('service/description').inner_html
            h[:total_days] = tag.at('estimatedarrival/totaltransitdays').inner_html
            h[:date] = tag.at('estimatedarrival/date').inner_html

            a << h
          end
          a
        end

    end
  end
end

