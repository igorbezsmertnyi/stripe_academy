class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :token, null: :false, default: ''

      t.timestamps
    end
  end
end
