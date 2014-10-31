require 'spec_helper'

describe SaveGroup do
  let(:group) { Group.new }
  let(:user) { FactoryGirl.create :user }
  let(:saver) { SaveGroup.new(group) }

  describe '#save' do
    before { @res = saver.save params }

    context 'when passed valid data' do
      let(:params) do
        {
          name: 'Yolo Circus',
          user_ids: [user.id]
        }
      end

      it 'should create the group' do
        expect(group.persisted?).to be_true
      end

      it 'should name the group' do
        expect(group.name).to eq(params[:name])
      end

      it 'should associate the group with the relevant users' do
        expect(group.users).to eq([user])
      end

      context 'with duplicate user ids' do
        let(:params) do
          {
            name: 'Yolo Circus',
            user_ids: [user.id, user.id]
          }
        end

        it 'should create the group' do
          expect(group.persisted?).to be_true
        end

        it 'should associate the group with unique users' do
          expect(group.users).to eq([user])
        end
      end

      context 'when passed attributes that dont exist on Group' do
        let(:params) do
          {
            name: 'Yolo Circus',
            width: 21,
            user_ids: [user.id, user.id]
          }
        end

        it 'should ignore the non-existant params and create the group' do
          expect(group.persisted?).to be_true
        end
      end
    end

    context 'when passed invalid data' do
      let(:params) do
        {
          name: '   ',
          user_ids: [user.id]
        }
      end

      it 'should not persist the group' do
        expect(group.persisted?).to be_false
      end

      it 'should return false' do
        expect(@res).to be_false
      end

      it 'should set errors on the group' do
        expect(group.errors.full_messages.length).to eq(1)
      end
    end
  end
end
