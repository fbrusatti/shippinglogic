require "shippinglogic/UPS/attributes"

module Shippinglogic
  class UPS
    class Track < Service

      attribute :tracking_number,              :string,      :default => "1Z99EY166800069867"


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
            b.TrackingNumber tracking_number
          end
        end

        def parse_response(response)
          a = Array.new
          activities = Hash.new
          Hpricot(response).search('//activity').each_with_index do |tag, index|
            if tag.at('activitylocation/address/city') && tag.at('activitylocation/address/stateprovincecode')
              address = { 
                  :city => tag.at('activitylocation/address/city').inner_html,
                  :state => tag.at('activitylocation/address/stateprovincecode').inner_html,
                  :country_code => tag.at('activitylocation/address/countrycode').inner_html 
              }
            else
              address = {:country_code => tag.at('activitylocation/address/countrycode').inner_html }
            end

            status = { :desc => tag.at('status/statustype/description').inner_html, :code => tag.at('status/statuscode/code').inner_html }
            date = { :date => tag.at('date').inner_html, :time => tag.at('time').inner_html }
            h = { :location => address, :status => status, :date => date }

            activities = activities.merge({"#{index}" => h})
          end

          ship_to = {
              :city => Hpricot(response).search('//shipto/address/city').inner_html,
              :state => Hpricot(response).search('//shipto/address/stateprovincecode').inner_html,
              :zip => Hpricot(response).search('//shipto/address/postalcode').inner_html,
              :country_code => Hpricot(response).search('//shipto/address/countrycode').inner_html
          }

          shipper = {
            :address_line => Hpricot(response).search('//shipper/address/addressline1').inner_html,
            :city => Hpricot(response).search('//shipper/address/city').inner_html,
            :state_province_code => Hpricot(response).search('//shipper/address/stateprovincecode').inner_html,
            :postal_code => Hpricot(response).search('//shipper/address/postalcode').inner_html,
            :country_code => Hpricot(response).search('//shipper/address/countrycode').inner_html
          }

          service = {:code => Hpricot(response).search('//service/code').inner_html, :description => Hpricot(response).search('//service/description').inner_html}

          a << {:activities => activities}
          a << {:ship_to => ship_to}
          a << {:shipper => shipper}
          a << {:service => service}
          a << {:status => {:status => Hpricot(response).search('//responsestatusdescription').inner_html}}
          a << {:ship_id_number => {:number => Hpricot(response).search('//shipmentidentificationnumber').inner_html}}
          a << {:pickup_date => {:date => Hpricot(response).search('//pickupdate').inner_html}}
          a
        end

    end
  end
end


#[
#{:activities=>{
#  "6"=>{:status=>{:desc=>"LOCATION SCAN", :code=>"LC"}, :location=>{:country_code=>"US", :city=>"SEATTLE", :state=>"WA"}, :date=>{:date=>"20100225", :time=>"193600"}}, 
#  "11"=>{:status=>{:desc=>"IMPORT SCAN", :code=>"IP"}, :location=>{:country_code=>"US", :city=>"SEATTLE", :state=>"WA"}, :date=>{:date=>"20100225", :time=>"171000"}}, 
#  "12"=>{:status=>{:desc=>"ARRIVAL SCAN", :code=>"AR"}, :location=>{:country_code=>"US", :city=>"SEATTLE", :state=>"WA"}, :date=>{:date=>"20100225", :time=>"091500"}}, 
#  "7"=>{:status=>{:desc=>"ARRIVAL SCAN", :code=>"AR"}, :location=>{:country_code=>"US", :city=>"SEATTLE", :state=>"WA"}, :date=>{:date=>"20100225", :time=>"181800"}}, 
#  "8"=>{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"US", :city=>"SEATTLE", :state=>"WA"}, :date=>{:date=>"20100225", :time=>"175400"}},
#  "13"=>{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100225", :time=>"005600"}},
#  "14"=>{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100225", :time=>"000100"}},
#  "9"=>{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"US", :city=>"SEATTLE", :state=>"WA"}, :date=>{:date=>"20100225", :time=>"171500"}},
#  "15"=>{:status=>{:desc=>"EXPORT SCAN", :code=>"EP"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"220800"}}, 
#  "16"=>{:status=>{:desc=>"LOCATION SCAN", :code=>"LC"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"220800"}},
#  "0"=>{:status=>{:desc=>"IN TRANSIT TO", :code=>"IT"}, :location=>{:country_code=>"US", :city=>"COMMERCE CITY", :state=>"CO"}, :date=>{:date=>"20100227", :time=>"005200"}},
#  "1"=>{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"US", :city=>"SALT LAKE CITY", :state=>"UT"}, :date=>{:date=>"20100227", :time=>"005100"}}, 
#  "17"=>{:status=>{:desc=>"ARRIVAL SCAN", :code=>"AR"}, :location=>{:country_code=>"CA", :city=>"RICHMOND", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"210600"}},
#  "18"=>{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"CA", :city=>"VICTORIA", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"180000"}},
#  "2"=>{:status=>{:desc=>"ARRIVAL SCAN", :code=>"AR"}, :location=>{:country_code=>"US", :city=>"SALT LAKE CITY", :state=>"UT"}, :date=>{:date=>"20100227", :time=>"000900"}},
#  "20"=>{:status=>{:desc=>"BILLING INFORMATION RECEIVED", :code=>"MP"}, :location=>{:country_code=>"CA"}, :date=>{:date=>"20100224", :time=>"190419"}},
#  "3"=>{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"US", :city=>"HERMISTON", :state=>"OR"}, :date=>{:date=>"20100226", :time=>"082500"}}, 
#  "19"=>{:status=>{:desc=>"ORIGIN SCAN", :code=>"OR"}, :location=>{:country_code=>"CA", :city=>"VICTORIA", :state=>"BC"}, :date=>{:date=>"20100224", :time=>"172200"}}, 
#  "10"=>{:status=>{:desc=>"LOCATION SCAN", :code=>"LC"}, :location=>{:country_code=>"US", :city=>"SEATTLE", :state=>"WA"}, :date=>{:date=>"20100225", :time=>"171100"}}, 
#  "4"=>{:status=>{:desc=>"ARRIVAL SCAN", :code=>"AR"}, :location=>{:country_code=>"US", :city=>"HERMISTON", :state=>"OR"}, :date=>{:date=>"20100226", :time=>"051000"}}, 
#  "5"=>{:status=>{:desc=>"DEPARTURE SCAN", :code=>"DP"}, :location=>{:country_code=>"US", :city=>"SEATTLE", :state=>"WA"}, :date=>{:date=>"20100225", :time=>"232300"}}
#  }
#}, 
#{:ship_to=>{:country_code=>"US", :city=>"OVERLAND PARK", :zip=>"66212", :state=>"KS"}}, 
#{:shipper=>{:country_code=>"CA", :city=>"VICTORIA", :address_line=>"2175 DOWLER PL", :postal_code=>"V8T4H2", :state_province_code=>"BC"}}, 
#{:service=>{:code=>"011", :description=>"STANDARD"}}, 
#{:status=>{:status=>"Success"}}, 
#{:ship_id_number=>{:number=>"1Z99EY166800069867"}}, 
#{:pickup_date=>{:date=>"20100224"}}
#]

