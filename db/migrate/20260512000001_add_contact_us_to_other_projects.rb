class AddContactUsToOtherProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :other_projects, :contact_us, :string
  end
end
