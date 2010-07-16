require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS


    # === Delivery options
    #
    # * <tt>service_type</tt> - one of SERVICE_TYPES, this is optional, leave this blank if you want a list of all available services. (default: nil)
    # * <tt>delivery_deadline</tt> - whether or not to include estimated transit times. (default: true)
    # * <tt>dropoff_type</tt> - one of DROP_OFF_TYPES. (default: REGULAR_PICKUP)

    class Rate < Service
      include Attributes

      attribute :weight,                :float,      :default => 5
  
      # Shipper Attributes
	    attribute :shipper_city,          :string
      attribute :shipper_state,         :string
      attribute :shipper_zip,           :string
      attribute :shipper_country_code,  :string

      # Ship To Attributes
	    attribute :ship_to_city,          :string
      attribute :ship_to_state,         :string
      attribute :ship_to_zip,           :string
      attribute :ship_to_country_code,  :string

      # delivery options
      attribute :service_type,                :string
      attribute :dropoff_type,                :string,      :default => "01"
      attribute :saturday,                    :boolean,     :default => false

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
              b.RequestOption service_type ? "Rate" : "Shop"
            end

            b.PickupType do
              b.Code dropoff_type
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

