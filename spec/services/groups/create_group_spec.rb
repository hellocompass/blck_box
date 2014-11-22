require 'spec_helper'

describe Groups::CreateGroup do
  let(:group) { Group.new }
  let(:user) { FactoryGirl.create :user }
  let(:user2) { FactoryGirl.create :user, email: 'h@hogwarts.com' }
  let(:saver) { Groups::CreateGroup.new(group, user) }
  let(:contacts) do
    data = JSON.parse(File.read(Rails.root + 'spec/fixtures/contacts.json'))
    data[0..1] + data[4..5]
  end
  let(:params) do
    { name: 'Balligerent', contacts: contacts }
  end

  describe '#create' do
    let(:new_group) { saver.instance_eval { @group } }

    context 'when given invalid data' do
      before do
        params[:name] = '    '
        @res = saver.create(params)
      end

      it 'should return false' do
        expect(@res).to be_false
      end

      it 'should not persist the group' do
        expect(new_group.persisted?).to be_false
      end
    end

    context 'when given valid data' do
      before { @res = saver.create(params) }

      it 'should return true' do
        expect(@res).to be_true
      end

      it 'should create the group' do
        expect(new_group.persisted?).to be_true
      end

      it 'should associate one user per valid contact, plus the current user with the group' do
        expect(new_group.users.length).to eq(3)
      end
    end
  end

  describe '#update_attributes' do
    before { saver.send(:update_attributes, params) }

    context 'when passed valid data' do
      let(:params) { { name: 'Yolo Circus' } }

      it 'should name the group' do
        expect(group.name).to eq(params[:name])
      end

      context 'when passed attributes that dont exist on Group' do
        let(:params) do
          {
            width: 21,
            name: 'Yolo Circus'
          }
        end

        it 'should ignore the non-existant params, and set the proper attrs' do
          expect(group.name).to eq(params[:name])
        end
      end
    end
  end

  describe '#associate_users' do
    let(:res) { saver.instance_eval { @group.users } }
    before do
      saver.instance_variable_set :@contacts, contacts
      saver.send :associate_users
    end

    it 'should associate the current user with the group' do
      expect(res.include? user).to be_true
    end

    it 'should associate a user for each valid contact, plus the current user' do
      expect(res.length).to eq(3)
    end
  end

  describe '#existing_users' do
    before do
      saver.instance_variable_set :@contacts, contacts
      saver.send :normalize_numbers
      saver.send :prune_contacts
    end
    let(:res) { saver.send :existing_users }

    context 'when all invitees are already users' do
      before do
        FactoryGirl.create :email,
                           user: user,
                           email: contacts[0]['emails'][0]['value']
        FactoryGirl.create :phone_number,
                           user: user2,
                           phone_number: contacts[1]['phoneNumbers'][0]['value']
      end

      it 'should return a user for each valid contact' do
        expect(res.length).to eq(2)
      end
    end

    context 'when some invitees are already users' do
      before do
        FactoryGirl.create :email,
                           user: user,
                           email: contacts[0]['emails'][0]['value']
      end

      it 'should return a new user for each existing user' do
        expect(res.length).to eq(1)
      end
    end

    context 'when no invitees are already users' do
      it 'should return an empty array' do
        expect(res).to eq([])
      end
    end
  end

  describe '#fresh_users' do
    before do
      saver.instance_variable_set :@contacts, contacts
      saver.send :normalize_numbers
      saver.send :prune_contacts
    end
    let(:res) { saver.send :fresh_users }

    context 'when all invitees are already users' do
      before do
        FactoryGirl.create :email,
                           user: user,
                           email: contacts[0]['emails'][0]['value']
        FactoryGirl.create :phone_number,
                           user: user2,
                           phone_number: contacts[1]['phoneNumbers'][0]['value']
      end

      it 'should return an empty array' do
        expect(res).to eq([])
      end
    end

    context 'when some invitees are already users' do
      before do
        FactoryGirl.create :email,
                           user: user,
                           email: contacts[0]['emails'][0]['value']
      end

      it 'should return a new user for each valid new invitee' do
        expect(res.length).to eq(1)
      end
    end

    context 'when no invitees are already users' do
      it 'should return a user for each valid contact' do
        expect(res.length).to eq(2)
      end
    end
  end

  describe '#existing_numbers' do
    before do
      saver.instance_variable_set :@contacts, contacts
      saver.send :normalize_numbers
      @numbers = [
        FactoryGirl.create(:phone_number, phone_number: 5555648583, user: user),
        FactoryGirl.create(:phone_number, phone_number: 4085555270, user: user2)
      ]
    end

    it 'should return a list of existing emails' do
      expect(saver.send(:existing_numbers)).to eq (@numbers)
    end
  end

  describe '#contact_numbers' do
    before do
      saver.instance_variable_set :@contacts, contacts
      saver.send :normalize_numbers
    end
    let(:numbers) do
      [
        5555648583,
        4155553695,
        5554787672,
        4085555270,
        4085553514
      ]
    end

    it 'should return all contact numbers' do
      expect(saver.send(:contact_numbers)).to eq(numbers)
    end

    context 'when a contact does not have any numbers' do
      before { contacts[0]['phoneNumbers'] = [nil] }
      let(:nums) { numbers[2..4] }

      it 'should return a list of present emails' do
        expect(saver.send(:contact_numbers)).to eq(nums)
      end
    end
  end

  describe '#existing_emails' do
    before do
      saver.instance_variable_set :@contacts, contacts
      saver.send :normalize_numbers
      @email = FactoryGirl.create :email, user: user,
                                  email: contacts[0]['emails'][0]['value']
    end

    it 'should return a list of existing emails' do
      expect(saver.send(:existing_emails)).to eq ([@email])
    end
  end

  describe '#contact_email_addresses' do
    before { saver.instance_variable_set :@contacts, contacts }
    let(:addresses) do
      [
        'kate-bell@mac.com',
        'www.icloud.com',
        'd-higgins@mac.com'
      ]
    end

    it 'should return all contact email address' do
      expect(saver.send(:contact_email_addresses)).to eq(addresses)
    end

    context 'when a contact does not have any emails' do
      before { contacts[0]['emails'] = [] }
      let(:addresses) { ['d-higgins@mac.com'] }

      it 'should return a list of present emails' do
        expect(saver.send(:contact_email_addresses)).to eq(addresses)
      end
    end
  end

  describe '#fresh_contacts' do
    before do
      saver.instance_variable_set :@contacts, contacts
      saver.send :normalize_numbers
    end

    context 'when there are some existing emails and phone numbers' do
      before do
        FactoryGirl.create :email,
                           user: user,
                           email: contacts[0]['emails'][0]['value']
        FactoryGirl.create :phone_number,
                           user: user2,
                           phone_number: contacts[1]['phoneNumbers'][0]['value']
      end

      it 'should return only the contacts that do not exist' do
        expect(saver.send(:fresh_contacts)).to eq(contacts[2..3])
      end
    end

    context 'when all contacts already exist' do
      before do
        saver.instance_eval { @contacts = @contacts[0..1] }
        FactoryGirl.create :email,
                           user: user,
                           email: contacts[0]['emails'][0]['value']
        FactoryGirl.create :phone_number,
                           user: user2,
                           phone_number: contacts[1]['phoneNumbers'][0]['value']
      end

      it 'should return an empty array' do
        expect(saver.send(:fresh_contacts)).to eq([])
      end
    end

    context 'when there are no existing emails' do
      before do
        FactoryGirl.create :phone_number,
                           user: user,
                           phone_number: contacts[0]['phoneNumbers'][0]['value']
      end

      it 'should return only non-existant contacts' do
        expect(saver.send(:fresh_contacts)).to eq(contacts[1..3])
      end
    end

    context 'when there are no existing phone numbers' do
      before do
        FactoryGirl.create :email,
                           user: user,
                           email: contacts[0]['emails'][0]['value']
      end

      it 'should return only non-existant contacts' do
        expect(saver.send(:fresh_contacts)).to eq(contacts[1..3])
      end
    end

    context 'when there are neither existing phone numbers nor emails' do
      it 'should return all contacts' do
        expect(saver.send(:fresh_contacts)).to eq(contacts)
      end
    end
  end

  describe '#normalize_numbers' do
    before { saver.instance_variable_set :@contacts, contacts }
    let(:res) do
      saver.instance_eval do
        @contacts.flat_map do |contact|
          next if contact['phoneNumbers'].blank?
          contact['phoneNumbers'].map { |num| num['value'] }
        end
      end
    end

    context 'when given all valid numbers or non-present numbers' do
      let(:expected_result) do
        [
          5555648583,
          4155553695,
          5554787672,
          4085555270,
          4085553514,
          nil,
          nil
        ]
      end
      before { saver.send :normalize_numbers }

      it 'should normalize all numbers' do
        expect(res).to eq(expected_result)
      end
    end

    context 'when some numbers are not numbers' do
      let(:expected_result) do
        [
          nil,
          4155553695,
          5554787672,
          4085555270,
          4085553514,
          nil,
          nil
        ]
      end
      before do
        contacts[0]['phoneNumbers'][0]['value'] = 'test@this.com'
        saver.send :normalize_numbers
      end

      it 'should nil out invalid numbers' do
        expect(res).to eq(expected_result)
      end
    end
  end

  describe '#prune_contacts' do
    let(:res) { saver.instance_eval { @contacts } }
    before { saver.instance_variable_set :@contacts, contacts }

    context 'when there are some invalid contacts' do
      before { saver.send :prune_contacts }

      it 'should remove contacts without contact data' do
        expect(res.length).to eq(2)
      end
    end

    context 'when all contacts are invalid' do
      before do
        saver.instance_eval do
          @contacts.each do |contact|
            contact['emails'] = []
            contact['phoneNumbers'] = nil
          end
        end
        saver.send :prune_contacts
      end

      it 'should set contacts to an empty array' do
        expect(res).to eq([])
      end
    end

    context 'when all contacts are valid' do
      before do
        saver.instance_eval do
          @contacts[2..3].each do |contact|
            contact['emails'] = [{'value' => 'this@that.com'}]
          end
        end
        saver.send :prune_contacts
      end

      it 'should not remove any contacts' do
        expect(res.length).to eq(4)
      end
    end
  end
end
