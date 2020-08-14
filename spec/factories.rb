FactoryBot.define do
  factory :user do
    username { Faker::Internet.username }
    password { Faker::Internet.password }
  end

  factory :record do
    name { Faker::Food.send(%w[dish fruits ingredient spice sushi vegetables].sample) }

    amount { rand(-100.00..100.00).round(2) }
    
    trait(:replt) do
      amount { rand(1.00..100.00).round(2) }
    end

    trait(:expn) do
      amount { rand(-100.00..-1.00.round(2)) }
    end

    rest { 99.00 }
    performed_at { rand((Time.now - 1.year)...Time.now) }

    factory :record_with_card_and_tags do
      transient do
        tags_count { 5 }
      end

      card { association :card, user: user}

      after(:create) do |record, evaluator|
        create_list :tag, evaluator.tags_count, user: record.user
      end
    end
  end

  factory :card do
    name { Faker::Finance.credit_card }
    user
  end

  factory :tag do
    name { Faker::App.name }
    user
  end
end
