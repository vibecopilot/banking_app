class Submission < ApplicationRecord
	belongs_to :activity, optional: true
	belongs_to :site_asset, foreign_key: :asset_id, optional: true
	belongs_to :checklist, optional: true
	belongs_to :user
	belongs_to :question, optional: true
	belongs_to :soft_service, optional: true
	belongs_to :asset_param, optional: true
	ransacker :created_on do
    Arel.sql("DATE(#{table_name}.created_at)")

    validates :questions, presence: true, if: :questions_mandatory?
    validates :image, presence: true, if: :image_mandatory?
     validates :question_id, uniqueness: { scope: [:checklist_id, :activity_id ,:asset_id, :soft_service_id, :asset_param_id, :patrolling_id], message: "must be unique" }

  end
end
