json.total_pages @visitors.total_pages
json.current_page @visitors.current_page
json.total_count @visitors.total_entries
#json.per_page @visitors.per_page

json.visitors do
  json.array! @visitors do |visitor|
    json.id visitor.id
    json.name visitor.name
    json.no_of_goods visitor.no_of_goods
    json.contact_no visitor.contact_no
    json.purpose visitor.purpose
    json.site_id visitor.site_id
    json.coming_from visitor.coming_from
    json.vehicle_number visitor.vehicle_number
    json.expected_date visitor&.expected_date
    json.verified visitor.verified
    json.pass_start_date visitor&.pass_start_date
    json.pass_end_date visitor&.pass_end_date
    json.driving_license visitor.driving_license
    json.consignment_form visitor.consignment_form

    json.hosts visitor.hosts do |host|
      json.id host.id
      json.user_id host.user_id
      json.is_approved host.is_approved
      json.full_name host.user&.full_name
      json.mode_of_approval host&.approval_mode || "--"
  #      user_site = host.user.user_sites.find_by(is_approved: true)

  # if user_site
  #   building_name = user_site.unit&.building&.name
  #   unit_name     = user_site.unit&.name
  #   json.unit_name "#{building_name}-#{unit_name}"
  # else
  #   json.unit_name nil
  # end
  user_site = host.user&.user_sites&.find_by(user_id: host.user_id) # or .first

  if user_site
    building = user_site.unit&.building&.name
    floor    = user_site.unit&.floor&.name
    unit     = user_site.unit&.name

    # json.building_name building
    # json.floor_name floor
    # json.unit_name unit
    json.unit_name "#{building}-#{floor}-#{unit}"
  else
    json.building_name nil
    json.floor_name nil
    json.unit_name nil
    json.full_address nil
   end
  end

    json.otp visitor.otp
    if visitor.goods_in_out.present?
      json.goods_in_out do
        json.id visitor.goods_in_out.id
        json.no_of_goods visitor.goods_in_out.no_of_goods
        json.description visitor.goods_in_out.description
        json.no_of_goods visitor.no_of_goods
        json.goods_files visitor.goods_in_out.goods_files do |goods_file|
          json.id goods_file.id
          json.original_url goods_file.image.url(:original)
        end
      end
    end

    json.expected_time visitor.expected_time&.strftime("%H:%M:%S")

    json.skip_host_approval !!visitor.skip_host_approval
    json.goods_inwards !!visitor.goods_inwards
    json.visit_type visitor.visit_type
    json.frequency visitor.frequency
    json.working_days visitor.working_days
    json.status visitor.hosts.pluck(:is_approved).uniq.one? ? visitor.hosts.first.is_approved : nil

    created_by_user = User.find_by(id: visitor.created_by_id)
    json.created_by_id visitor.created_by_id
    json.created_by_name created_by_user&.slice(:firstname, :lastname)
    json.user_type created_by_user&.user_type

    json.start_pass visitor.start_pass
    json.end_pass visitor.end_pass
    json.pass_number visitor.pass_number
    json.created_at visitor.created_at
    json.updated_at visitor.updated_at
    json.visitor_in_out visitor.visitor_in_out

    if visitor.visitor_cards.present?
      json.card_id visitor.visitor_cards.first.card_id
    else
      json.card_id nil
    end

    last_visit = visitor.visitor_visits.last
     json.in_out_time =
     if last_visit&.check_out.present?
      last_visit.check_out.strftime("%d-%m-%Y %H:%M")
     elsif last_visit&.check_in.present?
      last_visit.check_in.strftime("%d/%m/%y %H:%M")
     end
     
    json.parking_slot ParkingConfiguration.find_by(id: visitor.parking_slot)&.name
    json.visits_log visitor.visitor_visits do |visit|
      json.visitor_id visit.visitor_id if visit.check_in.present?
      json.check_in visit.check_in if visit.check_in.present?
      json.check_out visit.check_out if visit.check_out.present?
    end

    json.visitor_staff_category do
      json.id visitor.visitor_staff_category.id
      json.name visitor.visitor_staff_category.name
    end if visitor.visitor_staff_category.present?

    json.extra_visitors visitor.extra_visitors do |extra_visitor|
      json.id extra_visitor.id
      json.name extra_visitor.name
      json.contact_no extra_visitor.contact_no
      json.created_at extra_visitor.created_at
      json.updated_at extra_visitor.updated_at
    end

    json.qr_code_image_url visitor.qr_code_image.try(:document_url)
    if visitor.parent_id.present?
      parent_visitor = Visitor.find_by(id: visitor.parent_id)
      json.profile_picture parent_visitor.profile_pic&.image&.url
    else
      json.profile_picture visitor.profile_pic&.image&.url
    end

    json.visitor_files visitor.visitor_files do |doc|
      json.id doc.id
      json.relation doc.relation
      json.relation_id doc.relation_id
      json.category_type doc.category_type
      json.document doc.document_url
    end

     json.visitor_license visitor.visitor_license do |doc|
       json.id doc.id
       json.relation doc.relation
       json.relation_id doc.relation_id
       json.category_type doc.category_type
       json.document doc.document_url
     end

     json.visitor_consignment visitor.visitor_consignment do |doc|
       json.id doc.id
       json.relation doc.relation
       json.relation_id doc.relation_id
       json.category_type doc.category_type
       json.document doc.document_url
     end

    json.url visitor_url(visitor, format: :json)
  end
end
