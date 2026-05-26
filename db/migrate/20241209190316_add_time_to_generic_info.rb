class AddTimeToGenericInfo < ActiveRecord::Migration[5.1]
  def change
    add_column :generic_infos, :time, :integer
  end
end
