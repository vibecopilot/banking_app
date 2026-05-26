class CreatePatrollingHistoriesBatchJob < ApplicationJob
  queue_as :default

  def perform(patrolling_ids)
    patrolling_ids.each do |patrolling_id|
      CreatePatrollingHistoriesJob.perform_later(patrolling_id)
    end
  end
end
