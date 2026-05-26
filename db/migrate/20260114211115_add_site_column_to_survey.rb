class AddSiteColumnToSurvey < ActiveRecord::Migration[5.1]
  def change
    add_column :surveys, :id_of_site, :integer
    add_column :surveys, :extra, :string
  end
end
