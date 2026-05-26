class CreateQuotations < ActiveRecord::Migration[5.2]
  def change
    create_table :quotations do |t|
      t.string :ticket_id
      t.integer :vendor_id
      t.decimal :tax_pct, default: 18
      t.decimal :discount_pct, default: 0
      t.string :status, default: "draft"
      t.integer :version, default: 1
      t.text :notes
      t.string :created_by
      t.integer :site_id
      t.timestamps
    end

    create_table :quotation_lines do |t|
      t.integer :quotation_id
      t.string :description
      t.integer :qty, default: 1
      t.decimal :rate, default: 0
      t.timestamps
    end

    create_table :quotation_histories do |t|
      t.integer :quotation_id
      t.string :action
      t.string :actor
      t.datetime :created_at
    end

    add_index :quotations, :site_id
    add_index :quotation_lines, :quotation_id
    add_index :quotation_histories, :quotation_id
  end
end
