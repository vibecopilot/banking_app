class GoodsInOut < ApplicationRecord
	belongs_to :visitor, optional: true
	belongs_to :staff, optional: true
  belongs_to :site
  has_many :goods_items, dependent: :destroy

	after_create :create_qr
	has_many :goods_files, -> { where(relation: "GoodsFile") }, foreign_key: :relation_id, class_name: "Attachfile"
	has_one :qr_code_image, -> { where(relation: "GoodsQR") }, foreign_key: :relation_id, class_name: "Attachfile"
  
  accepts_nested_attributes_for :goods_items, allow_destroy: true

	def create_qr
    qr_code = RQRCode::QRCode.new("#{self.try(:id)}", self.id, size: 10, :level => :h)
    png = qr_code.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 200,
      border_modules: 4,
      module_px_size: 6,
      file: nil # path to write
    )
    png.save("tmp/#{self.id}.png")
    file = File.open("tmp/#{self.id}.png", "r")
    Attachfile.create(image: file, relation: "GoodsQR", relation_id: self.id, active: 1)
  end
end
