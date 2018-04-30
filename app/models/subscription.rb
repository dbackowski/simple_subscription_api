class Subscription < ApplicationRecord
  validates :credit_card_number,
    presence: true,
    credit_card_number: true
  validates :name,
    presence: true
  validates :address,
    presence: true
  validates :country,
    presence: true

  before_save :set_next_billing_date

  private

  def set_next_billing_date
    self.next_billing_date = Time.zone.today + 1.month
  end
end
