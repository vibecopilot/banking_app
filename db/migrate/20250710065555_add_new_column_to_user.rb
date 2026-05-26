class AddNewColumnToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :rotary_club, :string unless column_exists?(:users, :rotary_club)
    add_column :users, :wedding_date, :datetime unless column_exists?(:users, :wedding_date)
    add_column :users, :business_name, :string unless column_exists?(:users, :business_name)
    add_column :users, :business_category, :string unless column_exists?(:users, :business_category)
    add_column :users, :education_qualification, :string unless column_exists?(:users, :education_qualification)
    add_column :users, :office_address, :string unless column_exists?(:users, :office_address)
    add_column :users, :rbm_by_id, :integer unless column_exists?(:users, :rbm_by_id)
    add_column :users, :member_of_rmb, :boolean unless column_exists?(:users, :member_of_rmb)
    add_column :users, :facebook_link, :string unless column_exists?(:users, :facebook_link)
    add_column :users, :instagram_link, :string unless column_exists?(:users, :instagram_link)
    add_column :users, :linkedin_profile, :string unless column_exists?(:users, :linkedin_profile)
    add_column :users, :date_of_joining, :datetime unless column_exists?(:users, :date_of_joining)
    add_column :users, :blood_group, :string unless column_exists?(:users, :blood_group)
  end
end
