class CreateCoinPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :coin_prices do |t|
      t.string :coin_name
      t.float :price_usd
      t.float :price_brl
      t.datetime :timestamp

      t.timestamps
    end
  end
end
