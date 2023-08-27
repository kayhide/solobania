class MitorizanProblem < Problem
  def self.generate spec
    spec = spec.symbolize_keys
    pos0, pos1 = spec[:positive]
    neg0, neg1 = spec[:negative]
    r = Random.new
    question, answer = spec[:count].times.inject([[], 0]) do |acc, _|
      ns, sum = acc
      n = neg0 && r.rand(2) == 1 && self.rand_digit_number(r, neg0, neg1, max: sum)&.-@
      if !n || sum + n < 0
        n = self.rand_digit_number(r, pos0, pos1)
      end
      [[*ns, n], sum + n]
    end
    new(count: spec[:count], body: { question:, answer: }, spec: spec)
  end
end
