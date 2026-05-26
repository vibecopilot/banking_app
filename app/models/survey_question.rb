class SurveyQuestion < ApplicationRecord
  belongs_to :survey
  # has_many :survey_question_options, dependent: :destroy
  has_many :survey_answers, dependent: :destroy
  has_many :options, class_name: "SurveyQuestionOption", foreign_key: :survey_question_id, inverse_of: :survey_question, dependent: :destroy
  has_many :attachments, -> { where(relation: "QuestionAttachment").active }, class_name: "Attachfile", foreign_key: :relation_id
  accepts_nested_attributes_for :options, allow_destroy: true
  # accepts_nested_attributes_for :survey_question_options, allow_destroy: true
  QUESTION_TYPES = %w[rating multiple_choice star_rating single_choice true_false text scale].freeze
  validates :q_title, presence: true
  validates :question_type, presence: true, inclusion: { in: QUESTION_TYPES }
  default_scope { order(position: :asc) }
end