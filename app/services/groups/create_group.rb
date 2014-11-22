module Groups

  # TODO: extract a ContactsCleaner class
  class CreateGroup

    def self.create(group, params, current_user)
      new(group, current_user).create params
    end

    def initialize(group, current_user)
      @group = group
      @current_user = current_user
    end

    def create(params)
      @contacts = params.delete(:contacts) || []
      update_attributes params
      associate_users

      @group.save
    end

    private

    def update_attributes(params)
      accessibles = params.select { |k,v| Group.attribute_names.include? k.to_s }

      accessibles.each_pair do |k,v|
        @group.send("#{k}=", v)
      end
    end

    def associate_users
      normalize_numbers
      prune_contacts
      @group.users = ([@current_user] + existing_users + fresh_users).uniq
    end

    def existing_users
      return [] unless existing_emails.present? || existing_numbers.present?

      user_ids = existing_emails.map(&:user_id) + existing_numbers.map(&:user_id)

      User.where(id: user_ids)
    end

    def fresh_users
      fresh_contacts.map do |contact|
        ::Contacts::CreateUserFromContact.create contact, pending: true, invite: true
      end
    end

    def existing_numbers
      @existing_numbers ||= PhoneNumber.where(phone_number: contact_numbers)
    end

    def contact_numbers
      phones = @contacts.flat_map do |contact|
        collect_contact_numbers contact
      end

      phones.compact
    end

    def collect_contact_numbers(contact)
      return [] if contact['phoneNumbers'].blank?
      contact['phoneNumbers'].collect { |num| num.try :[], 'value' }
    end

    def existing_emails
      @existing_emails ||= Email.where(email: contact_email_addresses)
    end

    def contact_email_addresses
      addresses = @contacts.flat_map do |contact|
        collect_contact_emails contact
      end

      addresses.compact
    end

    def collect_contact_emails(contact)
      return [] if contact['emails'].blank?
      contact['emails'].collect { |email| email.try :[], 'value' }
    end

    def fresh_contacts
      current_emails = existing_emails.collect(&:email)
      current_nums = existing_numbers.collect(&:phone_number)

      @contacts.reject do |contact|
        (collect_contact_emails(contact) & current_emails).length > 0 ||
          (collect_contact_numbers(contact) & current_nums).length > 0
      end
    end

    def normalize_numbers
      @contacts.each do |contact|
        next if contact['phoneNumbers'].blank?
        contact['phoneNumbers'].each do |num|
          num['value'] = PhoneNumber.normalize_number(num['value'])
        end
      end
    end

    # TODO: add way to notify which invitees don't have contact info
    def prune_contacts
      @contacts.reject! do |contact|
        contact['emails'].blank? && contact['phoneNumbers'].blank?
      end
    end
  end

end
