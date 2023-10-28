require 'rails_helper'

RSpec.describe Api::ActsController, type: :controller do
  authenticate_user

  let(:now) { Time.current.change(nsec: 0) }

  describe "GET #index" do
    let(:problem) { create :problem }

    it "returns a success response" do
      acts = create_list(:act, 2, user: current_user, actable: problem.pack)
      get :index
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.count).to eq 2
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

    it "ignores problem and sheet acts" do
      acts = [
        create_list(:act, 2, user: current_user, actable: problem),
        create_list(:act, 2, user: current_user, actable: problem.sheet),
      ]
      get :index
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.count).to eq 0
    end

    it "limits items up to 20" do
      create_list(:act, 21, user: current_user, actable: problem.pack)
      get :index
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.count).to eq 20
    end

    context "with spec_key" do
      it "filters acts" do
        pack = create :pack
        acts = create_list(:act, 3, user: current_user, actable: pack)

        create_list(:pack, 2).each do |p|
          create_list(:act, 2, user: current_user, actable: p)
        end
        get :index, params: { spec_key: pack.spec.key}
        expect(response).to be_successful
        body = JSON.parse(response.body)
        expect(body.count).to eq 3
        expect(body.map { |x| x["actable_type"] }).to all eq "Pack"
        expect(body.map { |x| x["actable_id"] }).to all eq pack.id
      end
    end

    context "with pack_id" do
      it "lists sheet acts" do
        pack = create :pack
        acts = create_list(:sheet, 3, pack: pack).map do |sheet|
          create :act, user: current_user, actable: sheet
        end
        get :index, params: { pack_id: pack.id}
        expect(response).to be_successful
        body = JSON.parse(response.body)
        expect(body.count).to eq 3
        expect(body.map { |x| x["actable_type"] }).to all eq "Sheet"
        expect(body.map { |x| x["actable_id"] }).to eq pack.sheet_ids.reverse
      end
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
