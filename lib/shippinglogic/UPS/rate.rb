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

      attribute :weight,                :float,       :default => 5
  
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
      attribute :recipient_country,       :string,    :modifier => :country_code

      # monetary options
      attribute :currency_type,           :string


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
                build_address(b, :shipper)
              end

              b.ShipTo do
                b.Address do
                  b.PostalCode recipient_postal_code
                  b.CountryCode recipient_country
                  b.City recipient_city
                  b.StateProvinceCode recipient_state
                end
              end

              if service_type
                b.Service do
                  b.Code service_type
                end
              end

              build_packages(b, weight)
            end
          end
        end


        def parse_response(response)
          return [] if !Hpricot(response).search('//ratedshipment')

          Hpricot(response).search('//ratedshipment').collect do |details|
            OpenStruct.new(
              :service_code => details.at('service/code').inner_html,
              :speed        => details.at('guaranteeddaystodelivery').inner_html,
              :rate         => details.at('totalcharges/monetaryvalue').inner_html,
              :currency     => details.at('totalcharges/currencycode').inner_html
            )
          end.sort_by(&:rate)
        end

    end
  end
end

