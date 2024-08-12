FactoryBot.define do
  factory :company_staff do
    email { "company_staff@gmail.com" }
    password { "abcd1234" }
    family_name { "company_staff" }
    first_name { "company_staff" }
    family_kana_name { "ーラースタッフ" }
    first_kana_name { "ーラースタッフ" }
    kind { :company_staff }
    company_id { 1 }
    pref_id { 1 }
    zip_code { "1234567" }
    city { "Tokyo" }
    street { "ミヤコジマシ" }
    phone { "0123456789" }
    customer_mail_consent { User.customer_mail_consents.keys.sample }
    customer_status { User.customer_statuses.keys.sample }
    gender { User.genders.keys.sample }
    confirmed_at { Time.current }
  end
end
