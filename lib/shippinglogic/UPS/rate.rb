require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    # An interface to the rate services provided by UPS. Allows you to get an array of rates from UPS for a shipment,
    # or a single rate for a specific service.
    #
    # == Options
    # === Shipper options
    #
    # * <tt>shipper_name</tt> - name of the shipper.
    # * <tt>shipper_streets</tt> - street part of the address, separate multiple streets with a new line, dont include blank lines.
    # * <tt>shipper_city</tt> - city part of the address.
    # * <tt>shipper_state_</tt> - state part of the address, use state abreviations.
    # * <tt>shipper_postal_code</tt> - postal code part of the address. Ex: zip for the US.
    # * <tt>shipper_country</tt> - country code part of the address. UPS expects abbreviations, but Shippinglogic will convert full names to abbreviations for you.
    #
    # === Delivery options
    #
    # * <tt>service_type</tt> - one of SERVICE_TYPES, this is optional, leave this blank if you want a list of all available services. (default: nil)
    # * <tt>delivery_deadline</tt> - whether or not to include estimated transit times. (default: true)
    # * <tt>dropoff_type</tt> - one of DROP_OFF_TYPES. (default: REGULAR_PICKUP)

    class Rate < Service
      # Useful to complete url request
      def self.path
        "/Rate"
      end

      include Attributes

      attribute :weight,                :float,      :default => 5
  
      # Shipper Attributes
      attribute :shipper_name,          :string
      attribute :shipper_streets,       :string
      attribute :shipper_city,          :string
      attribute :shipper_state,         :string
      attribute :shipper_postal_code,   :string
      attribute :shipper_country,       :string,      :modifier => :country_code

      # Ship To Attributes
	    attribute :recipient_city,          :string
      attribute :recipient_state,         :string
      attribute :recipient_postal_code,   :string
      attribute :recipient_country,       :string,      :modifier => :country_code

      # delivery options
      attribute :service_type,          :string
      attribute :dropoff_type,          :string,      :default => "01"
      attribute :saturday,              :boolean,     :default => false

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
                  b.PostalCode shipper_postal_code
                  b.CountryCode shipper_country
                end
              end
              b.ShipTo do
                b.Address do
                  b.PostalCode recipient_postal_code
                  b.CountryCode recipient_country
                  b.City recipient_city
                  b.StateProvinceCode recipient_state
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


puts "*************** Response is:"
puts response.inspect
puts response.class
puts response[:rated_shipment]
#          return [] if !response[:rated_shipment]
#          
#          response[:rated_shipment].collect do |details|
#            service = Service.new
#            service.name = Enumerations::SERVICE_TYPES[details[:service][:code]]
#            service.type = service.name
#            service.speed = (days = details[:guaranteed_days_to_delivery]) && (days.to_i * 86400)
#            service.rate = BigDecimal.new(details[:total_charges][:monetary_value])
#            service.currency = details[:total_charges][:currency_code]
#            service
#          end
        end

    end
  end
end

