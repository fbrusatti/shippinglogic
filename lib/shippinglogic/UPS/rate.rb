require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    class Rate < Service
      include Attributes

      attribute :weight,              :integer,      :default => 5
  
      # Shipper Attributes
	    attribute :shipper_city,          :string,      :default => 'Victoria'
      attribute :shipper_state,         :string,      :default => 'BC'
      attribute :shipper_zip,           :string,      :default => 'V8T4H2'
      attribute :shipper_country_code,  :string,      :default => 'CA'

      # Ship To Attributes
	    attribute :ship_to_city,          :string,      :default => 'New York'
      attribute :ship_to_state,         :string,      :default => 'NY'
      attribute :ship_to_zip,           :string,      :default => '10003'
      attribute :ship_to_country_code,  :string,      :default => 'US'

      private
        def target
          @target ||= parse_response(request(build_request))
        end

        def build_request
          b = builder
          build_authentication(b)
          b.instruct!

          b.RatingServiceSelectionRequest do
            b.Request do
              b.TransactionReference do
                b.CustomerContext 'Rating and Service'
                b.XpciVersion '1.0001'
              end
              b.RequestAction 'Rate'
            end
            b.PickupType do
              b.Code '01'
            end

            b.Shipment do
              b.Shipper do
                b.Address do
                  b.City shipper_city
                  b.StateProvinceCode shipper_state
                  b.PostalCode shipper_zip
                  b.CountryCode shipper_country_code
                end
              end
              b.ShipTo do
                b.Address do
                  b.PostalCode ship_to_zip
                  b.CountryCode ship_to_country_code
                  b.City ship_to_city
                  b.StateProvinceCode ship_to_state
                end
              end
              b.Service do
                b.Code '03'
              end
              build_package(b, weight)
            end
          end
        end


        def parse_response(response)
          puts "Response ----------------------------------------------"
          puts response
        end

    end
  end
end

