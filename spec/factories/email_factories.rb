FactoryGirl.define do

  factory :email do
    email 'hermoine@hogwarts.com'
    email_type 'personal'
    preferred true
  end
end
