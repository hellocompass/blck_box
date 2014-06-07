if Rails.env == 'production'
  omniauth_config = {
    google_id: ENV['GOOGLE_ID'],
    google_secret: ENV['GOOGLE_SECRET'],
    fb_key: ENV['FACEBOOK_KEY'],
    fb_secret: ENV['FACEBOOK_SECRET'],
    twitter_key: ENV['TWITTER_KEY'],
    twitter_secret: ENV['TWITTER_SECRET']
  }
else
  omniauth_config = {}
  fb_config = YAML.load_file(Rails.root + 'config/facebook.secret.yml')[Rails.env]
  # twitter_config = YAML.load_file(Rails.root + 'config/twitter.secret.yml')[Rails.env]
  omniauth_config[:fb_key] = fb_config[:app_id]
  omniauth_config[:fb_secret] = fb_config[:app_secret]
  # omniauth_config[:twitter_key] = twitter_config[:app_id]
  # omniauth_config[:twitter_secret] = twitter_config[:app_secret]
end

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :google_oauth2, omniauth_config[:google_id], omniauth_config[:google_secret], provider_ignores_state: true
  # provider :facebook, omniauth_config[:fb_key], omniauth_config[:fb_secret], scope: 'email', provider_ignores_state: true
  # provider :twitter, omniauth_config[:twitter_key], omniauth_config[:twitter_secret]
end

Rails.application.config.omniauth_config = omniauth_config

OmniAuth.config.on_failure = Api::SessionsController.action(:auth_failure)
