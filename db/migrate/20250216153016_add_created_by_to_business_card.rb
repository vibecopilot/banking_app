class AddCreatedByToBusinessCard < ActiveRecord::Migration[5.1]
  def change
    add_column :business_cards, :created_by, :integer
  end
end
