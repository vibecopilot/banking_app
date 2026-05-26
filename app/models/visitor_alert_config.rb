class VisitorAlertConfig < ApplicationRecord
  belongs_to :site

  validates :threshold_value, presence: true, numericality: { greater_than: 0 }
  validates :threshold_unit, presence: true, inclusion: { in: %w[hours days] }
  validates :site_id, presence: true, uniqueness: true

  # Calculate threshold in seconds for easier comparison
  def threshold_in_seconds
    case threshold_unit
    when 'hours'
      threshold_value.hours.to_i
    when 'days'
      threshold_value.days.to_i
    else
      0
    end
  end

  # Check if a visitor has overstayed based on this config
  def visitor_overstayed?(check_in_time)
    return false unless enabled?
    return false unless check_in_time.present?
    
    Time.current - check_in_time > threshold_in_seconds
  end
end
