require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    class Rate < Service
      include Attributes

      attribute :weight,              :integer,      :default => 5

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
#              b.RequestOption 'shop' if compare
            end
            b.PickupType do
              b.Code '01'
            end

            b.Shipment do
              b.Shipper do
                b.Address do
                  b.City 'Victoria'
                  b.StateProvinceCode 'BC'
                  b.PostalCode 'V8T4H2'
                  b.CountryCode 'CA'
                end
              end
              b.ShipTo do
                b.Address do
                  b.PostalCode '10003'
                  b.CountryCode 'US'
                  b.City 'NY'
                  b.StateProvinceCode 'NY'
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

