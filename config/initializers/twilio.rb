if Rails.env == 'production'
  Rails.application.config.twilio_config = {
    account_sid: ENV['TWILIO_ACCOUNT_SID'],
    auth_token: ENV['TWILIO_AUTH_TOKEN'],
    phone_numbers: ENV['TWILIO_PHONE_NUMBERS']
  }
else
  Rails.application.config.twilio_config =
    YAML.load_file(Rails.root + 'config/twilio.secret.yml')[Rails.env]
end
