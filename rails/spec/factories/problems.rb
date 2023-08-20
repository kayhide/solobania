FactoryBot.define do
  factory :problem do
    sheet
    count { 3 }
    body { { question: [1, 2, 3], answer: 6 } }
    spec { {} }
  end
end
