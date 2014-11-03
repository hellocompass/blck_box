FactoryGirl.define do
  
  factory :image_content, class: Content do
    image File.open(Rails.root + 'spec/fixtures/images/cutler.jpg')
  end
end
