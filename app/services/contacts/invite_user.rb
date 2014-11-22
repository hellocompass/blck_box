module Contacts

  class InviteUser

    def initialize(user, current_user)
      @user = user
      @current_user = current_user
    end

    def invite
      SmsWorker.perform_async(
        @user.preferred_number.phone_number,
        message_body
      )
    end

    private

    def message_body
      message = "Hey, "
      if inviter_name.present?
        message += "#{inviter_name} invited you to join BlackIn. Join here: <LINK>"
      else
        message += "you've been invited to join BlackIn. Join here: <LINK>"
      end
    end

    def inviter_name
      return @inviter_name if @inviter_name

      name = ""
      name += @current_user.first_name if @current_user.first_name.present?
      name += " #{@current_user.last_name}" if @current_user.last_name.present?
      name = @current_user.username if name.blank? && @current_user.username.present?

      @inviter_name = name.strip
    end
  end

end
