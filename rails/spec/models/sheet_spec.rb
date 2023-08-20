require "rails_helper"

RSpec.describe Sheet, type: :model do
  describe ".generate" do
    let(:spec) {
      {
        name: "Mitorizan",
        timelimit: 7,
        problem_type: :mitorizan,
      }
    }

    it "generates sheet" do
      sheet = Sheet.generate spec
      expect(sheet.name).to eq "Mitorizan"
      expect(sheet.timelimit).to eq 7
    end

    it "generates problems" do
      expect(Problem)
        .to receive(:generate)
          .exactly(2)
          .with(sequential_args([
            { type: :mitorizan, spec: "problem1" },
            { type: :mitorizan, spec: "problem2" },
          ]))
          .and_return(build :problem)

      Sheet.generate spec.merge(problems: %w(problem1 problem2))
    end
  end
end
