FactoryBot.define do
  factory :invoice do
    status { "shipped" }
    association :customer
    association :merchant 
    coupon_id { nil } 
  end
end