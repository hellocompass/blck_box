require 'fast_helper'
require 'ostruct'
require './app/services/reset_password'

describe ResetPassword do
  before do 
    stub_const 'User', Object.new
    stub_const 'PasswordResetMailer', Object.new
  end
  
  describe '#reset!' do
    let!(:user) do
      attrs = FactoryGirl.attributes_for :user
      OpenStruct.new(
        email: attrs[:email],
        password: attrs[:password]
      )
    end
    let(:resetter) { ResetPassword.new(user.email) }

    context 'when the given email is not associated with a user' do
      before { User.stub(:find_by_email).and_return(nil) }
      let(:resetter) { ResetPassword.new('asdfasdfaf') }

      it 'should raise a not found error' do
        expect { resetter.reset! }.to raise_exception
      end
    end

    context 'when the given email is associated with a user' do
      before do 
        User.stub(:find_by_email).and_return(user)
        user.stub(:update_attributes).and_return(true)
        PasswordResetMailer.stub(:password_reset).and_return(true)
      end

      it 'should return true' do
        expect(resetter.reset!).to be_true
      end

      context 'when the email fails to send' do
        before { ResetPasswordMailer.stub(:password_reset).and_return(false) }

        it 'should return false' do
          expect(resetter.reset!).to be_false 
        end
      end

      context 'when the password fails to update' do
        before { user.stub(:update_attributes).and_return(false) }

        it 'should return false' do
          expect(resetter.reset!).to be_false
        end
      end
    end
  end
end
