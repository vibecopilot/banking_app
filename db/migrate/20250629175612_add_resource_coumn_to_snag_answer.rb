class AddResourceCoumnToSnagAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :snag_answers, :resource_id, :integer
    add_column :snag_answers, :resource_type, :string
  end
end
