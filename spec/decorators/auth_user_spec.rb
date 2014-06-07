require 'spec_helper'

describe AuthUser do

  describe '#find' do
    let(:google_auth) { OmniAuth.config.mock_auth[:google_oauth2] }

    context 'when the user exists' do
      context 'and is connected to the auth provider' do
        let!(:user) { FactoryGirl.create(:google_user) }
        before { @auth_user = AuthUser.find(google_auth) }

        it 'should return the user' do
          expect(@auth_user).to eq(user)
        end 
      end

      context 'but is not connected to the auth provider' do
        let!(:user) { User.create FactoryGirl.attributes_for(:google_user) }
        before { @auth_user = AuthUser.find(google_auth) }

        it 'should create a new connection' do
          expect(Connection.count).to eq(1)
        end

        it 'should connect the user' do
          expect(@auth_user.connections.first).to eq(Connection.first)
        end
      end
    end

    context 'when the user does not exist' do
      before { @auth_user = AuthUser.find(google_auth) }

      it 'should create the user' do
        expect(@auth_user).to eq(User.first)
      end  
    end
  end

end