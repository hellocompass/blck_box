require 'spec_helper'

describe Group do
    let(:user) { FactoryGirl.create :user }

  describe '#contents' do
    let(:content) { FactoryGirl.build(:image_content) }
    let(:group) { FactoryGirl.create :group, contents: [content], users: [user] }

    it 'should return the contents' do
      expect(group.contents).to eq([content])
    end

    context 'when the group is disabled' do
      before { group.update_attribute :enabled, false }

      it 'should return nil' do
        expect(group.contents).to be_nil
      end
    end
  end

  describe '#maybe_disable_group' do
    let(:group) { FactoryGirl.create :group, users: [user] }

    context 'when the group is fresh' do
      before { group.send :maybe_disable_group }

      it 'should not disable the group' do
        expect(group.enabled).to be_true
      end
    end

    context 'when the group old' do
      before do
        group.update_column :created_at, (Group::ACTIVE_HOURS + 1).hours.ago
        group.send(:maybe_disable_group)
      end

      it 'should disable the group' do
        expect(group.enabled).to be_false
      end
    end

    context 'when the group is already disabled' do
      before do
        group.stub(:save!)
        group.send(:maybe_disable_group)
      end

      it 'should not try to save the group' do
        expect(group).not_to receive(:save!)
      end
    end
  end

  describe '#ensure_enabled' do
    let(:group) { FactoryGirl.create :group, users: [user] }

    context 'when the group is disabled' do
      before do
        group.update_attribute :enabled, false
        group.reload
        group.send(:ensure_enabled)
      end

      it 'should add an error' do
        expect(group.errors.full_messages.length).to eq(1)
      end
    end

    context 'when the group is in the process of being disabled' do
      before { group.update_attribute :enabled, false }

      it 'should not add an error' do
        expect(group.errors.full_messages.length).to eq(0)
      end
    end

    context 'when the group is enabled' do
      before { group.send(:ensure_enabled) }

      it 'should not add an error' do
        expect(group.errors.full_messages.length).to eq(0)
      end
    end
  end
end
