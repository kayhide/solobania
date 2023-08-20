require "rails_helper"

RSpec.describe Problem, type: :model do
  describe ".generate" do
    it "generates MitorizanProblem" do
      spec = {
        type: :mitorizan,
        spec: :problem_spec,
      }
      expect(MitorizanProblem).to receive(:generate).with(:problem_spec)
      Problem.generate spec
    end
  end
end
