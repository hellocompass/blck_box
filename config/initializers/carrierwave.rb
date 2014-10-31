if Rails.env == 'production'
  aws_config = {
    key: ENV['AWS_KEY'],
    secret: ENV['AWS_SECRET']
  }
else
  aws_config = YAML.load_file(Rails.root + 'config/aws.secret.yml')[Rails.env]
end

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => aws_config[:key],                        # required
    :aws_secret_access_key  => aws_config[:secret],                        # required
    # :region                 => 'us-west-1',                  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = 'blck-in'                          # required
  config.fog_attributes = {'Cache-Control'=>"max-age=#{365.day.to_i}"} # optional, defaults to {}
  config.root = Rails.root.join('tmp')
  config.cache_dir = 'uploads'
  config.storage = :fog

  if !Rails.env.production?
    if Rails.env.development?
      config.storage = :file
      config.enable_processing = true
    else
      config.storage = :file
      config.enable_processing = false
    end
  end
end
