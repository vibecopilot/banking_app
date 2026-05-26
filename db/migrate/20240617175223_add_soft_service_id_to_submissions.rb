class AddSoftServiceIdToSubmissions < ActiveRecord::Migration[5.1]
  def change
    add_column :submissions, :soft_service_id, :integer
  end
end
