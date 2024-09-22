class SeedCoupons < ActiveRecord::Migration[7.1]
  def up

    merchants = Merchant.all

  if merchants.any?
    merchants.each do |merchant|
      10.times do
        Coupon.create!(
          name: Faker::Commerce.promotion_code,
          code: Faker::Alphanumeric.alphanumeric(number: 10).upcase,
          active: [true, false].sample,
          merchant: merchant,
          discount_type: ['dollar_off', 'percentage_off'].sample,
          discount_value: Faker::Commerce.price(range: 1..100)
        )
      end
    end
    puts "10 coupons created for each merchant!"
  else
    puts "No merchants found. Please seed merchants first!"
  end
    end
  def down
    Coupon.all.destroy
  end
end
