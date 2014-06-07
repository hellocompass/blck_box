require 'spec_helper'

# NOTE: validations are tested in users_validator_spec, unless the scenario
# NOTE: requires Rails
describe User do

  describe '.create' do
    context 'with all required fields' do
      let!(:user) { FactoryGirl.create(:user) }

      it 'should create a User object' do
        expect(User.count).to eq(1)
      end

      it 'should create a remember_token' do
        expect(user.remember_token.nil?).to be_false
      end

      context 'but without all valid data for each field' do
        it 'should err with an already taken email' do
          bad_user = FactoryGirl.build(:user, email: user.email)
          expect { bad_user.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(User.count).to eq(1)
        end
      end
    end
  end
end