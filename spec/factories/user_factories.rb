FactoryGirl.define do
  factory :user do
    email 'hagrid@hogwarts.com'
    password 'Wing4rdiumLev!osa'
    password_confirmation 'Wing4rdiumLev!osa'
  end

  factory :google_user, class: :user do
    pass = SecureRandom.urlsafe_base64 + '!D9' # to pass validations
    email 'hagrid@gmail.com'
    password pass
    password_confirmation pass

    after :build do |user|
      user.connections << FactoryGirl.build(:google_connection)
    end
  end
end