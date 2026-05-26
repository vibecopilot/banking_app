# config/initializers/paperclip.rb
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end

