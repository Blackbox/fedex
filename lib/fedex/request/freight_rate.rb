require 'fedex/request/base'

module Fedex
  module Request
    class FreightRate < Rate

      private

      # Add information for shipments
      def add_requested_shipment(xml)
        xml.RequestedShipment{
          xml.ServiceType service_type if service_type
          xml.PreferredCurrency @shipper[:country_code] == "CA" ? "CAD" : "USD"
          add_shipper(xml)
          add_recipient(xml)
          xml.ShippingChargesPayment{
            xml.PaymentType 'SENDER'
            xml.Payor{
              xml.ResponsibleParty{
                xml.AccountNumber @freight_account[:account_number]
              }
            }
          }
          add_unified_freight_shipment_detail(xml) if (@freight_account[:account_number] == '300288790')
          add_freight_shipment_detail(xml) unless (@freight_account[:account_number] == '300288790')
          xml.RateRequestTypes "PREFERRED"
        }
      end

      def add_unified_freight_shipment_detail(xml)
        xml.FreightShipmentDetail{
          xml.FedExFreightAccountNumber @freight_account[:account_number]
          xml.FedExFreightBillingContactAndAddress{
            xml.Contact{
              xml.CompanyName @shipper[:name]
              xml.PhoneNumber @shipper[:phone_number]
            }
            xml.Address{
              xml.StreetLines @freight_account[:address]
              xml.City @freight_account[:city]
              xml.StateOrProvinceCode @freight_account[:state]
              xml.PostalCode @freight_account[:postal_code]
              xml.CountryCode @freight_account[:country_code]
            }
          }
          xml.Role 'SHIPPER'
          @packages.each do |package|
            xml.LineItems{
              xml.FreightClass package[:freight_class] || 'CLASS_070'
              xml.Packaging 'PALLET'
              xml.Weight{
                xml.Units package[:weight][:units]
                xml.Value package[:weight][:value]
              }
            }
          end
        }
      end

      def add_freight_shipment_detail(xml)
        xml.FreightShipmentDetail{
          xml.AlternateBilling{
            xml.AccountNumber @freight_account[:account_number]
            xml.Address{
              xml.StreetLines @freight_account[:address]
              xml.City @freight_account[:city]
              xml.StateOrProvinceCode @freight_account[:state]
              xml.PostalCode @freight_account[:postal_code]
              xml.CountryCode @freight_account[:country_code]
            }
          }
          xml.Role 'SHIPPER'
          @packages.each do |package|
            xml.LineItems{
              xml.FreightClass package[:freight_class] || 'CLASS_050'
              xml.Packaging 'PALLET'
              xml.Weight{
                xml.Units package[:weight][:units]
                xml.Value package[:weight][:value]
              }
            }
          end
        }
      end

    end
  end
end
