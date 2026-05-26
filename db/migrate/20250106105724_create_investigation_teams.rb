class CreateInvestigationTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :investigation_teams do |t|
      t.string :name
      t.string :mobile
      t.string :designation
      t.references :incident, foreign_key: true

      t.timestamps
    end
  end
end
