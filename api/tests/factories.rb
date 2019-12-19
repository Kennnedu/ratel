require 'faker'

FactoryBot.define do
  factory :record do
    name { 'shop' }
    amount { rand(-100.00..100.00) }
    rest { 99.00 }
  end

  factory :card do
    name { 'cash' }
  end
end