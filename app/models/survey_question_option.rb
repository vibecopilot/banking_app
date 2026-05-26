class SurveyQuestionOption < ApplicationRecord
    belongs_to :survey_question, inverse_of: :options
    validates :label, presence: true
    default_scope { order(position: :asc) }
end
