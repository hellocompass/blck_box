require 'spec_helper'

describe Email do

  describe '.valid_format?' do

    context 'when given a valid email address' do
      it 'should return true' do
        expect(Email.valid_format?('test@this.com')).to be_true
      end
    end

    context 'when given an invalid email address' do
      it 'should return false' do
        expect(Email.valid_format?(123455)).to be_false
      end
    end
  end

  describe '#sanitize_email' do
    let(:email) { FactoryGirl.build :email, email: 'TeSSSSt@dIS.coM' }
    before { email.send(:sanitize_email) }

    it 'should sanitize the address' do
      expect(email.email).to eq('tesssst@dis.com')
    end
  end

  describe '#enforce_preferred_constraint' do
    let(:user) { FactoryGirl.create :user }
    let(:email) { FactoryGirl.build :email, user: user }
    before do
      @current = FactoryGirl.create :email, email: 'hagrid@hogwarts.com', user: user
      email.send(:enforce_preferred_constraint)
      @current.reload
    end

    it 'should un-prefer any previously preferred emails' do
      expect(@current.preferred).to be_false
    end
  end
end
