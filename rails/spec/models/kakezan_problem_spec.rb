require "rails_helper"

RSpec.describe KakezanProblem, type: :model do
  describe ".generate" do
    it "generates KakezanProblem" do
      spec =  { factors: [2, 1] }
      problem = KakezanProblem.generate spec
    
      expect(problem.class).to eq KakezanProblem
      expect(problem.type).to eq "KakezanProblem"
      expect(problem.spec).to eq spec.deep_stringify_keys
    end

    it "fills body" do
      spec =  { factors: [2, 1] }
      problem = KakezanProblem.generate spec
    
      expect(problem.body.keys).to match_array %w(question answer)
      expect(problem.body["question"].length).to eq 2
      expect(problem.body["answer"]).to eq problem.body["question"].inject(:*)
    end

    it "takes digit ranges" do
      spec =  { factors: [[2, 3], [1, 2]] }
      100.times do
        problem = KakezanProblem.generate spec
        question = problem.body["question"]
        expect(question[0]).to be_between(10, 999)
        expect(question[1]).to be_between(1, 99)
      end
    end

    it "never introduce neutral number" do
      spec =  { factors: [1, 1] }
      100.times do
        problem = KakezanProblem.generate spec
        question = problem.body["question"]
        expect(question[0]).not_to eq 1
        expect(question[1]).not_to eq 1
      end
    end
  end
end
