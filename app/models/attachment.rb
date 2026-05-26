class Attachment < ApplicationRecord
  belongs_to :incident
  has_attached_file :file
  validates_attachment_content_type :file, content_type: /\A.*\z/

   def file_url
    file.url # This will generate the URL for the attached file
  end
end