class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.string :credit_card_number
      t.string :name
      t.string :address
      t.string :country
      t.date :next_billing_date

      t.timestamps
    end
  end
end
