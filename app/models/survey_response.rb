class SurveyResponse < ApplicationRecord
  belongs_to :survey
  belongs_to :user, optional: true
  has_many :survey_answers, dependent: :destroy

  accepts_nested_attributes_for :survey_answers
end