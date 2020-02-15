require 'faker'

FactoryBot.define do
  factory :user do
    username { Faker::Internet.username }
    password { Faker::Internet.password }
  end

  factory :record do
    name { Faker::Food.send(%w(dish fruits ingredient spice sushi vegetables).sample) }
    amount { rand(0..100.00) }
    rest { 99.00 }
  end

  factory :card do
    name { Faker::Finance.credit_card }
  end
end