require "rails_helper"

RSpec.describe MitorizanProblem, type: :model do
  describe ".generate" do
    it "generates MitorizanProblem" do
      spec =  { positive: [1, 1], negative: [1, 1], count: 5 }
      problem = MitorizanProblem.generate spec
    
      expect(problem.class).to eq MitorizanProblem
      expect(problem.type).to eq "MitorizanProblem"
      expect(problem.spec).to eq spec.deep_stringify_keys
    end

    it "fills body" do
      spec =  { positive: 1, count: 5 }
      problem = MitorizanProblem.generate spec
    
      expect(problem.body.keys).to match_array %w(question answer)
      expect(problem.body["question"].length).to eq 5
      expect(problem.body["answer"]).to eq problem.body["question"].sum
    end

    it "adds negatives" do
      spec =  { positive: 1, negative: 1, count: 200 }
      problem = MitorizanProblem.generate spec
    
      min, max = problem.body["question"].minmax
      expect(min).to be_between(-9, -1)
      expect(max).to be_between(1, 9)
    end

    it "takes digits" do
      spec =  { positive: [1, 2], count: 200 }
      problem = MitorizanProblem.generate spec

      min, max = problem.body["question"].minmax
      expect(min).to be_between(1, 9)
      expect(max).to be_between(10, 99)
    end

    it "takes digits for both of positives and negatives" do
      spec =  { positive: [1, 2], negative: [1, 2], count: 200 }
      problem = MitorizanProblem.generate spec

      min, max = problem.body["question"].minmax
      expect(min).to be_between(-99, -10)
      expect(max).to be_between(10, 99)
    end
  end
end
