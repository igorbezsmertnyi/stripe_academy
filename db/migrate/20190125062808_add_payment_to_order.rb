class AddPaymentToOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :payments, :order, index: true
  end
end
