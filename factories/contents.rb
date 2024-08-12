FactoryBot.define do
  factory :content do
    title { Faker::Lorem.characters(number: 6) }
    body { Faker::Lorem.characters(number: 6) }
    start_time { Time.now }
    end_time { Time.now + 1.day }
    target_flag { 0 }
    discarded_at { nil }
    for_customer { false }
    for_employee { false }
  end
end
