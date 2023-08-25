require 'rails_helper'

RSpec.describe Api::SpecsController, type: :controller do
  authenticate_user

  describe "GET #index" do
    it "returns a success response" do
      specs = create_list :spec, 2
      get :index
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.count).to eq 2
      expect(body.map(&:keys))
        .to all match_array %w(
          id
          key
          name
          created_at
          updated_at
        )
    end
  end
end
