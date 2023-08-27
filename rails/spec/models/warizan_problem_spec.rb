require "rails_helper"

RSpec.describe WarizanProblem, type: :model do
  describe ".generate" do
    it "generates WarizanProblem" do
      spec =  { divisor: 1, quatient: 2 }
      problem = WarizanProblem.generate spec
    
      expect(problem.class).to eq WarizanProblem
      expect(problem.type).to eq "WarizanProblem"
      expect(problem.spec).to eq spec.deep_stringify_keys
    end

    it "fills body" do
      spec =  { divisor: 1, quatient: 2 }
      problem = WarizanProblem.generate spec
    
      expect(problem.body.keys).to match_array %w(question answer)
      expect(problem.body["question"].length).to eq 2
      expect(problem.body["answer"]).to eq problem.body["question"].inject(:/)
    end

    it "supports multiple divisors" do
      spec =  { divisors: [1, 1, 1], quatient: 2 }
      problem = WarizanProblem.generate spec
    
      expect(problem.body.keys).to match_array %w(question answer)
      expect(problem.body["question"].length).to eq 4
      expect(problem.body["answer"]).to eq problem.body["question"].inject(:/)
    end

    it "takes digit ranges" do
      spec =  { divisor: [1, 2], quatient: [2, 3] }
      100.times do
        problem = WarizanProblem.generate spec
        question = problem.body["question"]
        answer = problem.body["answer"]
        expect(question[1]).to be_between(1, 99)
        expect(answer).to be_between(10, 999)
      end
    end

    it "never introduce neutral number" do
      spec =  { divisors: [1, 1], quatient: 1 }
      100.times do
        problem = WarizanProblem.generate spec
        question = problem.body["question"]
        answer = problem.body["answer"]
        expect(question[1]).not_to eq 1
        expect(answer).not_to eq 1
      end
    end
  end
end

