require 'rqrcode'
class SoftService < ApplicationRecord
  belongs_to :building , optional: true
  belongs_to :floor , optional: true
  belongs_to :unit , optional: true
  belongs_to :site , optional: true
  belongs_to :loi_service, optional: true
  belongs_to :user, optional: true
  has_many :activities

  include Cronnable
  has_one :cron_setting, as: :cronnable, dependent: :destroy, inverse_of: :cronnable
  accepts_nested_attributes_for :cron_setting, allow_destroy: true
  has_many :attachfiles, -> {where(relation: "ServiceImaage")}, foreign_key: :relation_id, class_name: "Attachfile"
  # after_create :create_qr
  # has_one :qr_code_image, -> { where(relation: "SoftService") }, :foreign_key => :relation_id, :class_name => "Attachfile"

  after_create :create_qr
  has_one :qr_code_image, -> { where(relation: "SoftService") }, foreign_key: :relation_id, class_name: "Attachfile"

  ransacker :search do |parent|
    Arel.sql(
      "CONCAT_WS(' ',
        soft_services.id,
        soft_services.name,
        users.firstname,
        users.lastname,
        buildings.name,
        floors.name,
        units.name
      )"
    )
  end

  def unit_id
    super.to_s.split(',').map(&:to_i).reject(&:zero?)
  end

  def unit_id=(value)
    super(Array(value).flatten.reject(&:blank?).uniq.join(','))
  end

  def related_units
    Unit.where(id: unit_id)
  end



  # def create_qr
  #   qr_code = RQRCode::QRCode.new("SoftService_#{self.id}", self.id, size: 10, :level => :h)
  #   png = qr_code.as_png(
  #     resize_gte_to: false,
  #     resize_exactly_to: false,
  #     fill: 'white',
  #     color: 'black',
  #     size: 200,
  #     border_modules: 4,
  #     module_px_size: 6,
  #     file: nil # path to write
  #   )
  #   png.save("tmp/#{self.id}.png")
  #   file = File.open("tmp/#{self.id}.png", "r")
  #   Attachfile.create(image: file, relation: "SoftService", relation_id: self.id, active: 1)
  # end
  def create_qr
    begin
      qr_code = RQRCode::QRCode.new("SoftService_#{self.id}", size: 10, level: :h)
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

      # Ensure tmp directory exists
      Dir.mkdir('tmp') unless Dir.exist?('tmp')

      # Save the PNG file
      png.save("tmp/#{self.id}.png")

      # Delete existing QR code if it exists
      qr_code_image&.destroy

      # Create new QR code attachment
      file = File.open("tmp/#{self.id}.png", "r")
      Attachfile.create(image: file, relation: "SoftService", relation_id: self.id, active: 1)
      file.close

      # Clean up temporary file
      File.delete("tmp/#{self.id}.png") if File.exist?("tmp/#{self.id}.png")

    rescue => e
      Rails.logger.error "Error creating QR code for SoftService #{self.id}: #{e.message}"
      puts "Error creating QR code: #{e.message}"
    end
  end

  # Method to regenerate QR code for existing SoftService
  def regenerate_qr
    create_qr
  end

  # Class method to regenerate QR codes for all SoftServices
  def self.regenerate_all_qr_codes
    SoftService.find_each do |soft_service|
      puts "Regenerating QR code for SoftService #{soft_service.id}"
      soft_service.regenerate_qr
    end
  end

  # Class method to regenerate QR code for a specific SoftService
  def self.regenerate_qr_for(id)
    soft_service = SoftService.find(id)
    soft_service.regenerate_qr
    puts "QR code regenerated for SoftService #{id}"
  end

end
