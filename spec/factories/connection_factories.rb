FactoryGirl.define do
  factory :google_connection, class: :connection do
    source 'google_oauth2'
    source_id '123456789'
    auth_token SecureRandom.urlsafe_base64 
  end
end
