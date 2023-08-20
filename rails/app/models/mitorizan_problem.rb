class MitorizanProblem < Problem
  def self.generate spec
    pos0, pos1 = spec[:positive]
    pos1 ||= pos0
    pos0 &&= 10 ** (pos0 - 1)
    pos1 &&= 10 ** pos1
    neg0, neg1 = spec[:negative]
    neg1 ||= neg0
    neg0 &&= 10 ** (neg0 - 1)
    neg1 &&= 10 ** neg1
    r = Random.new
    question, answer = spec[:count].times.inject([[], 0]) do |acc, _|
      ns, sum = acc
      n =
        if neg0 && neg0 < sum && r.rand(2) == 1
          - r.rand(neg0...[neg1, sum].min)
        else
          r.rand(pos0...pos1)
        end
      [[*ns, n], sum + n]
    end
    new(body: { question:, answer: }, spec: spec)
  end
end
