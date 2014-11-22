require 'fast_helper'
require './app/services/contacts/create_user_from_contact'

# NOTE: This spec is purely for unit testing logic-holding helper methods.
# NOTE: Public methods are tested under spec/features/invite_new_user_spec.rb

class StubEmail < OpenStruct
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  def self.valid_format?(email_address)
    email_address.downcase.match VALID_EMAIL_REGEX
  end
end

class StubPhoneNumber < OpenStruct
  def self.normalize_number(number)
    number.to_s.scan(/\d+/).join('').to_i
  end

  def self.valid_format?(number)
    self.normalize_number(number).to_s.length > 9
  end
end

describe Contacts::CreateUserFromContact do
  before do
    stub_const 'Email', StubEmail
    stub_const 'PhoneNumber', StubPhoneNumber
  end

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
          "pref" => false,
          "id" => 1,
          "type" => "other"
        }
      ],
      "emails" =>  [
        {
          "value" => "kate-bell@mac.com",
          "pref" => false,"id" => 0,
          "type" => "work"
        },
        {
          "value" => "www.icloud.com",
          "pref" => false,
          "id" => 1,
          "type" => "work"
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
  let(:creator) { Contacts::CreateUserFromContact.new(contact) }

  describe '#base_user_attrs' do
    let(:password) { 'password' }
    let(:expected_result) do
      {
        email: 'kate-bell@mac.com',
        username: 'Kate Bell',
        pending: true,
        first_name: 'Kate',
        last_name: 'Bell',
        street_address: '165 Davis Street',
        locality: 'Hillsborough',
        region: 'CA',
        country: nil,
        zip_code: '94010',
        birthday: Time.new(1990, 12, 1).utc,
        password: 'password',
        password_confirmation: 'password'
      }
    end
    before { SecureRandom.stub(:urlsafe_base64).and_return(password) }

    context 'when pending' do
      it 'should return a hash of user attributes' do
        expect(creator.send(:base_user_attrs, true)).to eq(expected_result)
      end
    end

    context 'when not pending' do
      before { expected_result[:pending] = false }

      it 'should return a hash of user attributes' do
        expect(creator.send(:base_user_attrs, false)).to eq(expected_result)
      end
    end
  end

  describe '#address' do
    context 'when there are no addresses' do
      before { contact['addresses'] = [] }

      it 'should return an empty hash' do
        expect(creator.send(:address)).to eq({})
      end
    end

    context 'when there is a preferred address' do
      before { contact['addresses'][1]['pref'] = true }

      it 'should return that address' do
        expect(creator.send(:address)).to eq(contact['addresses'][1])
      end
    end

    context 'when there is not a preferred address' do

      it 'should pull the first address' do
        expect(creator.send(:address)).to eq(contact['addresses'][0])
      end
    end
  end
end
