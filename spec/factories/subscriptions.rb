FactoryBot.define do
  factory :subscription do
    credit_card_number CreditCardValidations::Factory.random
    name FFaker::Name.name
    address FFaker::Address.street_address
    country FFaker::Address.country

    trait :maestro_card do
      credit_card_number CreditCardValidations::Factory.random(:maestro)
    end

    trait :visa_card do
      credit_card_number CreditCardValidations::Factory.random(:visa)
    end

    trait :amex_card do
      credit_card_number CreditCardValidations::Factory.random(:amex)
    end

    trait :mastercard do
      credit_card_number CreditCardValidations::Factory.random(:mastercard)
    end
  end
end
