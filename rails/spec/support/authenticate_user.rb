Module.new do
  def authenticate_user admin: false
    let(:current_user) { @current_user }

    before do
      @current_user = block_given? ? yield : FactoryBot.create(:user)
      @token = controller.create_token @current_user

      allow(controller).to receive(:authenticate!)
      allow(controller).to receive(:authenticate_m2m!)
      if admin
        allow(controller).to receive(:authenticate_admin!)
      end
      allow(controller).to receive(:auth_token) { @token }
      allow(controller).to receive(:current_user_id) { @current_user.id }

    end
  end

  def authenticate_without_user
    authenticate_user do
      nil
    end
  end

  RSpec.configure do |config|
    config.extend self, type: :controller
  end
end
