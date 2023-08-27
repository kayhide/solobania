class WarizanProblem < Problem
  def self.generate spec
    spec = spec.symbolize_keys
    quatient = spec[:quatient]
    divisors = [spec[:divisor], *spec[:divisors]].compact
    r = Random.new
    factors, product = [quatient, *divisors].inject([[], 1]) do |acc, num|
      ns, prod = acc
      num0, num1 = num
      n = rand_digit_number r, num0, num1, min: 2
      [[*ns, n], prod * n]
    end
    question = [product, *factors.drop(1)]
    answer = factors[0]
    new(count: question.count, body: { question:, answer: }, spec: spec)
  end
end
