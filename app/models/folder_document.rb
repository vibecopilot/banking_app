class FolderDocument < ApplicationRecord
belongs_to :folder, class_name: "Folder", foreign_key: "folder_id", optional: true

  has_attached_file :image,
                    path: ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename",
                    url: "/system/:class/:attachment/:id_partition/:style/:filename",
                    default_url: "/images/upload.svg"

  validates_attachment :image, 
                       content_type: {
                         content_type: %w[
                           application/pdf
                           image/jpeg
                           image/jpg
                           image/png
                           text/plain
                           text/csv
                           application/msword
                           application/vnd.openxmlformats-officedocument.wordprocessingml.document
                         ]
                       }

  def whole_path
    "http://13.215.74.38" + self.image.url
  end

  def document_url
    self.image.url
  end
end
