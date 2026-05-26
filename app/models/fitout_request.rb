class FitoutRequest < ApplicationRecord
  belongs_to :building, optional: true
  belongs_to :floor, optional: true  
  belongs_to :unit
  belongs_to :user
  belongs_to :supplier, class_name: "Vendor", foreign_key: "supplier_id", optional: true
  
  has_many :fitout_request_categories, dependent: :destroy
  has_many :attachfiles, through: :fitout_request_categories

  before_create :set_default_status

  def send_document_request_email
    FitoutRequestMailer.fitout_documents_request(self).deliver_now
  end

  def send_document_request_email_later
    FitoutRequestMailer.fitout_documents_request(self).deliver_later
  end

  def building_name
    building&.name || unit&.building&.name || "Building"
  end

  def floor_name
    floor&.name || unit&.floor&.name || "Floor"
  end
  
  def effective_building
    building.presence || unit&.building
  end
  
  def effective_floor
    floor.presence || unit&.floor
  end

private

def set_default_status
  self.status ||= "pending"
end

end

