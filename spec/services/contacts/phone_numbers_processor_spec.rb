require 'fast_helper'
require 'ostruct'
require './app/services/contacts/create_user_from_contact'

class StubPhoneNumber < OpenStruct
  def self.normalize_number(number)
    number.to_s.scan(/\d+/).join('').to_i
  end

  def self.valid_format?(number)
    self.normalize_number(number).to_s.length > 9
  end
end

describe Contacts::CreateUserFromContact::PhoneNumbersProcessor do
  before { stub_const 'PhoneNumber', StubPhoneNumber }
  let(:numbers) do
    [
      {
        "value"=>"(555) 564-8583",
        "pref"=>false,
        "id"=>0,
        "type"=>"mobile"
      },
      {
        "value"=>"(555) 564-8",
        "pref"=>false,
        "id"=>0,
        "type"=>"mobile"
      },
      {
        "value"=>"(415) 555-3695",
        "pref"=>false,
        "id"=>1,
        "type"=>"other"
      },
      {
        "value"=>"(415) 555-3695",
        "pref"=>false,
        "id"=>1,
        "type"=>"mobile"
      }
    ]
  end
  let(:processor) { Contacts::CreateUserFromContact::PhoneNumbersProcessor.new(numbers) }

  describe '#preferred_number' do
    context 'when there is at least one mobile number' do

      context 'and there is a non-mobile preferred number' do
        before { numbers[2]['pref'] = true }

        it 'should return the first mobile number' do
          expect(processor.preferred_number).to eq(numbers[0])
        end
      end

      context 'and that number is preferred' do
        before { numbers[3]['pref'] = true }

        it 'should return the preferred mobile number' do
          expect(processor.preferred_number).to eq(numbers[3])
        end
      end
    end

    context 'when there are no mobile numbers' do
      before { numbers.each { |num| num['type'] = 'work' } }

      context 'and there is a preferred number' do
        before { numbers[2]['pref'] = true }

        it 'should return that number' do
          expect(processor.preferred_number).to eq(numbers[2])
        end
      end

      context 'and there is not a preferred number' do
        it 'should return the first number' do
          expect(processor.preferred_number).to eq(numbers[0])
        end
      end
    end
  end

  describe 'generate_numbers' do
    context 'when there are no valid numbers' do
      let(:numbers) do
        [
          {
            "value"=>"(555) 564-8",
            "pref"=>false,
            "id"=>0,
            "type"=>"mobile"
          },
          {
            "value"=>"test@icloud.com",
            "pref"=>true,
            "id"=>0,
            "type"=>"other"
          },
        ]
      end

      it 'should return an empty array' do
        expect(processor.generate_numbers).to eq([])
      end
    end

    context 'when there is only 1 valid number (the preferred number)' do
      let(:valid_number) do
        {
          "value"=>"(415) 555-3695",
          "pref"=>false,
          "id"=>1,
          "type"=>"personal"
        }
      end
      let(:numbers) do
        [
          {
            "value"=>"www.icloud.com",
            "pref"=>false,
            "id"=>1,
            "type"=>"work"
          },
          valid_number
        ]
      end
      let(:res) { processor.generate_numbers }

      it 'should return an array of 1 number object' do
        expect(res.length).to eq(1)
      end

      it 'should set that single number to be preferred' do
        expect(res[0].preferred).to be_true
      end

      it 'should set the expected attributes on the PhoneNumber' do
        expect(res[0].phone_number).to eq(valid_number['value'])
        expect(res[0].number_type).to eq(valid_number['type'])
      end
    end

    context 'when there are several valid phone numbers' do
      let(:res) { processor.generate_numbers }

      it 'should create PhoneNumber objects for all valid entries' do
        expect(res.length).to eq(3)
      end

      it 'should only create one preferred PhoneNumber' do
        expect(res.select { |num| num.preferred }.length).to eq(1)
      end
    end
  end

  describe '#new_phone_number' do
    context 'when given nothing' do
      it 'should return nil' do
        expect(processor.send(:new_phone_number, nil, true)).to be_nil
      end
    end

    context 'when given a valid contact number abstraction' do
      let(:number) { { "value" => 5555648583, "type" => "mobile" } }
      let(:res) { processor.send(:new_phone_number, number, true) }

      it 'should create a new email' do
        expect(res.phone_number).to eq(5555648583)
        expect(res.number_type).to eq('mobile')
        expect(res.preferred).to be_true
      end
    end
  end

  describe '#normalize_numbers' do
    context 'when given nothing' do
      it 'should return an empty list' do
        expect(processor.send(:normalize_numbers, nil)).to eq([])
      end
    end

    context 'when given invalid numbers' do
      let(:nums) do
        [
          { 'value' => 'historydotcom.net' },
          { 'value' => '12345678' }
        ]
      end

      it 'should return an empty list' do
        expect(processor.send(:normalize_numbers, nums)).to eq([])
      end
    end

    context 'when given some valid data' do
      let(:nums) do
        [
          { 'value' => '1234567891' },
          { 'value' => 'this.com' }
        ]
      end
      let(:expected_result) { [{ 'value' => 1234567891 }] }

      it 'should return a list of valid email objects' do
        expect(processor.send(:normalize_numbers, nums)).to eq(expected_result)
      end
    end
  end

end
