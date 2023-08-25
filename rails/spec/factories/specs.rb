FactoryBot.define do
  factory :spec do
    sequence(:key) { |i| "spec-#{i}" }
    sequence(:name) { |i| "Spec #{i}" }
    body { {} }
  end
end
