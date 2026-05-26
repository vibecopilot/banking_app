class Unit < ApplicationRecord
	belongs_to :building
	belongs_to :floor
	belongs_to :site
	belongs_to :unit_configuration, optional: true
	belongs_to :user, optional: true
	has_many :service_bookings, dependent: :destroy
	has_many :staff_units, dependent: :destroy
	has_many :staffs, through: :staff_units
	has_many :accounting_invoices

	validates :name, uniqueness: { scope: [:building_id, :floor_id] }

	def unit_type
		unit_configuration&.name || "Not Configured"
	end

	def unit_configuration_name
		unit_configuration&.name
	end

	def with_floor_building
		building&.name.to_s + " / " + floor&.name.to_s + " / " + self.name.to_s
	end

	def full_address
		"#{name}, #{floor&.name}, #{building&.name}, #{site&.name}"
	end

	def self.import(file,user)
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    header = spreadsheet.row(1)
	    rowcomp = []
	    (2..spreadsheet.last_row).each do |i|
	      rowhs = Hash.new
	      rowhs[:row_number] = i
	      row = Hash[[header, spreadsheet.row(i)].transpose]

	      begin
	        id = row["Id"] if row["Id"]
	        if id.present? 
	          unit = Unit.find_or_initialize_by(id: row["Id"])
	          else
	          unit = Unit.new
	        end
	        unit.name = row["UnitName"]
	        if row["SiteName"].present?
	        	@site = Site.find_by(name: row["SiteName"] )
	        	unit.site_id = @site.id
	        end

	        if row["BuildingName"].present?
	        	@building = Building.find_by(name: row["BuildingName"] , site_id: @site.id )
	        	unit.building_id = @building.id
	        end


	        if row["FloorName"].present?
	        	floor = Floor.find_by(name: row["FloorName"], site_id: @site.id , building_id: @building.id)
	        	unit.floor_id = floor.id
	        end
	        
	        if !unit.save
	          rowhs[:message] = unit.errors
	        else
	          rowhs[:message] = "success"
	        end
	      rescue Exception => e
	        rowhs[:error] = e.to_s
	      end
	      rowcomp << rowhs
	    end
	    return rowcomp
	end 

end
