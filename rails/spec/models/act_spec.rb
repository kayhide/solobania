require 'rails_helper'

RSpec.describe Act, type: :model do
  describe "#parent" do
    context "of problem" do
      let(:problem) { create :problem }
      subject { build :act, actable: problem }

      it "builds sheet act" do
        parent = subject.parent
        expect(parent.actable).to eq problem.sheet
      end

      it "returns sheet act" do
        sheet_act = create :act, actable: problem.sheet
        parent = subject.parent
        expect(parent).to eq sheet_act
        expect(parent.actable).to eq problem.sheet
      end
    end

    context "of sheet" do
      let(:sheet) { create :sheet }
      subject { build :act, actable: sheet }

      it "builds pack act" do
        parent = subject.parent
        expect(parent.actable).to eq sheet.pack
      end

      it "returns pack act" do
        pack_act = create :act, actable: sheet.pack
        parent = subject.parent
        expect(parent).to eq pack_act
        expect(parent.actable).to eq sheet.pack
      end
    end
  end
end
