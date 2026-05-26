class GenerateStaffEmbeddingJobJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(staff_id, image_path)
    staff = Staff.find_by(id: staff_id)
    
    unless staff
      Rails.logger.warn "GenerateStaffEmbeddingJobJob: Staff #{staff_id} not found"
      return
    end

    unless image_path.present? && File.exist?(image_path)
      Rails.logger.warn "GenerateStaffEmbeddingJobJob: Image not found at #{image_path}"
      return
    end

    result = FaceAiService.analyze(image_path)

    if result["success"]
      staff.update(embedding: result["embedding"].to_json)
      Rails.logger.info "GenerateStaffEmbeddingJobJob: Embedding saved for Staff #{staff_id}"
    else
      Rails.logger.warn "GenerateStaffEmbeddingJobJob: Face AI failed for Staff #{staff_id}: #{result['error']}"
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "GenerateStaffEmbeddingJobJob: Staff not found - #{e.message}"
  rescue StandardError => e
    Rails.logger.error "GenerateStaffEmbeddingJobJob error: #{e.message}"
    raise e # Re-raise to trigger retry
  end
end
