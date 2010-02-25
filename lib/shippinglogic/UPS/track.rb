require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    class Track < Service

      private
        def target
          @target ||= parse_response(request(build_request))          
        end

        def build_request
          b = builder
          build_authentication(b)
          b.instruct!

          b.TrackRequest do 
            b.Request do
              b.TransactionReference do
                b.CustomerContext do
                  b.InternalKey "blah"
                end
                b.XpciVersion "1.0"
              end
              b.RequestAction "Track"
              b.RequestOption "activity"
            end
            b.TrackingNumber "1Z99EY166800069867"
          end
        end

        def parse_response(response)
          puts "Response ----------------------------------------------"
          puts response

          a = Array.new
          Hpricot(response).search('//activity').collect do |tag|

            if tag.at('activitylocation/address/city') && tag.at('activitylocation/address/stateprovincecode')
              address = { 
                  :city => tag.at('activitylocation/address/city').inner_html,
                  :state => tag.at('activitylocation/address/stateprovincecode').inner_html,
                  :country_code => tag.at('activitylocation/address/countrycode').inner_html 
              }
            else
              address = {:country_code => tag.at('activitylocation/address/countrycode').inner_html }
            end

            status = {
                :desc => tag.at('status/statustype/description').inner_html,
                :code => tag.at('status/statuscode/code').inner_html 
            }

            date = {
                :date => tag.at('date').inner_html,
                :time => tag.at('time').inner_html 
            }

            h = { :location => address, :status => status, :date => date }

            puts h

            a << h
          end
          a
        end

    end
  end
end

# Return an Array of Hash where each hash has three keys 'status', 'location' and 'date'

#[
#{:status=>{:desc=>"IN TRANSIT TO", :code=>"IT"}, :location=>{:country_code=>"US", :city=>"SEATTLE", :state=>"WA"}, :date=>{:date=>"20100225", :time=>"005700"}}, 

#{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100225", :time=>"005600"}}, 

#{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100225", :time=>"000100"}}, 

#{:status=>{:desc=>"EXPORT SCAN", :code=>"EP"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"220800"}}, 

#{:status=>{:desc=>"LOCATION SCAN", :code=>"LC"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"220800"}}, 

#{:status=>{:desc=>"ARRIVAL SCAN", :code=>"AR"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"210600"}}, 

#{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"CA", :city=>"VICTORIA", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"180000"}}, 

#{:status=>{:desc=>"ORIGIN SCAN", :code=>"OR"}, :location=>{:country_code=>"CA", :city=>"VICTORIA", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"172200"}}, 

#{:status=>{:desc=>"BILLING INFORMATION RECEIVED", :code=>"MP"}, :location=>{:country_code=>"CA"}, :date=>{:date=>"20100224", :time=>"190419"}}]

