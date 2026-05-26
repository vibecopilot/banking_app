require 'json'

module Utils
  class RailsParamConverter
    def self.safe_to_json(input)
      # Case 1: Already a Ruby Hash
      if input.is_a?(Hash)
        return JSON.pretty_generate(input)
      end

      # Case 2: String (Rails log style)
      json_like = input.dup
      json_like.gsub!("=>", ":")

      # Only fix unquoted keys
      json_like.gsub!(/([{,]\s*)([a-zA-Z0-9_]+)\s*:/, '\1"\2":')

      JSON.pretty_generate(JSON.parse(json_like))
    rescue => e
      puts "❌ Conversion failed: #{e.message}"
      nil
    end
  end
end