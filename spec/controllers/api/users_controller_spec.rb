require 'spec_helper'

describe Api::UsersController do
  include SessionsHelper

  describe '#create' do
    context 'on succesful save' do
      let(:user) { FactoryGirl.attributes_for :user }
      before { @res = post :create, user: user }

      it 'should create a user' do
        expect(User.count).to eq(1)
      end

      it 'should redirect to the user page' do
        expect(response).to redirect_to(api_user_path(User.first))
      end

      it 'should sign in the user' do
        expect(current_user.email).to eq(user[:email])
      end
    end

    context 'on a failed save attempt' do
      let(:user) do
        FactoryGirl.attributes_for(:user,
                                   email: ' ',
                                   password_confirmation: 'avadakedavra')
      end
      before { post :create, user: user }

      it 'should not create a user' do
        expect(User.count).to eq(0)
      end

      it 'should return 400' do
        expect(response.status).to eq(400)      
      end
    end
  end

  describe '#new' do
    before { get :new }
    let(:empy_serialized_user) do
      {
        user: {
          id: nil,
          email: nil,
          username: nil
        }
      }.to_json
    end 

    it 'should return a new user' do
      expect(response.body).to eq(empy_serialized_user)
    end
  end

  describe '#show' do
    let(:user) { FactoryGirl.create :user }
    let(:user_res) { { user: { id: user.id, email: user.email, username: user.username } }.to_json }

    context 'when the user is signed in' do
      before do
        sign_in user
        get :show, id: user.id
      end

      it 'should render the user\'s page' do
        expect(response.body).to eq(user_res)
      end
    end

    context 'when the user is not signed in' do
      before { get :show, id: user.id }

      it 'should return a 404' do
        expect(response.status).to eq(404)
      end
    end
  end

  describe '#update' do
    let!(:user) { FactoryGirl.create :user }
    let(:user_update) { { email: 'hagrid@eowls.com' } }

    context 'when not logged in' do
      before { put :update, id: user.id, user: user_update }
      
      it 'should return 404' do
        expect(response.status).to eq(404)
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      context 'when update is successful' do
        before { put :update, id: user.id, user: user_update }

        it 'should update the user' do
          user.reload
          expect(user.email).to eq(user_update[:email])
        end

        it 'should redirect to the user\'s page' do
          expect(response).to redirect_to(api_user_path(user.id))
        end 
      end

      context 'when update fails' do
        let(:user_update) { { email: nil } }
        before { put :update, id: user.id, user: user_update }

        it 'should return 400' do
          expect(response.status).to eq(400)
        end
      end
    end
  end

  describe '#reset_password' do
    context 'when given an email that does not match a user' do
      before { get :reset_password, email: 'asfasd' }      

      it 'should return a 404 error' do
        expect(response.status).to eq(404)
      end
    end

    context 'when given an email that does not match a user' do
      let(:user) { FactoryGirl.create :user } 
      let!(:password_digest) { user.password_digest } 
      before { get :reset_password, email: user.email } 

      it 'should update the user\'s password' do
        expect(user.password_digest).not_to eq(password_digest)
      end

      it 'should respond with a 200' do
        expect(response.status).to eq(200) 
      end
    end
  end

end
