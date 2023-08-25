require 'rails_helper'

RSpec.describe Api::PacksController, type: :controller do
  authenticate_user

  let(:spec) { create :spec }

  describe "GET #index" do
    it "returns a success response" do
      packs = create_list :pack, 2, spec: spec
      get :index, params: { spec_id: spec.id }
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.count).to eq 2
      expect(body.map(&:keys))
        .to all match_array %w(
          id
          spec_id
          category
          name
          grade
          grade_unit
          created_at
          updated_at
        )
    end
  end

  describe "HEAD #index" do
    it "includes Total-Count" do
      packs = create_list :pack, 2, spec: spec
      head :index, params: { spec_id: spec.id }
      expect(response).to be_successful
      expect(response.headers['Total-Count']).to eq 2
    end
  end

  describe "GET #show" do
    let(:pack) { create :pack, spec: spec }

    it "returns a success response" do
      get :show, params: { id: pack.id }
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.keys)
        .to match_array %w(
          id
          spec_id
          category
          name
          grade
          grade_unit
          created_at
          updated_at
          sheets
        )
      expect(body["sheets"]).to all match_array %w()
    end

    it "renders sheets and problems" do
      2.times do
        create(:sheet, pack: pack).tap do |sheet|
          create_list(:problem, 3, sheet: sheet)
        end
      end
      get :show, params: { id: pack.id }
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["sheets"].length).to eq 2
      expect(body["sheets"].map(&:keys)).to all match_array %w(
        id pack_id name timelimit problems created_at updated_at
      )
      expect(body["sheets"].map { |x| x["problems"].length }).to eq [3, 3]
      expect(body["sheets"].flat_map { |x| x["problems"] }.map(&:keys)).to all match_array %w(
        id sheet_id count body spec created_at updated_at
      )
    end
  end

  describe "POST #create" do
    context "with valid spec" do
      before do
        spec.update body: { category: :shuzan, grade: 10, grade_unit: :kyu, name: "New Pack" }
      end

      it "creates a new Pack" do
        expect {
          post :create, params: { spec_id: spec.id }
        }.to change(Pack, :count).by(1)
        pack = Pack.last
        expect(pack.category).to eq "shuzan"
        expect(pack.grade).to eq 10
        expect(pack.grade_unit).to eq "kyu"
        expect(pack.name).to eq "New Pack"
      end

      it "renders a JSON response with the new item" do
        post :create, params: { spec_id: spec.id }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end
end
