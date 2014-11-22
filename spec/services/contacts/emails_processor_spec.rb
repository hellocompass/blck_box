require 'fast_helper'
require 'ostruct'
require './app/services/contacts/create_user_from_contact'

class StubEmail < OpenStruct
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  def self.valid_format?(email_address)
    email_address.downcase.match VALID_EMAIL_REGEX
  end
end

describe Contacts::CreateUserFromContact::EmailsProcessor do
  before { stub_const 'Email', StubEmail }

  let(:emails) do
    [
      {
        "value"=>"kate-bell@mac.com",
        "pref"=>false,
        "id"=>0,
        "type"=>"work"
      },
      {
        "value"=>"www.icloud.com",
        "pref"=>false,
        "id"=>1,
        "type"=>"work"
      },
      {
        "value"=>"test@icloud.com",
        "pref"=>false,
        "id"=>1,
        "type"=>"work"
      }
    ]
  end
  let(:processor) { Contacts::CreateUserFromContact::EmailsProcessor.new(emails) }

  describe '#preferred_email' do
    context 'when there is a preferred email' do
      before { emails[2]['pref'] = true }

      it 'should return that email' do
        expect(processor.preferred_email).to eq(emails[2])
      end
    end

    context 'when there is not a preferred email' do
      it 'should return the first email' do
        expect(processor.preferred_email).to eq(emails[0])
      end
    end
  end

  describe 'generate_emails' do
    context 'when there are no valid emails' do
      let(:emails) do
        [
          {
            "value"=>"www.icloud.com",
            "pref"=>false,
            "id"=>1,
            "type"=>"work"
          },
          {
            "value"=>"test@icloud",
            "pref"=>false,
            "id"=>1,
            "type"=>"work"
          }
        ]
      end

      it 'should return an empty array' do
        expect(processor.generate_emails).to eq([])
      end
    end

    context 'when there is only 1 valid email (the preferred email)' do
      let(:valid_email) do
        {
          "value"=>"test@icloud.com",
          "pref"=>false,
          "id"=>1,
          "type"=>"personal"
        }
      end
      let(:emails) do
        [
          {
            "value"=>"www.icloud.com",
            "pref"=>false,
            "id"=>1,
            "type"=>"work"
          },
          valid_email
        ]
      end
      let(:res) { processor.generate_emails }

      it 'should return an array of 1 email object' do
        expect(res.length).to eq(1)
      end

      it 'should set that single email to be preferred' do
        expect(res[0].preferred).to be_true
      end

      it 'should set the expected attributes on the Email' do
        expect(res[0].email).to eq(valid_email['value'])
        expect(res[0].email_type).to eq(valid_email['type'])
      end
    end

    context 'when there are several valid emails' do
      let(:res) { processor.generate_emails }

      it 'should create Email objects for all valid entries' do
        expect(res.length).to eq(2)
      end

      it 'should only create one preferred Email' do
        expect(res.select { |email| email.preferred }.length).to eq(1)
      end
    end
  end

  describe '#new_email' do
    context 'when given nothing' do
      it 'should return nil' do
        expect(processor.send(:new_email, nil, true)).to be_nil
      end
    end

    context 'when given a valid contact email abstraction' do
      let(:email) { { 'value' => 'test@this.com', 'type' => 'personal' } }
      let(:res) { processor.send(:new_email, email, true) }

      it 'should create a new email' do
        expect(res.email).to eq('test@this.com')
        expect(res.email_type).to eq('personal')
        expect(res.preferred).to be_true
      end
    end
  end

  describe '#normalize_emails' do
    context 'when given nothing' do
      it 'should return an empty list' do
        expect(processor.send(:normalize_emails, nil)).to eq([])
      end
    end

    context 'when given invalid emails' do
      let(:addresses) do
        [
          { 'value' => 'historydotcom.net' },
          { 'value' => 'check@this' }
        ]
      end

      it 'should return an empty list' do
        expect(processor.send(:normalize_emails, addresses)).to eq([])
      end
    end

    context 'when given some valid data' do
      let(:addresses) do
        [
          { 'value' => 'test@historydotcom.net' },
          { 'value' => 'this.com' }
        ]
      end
      let(:expected_result) { [{ 'value' => 'test@historydotcom.net' }] }

      it 'should return a list of valid email objects' do
        expect(processor.send(:normalize_emails, addresses)).to eq(expected_result)
      end
    end
  end

end
