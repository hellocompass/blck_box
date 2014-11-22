require 'spec_helper'

describe Api::SessionsController do
  include SessionsHelper

  before do
    Api::SessionsController.any_instance.stub(:form_authenticity_token).
                                       and_return('mahsecuritytoken')
  end

  describe '#new' do
    # do nothing
  end

  describe '#create' do
    let(:user) { FactoryGirl.create :user }
    context 'with proper credentials' do
      before do
        post :create, session: {
          email: user.email,
          password: FactoryGirl.attributes_for(:user)[:password]
        }
      end

      it 'should sign in the user' do
        expect(current_user.email).to eq(user[:email])
      end

      it 'should set the remember_token cookie' do
        token = response.cookies['remember_token']
        expect(token).to eq(user.digest(current_user.remember_token))
      end
    end

    context 'without invalid credentials' do
      before { post :create, session: { email: user.email } }

      it 'should return a 400' do
        expect(response.status).to eq(400)
      end
    end
  end

  describe '#create_with_omniauth' do
    let!(:google_user) { FactoryGirl.create(:google_user) }

    it 'should 400 without an auth token' do
      get(
        :create_with_omniauth,
        { provider: OmniAuth.config.mock_auth[:google_oauth2][:provider] }
      )
      expect(response.status).to eq(400)
    end

    context 'with an auth token' do
      before do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
        get(
          :create_with_omniauth,
          provider: OmniAuth.config.mock_auth[:google_oauth2][:provider]
        )
      end

      it 'should sign in the user' do
        expect(current_user).to eq(google_user)
      end
    end
  end

  describe '#destroy' do
    let!(:user) { FactoryGirl.create :user }
    before do
      sign_in user
      delete :destroy
    end

    it 'should delete the remember_token cookie' do
      expect(response.cookies['remember_token']).to eq(nil)
    end
  end
end
