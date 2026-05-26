class Attachfile < ApplicationRecord
  require 'base64'
  require 'tempfile'

  # =========================
  # Paperclip Attachment
  # =========================
  has_attached_file :image,
                    default_url: "/images/upload.svg",
                    use_timestamp: false,
                    preserve_files: true

  validates_attachment_content_type :image,
    content_type: %w[
      image/jpeg
      image/jpg
      image/png
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/vnd.ms-excel
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/vnd.openxmlformats-officedocument.presentationml.presentation
      text/plain
      text/csv
      video/mp4
    ]
  
  validates_attachment_size :image, less_than: 50.megabytes

  # =========================
  # Scopes
  # =========================
  scope :active, -> { where(active: [true, nil]) }

  # =========================
  # Class Methods
  # =========================

  # Create PNG from base64 string
  def self.createpng(imgstring)
    data = imgstring.sub(/^data:image\/png;base64,/, '')
    tempfile = Tempfile.new(['upload', '.png'])
    tempfile.binmode
    tempfile.write(Base64.decode64(data))
    tempfile.rewind
    tempfile
  end

  # Create image from uploaded file OR base64
  def self.createimage(img)
    return img if img.is_a?(ActionDispatch::Http::UploadedFile)

    data = img.sub(/^data:image\/\w+;base64,/, '')
    tempfile = Tempfile.new(['upload', '.jpg'])
    tempfile.binmode
    tempfile.write(Base64.decode64(data))
    tempfile.rewind
    tempfile
  end

  # =========================
  # Instance Methods
  # =========================

  def document_name
    return nil unless image_file_name.present?
    File.basename(image_file_name, File.extname(image_file_name))
  end

  # Use this from controller by passing host
  def whole_path(host = 'app.myciti.life')
    base =
      if host.include?('admin.vibecopilot.ai')
        'https://admin.vibecopilot.ai'
      else
        'https://app.myciti.life'
      end

    "#{base}#{image.url}"
  end

  def document_url
    image.url
  end
end
