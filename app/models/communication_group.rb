class CommunicationGroup < ApplicationRecord
  has_and_belongs_to_many :users
   # Paperclip attachment for picture
  has_attached_file :picture
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\z/

  validates :name, presence: true

  # Add picture URL to JSON response
  def as_json(options = {})
    super(options).merge(picture_url: picture.url)
  end
end