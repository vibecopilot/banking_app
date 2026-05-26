class Building < ApplicationRecord
	belongs_to :site
	has_many :floors
	has_many :units
	validates :name, uniqueness: {scope: :site_id}

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
	          building = Building.find_or_initialize_by(id: row["Id"])
	          else
	          building = Building.new
	        end
	        building.name = row["BuildingName"]

	        if row["SiteName"].present?
	        	site = Site.find_by(name: row["SiteName"] )
	        	building.site_id = site.id
	        end
	        
	        if !building.save
	          rowhs[:message] = building.errors
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
