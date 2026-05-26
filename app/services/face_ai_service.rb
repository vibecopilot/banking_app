require 'net/http'
require 'uri'
require 'json'

class FaceAiService
  AI_URL = ENV.fetch('FACE_AI_URL', 'http://127.0.0.1:8000')
  TIMEOUT = 30 # seconds

  class << self
    def analyze(image_path)
      return error_response("Image path is required") if image_path.blank?
      return error_response("Image file not found") unless File.exist?(image_path)

      uri = URI.parse("#{AI_URL}/face/analyze")

      begin
        request = Net::HTTP::Post.new(uri)
        form_data = [['image', File.open(image_path)]]
        request.set_form(form_data, 'multipart/form-data')

        response = Net::HTTP.start(uri.hostname, uri.port, read_timeout: TIMEOUT, open_timeout: TIMEOUT) do |http|
          http.request(request)
        end

        result = JSON.parse(response.body)
        
        if response.code.to_i >= 500
          return error_response("Face AI service error", response.code)
        end
        
        result
      rescue Errno::ECONNREFUSED
        error_response("Face AI service is not running")
      rescue Net::ReadTimeout, Net::OpenTimeout
        error_response("Face AI service timeout")
      rescue JSON::ParserError
        error_response("Invalid response from Face AI service")
      rescue StandardError => e
        Rails.logger.error "FaceAiService error: #{e.message}"
        error_response(e.message)
      end
    end

    def compare(embedding1, embedding2)
      uri = URI.parse("#{AI_URL}/face/compare")

      begin
        request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        request.body = { embedding1: embedding1, embedding2: embedding2 }.to_json

        response = Net::HTTP.start(uri.hostname, uri.port, read_timeout: TIMEOUT) do |http|
          http.request(request)
        end

        JSON.parse(response.body)
      rescue StandardError => e
        Rails.logger.error "FaceAiService compare error: #{e.message}"
        { "error" => e.message }
      end
    end

    def health_check
      uri = URI.parse("#{AI_URL}/health")
      
      begin
        response = Net::HTTP.get_response(uri)
        JSON.parse(response.body)
      rescue StandardError => e
        { "status" => "unavailable", "error" => e.message }
      end
    end

    private

    def error_response(message, code = nil)
      result = { "success" => false, "error" => message }
      result["code"] = code if code
      result
    end
  end
end
