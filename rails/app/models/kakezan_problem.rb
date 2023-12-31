class KakezanProblem < Problem
  def self.generate spec
    spec = spec.symbolize_keys
    factors = spec[:factors]
    r = Random.new
    question, answer = factors.inject([[], 1]) do |acc, num|
      ns, prod = acc
      num0, num1 = num
      n = rand_digit_number r, num0, num1, min: 2
      [[*ns, n], prod * n]
    end
    new(count: question.count, body: { question:, answer: }, spec: spec)
  end
end
