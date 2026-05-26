class RegisteredVehicle < ApplicationRecord
	belongs_to :parking_configuration , foreign_key: 'slot_number', class_name: 'ParkingConfiguration', primary_key: 'id'
  belongs_to :site
  before_create :set_sticker_number
	after_create :create_qr
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id, optional: true
  belongs_to :user, class_name: "User", foreign_key: :user_id, optional: true 
	has_one :qr_code_image, ->{where(relation: "RegisteredVehicleQR") }, :foreign_key => :relation_id, :class_name => "Attachfile"
  has_many :registered_vehicle_visits, dependent: :destroy
  belongs_to :unit , class_name: "Unit", foreign_key: :unit_id, optional: true

  enum approved: { Approved: 'Approved', Rejected: 'Rejected', Pending: 'Pending' }
  enum vehicle_in_out: { 'IN' => 'IN', 'OUT' => 'OUT' }

  def random_sticker_number
    loop do 
      code = SecureRandom.alphanumeric(rand(6..7)).upcase
      break code unless  RegisteredVehicle.exists?(sticker_number: code)
    end
  end

  def set_sticker_number
    self.sticker_number ||= random_sticker_number
  end

  def create_qr
    qr_code = RQRCode::QRCode.new(
      "RegisteredVehicle_#{self.id}",
        size: 10,
        level: :h
    )
  png = qr_code.as_png(
    fill: 'white',
    color: 'black',
    size: 200,
    border_modules: 4,
    module_px_size: 6
  )

  path = Rails.root.join("tmp/registered_vehicle_#{self.id}.png")
  png.save(path)

  Attachfile.create!(
    image: File.open(path),
    relation: "RegisteredVehicleQR",
    relation_id: self.id,
    active: 1
  )
end

  def self.import(file, user)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    rowcomp = []
    success_count = 0
    error_count = 0

    (2..spreadsheet.last_row).each do |i|
      rowhs = { row_number: i }
      row = Hash[[header, spreadsheet.row(i)].transpose]

      begin
        # Find or initialize registered vehicle
        registered_vehicle = RegisteredVehicle.new

        # Required fields
        vehicle_number = row["VehicleNumber"]&.to_s&.strip&.upcase
        
        if vehicle_number.blank?
          rowhs[:success] = false
          rowhs[:message] = "Vehicle number is required"
          error_count += 1
          rowcomp << rowhs
          next
        end

        # Check if vehicle already exists in this site
        existing_vehicle = RegisteredVehicle.find_by(
          vehicle_number: vehicle_number, 
          site_id: user.current_site_id
        )
        
        if existing_vehicle.present?
          rowhs[:success] = false
          rowhs[:message] = "Vehicle #{vehicle_number} already registered in this site"
          error_count += 1
          rowcomp << rowhs
          next
        end

        registered_vehicle.vehicle_number = vehicle_number
        registered_vehicle.site_id = user.current_site_id
        registered_vehicle.created_by_id = user.id

        # Vehicle Type
        if row["VehicleType"].present?
          registered_vehicle.vehicle_type = row["VehicleType"].to_s.strip
        end

        # Vehicle Category
        if row["VehicleCategory"].present?
          registered_vehicle.vehicle_category = row["VehicleCategory"].to_s.strip
        end

        # Registration Number
        if row["RegistrationNumber"].present?
          registered_vehicle.registration_number = row["RegistrationNumber"].to_s.strip
        end

        # Insurance Number
        if row["InsuranceNumber"].present?
          registered_vehicle.insurance_number = row["InsuranceNumber"].to_s.strip
        end

        # Insurance Valid Till
        if row["InsuranceValidTill"].present?
          begin
            registered_vehicle.insurance_valid_till = Date.parse(row["InsuranceValidTill"].to_s) rescue nil
          rescue
            rowhs[:message] = "Invalid insurance valid till date format"
          end
        end

        # Valid Till
        if row["ValidTill"].present?
          begin
            registered_vehicle.valid_till = Date.parse(row["ValidTill"].to_s) rescue nil
          rescue
            rowhs[:message] = "Invalid valid till date format"
          end
        end

        # Category
        if row["Category"].present?
          registered_vehicle.category = row["Category"].to_s.strip
        end

        # Status
        if row["Status"].present?
          registered_vehicle.status = row["Status"].to_s.strip
        end

        # Approved status (default to Pending)
        if row["Approved"].present?
          approved_value = row["Approved"].to_s.strip
          if ['Approved', 'Rejected', 'Pending'].include?(approved_value)
            registered_vehicle.approved = approved_value
          else
            registered_vehicle.approved = 'Pending'
          end
        else
          registered_vehicle.approved = 'Pending'
        end

        # Find unit by name if provided
        if row["UnitName"].present?
          unit = Unit.find_by(name: row["UnitName"].to_s.strip, site_id: user.current_site_id)
          if unit
            registered_vehicle.unit_id = unit.id
            registered_vehicle.user_id = unit.user_id if unit.user_id.present?
          else
            rowhs[:message] = (rowhs[:message] || "") + " Unit '#{row["UnitName"]}' not found."
          end
        end

        # Find user by email or phone if provided
        if row["UserEmail"].present? && registered_vehicle.user_id.blank?
          user_obj = User.find_by(email: row["UserEmail"].to_s.strip)
          if user_obj
            registered_vehicle.user_id = user_obj.id
          else
            rowhs[:message] = (rowhs[:message] || "") + " User with email '#{row["UserEmail"]}' not found."
          end
        end

        # Find parking configuration/slot by name
        if row["SlotNumber"].present?
          parking_slot = ParkingConfiguration.find_by(
            slot_number: row["SlotNumber"].to_s.strip,
            site_id: user.current_site_id
          )
          if parking_slot
            registered_vehicle.slot_number = parking_slot.id
          else
            rowhs[:message] = (rowhs[:message] || "") + " Parking slot '#{row["SlotNumber"]}' not found."
          end
        end

        # Save the registered vehicle
        if registered_vehicle.save
          rowhs[:success] = true
          rowhs[:message] = rowhs[:message].present? ? rowhs[:message] : "Successfully imported"
          success_count += 1
        else
          rowhs[:success] = false
          rowhs[:message] = registered_vehicle.errors.full_messages.join(", ")
          error_count += 1
        end

      rescue => e
        rowhs[:success] = false
        rowhs[:message] = "Error: #{e.message}"
        error_count += 1
      end

      rowcomp << rowhs
    end

    {
      success: true,
      message: "Import completed: #{success_count} successful, #{error_count} failed",
      total_rows: rowcomp.size,
      success_count: success_count,
      error_count: error_count,
      details: rowcomp
    }
  end

end
