class PatrollingHistory < ApplicationRecord
	belongs_to :patrolling, foreign_key: 'patrolling_id', class_name: 'Patrolling'
	belongs_to :user, optional: true

	validates :patrolling_id, presence: true
	validates :expected_time, presence: true
end
