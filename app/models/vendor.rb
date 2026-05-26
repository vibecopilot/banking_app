class Vendor < ApplicationRecord

	belongs_to :supplier, class_name: 'GenericSubInfo', foreign_key: 'vendor_supplier_id', optional: true
  	belongs_to :category, class_name: 'GenericSubInfo', foreign_key: 'vendor_categories_id', optional: true



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
	          vendor = Vendor.find_or_initialize_by(id: row["Id"])
	          else
	          vendor = Vendor.new
	        end
	        vendor.vendor_name = row["Name"]
	        vendor.company_name = row["VendorCompanyName"]
	        vendor.mobile = row["MobileNumber"]
	        vendor.email = row["Email"]
	        vendor.notes = row["Notes"]
	        vendor.vtype = row["Type"]
	        if row["SiteName"].present?
	        	site = Site,find_by(name: row["SiteName"] )
	        	vendor.site_id = site.id
	        end
	        if !vendor.save
	          rowhs[:message] = vendor.errors
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
