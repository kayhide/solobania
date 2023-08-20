module Authenticator
  extend ActiveSupport::Concern

  attr_reader :auth_token, :current_user_id

  def authenticate!
    token, _options = ActionController::HttpAuthentication::Token.token_and_options(request)
    token ||= request.params[:token]

    raise Api::NoToken if token.nil?

    @auth_token = token
    local_jwt = LocalJwt.new token
    unless local_jwt.error
      @current_user_id = local_jwt.user_id
      return
    end

    logger.info "Invalid as local jwt: #{local_jwt.error}"
    raise Api::BadToken.new
  end

  def authenticate_admin!
    authenticate!
    raise Api::Unauthorized unless current_user.admin
  end

  def authenticate_m2m!
    token, _options = ActionController::HttpAuthentication::Token.token_and_options(request)
    token ||= request.params[:token]

    raise Api::NoToken if token.nil?

    @auth_token = token
    auth0_jwt = Auth0Jwt.new token
    unless auth0_jwt.error
      @user = User.find_or_initialize_by(email: auth0_jwt.email)
      unless @user.persisted?
        @user.username = auth0_jwt.nickname
        @user.password = SecureRandom.alphanumeric(16)
      end
      @current_user_id = @user.id
      return
    end

    local_jwt = LocalJwt.new token
    unless local_jwt.error
      @current_user_id = local_jwt.user_id
      return
    end

    logger.info "Invalid as auth0 jwt: #{auth0_jwt.error}"
    logger.info "Invalid as local jwt: #{local_jwt.error}"
    raise Api::BadToken.new
  end

  def current_user
    User.find(current_user_id)
  end

  def create_token user
    LocalJwt.create_token user
  end


  class LocalJwt
    JWT_SECRET = ENV["JWT_SECRET"]
    JWT_ALGORITHM = 'HS256'
    JWT_ISSUER = Rails.application.class.module_parent_name.downcase

    attr_reader :body, :user_id, :error

    def initialize token
      @body = from_jwt token
      @user_id = @body.first["sub"]
    rescue JWT::DecodeError => e
      @error = e
    end

    def from_jwt token
      JWT.decode token, JWT_SECRET, true, { algorithm: JWT_ALGORITHM }
    end

    def self.create_token user
      payload = { iss: JWT_ISSUER, sub: user.id.to_s }
      JWT.encode payload, JWT_SECRET, JWT_ALGORITHM
    end
  end
end
