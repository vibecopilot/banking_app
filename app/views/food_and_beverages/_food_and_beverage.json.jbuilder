json.extract! food_and_beverage,
  :id, :restaurant_name, :cost_for_two, :mobile_number,
  :alternate_mobile_number, :landline_number, :delivery_time, :cuisines,
  :serves_alcohols, :wheelchair_accessible, :cash_on_delivery, :pure_veg,
  :address, :terms_and_conditions, :disclaimer, :closing_message,
  :minimum_person, :maximum_person, :cancel_before,
  :serviceCharges, :gst, :delivery_charges, :convenience_fee, :minimum_order,
  :status, :site_id, :created_by_id, :created_at, :updated_at,
  :mon, :tue, :wed, :thu, :fri, :sat, :sun,
  :booking_allowed, :order_allowed,
  :last_booking_time, :table_booking_start_date, :table_number,
  :table_booking_end_date, :table_booking_start_time, :table_booking_end_time,
  :booking_capacity, :waiting_capacity, :booking_not_available_text,
  :food_and_beverages_availability, :start_time, :end_time,
  :order_not_allowed_text, :restauranttype,
  :break_end_time, :break_start_time,
  :email, :gst_number, :license_number, :fssai_number,
  :location_branch, :delivery_zone, :service_radius,
  :tax_type, :area_type,
  :payment_methods, :gpay_upi, :phonepe_upi, :paytm_upi,
  :razorpay_enabled, :razorpay_key, :razorpay_secret,
  :restaurant_schedule, :cuisins_id

# if food_and_beverage.restaurant_cuisines.present?
#   cuisine_ids = JSON.parse(food_and_beverage.restaurant_cuisines) rescue []
#   # @cuisun = GenericInfo.where(id: cuisine_ids)
#   json.restaurant_cuisines @cuisun.map(&:name).join(',')
# else
#   json.cuisines ''
# end

json.cuisines food_and_beverage.cuisines || []
json.restaurant_cuisines food_and_beverage.restaurant_cuisines do |cuisine|
  json.id cuisine.id
  json.name cuisine.name
  json.custom cuisine.custom
end

json.restaurant_floors food_and_beverage.restaurant_floors do |floor|
  json.id floor.id
  json.name floor&.name
end

json.restaurant_tables food_and_beverage.restaurant_tables do |tables|
  json.id tables.id
  json.restaurant_floor_id tables.restaurant_floor_id
  json.restaurant_floor_name tables.restaurant_floor&.name
  json.table_name tables&.name
  json.capacity tables.capacity
end

json.restaurant_menus food_and_beverage.restaurant_menus do |menu|
  json.extract! menu, :id, :restaurant_id, :name, :sku, :price, :active,
                :category_id, :sub_category_id, :description, :master_price,
                :category_name, :selected, :prep_time, :spice_level, :is_favorite,
                :created_at, :updated_at
  json.image_url menu.menu_image&.document_url
end

json.restaurant_categories food_and_beverage.restaurant_categories do |category|
  json.id category.id
  json.name category.name
  json.custom category.custom
end

json.created_by_name User.find_by(id: food_and_beverage.created_by_id)&.slice(:firstname, :lastname)
json.site_name Site.find_by(id: food_and_beverage&.site_id)&.name

if food_and_beverage.restaurant_schedule.present?
  boolean = ActiveModel::Type::Boolean.new
  json.restaurant_schedule do
    food_and_beverage.restaurant_schedule&.each do |day, schedule|
      next unless schedule.present?

      json.set! day do
        json.selected boolean.cast(schedule['selected'])
        json.start_time schedule['start_time']
        json.end_time schedule['end_time']
        json.booking_allowed boolean.cast(schedule['booking_allowed'])
        json.order_allowed boolean.cast(schedule['order_allowed'])
      end
    end
  end
end

json.blocked_days do
  json.array! food_and_beverage.blocked_days&.map do |block_day|
    json.partial! "blocked_days/blocked_day", blocked_day: block_day
  end
end

@attachments = Attachfile.where(relation: 'FoodAndBeveragesDocument', relation_id: food_and_beverage.id)
json.food_and_beverages_attachments do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

# Add cover images
@cover_images = Attachfile.where(relation: 'FoodAndBeveragesCoverImage', relation_id: food_and_beverage.id)
json.cover_images do
  json.array!(@cover_images) do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end

# Add menu images
@menu_images = Attachfile.where(relation: 'FoodAndBeveragesMenuImage', relation_id: food_and_beverage.id)
json.menu_images do
  json.array!(@menu_images) do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end

# Add gallery images
@gallery_images = Attachfile.where(relation: 'FoodAndBeveragesGalleryImage', relation_id: food_and_beverage.id)
json.gallery_images do
  json.array!(@gallery_images) do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end


json.other_files food_and_beverage.other_files do |ot_f|
  json.extract! ot_f, :id, :relation, :relation_id
  json.other_file_url ot_f.document_url
end

json.menu_pdf food_and_beverage.menu_pdf do |pdf|
  json.id pdf.id
  json.url pdf.document_url
end

json.logo food_and_beverage&.logo&.document_url 


json.url food_and_beverage_url(food_and_beverage, format: :json)
