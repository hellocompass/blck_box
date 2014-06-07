class AuthUser
  
  def self.find(auth_data)
    new(auth_data).find
  end  

  def initialize(auth_data)
    @auth_data = auth_data
  end

  def find
    @user = User.find_by_email(@auth_data[:info][:email])
    @user ? connect_user : create_user

    @user
  end

  private

  def create_user
    password = generate_password
    @user = User.new(
      email: @auth_data[:info][:email], 
      password: password,
      password_confirmation: password
    )
    add_connection
    
    CreateUser.create @user
  end

  def connect_user
    unless @user.connections.where(source_id: @auth_data[:uid]).first
      add_connection
      @user.save
    end
  end

  def add_connection
    @user.connections << Connection.new(
      source: @auth_data[:provider],
      source_id: @auth_data[:uid], 
      auth_token: @auth_data[:credentials][:token].to_s
    )
  end

  def generate_password
    SecureRandom.base64(20) + '!D9' # to pass validations
  end
end
