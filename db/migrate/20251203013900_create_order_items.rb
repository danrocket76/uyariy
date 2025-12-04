class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :hearing_aid, null: false, foreign_key: true
      t.references :cart, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
