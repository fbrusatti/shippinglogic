require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    class TimeInTransit < Service
      include Attributes

      attribute :customer_context,              :string,  :default => "TNT_D Origin Country Code"
      attribute :xpci_version,                  :string,  :default => "1.0002"

      # Transit From
	    attribute :from_political_division_2,     :string
      attribute :from_political_division_1,     :string
      attribute :from_country_code,             :string
      attribute :from_post_code_primary_low,    :string

      # Transit To
	    attribute :to_political_division_2,       :string
      attribute :to_political_division_1,       :string
      attribute :to_country_code,               :string
      attribute :to_post_code_primary_low,      :string

      attribute :weight,                        :string
      attribute :currency_code,                 :string
      attribute :monetary_value,                :string
      attribute :unit_of_measurement_code,      :string,  :default => 'LBS'
      attribute :unit_of_measurement_desc,      :string,  :default => 'Pounds'

      attribute :pickup_date,                   :string,  :default => Date.today.strftime('%Y%m%d')

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

        # Returns an array of hashs like the following one...
        #
        #[ {:service_code=>"23", :date=>"2010-03-02", :total_days=>"1", :label=>"UPS Express Plus"},
        #  {:service_code=>"24", :date=>"2010-03-02", :total_days=>"1", :label=>"UPS Express"},
        #  {:service_code=>"20", :date=>"2010-03-02", :total_days=>"1", :label=>"UPS Express Saver"},
        #  {:service_code=>"19", :date=>"2010-03-03", :total_days=>"2", :label=>"UPS Expedited"},
        #  {:service_code=>"25", :date=>"2010-03-05", :total_days=>"4", :label=>"UPS Standard"}]
        def parse_response(response)
          a = Array.new
          Hpricot(response).search('//servicesummary').collect do |tag|
            h = {
              :service_code => tag.at("service/code").inner_html,
              :label => tag.at('service/description').inner_html,
              :total_days => tag.at('estimatedarrival/totaltransitdays').inner_html,
              :date => tag.at('estimatedarrival/date').inner_html
            }

            a << h
          end
          a
        end

    end
  end
end

