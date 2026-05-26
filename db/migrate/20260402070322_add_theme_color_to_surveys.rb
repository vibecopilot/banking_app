class AddThemeColorToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :theme_color, :string
  end
end
