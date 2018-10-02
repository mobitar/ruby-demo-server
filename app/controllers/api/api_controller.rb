class Api::ApiController < ApplicationController
  respond_to :json

  attr_accessor :current_user
  attr_accessor :user_manager

  before_action :authenticate_user

  before_action {
    request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'

    self.user_manager = StandardFile::UserManager.new(User)
  }

  protected

  def authenticate_user
    if !request.headers['Authorization'].present?
      render_invalid_auth
      return
    end

    strategy, token = request.headers['Authorization'].split(' ')
    if (strategy || '').downcase != 'bearer'
      render_invalid_auth
      return
    end

    claims = StandardFile::JwtHelper.decode(token) rescue nil
    user = User.find_by_uuid claims['user_uuid']
    if claims['pw_hash']
      # newer versions of our jwt include the user's hashed encrypted pw,
      # to check if the user has changed their pw and thus forbid them from access if they have an old jwt
      if claims['pw_hash'] != Digest::SHA256.hexdigest(user.encrypted_password)
        render_invalid_auth
        return
      end
    end

    self.current_user = user
  end

  def not_found(message = 'not_found')
    render json: {error: {:message => message, :tag => "not-found"}}, status: :not_found
  end

  def render_invalid_auth
    render :json => {:error => {:tag => "invalid-auth", :message => "Invalid login credentials."}}, :status => 401
  end

end
