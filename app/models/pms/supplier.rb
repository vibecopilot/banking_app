class Pms::Supplier < ApplicationRecord

  validates :company_name, presence: true, if: proc{|o| o.site_id.present? }
  validates_uniqueness_of :company_name, :scope => :site_id, if: proc{|o| o.site_id.present? }
  has_many :pms_grns, class_name: "Pms::Grn" , foreign_key: "supplier_id"
  has_many :pms_purchase_orders, class_name:"Pms::PurchaseOrder",foreign_key:"pms_supplier_id"
  has_many :pms_work_orders, class_name:"Pms::WorkOrder",foreign_key:"pms_supplier_id"
  belongs_to :company, class_name: "Pms::CompanySetup", foreign_key: "company_id"
  has_many :pms_text_fields, class_name: "Pms::TextField", as: :customizable
  has_many :pms_assets, class_name: "Pms::Asset", foreign_key: "pms_supplier_id"
  has_many :complaints
  has_many :custom_forms, class_name: "Pms::CustomForm", foreign_key: "supplier_id"
  has_many :occurrences, through: :custom_forms
  has_many :ratings, through: :occurrences
  has_many :work_order_invoices, through: :pms_work_orders
  has_many :bills, foreign_key: "supplier_id"
  has_many :pms_supplier_contacts, class_name: "PmsSupplierContact",foreign_key: "supplier_id"
  has_many :attachments, -> { where(relation: "Pms::Supplier") }, :foreign_key => :relation_id, class_name: "Attachfile"

  accepts_nested_attributes_for :pms_text_fields, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :pms_supplier_contacts, reject_if: :all_blank, allow_destroy: true

  serialize :supplier_type, JSON

  scope :ppm_suppliers , -> (company_id) { where("supplier_type is null or supplier_type like ? or supplier_type like ? and company_id = ?", "%Manu%", "%PPM%", company_id) }
  scope :amc_suppliers, -> (company_id) { where("supplier_type is null or supplier_type like ? and company_id = ?", "%AMC%", company_id) } 

  def name
		company_name || first_name.try(:to_s).try(:concat, " ").try(:concat, last_name)
	end

  def name_with_supplier
    "#{company_name} - #{self.email}"
  end

  def firstname
    company_name || first_name
  end

  def full_name
    name
  end

  def self.active
    where("active is true or active !=0")
  end

  def po_outstanding_amount
    pms_purchase_orders.where(letter_of_indent: false).map(&:outstanding_amount).sum
  end

  def wo_outstanding_amount
    pms_work_orders.where(letter_of_indent: false).map(&:outstanding_amount).sum
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
        id = nil
        id = row["Id"] if row["Id"]
        if row['SiteId'].present? && user.allowed_sites.pluck(:id).include?(row['SiteId'].to_i)
          supplier = Pms::Supplier.find_or_initialize_by(company_name: row["CompanyName"], site_id: row['SiteId'])
          supplier.email = row["Email"]
          supplier.mobile1 = row["Phone"]
          supplier.mobile2 = row["AlternatePhone"]
          supplier.gstin_number = row["Gst"]
          supplier.pan_number = row["Pan"]
          supplier.supplier_type = row["SupplierType"].split(",") if row["SupplierType"].present?
          supplier.company_id = user.company_id
          supplier.country = row["Country"]
          supplier.state = row["State"]
          supplier.city = row["City"]
          supplier.pincode = row["Pincode"]
          supplier.address = row["AddressLine1"]
          supplier.address2 = row["AddressLine2"]
          supplier.active = true
          if supplier.save
            startc = nil
            10.times do |s|
              startc = startc || 13
              endc = startc + 5
              rown = Hash[[header[startc..endc], spreadsheet.row(i)[startc..endc]].transpose]
              supplier_contact = supplier.pms_supplier_contacts.find_or_initialize_by(email1: rown['PrimaryEmail'])
              supplier_contact.first_name = rown['FirstName']
              supplier_contact.last_name = rown['LastName']
              supplier_contact.email2 = rown['SecondaryEmail']
              supplier_contact.mobile1 = rown['PrimaryPhone']
              supplier_contact.mobile2 = rown['SecondaryPhone']
              supplier_contact.active = true
              supplier_contact.save
              startc = endc + 1
            end
            rowhs[:message] = "success"
          else
            rowhs[:message] = supplier.errors
          end
        end
      rescue Exception => e
        rowhs[:error] = e.to_s
      end
      rowcomp << rowhs
    end
    return rowcomp
  end

  def avarage_rating
    total_ratings = ratings.where.not(ratings: nil)
    (total_ratings.sum(:ratings) / total_ratings.count) if total_ratings.present?
  end

  def name_with_email
    "#{name} -- #{email}"
  end

end
