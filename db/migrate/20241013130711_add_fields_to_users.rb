class AddFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :user_courtesy, :string
    add_column :users, :user_phase, :string
    add_column :users, :user_status, :boolean
    add_column :users, :building_id, :integer
    add_column :users, :user_category_id, :integer
    add_column :users, :user_address, :text
    add_column :users, :resident_type, :boolean
    add_column :users, :membership_type, :boolean
    add_column :users, :lives_here, :boolean
    add_column :users, :allow_fitout, :boolean
    add_column :users, :birth_date, :date
    add_column :users, :anniversary, :date
    add_column :users, :spouse_birth_date, :date
    add_column :users, :email_1, :string
    add_column :users, :email_2, :string
    add_column :users, :landline_number, :string
    add_column :users, :intercom_number, :string
    add_column :users, :gst_number, :integer
    add_column :users, :pan_number, :integer
    add_column :users, :ev_connection, :string
    add_column :users, :no_of_adults, :integer
    add_column :users, :no_of_childrens, :integer
    add_column :users, :no_of_pets, :integer
    add_column :users, :differently_abled, :boolean
  end
end
