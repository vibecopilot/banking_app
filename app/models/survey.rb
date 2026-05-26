class Survey < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: :created_by_id, optional: true
  has_many :survey_questions, dependent: :destroy
  has_many :survey_responses, dependent: :destroy
  has_many :survey_images, -> { where(relation: "SurveyImage") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :background_images, -> { where(relation: "BackgroundImage") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :client_logos, -> { where(relation: "ClientLogo") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :header_images, -> { where(relation: "HeaderImage") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :footer_images, -> { where(relation: "FooterImage") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :mail_logos, -> {where(relation: "MailerLogos")}, foreign_key: :relation_id, class_name: "Attachfile"

  accepts_nested_attributes_for :survey_questions, allow_destroy: true
  STATUSES = %w[draft active closed].freeze
  validates :survey_title, presence: true
  validates :status, inclusion: { in: STATUSES }, allow_nil: true

  scope :active, -> { where(status: 'active') }
end
