FactoryBot.define do
  factory :sheet do
    pack
    sequence(:name) { |i| "Sheet #{i}" }
    timelimit { 1 }
  end
end
