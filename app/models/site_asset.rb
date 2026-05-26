require 'rqrcode'
require 'chunky_png'
class SiteAsset < ApplicationRecord
  belongs_to :building
  belongs_to :floor, optional: true
  belongs_to :unit , optional: true
  belongs_to :site
  belongs_to :user
  belongs_to :parent_asset, class_name: "SiteAsset", optional: true
  belongs_to :vendor, optional: true
  belongs_to :asset_group, optional: true
  scope :ppm, -> {joins(:checklist).where(checklists: {ctype: "ppm"})}
  belongs_to :sub_group, foreign_key: :asset_sub_group_id, optional: true
  has_many :asset_params, foreign_key: "asset_id", inverse_of: :site_asset
  has_many :activities, foreign_key: "asset_id"
  has_many :asset_amcs, foreign_key: 'asset_id'
  has_many :tickets, foreign_key: "asset_id", class_name: "Complaint"
  has_many :purchase_invoices, -> { where(relation: "AssetPurchaseInvoice") }, :foreign_key => :relation_id, class_name: "Attachfile"
  has_many :insurances, -> { where(relation: "AssetInsurance") }, :foreign_key => :relation_id, class_name: "Attachfile"
  has_many :manuals, -> { where(relation: "AssetManual") }, :foreign_key => :relation_id, class_name: "Attachfile"
  has_many :other_files, -> { where(relation: "AssetOther") }, :foreign_key => :relation_id, class_name: "Attachfile"
  accepts_nested_attributes_for :asset_params

  after_create :add_params
  after_create :create_qr
  has_one :qr_code_image, -> { where(relation: "AssetQR") }, :foreign_key => :relation_id, :class_name => "Attachfile"
  scope :expired, -> { where('warranty_expiry < ?', Date.today) }
  scope :under_warranty, -> { where('warranty_expiry >= ?', Date.today) }
  scope :in_use, -> { where(breakdown: false) }
  scope :breakdown, -> { where(breakdown: true) }


  def add_params
    if self.asset_group_id.present?
      AssetGroup.find(self.asset_group_id).asset_group_params.each do |ap|
        AssetParam.create(asset_id: self.id, name: ap.name, dashboard_view: ap.dashboard_view, consumption_view: ap.consumption_view, order: ap.order)
      end
    end
  end

  ransacker :search do |parent|
    Arel.sql(
      "CONCAT_WS(' ',
        site_assets.id,
        site_assets.oem_name,
        site_assets.name,
        site_assets.serial_number,
        site_assets.model_number,
        site_assets.uom,
        buildings.name,
        floors.name,
        users.firstname,
        users.lastname,
        units.name
      )"
    )
  end

  # def self.import(file,user)
  #   spreadsheet = Roo::Spreadsheet.open(file.path)
  #   header = spreadsheet.row(1)
  #   rowcomp = []
  #   (2..spreadsheet.last_row).each do |i|
  #     rowhs = Hash.new
  #     rowhs[:row_number] = i
  #     row = Hash[[header, spreadsheet.row(i)].transpose]

  #     begin
  #       id = row["Id"] if row["Id"]
  #       if id.present?
  #         site_asset = SiteAsset.find_or_initialize_by(id: row["Id"])
  #         else
  #         site_asset = SiteAsset.new

  #       end
  #       site_asset.name = row["Name"]
  #       if row["SiteName"].present?
  #         site = Site.find_by(name: row["SiteName"])
  #         site_asset.site_id = site&.id
  #       end
  #       if row["BuildingName"].present?
  #         bldg = Building.find_by(name: row["BuildingName"])
  #         site_asset.building_id = bldg&.id
  #       end

  #       # if row["FloorName"].present?
  #       #   floor = Floor.find_by(name: row["FloorName"])

  #       #   site_asset.floor_id = floor.id
  #       # end
  #       if row["FloorName"].present? && site_asset.building_id.present?
  #         floor_name = row["FloorName"].strip
  #         floor = Floor.find_by(name: floor_name, building_id: site_asset.building_id) # Fetch floors only associated with the building
  #         site_asset.floor_id = floor&.id if floor
  #       end

  #       if row["UnitName"].present?
  #         unit = Unit.find_by(name: row["UnitName"])
  #         site_asset.unit_id = unit&.id
  #       end
  #       site_asset.serial_number = row["SerialNumber"]
  #       site_asset.model_number = row["ModelNumber"]
  #       site_asset.purchased_on = row["PurchasedOn"]
  #       site_asset.purchase_cost = row["PurchasedCost"]
  #       site_asset.warranty_expiry = row["WarrantyExpiry"]
  #       site_asset.critical = row["Critical"]
  #       site_asset.breakdown = row["Breakdown"]
  #       site_asset.is_meter = row["IsMeter"]
  #       site_asset.parent_asset_id = row["ParentAssetId"]
  #       site_asset.active = row["Active"]
  #       site_asset.description = row["Description"]
  #       site_asset.oem_name = row["OemName"]
  #       site_asset.capacity = row["Capacity"]
  #       site_asset.installation = row["Installation"]
  #       site_asset.warranty_start = row["WarrantyStart"]
  #       site_asset.remarks = row["Remarks"]
  #       site_asset.vendor_id = row["VendorId"]
  #       site_asset.asset_group_id = row["AssetGroupId"]
  #       site_asset.user_id = user&.id
  #       if !site_asset.save
  #         rowhs[:message] = site_asset.errors
  #       else
  #         rowhs[:message] = "success"
  #       end
  #     rescue Exception => e
  #       rowhs[:error] = e.to_s
  #     end
  #     rowcomp << rowhs
  #   end
  #   return rowcomp
  # end

  def self.import(file, user)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    rowcomp = []

    (2..spreadsheet.last_row).each do |i|
      rowhs = { row_number: i }
      row = Hash[[header, spreadsheet.row(i)].transpose]

      begin
        # Initialize SiteAsset by ID or create a new one
        # site_asset = row["Id"].present? ? SiteAsset.find_or_initialize_by(id: row["Id"]) : SiteAsset.new

        site_asset = if row["Id"].present?
          SiteAsset.find_or_initialize_by(id: row["Id"])
        elsif row["Name"].present? && row["SiteName"].present?
          # Look up site first
          site = Site.find_by(name: row["SiteName"])
          if site
            SiteAsset.find_or_initialize_by(name: row["Name"], site_id: site.id)
          else
            rowhs[:message] = "Site '#{row["SiteName"]}' not found."
            SiteAsset.new # Keep as a new record if the site isn't found
          end
        else
          SiteAsset.new
        end

        # Assign site asset attributes from the row data
        site_asset.name = row["Name"]

        # Associate Site if present
        if row["SiteName"].present?
          site = Site.find_by(name: row["SiteName"])
          if site
            site_asset.site_id = site.id
          else
            rowhs[:message] = "Site '#{row["SiteName"]}' not found."
          end
        end

        # Associate Building if present
        if row["BuildingName"].present?
          building = Building.find_by(name: row["BuildingName"])
          if building
            site_asset.building_id = building.id
          else
            rowhs[:message] = "Building '#{row["BuildingName"]}' not found."
          end
        end

        # Associate Floor with Building check
        if row["FloorName"].present? && site_asset.building_id.present?
          floor = Floor.find_by(name: row["FloorName"].strip, building_id: site_asset.building_id)
          if floor
            site_asset.floor_id = floor.id
          else
            rowhs[:message] = "Floor '#{row["FloorName"]}' not found for building ID #{site_asset.building_id}."
          end
        end

        # Associate Unit if present
        if row["UnitName"].present?
          unit = Unit.find_by(name: row["UnitName"])
          if unit
            site_asset.unit_id = unit.id
          else
            rowhs[:message] = "Unit '#{row["UnitName"]}' not found."
          end
        end

        # Assign remaining attributes
        site_asset.serial_number = row["SerialNumber"]
        site_asset.model_number = row["ModelNumber"]
        site_asset.purchased_on = row["PurchasedOn"]
        site_asset.purchase_cost = row["PurchasedCost"]
        site_asset.warranty_expiry = row["WarrantyExpiry"]
        site_asset.critical = row["Critical"]
        site_asset.breakdown = row["Breakdown"]
        site_asset.is_meter = row["IsMeter"]
        site_asset.parent_asset_id = row["ParentAssetId"]
        site_asset.active = row["Active"]
        site_asset.description = row["Description"]
        site_asset.oem_name = row["OemName"]
        site_asset.capacity = row["Capacity"]
        site_asset.installation = row["Installation"]
        site_asset.warranty_start = row["WarrantyStart"]
        site_asset.remarks = row["Remarks"]
        site_asset.vendor_id = row["VendorId"]
        site_asset.asset_group_id = row["AssetGroupId"]
        site_asset.asset_sub_group_id = row["AssetSubGroupId"]
        site_asset.user_id = user&.id
        # Save and check for validation errors
        if site_asset.save
          rowhs[:message] = "success"
        else
          rowhs[:message] = site_asset.errors.full_messages.join(", ")
          Rails.logger.error("Error on Row #{row[:row_number]}: #{site_asset.errors.full_messages.join(', ')}")
        end
      rescue StandardError => e
        rowhs[:error] = "Row #{i}: #{e.message}"
      end
      rowcomp << rowhs
    end
    rowcomp
  end

  def create_qr
    qr_code = RQRCode::QRCode.new("SiteAsset_#{self.try(:id)}", self.id, size: 10, :level => :h)
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
    Attachfile.create(image: file, relation: "AssetQR", relation_id: self.id, active: 1)
  end


  CATEGORIES = %w[
  land
  buildings
  leasehold_improvement
  vehicle
  furniture_fixtures
  it_equipment
  machinery_equipment
  tools_instruments
  meter
  custom_form
  general
].freeze

  validates :category, inclusion: {in: CATEGORIES }, allow_blank: true

  def category_field(field_name)
    category_data&.dig(field_name.to_s)
  end

  def set_category_field(field_name, value)
    self.category_data ||= {}
    self.category_data[field_name.to_s] = value
  end

  # ============ LAND CATEGORY HELPERS ============
  def land_type
    category_field('land_type')
  end

  def area
    category_field('area')
  end

  def area_unit
    category_field('area_unit')
  end

  def ownership_type
    category_field('ownership_type')
  end

  def zoning_classification
    category_field('zoning_classification')
  end

  def encumbrance_status
    category_field('encumbrance_status')
  end

  def legal_document_ref
    category_field('legal_document_ref')
  end

  def acquisition_date
    category_field('acquisition_date')
  end

  def acquisition_cost
    category_field('acquisition_cost')
  end

  def current_market_value
    category_field('current_market_value')
  end

  def currency
    category_field('currency')
  end

  # ============ IT EQUIPMENT HELPERS ============
  def os
    category_field('os')
  end

  def total_memory
    category_field('total_memory')
  end

  def processor
    category_field('processor')
  end

  # ============ VEHICLE HELPERS ============
  def vehicle_type
    category_field('vehicle_type')
  end

  def registration_number
    category_field('registration_number')
  end

  def engine_number
    category_field('engine_number')
  end

  def chassis_number
    category_field('chassis_number')
  end

  def fuel_type
    category_field('fuel_type')
  end

  # ============ BUILDING HELPERS ============
  def building_type
    category_field('building_type')
  end

  def total_floors
    category_field('total_floors')
  end

  def built_up_area
    category_field('built_up_area')
  end

  def carpet_area
    category_field('carpet_area')
  end

  def construction_year
    category_field('construction_year')
  end

end
