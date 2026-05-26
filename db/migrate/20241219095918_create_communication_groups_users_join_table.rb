class CreateCommunicationGroupsUsersJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :communication_groups, :users do |t|
      t.references :communication_group, foreign_key: true
      t.references :user, foreign_key: true
    end
  end
end
