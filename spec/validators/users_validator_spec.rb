require 'fast_helper'
require 'ostruct'
require './app/validators/users_validator'

describe UsersValidator do
  let(:user) do
    OpenStruct.new(
        email: 'hagrid@hogwarts.com',
        password: 'Wing4rdiumLev!osa',
        password_confirmation: 'Wing4rdiumLev!osa',
        errors:  {}
    )
  end
  before do
    user.errors.stub(:add) { |key, msg| user.errors[key.to_sym] = msg }
    stub_const('User', Object.new)
    User.stub(:where) { Array.new }
  end

  describe '.validate' do
    context 'with all required fields' do
      it 'should not add any errors' do
        UsersValidator.validate(user)
        expect(user.errors.length).to eq(0)
      end
    end

    context 'with a bad submission' do
      before do
       @bad_user = user.clone
       @bad_user.stub(:new_record?).and_return(true)
     end

      it 'should err with an invalid email' do
        @bad_user.email = 'ha ha@gmail.com'
        UsersValidator.validate(@bad_user)
        expect(@bad_user.errors.keys.length).to eq(1)
        expect(@bad_user.errors.keys.first).to eq(:email)
      end

      it 'should err without an email' do
        @bad_user.email = nil
        UsersValidator.validate(@bad_user)
        expect(@bad_user.errors.keys.length).to eq(1)
        expect(@bad_user.errors.keys.first).to eq(:email)
      end

      it 'should err with an empty string email' do
        @bad_user.email = ' '
        UsersValidator.validate(@bad_user)
        expect(@bad_user.errors.keys.length).to eq(1)
        expect(@bad_user.errors.keys.first).to eq(:email)
      end

      it 'should err with a too short password' do
        @bad_user.password = 'T3s!t'
        UsersValidator.validate(@bad_user)
        expect(@bad_user.errors.keys.length).to eq(1)
        expect(@bad_user.errors.keys.first).to eq(:password)
      end

      it 'should err with a too long password' do
        @bad_user.password = "T3!#{'a'*48}"
        UsersValidator.validate(@bad_user)
        expect(@bad_user.errors.keys.length).to eq(1)
        expect(@bad_user.errors.keys.first).to eq(:password)
      end

      it 'should err with an empty string password of sufficient length' do
        @bad_user.password = '              '
        UsersValidator.validate(@bad_user)
        expect(@bad_user.errors.keys.length).to eq(1)
        expect(@bad_user.errors.keys.first).to eq(:password)
      end

      context 'without a password' do
        it 'should err with email/password submission' do
          @bad_user.password = nil
          UsersValidator.validate(@bad_user)
          expect(@bad_user.errors.keys.length).to eq(1)
          expect(@bad_user.errors.keys.first).to eq(:password)
        end

        it 'should pass with a valid email and omniauth source' do
          # stub
        end
      end

      it 'should err without a password_confirmation' do
        @bad_user.password_confirmation = nil
        UsersValidator.validate(@bad_user)
        expect(@bad_user.errors.keys.length).to eq(1)
        expect(@bad_user.errors.keys.first).to eq(:password_confirmation)
      end
    end
  end
end
