require 'rails_helper'

RSpec.describe Subscription, type: :model do
  subject { described_class.new(FactoryBot.build(:subscription).attributes) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is invalid without a name" do
    subject.name = nil
    expect(subject).to_not be_valid
  end

  it "is invalid without a address" do
    subject.address = nil
    expect(subject).to_not be_valid
  end

  it "is invalid without a country" do
    subject.country = nil
    expect(subject).to_not be_valid
  end

  it "is invalid without a credit card number" do
    subject.credit_card_number = nil
    expect(subject).to_not be_valid
  end

  it "is invalid wihtout a valid credit card number" do
    subject.credit_card_number = "2229363141673131"
    expect(subject).to_not be_valid
  end
end
