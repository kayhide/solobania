FactoryBot.define do
  factory :pack do
    category { Pack::CATEGORIES.first }
    sequence(:name) { |i| "Pack #{i}" }
  end
end
