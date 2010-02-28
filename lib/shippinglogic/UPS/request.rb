module Shippinglogic
  class UPS
    module Request
      private
        # Convenience method for sending requests to FedEx
        def request(body)

          url = base.options[:test] ? base.options[:test_url] : base.options[:production_url]
          url = url + "/#{real_class.to_s.split('::').last}"
          puts "sending to #{url}"
          puts body
          puts "--------------------------------------------------------------------------"
          real_class.post(url, :body => body).body
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
        def build_package(xml, weight)
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
              end
            end
          end
        end

    end
  end
end

