RSpec::Matchers.define :sequential_args do |xs|
  xs = xs.clone
  match { |actual| actual == xs.shift }
end
