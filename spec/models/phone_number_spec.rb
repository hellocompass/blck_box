require 'spec_helper'

describe PhoneNumber do

  describe '.normalize_numbers' do
    context 'when given all valid numbers' do
      let(:nums) { ['(555) 555-5555', '7777777777'] }
      let(:expected_result) { [5555555555, 7777777777] }

      it 'should return a list of normalized numbers' do
        expect(PhoneNumber.normalize_numbers(nums)).to eq(expected_result)
      end
    end

    context 'when given some invalid numbers' do
      let(:nums) { ['(555) 555-5555', 'test@this.com'] }
      let(:expected_result) { [5555555555] }

      it 'should return a list of valid normalized numbers' do
        expect(PhoneNumber.normalize_numbers(nums)).to eq(expected_result)
      end
    end
  end

  describe '.normalize_number' do
    context 'when given a valid number' do
      let(:num) { '(555) 555-5555' }
      let(:expected_result) { 5555555555 }

      it 'should return the normalized version of that number' do
        expect(PhoneNumber.normalize_number(num)).to eq(expected_result)
      end
    end

    context 'when given an invalid number' do
      let(:num) { 'test@this.com' }

      it 'should return the nil' do
        expect(PhoneNumber.normalize_number(num)).to be_nil
      end
    end
  end

  describe '.valid_format?' do
    context 'when given a valid number' do
      it 'should return true' do
        expect(PhoneNumber.valid_format?(5555555555)).to be_true
      end
    end

    context 'when given an invalid number' do
      it 'should return false' do
        expect(PhoneNumber.valid_format?(55555555)).to be_false
      end
    end
  end

  describe '#number_format' do
    before { number.send(:number_format) }

    context 'with an invalid number' do
      let(:number) { FactoryGirl.build :phone_number, phone_number: 'test@this.com' }

      it 'should add an error on the model' do
        expect(number.errors.full_messages.length).to eq(1)
      end
    end

    context 'with a valid number' do
      let(:number) { FactoryGirl.build :phone_number }

      it 'should NOT add an error on the model' do
        expect(number.errors.full_messages.length).to eq(0)
      end
    end
  end

  describe '#enforce_preferred_constraint' do
    let(:user) { FactoryGirl.create :user }
    let(:number) { FactoryGirl.build :phone_number, user: user }

    context 'when there is already a preferred number' do
      before do
        @current = FactoryGirl.create :phone_number, phone_number: 5555555555, user: user
        number.save
        @current.reload
        number.reload
      end

      it 'should set the previous preferred to false' do
        expect(@current.preferred).to be_false
      end

      it 'should set the current numbers preferred to true' do
        expect(number.preferred).to be_true
      end
    end
  end

  describe '#update_preferred' do
    let(:user) { FactoryGirl.create :user }
    let(:number) { FactoryGirl.build :phone_number, user: user }

    context 'when current preferreds are mobile' do
      before do
        @current = FactoryGirl.create :phone_number, phone_number: 5555555555, user: user
      end

      context 'and the new number is mobile' do
        before do
          number.save
          @current.reload
          number.reload
        end

        it 'should set the new number to preferred' do
          expect(number.preferred).to be_true
        end

        it 'should unset the current preferred' do
          expect(@current.preferred).to be_false
        end
      end

      context 'and the new number is not mobile' do
        before do
          number.number_type = 'work'
          number.save
          @current.reload
          number.reload
        end

        it 'should set the new number to NOT be preferred' do
          expect(number.preferred).to be_false
        end

        it 'should keep the current preferred number' do
          expect(@current.preferred).to be_true
        end
      end
    end

    context 'when the current preferreds are not mobile' do
      before do
        current = FactoryGirl.create :phone_number, number_type: 'work', phone_number: 5555555555, user: user
        number.number_type = 'work'
        number.save
        number.reload
      end

      it 'should set the new number to preferred' do
        expect(number.preferred).to be_true
      end

      it 'should remove all other preferreds' do
        expect(user.phone_numbers.where(preferred: true).count).to eq(1)
      end
    end
  end
end
