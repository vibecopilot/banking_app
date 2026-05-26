class CreatePatrollingHistoriesJob < ApplicationJob
  queue_as :default

  def perform(patrolling_id)
    # binding.pry
    patrolling = Patrolling.find_by(id: patrolling_id)

    return unless patrolling
    PatrollingHistory.where(patrolling_id: patrolling_id).destroy_all

    if patrolling.time_intervals.present?
      process_intervals(patrolling)
    else
      current_date = patrolling.start_date
      patrolling.specific_times.each do |hour|
        expected_time = current_date.to_time.change(hour: hour.to_i)
        PatrollingHistory.create(patrolling_id: patrolling.id, expected_time: expected_time)
      end
    end
  end

  private

  def process_intervals(patrolling)
    start_time = patrolling.start_time.hour
    end_time = patrolling.end_time.hour
    interval = patrolling.time_intervals
    current_time = start_time
    current_date = patrolling.start_date

    while current_time
      expected_time = current_date.to_time.change(hour: current_time)
      PatrollingHistory.create(patrolling_id: patrolling.id, expected_time: expected_time)

      current_time += interval

      if current_time >= 24
        current_time -= 24
        current_date += 1.day
      end

      if start_time <= end_time
      # End time is on the same day or after the start time
        break if current_time > end_time && current_date > patrolling.end_date
      else
      # End time is on the next day
        if current_date > patrolling.end_date || (current_time > end_time && current_date > patrolling.start_date)
          break
        end
      end
      break if current_date > patrolling.end_date
    end
  end
end

    # if patrolling.time_intervals.present?
    #   start_time = patrolling.start_time.hour
    #   end_time = patrolling.end_time.hour
    #   interval = patrolling.time_intervals

    #   current_time = start_time

    #   while current_time <= end_time
    # binding.pry
    #     expected_time = patrolling.start_date.to_time.change(hour: current_time)
    #     PatrollingHistory.create(patrolling_id: patrolling.id, expected_time: expected_time)

    #     current_time += interval

    #     if current_time >= 24
    #       current_time -= 24
    #       patrolling.start_date += 1.day
    #     end
    #   end
    # binding.pry
    # else 
    #   current_date = patrolling.start_date
    #   patrolling.specific_times.each do |hour|
    #     expected_time = current_date.to_time.change(hour: hour.to_i)
    #     PatrollingHistory.create(patrolling_id: patrolling_id, expected_time: expected_time)
    #   end
    # end