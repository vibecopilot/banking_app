class GenerateVisitorEmbeddingJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(visitor_id, image_path)
    visitor = Visitor.find_by(id: visitor_id)
    
    unless visitor
      Rails.logger.warn "GenerateVisitorEmbeddingJob: Visitor #{visitor_id} not found"
      return
    end

    unless image_path.present? && File.exist?(image_path)
      Rails.logger.warn "GenerateVisitorEmbeddingJob: Image not found at #{image_path}"
      return
    end

    result = FaceAiService.analyze(image_path)

    if result["success"]
      visitor.update(embedding: result["embedding"].to_json)
      Rails.logger.info "GenerateVisitorEmbeddingJob: Embedding saved for visitor #{visitor_id}"
    else
      Rails.logger.warn "GenerateVisitorEmbeddingJob: Face AI failed for visitor #{visitor_id}: #{result['error']}"
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "GenerateVisitorEmbeddingJob: Visitor not found - #{e.message}"
  rescue StandardError => e
    Rails.logger.error "GenerateVisitorEmbeddingJob error: #{e.message}"
    raise e # Re-raise to trigger retry
  end
end
