FactoryBot.define do
  factory :pack do
    spec
    category { Pack::CATEGORIES.first }
    sequence(:name) { |i| "Pack #{i}" }
  end
end
