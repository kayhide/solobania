class KakezanProblem < Problem
  def self.generate spec
    spec = spec.symbolize_keys
    numbers = spec[:numbers]
    r = Random.new
    question, answer = numbers.inject([[], 1]) do |acc, num|
      ns, prod = acc
      num0, num1 = num
      num1 ||= num0
      num0 &&= [10 ** (num0 - 1), 2].max
      num1 &&= 10 ** num1
      n = r.rand(num0...num1)
      [[*ns, n], prod * n]
    end
    new(count: question.count, body: { question:, answer: }, spec: spec)
  end
end
