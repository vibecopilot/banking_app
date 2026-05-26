class TagSurrenderJob < ApplicationJob
  queue_as :default

  def perform
    # Surrender tags for visitors whose end_date has passed
    surrender_visitor_tags
    
    # Schedule the next run for tomorrow at midnight
    schedule_next_run
  end

  private

  def surrender_visitor_tags
    # Find visitors with end_date <= today and lotus_token present
    visitors = Visitor.where('end_date <= ?', Date.today)
                      .where.not(lotus_token: nil)
                      .where.not(lotus_token: '')
                      .joins(:visitor_cards)
                      .distinct

    visitors.each do |visitor|
      begin
        service = TagSurrenderService.new(visitor, 'visitor', 56)
        result = service.surrender_tag

        if result[:success]
          Rails.logger.info("Tag surrendered successfully for visitor #{visitor.id}")
        else
          Rails.logger.error("Failed to surrender tag for visitor #{visitor.id}: #{result[:error]}")
        end
      rescue StandardError => e
        Rails.logger.error("Error surrendering tag for visitor #{visitor.id}: #{e.message}")
      end
    end
  end

  def schedule_next_run
    # Schedule the job to run tomorrow at midnight (00:00)
    next_run_time = (Date.today + 1.day).to_time.beginning_of_day
    TagSurrenderJob.set(wait_until: next_run_time).perform_later
  end
end
