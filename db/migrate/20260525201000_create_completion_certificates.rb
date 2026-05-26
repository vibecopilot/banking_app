class CreateCompletionCertificates < ActiveRecord::Migration[5.2]
  def change
    create_table :completion_certificates do |t|
      t.integer :quotation_id, null: false
      t.string :certificate_number, null: false
      t.datetime :issued_at
      t.text :notes
      t.text :recipients
      t.timestamps
    end
    add_index :completion_certificates, :certificate_number, unique: true
    add_index :completion_certificates, :quotation_id
  end
end
