require 'rails_helper'

RSpec.describe Api::ActsController, type: :controller do
  authenticate_user

  let(:now) { Time.current.change(nsec: 0) }

  describe "GET #index" do
    let(:problem) { create :problem }

    it "returns a success response" do
      acts = [
        create_list(:act, 2, user: current_user, actable: problem),
        create_list(:act, 1, user: current_user, actable: problem.sheet),
        create_list(:act, 1, user: current_user, actable: problem.sheet.pack),
      ]
      get :index
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.count).to eq 4
      expect(body.map(&:keys))
        .to all match_array %w(
          id
          actable_type
          actable_id
          pack_id
          sheet_id
          problem_id
          mark
          display_name
          created_at
          updated_at
        )
    end

    it "limits items up to 200" do
      create_list(:act, 205, user: current_user, actable: problem)
      get :index
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.count).to eq 200
    end
  end

  describe "GET #show" do
    let(:problem) { create :problem }
    let(:act) { create :act, user: current_user, actable: problem }

    it "returns a success response" do
      get :show, params: { id: act.id }
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.keys)
        .to match_array %w(
          id
          actable_type
          actable_id
          pack_id
          sheet_id
          problem_id
          mark
          display_name
          created_at
          updated_at
        )
    end
  end

  describe "POST #create" do
    let(:problem) { create :problem }

    it "creates new Acts for problem, sheet and pack" do
      expect {
        post :create, params: { problem_id: problem.id }
      }.to change(Act, :count).by(3)
      acts = Act.last(3)
      expect(acts.map(&:user)).to all eq current_user
      expect(acts.map(&:actable)).to eq [problem, problem.sheet, problem.pack]
    end

    it "sets the timestamps for all created Acts" do
      post :create, params: { problem_id: problem.id }
      acts = Act.last(3)
      expect(acts.map(&:created_at).uniq).to eq [acts.last.created_at]
      expect(acts.map(&:updated_at).uniq).to eq [acts.last.created_at]
    end

    it "updates pack act if existing" do
      travel_to 1.hour.ago do
        @pack_act = create :act, user: current_user, actable: problem.pack
      end
      expect {
        post :create, params: { problem_id: problem.id }
      }.to change(Act, :count).by(2)
      acts = Act.last(3)
      expect(acts.map(&:created_at).uniq).to eq [@pack_act, acts.last].map(&:created_at)
      expect(acts.map(&:updated_at).uniq).to eq [acts.last.created_at]
    end

    it "updates sheet act and pack act if existing" do
      travel_to 2.hour.ago do
        @pack_act = create :act, user: current_user, actable: problem.pack
      end
      travel_to 1.hour.ago do
        @sheet_act = create :act, user: current_user, actable: problem.sheet
      end
      expect {
        post :create, params: { problem_id: problem.id }
      }.to change(Act, :count).by(1)
      acts = Act.last(3)
      expect(acts.map(&:created_at).uniq).to eq [@pack_act, @sheet_act, acts.last].map(&:created_at)
      expect(acts.map(&:updated_at).uniq).to eq [acts.last.created_at]
    end
  end

  describe "PUT #update" do
    let(:problem) { create :problem }
    let!(:act) { create :act, user: current_user, actable: problem }

    context "with valid params" do
      let(:new_params) {
        {
          mark: "confident",
        }
      }

      it "updates the requested item" do
        expect {
          put :update, params: { id: act.id, **new_params }
        }.to change { act.reload.mark }.to("confident")
      end

      it "renders a JSON response with the item" do
        put :update, params: { id: act.id, **new_params }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      let(:invalid_params) {
        {
          mark: "invalid mark",
        }
      }

      it "renders a JSON response with errors for the item" do
        put :update, params: { id: act.id, **invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end
end
