class Payment < ApplicationRecord
  # has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  # validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  belongs_to :resource, polymorphic: true

  after_commit :update_amenity_book_status, on: [:create, :update]

  private

  def update_amenity_book_status
    return unless resource_type == "AmenityBooking"

    a_booking = AmenityBooking.find(resource_id)

    if paid_amount.to_f >= total_amount.to_f
      a_booking.update(status: "PAID")
    end
  end
end



#  def image_url
#     image.url
#   end

# end
