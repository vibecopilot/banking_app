class Site < ApplicationRecord
	belongs_to :company
	has_many :hik_devices
	has_many :features
	has_many :buildings
	has_many :helpdesk_operations, -> { where(op_of: "Society") }, foreign_key: :op_of_id
	has_many :visitors
	has_many :visitor_visits
	has_many :rooms, dependent: :destroy
	has_many :room_bookings, dependent: :destroy
	has_one :visitor_alert_config, dependent: :destroy
	has_one :billing_configuration, dependent: :destroy
	has_many :income_entries, dependent: :destroy
	has_many :interest_calculations, dependent: :destroy
	has_many :cam_bills
	accepts_nested_attributes_for :helpdesk_operations, reject_if: :all_blank, allow_destroy: true


	# Role Access
	has_many :role_accesses
	has_many :site_modules
	has_many :role_modules, through: :site_modules

	def name_with_region
		company.try(:name).to_s + " / " + region.to_s + " / " + name.to_s
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
	          site = Site.find_or_initialize_by(id: row["Id"])
	          else
	          site = Site.new
	        end
	        site.name = row["Name"]
	        site.region = row["Region"]
	        company = Company.find_by(name: row["CompanyName"])
	        if company.present?
	        	site.company_id = company.id
	    	end
	        if !site.save
	          rowhs[:message] = site.errors
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