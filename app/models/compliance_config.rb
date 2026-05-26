class ComplianceConfig < ApplicationRecord
  has_many :compliance_trackers
  has_many :compliance_config_tags
  belongs_to :assign_to , class_name:'User' , foreign_key: :assign_to_id,optional: true
  belongs_to :reviewer , class_name:'User' , foreign_key: :reviewer_id,optional: true
  belongs_to :site , class_name:'Site' , foreign_key: :site_id
  after_create :create_compliance_tracker
  after_create :generate_random


  def generate_random
    loop do
      digits = (0..9).to_a.sample(2).join
      letters = ('A'..'Z').to_a.sample(4).join
      certificate_id = (digits + letters).chars.shuffle.join
      unless ComplianceConfig.exists?(cert_number: certificate_id)
        update_column(:cert_number, certificate_id)
        break
      end
    end
  end

  def create_compliance_tracker
    fyst = self.start_date.to_date
    endt = self.end_date.to_date
    std = fyst
    case self.frequency
    when "monthly"
      adder = 1.month
    when "quarterly"
      adder = 3.month
    when "half_yearly"
      adder = 6.month
    when "yearly"
      adder = 1.year
    end
    freq_end = nil
    if adder.present?
      while std < endt
        str = std.to_date
        etr = std + adder - 1.day

        freq_end = etr.to_date
        std = freq_end + 1.day

        begin
          ct = ComplianceTracker.create(compliance_config_id: self.id, due_date: freq_end + 1.day, status: "pending", site_id: self.site_id)
          Rails.logger.info "Created ComplianceTracker with due_date: #{freq_end + 1.day}"
        rescue => e
          Rails.logger.error "Error creating ComplianceTracker: #{e.message}"
        end
      end
    end
  end
end
