module BlackIn
  module Twilio

    class Client

      def initialize
        @client = ::Twilio::REST::Client.new(
          Rails.application.config.twilio_config[:account_sid],
          Rails.application.config.twilio_config[:auth_token]
        )
      end

      def send_message(to:, body:)
        @client.messages.create(
          from: Rails.application.config.twilio_config[:phone_numbers].sample,
          to: to.to_s,
          body: body
        )
      end
    end

  end
end
