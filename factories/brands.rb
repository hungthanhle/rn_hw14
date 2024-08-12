FactoryBot.define do
  factory :brand do
    name { Faker::Lorem.characters(number: 50) }
    code { Faker::Lorem.characters(number: 9) }
    kana_name { "ー" }
    discarded_at { nil }
    association :maker
    association :company
  end
end
