class GeneratePatrollingQrJob < ApplicationJob
  queue_as :default

  def perform(patrolling_id)
    patrolling = Patrolling.find_by(id: patrolling_id)
    return unless patrolling

    patrolling.generate_qr_code
  end
end
