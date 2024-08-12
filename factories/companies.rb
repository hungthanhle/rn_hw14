FactoryBot.define do
  factory :company do
    id { 201 }
    name { Faker::Lorem.characters(number: 20) }
    kana_name { "ブランドコー" }
    site_name { "site name" }
    tel { "0234233322" }
    memo { Faker::Lorem.characters(number: 500) }
    gross_margin { 0.0 }
    default_point { 1 }
    discarded_at { nil }
    represent_name { "MyString" }
    about_address { "MyString" }
    about_contact { "MyString" }
    about_price { "MyString" }
    about_additional_fee { "MyString" }
    about_payment_term { "MyString" }
    about_payment_method { "MyString" }
    about_delivery { "MyString" }
    about_return { "MyString" }
    company_code { "abcd1234" }
    email_contact { "company@example.com" }
    sender_email { "sender_email@gmail.com" }
    order_reception_email { "order_reception_email@gmail.com" }
    error_reception_email { "error_reception_email@gmail.com" }
    reply_to_email { "reply_to_email@gmail.com" }
    can_use_point { false }
    can_use_coupon { false }
    domain { "demo" }
    can_review_product { true }
    registration_number { "T5010401113399"}
  end

  factory :company_use_cip, class: "Company" do
    id { 1 }
    name { Faker::Lorem.characters(number: 20) }
    kana_name { "ブランドコー" }
    site_name { "site name" }
    tel { "0234233322" }
    memo { Faker::Lorem.characters(number: 500) }
    gross_margin { 0.0 }
    default_point { 1 }
    discarded_at { nil }
    represent_name { "MyString" }
    about_address { "MyString" }
    about_contact { "MyString" }
    about_price { "MyString" }
    about_additional_fee { "MyString" }
    about_payment_term { "MyString" }
    about_payment_method { "MyString" }
    about_delivery { "MyString" }
    about_return { "MyString" }
    company_code { "abcd1234" }
    email_contact { "company@example.com" }
    sender_email { "sender_email@gmail.com" }
    order_reception_email { "order_reception_email@gmail.com" }
    error_reception_email { "error_reception_email@gmail.com" }
    reply_to_email { "reply_to_email@gmail.com" }
    can_use_point { false }
    can_use_coupon { false }
    domain { "democip" }
    can_review_product { true }
    registration_number { "T5010401113361"}
  end
end
