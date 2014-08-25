require 'app/services/channels'

module Citygram::Models
  class Subscription < Sequel::Model
    many_to_one :publisher

    set_allowed_columns :geom, :publisher_id, :channel,
                        :webhook_url, :phone_number, :email_address

    plugin :email_validation
    plugin :geometry_validation
    plugin :phone_validation
    plugin :serialization, :geojson, :geom
    plugin :serialization, :phone, :phone_number
    plugin :url_validation

    def unsubscribe!
      self.unsubscribed_at = DateTime.now
      save!
    end

    def validate
      super
      validates_presence [:geom, :publisher_id, :channel]
      validates_includes Citygram::Services::Channels.available.map(&:to_s), :channel

      case channel
      when 'webhook'
        validates_url :webhook_url
      when 'email'
        validates_email :email_address
      when 'sms'
        validates_phone :phone_number
      end

      validates_geometry :geom
    end
  end
end
