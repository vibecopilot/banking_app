class CompletionCertificate < ApplicationRecord
  belongs_to :quotation

  before_validation :generate_certificate_number, on: :create
  before_validation :set_issued_at, on: :create

  validates :certificate_number, presence: true, uniqueness: true

  private

  def generate_certificate_number
    self.certificate_number ||= "CC-#{SecureRandom.hex(4).upcase}-#{Time.current.strftime('%Y%m')}"
  end

  def set_issued_at
    self.issued_at ||= Time.current
  end
end
