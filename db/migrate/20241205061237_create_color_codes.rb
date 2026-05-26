class CreateColorCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :color_codes do |t|
      t.string :code

      t.timestamps
    end
  end
end
