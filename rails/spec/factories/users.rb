FactoryBot.define do
  factory :user do
    sequence(:username) { |i| "User-#{i}" }
    sequence(:email) { |i| "user-#{i}@laphroaig.test" }
    sequence(:password) { |i| "password-#{i}" }
    admin { false }
  end
end
