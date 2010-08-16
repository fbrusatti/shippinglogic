module Shippinglogic
  class UPS
    module Request
      private
        # Convenience method for sending requests to FedEx
        def request(body)
          real_class.post(base.url + real_class.path, :body => body).body
        end

        # Convenience method to create a builder object so that our builder options are consistent across
        # the various services.
        #
        # Ex: if I want to change the indent level to 3 it should change for all requests built.
        def builder
          b = Builder::XmlMarkup.new(:indent => 2)
          b.instruct!
          b
        end
        
        # A convenience method for building the authentication block in your XML request
        def build_authentication(xml)
          xml.AccessRequest do
            xml.AccessLicenseNumber base.key
            xml.UserId base.account
            xml.Password base.password
          end
        end

        # Given a weight build several packages of 100 pounds each one. UPS support a maximum of 150 pounds
        def build_packages(xml, weight)
          @loop_times = (weight / 100).to_i + 1
          @weight_breakdown = (weight.to_f / @loop_times.to_f).round(2)

          @loop_times.times do |i|
            xml.Package do
              xml.PackagingType do
                  xml.Code '02'
                  xml.Description 'Package' + i.to_s
                end
                xml.Description 'Rate Shopping'
                xml.PackageWeight do
                  xml.Weight @weight_breakdown
                  xml.UnitOfMeasurement do
                    xml.Code "LBS"
                end
#                            <PackageServiceOptions>
#                                <InsuredValue>
#                                    <CurrencyCode>USD</CurrencyCode>
#                                    <MonetaryValue>$insured_value</MonetaryValue>
#                                </InsuredValue>
#                            </PackageServiceOptions>
              end
            end
          end
        end

        # A convenience method for building the address block in your XML request
        def build_address(b, type)
          address_lines = send("#{type}_streets").to_s.split(/(?:\s*\n\s*)+/m, 3)
          
          b.Address do
            b.AddressLine1 address_lines[0] if address_lines[0]
            b.AddressLine2 address_lines[1] if address_lines[1]
            b.AddressLine3 address_lines[2] if address_lines[2]
            b.City send("#{type}_city") if send("#{type}_city")
            b.StateProvinceCode send("#{type}_state") if send("#{type}_state")
            b.PostalCode send("#{type}_postal_code") if send("#{type}_postal_code")
            b.CountryCode send("#{type}_country") if send("#{type}_country")
            b.ResidentialAddressIndicator attribute_names.include?("#{type}_residential") && send("#{type}_residential")
          end
        end

    end
  end
end

