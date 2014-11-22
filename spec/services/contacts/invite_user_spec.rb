require 'fast_helper'
require 'sidekiq/testing'
require 'ostruct'
require './app/workers/sms_worker'
require './app/services/contacts/invite_user.rb'
Sidekiq::Testing.fake!

describe Contacts::InviteUser do
  let(:current_user) do
    OpenStruct.new(
      first_name: 'Rubeus',
      last_name: 'Hagrid',
      username: 'H-dawg',
    )
  end
  let(:user) do
    OpenStruct.new(
      preferred_number: OpenStruct.new(
        phone_number: 1234567890
      )
    )
  end
  let(:inviter) { Contacts::InviteUser.new(user, current_user) }

  describe '#invite' do
    before { inviter.invite }

    it 'should queue one SmsWorker' do
      expect(::SmsWorker.jobs.size).to eq(1)
    end
  end

  describe '#message_body' do
    let(:res) { inviter.send :message_body }

    context 'when the current user has a name' do
      let(:expected_message) do
        "Hey, Rubeus Hagrid invited you to join BlackIn. Join here: "
      end

      it 'should include the name in the message' do
        expect(res).to match(expected_message)
      end
    end

    context 'when the current user does not have a name' do
      let(:expected_message) do
        "Hey, you've been invited to join BlackIn. Join here: "
      end
      before do
        current_user.first_name = nil
        current_user.last_name = nil
        current_user.username = nil
      end

      it 'should return a user agnostic message' do
        expect(res).to match(expected_message)
      end
    end
  end

  describe '#inviter_name' do
    let(:res) { inviter.send :inviter_name }

    context 'when the current user has a first name' do
      context 'and no last name' do
        before { current_user.last_name = '' }

        it 'should return the first name' do
          expect(res).to eq(current_user.first_name)
        end
      end

      context 'and a last name' do
        it 'should return the current user\'s full name' do
          expect(res).to eq('Rubeus Hagrid')
        end
      end
    end

    context 'when the user has a last name but no first name' do
      before { current_user.first_name = nil }

      it 'should return the last name' do
        expect(res).to eq(current_user.last_name)
      end
    end

    context 'when the user has neither a first nor last name' do
      before do
        current_user.first_name = ''
        current_user.last_name = nil
      end

      it 'should return the username' do
        expect(res).to eq(current_user.username)
      end
    end
  end
end
