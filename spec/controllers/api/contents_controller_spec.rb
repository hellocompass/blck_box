require 'spec_helper'

describe Api::ContentsController do
  include SessionsHelper

  before do
    Api::ContentsController.any_instance.stub(:form_authenticity_token).
                                       and_return('mahsecuritytoken')
  end

  describe '#recent' do
    let(:last_week) { 1.weeks.ago }
    let(:yesterday) { 1.days.ago }
    let(:two_weeks_ago) { 2.weeks.ago }
    let(:user) { FactoryGirl.create :user }
    let(:group) do
      FactoryGirl.create :group,
        contents: [
          FactoryGirl.build(:image_content, created_at: last_week),
          FactoryGirl.build(:image_content, created_at: yesterday),
          FactoryGirl.build(:image_content, created_at: two_weeks_ago)
        ],
        users: [user]
    end

    context 'when the group is enabled' do
      let(:expected_json) do
        {
          contents: [
            {
              group_id: 1,
              user_ids: [],
              image_url: "/uploads/v_414x736_cutler.jpg",
              created_at: yesterday
            },
            {
              group_id: 1,
              user_ids: [],
              image_url: "/uploads/v_414x736_cutler.jpg",
              created_at: last_week
            },
            {
              group_id: 1,
              user_ids: [],
              image_url: "/uploads/v_414x736_cutler.jpg",
              created_at: two_weeks_ago
            }
          ],
          csrf_param: 'authenticity_token',
          csrf_token: 'mahsecuritytoken'
        }.to_json
      end

      context 'and the user is part of the group' do
        before do
          sign_in user
          get :recent, group_id: group.id, page: 1
        end

        it 'should return 200' do
          expect(response.status).to eq(200)
        end

        it 'should return the contents, in order of creation' do
          expect(response.body).to eq(expected_json)
        end
      end

      context 'and the user is not signed in' do
        before { get :recent, group_id: group.id }

        it 'should return 404' do
          expect(response.status).to eq(404)
        end
      end

      context 'and a user who is not part of the group is signed in' do
        let(:user_2) { FactoryGirl.create :user, email: 'harry@potter.com' }
        before { get :recent, group_id: group.id }

        it 'should return 404' do
          expect(response.status).to eq(404)
        end
      end
    end

    context 'when the group is not enabled' do
      before do
        sign_in user
        group.update_attribute :enabled, false
        get :recent, group_id: group.id
      end

      it 'should return 400' do
        expect(response.status).to eq(400)
      end
    end
  end
end
