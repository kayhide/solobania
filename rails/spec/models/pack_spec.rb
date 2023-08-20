require "rails_helper"

RSpec.describe Pack, type: :model do
  describe ".generate" do
    let(:spec) {
      {
        category: :shuzan,
        grade: 10,
        grade_unit: :kyu,
        name: "Shuzan 10 Kyu",
      }
    }

    it "generates pack" do
      pack = Pack.generate spec
      expect(pack.category).to eq "shuzan"
      expect(pack.grade).to eq 10
      expect(pack.grade_unit).to eq "kyu"
    end

    it "generates sheets" do
      expect(Sheet)
        .to receive(:generate)
          .exactly(2)
          .with(sequential_args(%w(sheet1 sheet2)))
          .and_return(build :sheet)

      Pack.generate spec.merge(sheets: %w(sheet1 sheet2))
    end
  end
end
