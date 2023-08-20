class Api::AuthController < ApplicationController
  before_action :authenticate!, except: :create

  def show
    user = User.find current_user_id
    body = {
      user: user.attributes,
    }
    render json: body
  end

  def create
    email = params.require :email
    password = params.require :password
    user = User.find_by! email: email
    raise ActiveRecord::RecordNotFound unless user.authenticate(password)

    token = create_token user
    body = {
      token: token,
      user: user.attributes,
    }
    render json: body

  rescue ActiveRecord::RecordNotFound
    raise Api::WrongEmailPassword
  end
end
