class AddBrandingColumnsToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :background_color, :string
    add_column :surveys, :header_text, :text
    add_column :surveys, :footer_text, :text
  end
end
