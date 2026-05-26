class FoodAndBeverage < ApplicationRecord
  has_many :blocked_days, class_name: "BlockedDay", foreign_key: "restaurant_id", dependent: :destroy
  accepts_nested_attributes_for :blocked_days, allow_destroy: true
  belongs_to :user , class_name: "User" ,foreign_key: :created_by_id
  belongs_to :site , class_name: "Site" ,foreign_key: :site_id,optional:true

  # ---- F&B Setup associations -------------------------------------------
  has_many :restaurant_floors,     dependent: :destroy
  has_many :restaurant_tables,     dependent: :destroy
  has_many :restaurant_categories, dependent: :destroy
  has_many :restaurant_cuisines,   dependent: :destroy
  has_many :restaurant_menus,      foreign_key: :restaurant_id, dependent: :destroy

  accepts_nested_attributes_for :restaurant_floors,     allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :restaurant_tables,     allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :restaurant_categories, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :restaurant_cuisines,   allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :restaurant_menus,      allow_destroy: true, reject_if: :all_blank

  serialize :restaurant_schedule, JSON
  serialize :payment_methods,     JSON


  has_one :logo, -> { where(relation: "FBLogo") }, foreign_key: :relation_id, class_name: "Attachfile", dependent: :destroy
  has_many :gallery_images, -> { where(relation: "FoodAndBeveragesGalleryImage") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :menu_images, -> { where(relation: "FoodAndBeveragesMenuImage") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :other_files, -> { where(relation: "FoodAndBeveragesOtherFile") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :menu_pdf, -> { where(relation: "FoodAndBeveragesMenuPdf") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :cover_images, -> { where(relation: "FoodAndBeveragesCoverImage") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :attachfiles, -> { where(relation: "FoodAndBeveragesCoverImage") }, foreign_key: :relation_id, class_name: "Attachfile"

  def initialize_restaurant_schedule
    self.restaurant_schedule ||= {}
    Date::DAYNAMES.each do |day|
      self.restaurant_schedule[day] ||= { 'selected' => false, 'start_time' => '', 'end_time' => '', 'booking_allowed' => false, 'order_allowed' => false }
    end
  end

  def filtered_restaurant_schedule
    if restaurant_schedule.present?
      restaurant_schedule.select do |day, times|
        times['start_time'].present? && times['end_time'].present?
      end
    end
  end

  def cuisines
    value = read_attribute(:cuisines)
    return [] if value.blank?
    return value if value.is_a?(Array)

    JSON.parse(value)
  rescue JSON::ParserError, TypeError
    value.to_s.split(',').map(&:strip).reject(&:blank?)
  end

  def cuisines=(value)
    parsed_value = value.is_a?(String) ? (JSON.parse(value) rescue value) : value
    write_attribute(:cuisines, Array(parsed_value).reject(&:blank?).to_json)
  end

  def blocked_days_for_date?(date, type: :booking)
    blocked_days.any? do |bd|
      date_range = bd.start_date..(bd.end_date || bd.start_date)
      date_range.cover?(date) &&
        (type == :booking ? !bd.booking_allowed : !bd.order_allowed)
    end
  end

  def table_available?(table_name, date: Date.today)
    running = RestaurantOrder.where(restaurant_id: id, ondate: date)
                             .where(status: ["Running", "Billed"])
                             .where(table_number: table_name.to_s)
                             .exists?
    !running
  end

end
