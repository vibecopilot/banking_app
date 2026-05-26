class CalculateInterestJob < ApplicationJob
  queue_as :default

  def perform
    # Calculate interest for all overdue CAM bills
    # Default: 18% annual interest rate, 5 days grace period
    Rails.logger.info "Starting interest calculation for overdue CAM bills..."
    
    count = 0
    CamBill.overdue.find_each do |bill|
      begin
        interest = bill.calculate_interest(18.0, 5)
        if interest > 0
          count += 1
          Rails.logger.info "Calculated interest of ₹#{interest} for CAM bill #{bill.id}"
        end
      rescue => e
        Rails.logger.error "Error calculating interest for bill #{bill.id}: #{e.message}"
      end
    end
    
    Rails.logger.info "Interest calculation completed. #{count} bills updated."
  end
end
