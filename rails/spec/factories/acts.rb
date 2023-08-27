FactoryBot.define do
  factory :act do
    user
    association :actable
    mark { nil }
  end
end
