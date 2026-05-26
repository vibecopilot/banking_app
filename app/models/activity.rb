class Activity < ApplicationRecord
    has_many :submissions
	belongs_to :site_asset, foreign_key: :asset_id , optional: true
    belongs_to :checklist
	belongs_to :soft_service, class_name: 'SoftService', foreign_key: 'soft_service_id', optional: true
	belongs_to :user, class_name: "User", foreign_key: "assigned_to", optional: true
    belongs_to :site, optional: true
    has_many :checklist_users, through: :checklist
	ransacker :start_time_on do
        Arel.sql("DATE(CONVERT_TZ(#{table_name}.start_time, '+00:00', '+05:30'))")
    end
 #   validates :start_time, uniqueness: { scope: [:checklist_id, :asset_id, :soft_service_id, :patrolling_id, :group_id], message: "must be unique" }
  #  validates :start_time_must_be_unique


  def get_status
  	status
  end	  

  ransacker :search do |parent|
   Arel.sql(
    "CONCAT_WS(' ',
        activities.id,
        activities.status,
        checklists.name,
        site_assets.name,
        users.firstname
      )"
    )
  end

  def self.update_status
  	#Activity.where("DATE(start_time) > ?", Date.today).update_all(status: "upcoming")
  	Activity.ransack(start_time_on_eq: Date.today).result.where.not(status: 'complete').update_all(status: "pending")
  	Activity.where("DATE(start_time) < ? and status != 'complete'", Date.today).update_all(status: "overdue")
  end
end
