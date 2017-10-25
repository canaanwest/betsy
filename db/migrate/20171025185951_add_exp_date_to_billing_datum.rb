class AddExpDateToBillingDatum < ActiveRecord::Migration[5.1]
  def change
    add_column :billing_data, :expiration_date, :string
  end
end
