FactoryBot.define do
  factory :invoice do
    status { "shipped" }
    association :customer # This links the invoice to a Merchant instance
    association :merchant # This links the invoice to a Customer instance
    coupon_id { nil } # Can specify coupon later, or leave nil
  end
end