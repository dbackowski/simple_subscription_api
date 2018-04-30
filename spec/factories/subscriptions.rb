FactoryBot.define do
  factory :subscription do
    credit_card_number CreditCardValidations::Factory.random
    name FFaker::Name.name
    address FFaker::Address.street_address
    country FFaker::Address.country

    trait :maestro do
      credit_card_number CreditCardValidations::Factory.random(:maestro)
    end

    trait :visa do
      credit_card_number CreditCardValidations::Factory.random(:visa)
    end

    trait :amex do
      credit_card_number CreditCardValidations::Factory.random(:amex)
    end

    trait :mastercard do
      credit_card_number CreditCardValidations::Factory.random(:mastercard)
    end

    trait :discover do
      credit_card_number CreditCardValidations::Factory.random(:discover)
    end
  end
end
