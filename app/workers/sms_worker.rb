class SmsWorker
  include Sidekiq::Worker

  def perform(to, message)
    client = BlackIn::Twilio::Client.new
    client.send_message(
      to: to,
      body: message
    )
  end
end
