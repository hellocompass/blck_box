require 'spec_helper'

describe 'creating and inviting a new user' do
  let(:contact) do
    {
      "id" => 2,
      "rawId" => nil,
      "displayName" => nil,
      "name" =>  {
        "givenName" => "Kate",
        "honorificSuffix" => nil,
        "formatted" => "Kate Bell",
        "middleName" => nil,
        "familyName" => "Bell",
        "honorificPrefix" => nil
      },
      "nickname" => nil,
      "phoneNumbers" =>  [
        {
          "value" => "(555) 564-8583",
          "pref" => false,
          "id" => 0,
          "type" => "mobile"
        },
        {
          "value" => "(415) 555-3695",
          "pref" => true,
          "id" => 1,
          "type" => "other"
        },
        {
          "value" => "(555) 555-95",
          "pref" => false,
          "id" => 1,
          "type" => "mobile"
        }
      ],
      "emails" =>  [
        {
          "value" => "kate-bell@mac.com",
          "pref" => false,
          "id" => 0,
          "type" => "work"
        },
        {
          "value" => "www.icloud.com",
          "pref" => false,
          "id" => 1,
          "type" => "work"
        },
        {
          "value" => "hermoine@hogwarts.com",
          "pref" => true,
          "id" => 0,
          "type" => "personal"
        }
      ],
      "addresses" =>  [
        {
          "pref" => "false",
          "locality" => "Hillsborough",
          "region" => "CA",
          "id" => 0,
          "postalCode" => "94010",
          "country" => nil,
          "type" => "work",
          "streetAddress" => "165 Davis Street"
        },
        {
          "pref" => "false",
          "locality" => "Hogsmeade",
          "region" => "EG",
          "id" => 0,
          "postalCode" => "94010",
          "country" =>  'UK',
          "type" => "home",
          "streetAddress" => "4 Privet Drive"
        }
      ],
      "ims" => nil,
      "organizations" =>  [
        {
          "pref" => "false",
          "title" => "Producer",
          "name" => "Creative Consulting",
          "department" => nil,
          "type" => nil
        }
      ],
      "birthday" => 660027600000,
      "note" => nil,
      "photos" => nil,
      "categories" => nil,
      "urls" => nil
    }
  end
  let(:expected_attributes) do
    {
      email: 'hermoine@hogwarts.com',
      username: 'Kate Bell',
      pending: true,
      first_name: 'Kate',
      last_name: 'Bell',
      street_address: '165 Davis Street',
      locality: 'Hillsborough',
      region: 'CA',
      country: nil,
      zip_code: '94010',
      birthday: Time.new(1990, 12, 1).utc
    }
  end
  let(:res) { Contacts::CreateUserFromContact.create(contact, invite: true, pending: true) }

  it 'should create a user' do
    expect(res).to eq(User.first)
    expect(User.count).to eq(1)
  end

  it 'should create a user with the expected attributes' do
    attrs = res.attributes.symbolize_keys.reject do |k,v|
      [:password_digest, :id, :created_at, :updated_at, :remember_token].include? k
    end

    expect(attrs).to eq(expected_attributes)
  end

  it 'should associate all valid emails with the created user, setting the expected preferred email' do
    expect(res.emails.length).to eq(2)
    expect(res.emails.where(preferred: true).length).to eq(1)
    expect(res.emails.find_by_preferred(true).email).to eq('hermoine@hogwarts.com')
  end

  it 'should associate all valid numbers with the created user, setting the expected preferred number' do
    expect(res.phone_numbers.length).to eq(2)
    expect(res.phone_numbers.where(preferred: true).length).to eq(1)
    expect(res.phone_numbers.find_by_preferred(true).phone_number).to eq(5555648583)
  end

  it 'should invite the user' do
    pending 'implement invite method'
  end
end
