class Floor < ApplicationRecord
	belongs_to :site
	belongs_to :building
	has_many :units

	def self.import(file,user)
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    header = spreadsheet.row(1)
	    rowcomp = []
	    (2..spreadsheet.last_row).each do |i|
	      rowhs = Hash.new
	      rowhs[:row_number] = i
	      row = Hash[[header, spreadsheet.row(i)].transpose]
 cccccccccccc                                                        
	      begin
	        id = row["Id"] if row["Id"]
	        if id.present? 
	          floor = Floor.find_or_initialize_by(id: row["Id"])
	          else
	          floor = Floor.new
	        end
	        floor.name = row["FloorName"]
	        if row["SiteName"].present?
	        	@site = Site.find_by(name: row["SiteName"] )
	        	floor.site_id = @site.id
	        end

	        if row["BuildingName"].present?
	        	building = Building.find_by(name: row["BuildingName"] , site_id:  @site.id)
	        	floor.building_id = building.id
	        end

	        
	        if !floor.save
	          rowhs[:message] = floor.errors
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
