class ForumComment < ApplicationRecord
  belongs_to :forum
  belongs_to :user # Ensure the association is defined

  def user_fullname
    user&.fullname || "Anonymous" # Replace 'fullname' with the correct attribute or method in User model
  end
  
  # Paperclip attachment
  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/  # Only images

  # Comment validation
  validates :comment, presence: true  # Ensure comment text is not empty

  # Method to return the image URL
  def image_url
    image.url if image.present?  # Return image URL if the image exists
  end
end
