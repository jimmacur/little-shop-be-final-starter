FactoryBot.define do
  factory :coupon do
    name { "Sample Coupon" }
    code { "CODE123" }
    discount_type { "percentage_off" }
    discount_value { 10 }
    active { true }
    association :merchant
  end
end