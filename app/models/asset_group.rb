class AssetGroup < ApplicationRecord
	has_many :asset_group_params , dependent: :destroy
	has_many :sub_groups, foreign_key: :group_id


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
	          asset_group = AssetGroup.find_or_initialize_by(id: row["Id"])
	          else
	          asset_group = AssetGroup.new
	        end
	        asset_group.name = row["GroupName"]
	        asset_group.description = row["Description"]
	        
	        if !asset_group.save
	          rowhs[:message] = asset_group.errors
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
