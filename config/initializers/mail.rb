if Rails.env == 'production'
  mandrill_config = {
    api_key: ENV['MANDRILL_KEY'],
    username: ENV['MANDRILL_USERNAME'],
    password: ENV['MANDRILL_PASS']
  }
else
  mandrill_config = YAML.load_file(Rails.root + 'config/mandrill.secret.yml')[Rails.env]
end

ActionMailer::Base.smtp_settings = {
  :address   => "smtp.mandrillapp.com",
  :port      => 587,
  :user_name => mandrill_config[:username],
  :password  => mandrill_config[:password],
  :domain    => 'heroku.com'
}
ActionMailer::Base.delivery_method = :smtp

MandrillMailer.configure do |config|
  config.api_key = mandrill_config[:api_key]
end
