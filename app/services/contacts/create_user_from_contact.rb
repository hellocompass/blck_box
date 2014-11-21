module Contacts

  def true?(value)
    value == true || value == 'true'
  end

  class CreateUserFromContact
    include Contacts

    def self.create(contact, options = {})
      instance = new(contact, options)
      instance.create(options[:pending])
      instance.invite if options[:invite]
    end

    def initialize(contact, options = {})
      @contact = contact
      @numbers = PhoneNumbersProcessor.new(@contact['phoneNumbers'])
      @emails = EmailsProcessor.new(@contact['emails'])
    end

    def create(pending)
      @user = User.new(base_user_attrs(pending))
      associate_phone_numbers
      associate_emails

      @user.save

      @user
    end

    def invite(user = @user)
      # stub
      user
    end

    class PhoneNumbersProcessor
      include Contacts

      def initialize(numbers)
        @raw_numbers = normalize_numbers(numbers)
      end

      def preferred_number
        return @preferred_number if @preferred_number

        mobiles = @raw_numbers.select { |num| num['type'] == 'mobile' }
        pref = mobiles.find { |num| true?(num['pref']) } || mobiles.first
        preferred_number = pref ||
          (@raw_numbers.find { |num| true?(num['pref']) } || @raw_numbers.first)

        @preferred_number = @raw_numbers.delete preferred_number
      end

      def generate_numbers
        return @numbers if @numbers

        @numbers = [new_phone_number(preferred_number, true)]

        @raw_numbers.each do |number|
          @numbers << new_phone_number(number, false)
        end

        @numbers = @numbers.compact
      end

      private

      def new_phone_number(number, pref)
        return unless number

        PhoneNumber.new({
          phone_number: number['value'],
          number_type: number['type'],
          preferred: pref
        })
      end

      def normalize_numbers(numbers)
        return [] unless numbers
        numbers.map do |num|
          if PhoneNumber.valid_format?(num['value'])
            num['value'] = PhoneNumber.normalize_number(num['value'])
            num
          end
        end.compact
      end
    end

    class EmailsProcessor
      include Contacts

      def initialize(emails)
        @raw_emails = normalize_emails(emails)
      end

      def preferred_email
        return @preferred_email if @preferred_email

        pref = @raw_emails.find { |email| true?(email['pref']) }
        @preferred_email = @raw_emails.delete(pref || @raw_emails.first)
      end

      def generate_emails
        return @emails if @emails

        @emails = [new_email(preferred_email, true)]
        @raw_emails.each { |email| @emails << new_email(email, false) }

        @emails = @emails.compact
      end

      private

      def new_email(email, pref)
        return unless email

        Email.new({
          email: email['value'],
          email_type: email['type'],
          preferred: pref
        })
      end

      def normalize_emails(emails)
        begin emails.compact! rescue return [] end
        emails.select { |email| Email.valid_format? email['value'] }
      end
    end

    private

    def base_user_attrs(pending)
      password = SecureRandom.urlsafe_base64(10)
      {
        email: @emails.preferred_email.try(:[], 'value'),
        username: @contact['name']['formatted'],
        pending: pending.present?,
        first_name: @contact['name']['givenName'],
        last_name: @contact['name']['familyName'],
        street_address: address['streetAddress'],
        locality: address['locality'],
        region: address['region'],
        country: address['country'],
        zip_code: address['postalCode'],
        birthday: (Time.at(@contact['birthday'] / 1000.0).utc if @contact['birthday'].present?),
        password: password,
        password_confirmation: password
      }
    end

    def address
      return @address if @address

      pref = @contact['addresses'].find { |address| true?(address['pref']) }
      @address = pref || (@contact['addresses'].first || {})
    end

    def associate_emails
      @user.emails = @emails.generate_emails
    end

    def associate_phone_numbers
      @user.phone_numbers = @numbers.generate_numbers
    end
  end

end
