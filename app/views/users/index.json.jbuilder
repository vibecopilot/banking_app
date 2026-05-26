
json.array! @users do |user|
  json.id user.id
  json.email user.email
  json.firstname user.firstname
  json.lastname user.lastname
  json.full_name user.full_name
  json.position user.position
  json.created_at user.created_at
  json.updated_at user.updated_at
  json.provider user.provider
  json.uid user.uid
  json.api_key user.api_key
  json.user_type user.user_type
  json.company_id user.company_id
  json.mobile user.mobile
  json.device_type user.user_devices.map(&:device_type)
  json.device_name user.user_devices.map(&:device_name)
  json.is_downloaded user.user_devices.size > 1
  # Add user_sites data
  json.user_sites user.user_sites, partial: 'user_sites/user_site', as: :user_site

  # Fetch unit from user_sites if available
  user_site_unit = user.user_sites.first&.unit
  if user_site_unit

      # Include Building details (if present)
      if user_site_unit.building
        json.building do
          json.id user_site_unit.building.id
          json.name user_site_unit.building.name
        end
      end
      json.unit do
      json.id user_site_unit.id
      json.name user_site_unit.name
      json.floor_id user_site_unit.floor_id # Include floor_id directly
      # Include Floor details (if present)
    end
     if user_site_unit.floor
        json.floor do
          json.id user_site_unit.floor.id
          json.name user_site_unit.floor.name
        end
      end
  end

  json.user_vendor user&.user_vendors
  json.user_member user&.user_members
  json.pets_details user&.pets, partial: "pets/pet", as: :pet
  
  json.vehicle_details user&.vehicle_details

  if user.unit
  json.unit do
    json.id user.unit.id
    json.name user.unit.name
    json.floor_id user.unit.floor_id # Include floor_id directly

    # Include Floor details (if present)
    if user.unit.floor
      json.floor do
        json.id user.unit.floor.id
        json.name user.unit.floor.name
      end
    end
  end
end

  json.profession user.profession
  json.created_by_id user.created_by_id
  json.moving_date user.moving_date&.strftime("%d/%m/%Y")
  json.building_id user.building_id
  json.floor_id user.floor_id
  json.unit_id user&.unit_id  
  json.full_unit_name user.full_unit_name
  json.rotary_club user.rotary_club
  json.wedding_date user.wedding_date
  json.business_name user.business_name
  json.net_provider_id user.net_provider_id
  json.mgl_customer_number user.mgl_customer_number
  json.adani_electricity_account_no user.adani_electricity_account_no
  json.net_provider_name user.net_provider_name
  json.business_category user.business_category
  json.education_qualification user.education_qualification
  json.office_address user.office_address
  json.rbm_by_id user.rbm_by_id
  json.member_of_rmb user.member_of_rmb
  json.facebook_link user.facebook_link
  json.instagram_link user.instagram_link
  json.linkedin_profile user.linkedin_profile
  json.date_of_joining user.date_of_joining
  json.blood_group user.blood_group
  json.current_site_id user.current_site_id
  json.face_added user.face_added
  json.user_face_url user.profile_image
  json.active user.active
  json.user_courtesy user.user_courtesy
  json.user_phase user.user_phase
  json.user_status user.user_status
  json.building_id user.building_id
  json.user_category_id user.user_category_id
  json.user_address user.user_address
  json.resident_type user.resident_type
  json.membership_type user.membership_type
  json.lives_here user.lives_here
  json.allow_fitout user.allow_fitout
  json.birth_date user.birth_date
  json.anniversary user.anniversary
  json.spouse_birth_date user.spouse_birth_date
  json.email_1 user.email_1
  json.email_2 user.email_2
  json.landline_number user.landline_number
  json.intercom_number user.intercom_number
  json.gst_number user.gst_number
  json.pan_number user.pan_number
  json.ev_connection user.ev_connection
  json.no_of_adults user.no_of_adults
  json.no_of_childrens user.no_of_childrens
  json.no_of_pets user.no_of_pets
  json.differently_abled user.differently_abled
  json.organization_id user.organization_id
  json.vendor_id user.vendor_id
  json.vendor_name user.vendor&.vendor_name
  json.is_admin_approved user&.is_admin_approved
  json.helpdesk_category_id user.helpdesk_category_id
  json.helpdesk_sub_category_id user.helpdesk_sub_category_id
  json.category_name user.helpdesk_category&.name
  json.sub_category_name user.helpdesk_sub_category&.name
end


# json.array! @users do |user|
#   json.id user.id
#   json.email user.email
#   json.firstname user.firstname
#   json.lastname user.lastname
#   json.created_at user.created_at
#   json.updated_at user.updated_at
#   json.provider user.provider
#   json.uid user.uid
#   json.api_key user.api_key
#   json.user_type user.user_type
#   json.company_id user.company_id
#   json.mobile user.mobile

#   # Add user_sites data
#   json.user_sites user.user_sites, partial: 'user_sites/user_site', as: :user_site

#   # Fetch unit from user_sites if available
#   user_site_unit = user.user_sites.first&.unit
#   if user_site_unit
#     json.units do
#       json.id user_site_unit.id
#       json.name user_site_unit.name
#       json.floor_id user_site_unit.floor_id # Include floor_id directly

#       # Include Building details (if present)
#       if user_site_unit.building
#         json.building do
#           json.id user_site_unit.building.id
#           json.name user_site_unit.building.name
#         end
#       end

#       # Include Floor details (if present)
#       if user_site_unit.floor
#         json.floor do
#           json.id user_site_unit.floor.id
#           json.name user_site_unit.floor.name
#         end
#       end
#     end
#   end

#   json.current_site_id user.current_site_id
#   json.face_added user.face_added
#   json.user_face_url user.user_face_url
#   json.active user.active
#   json.user_courtesy user.user_courtesy
#   json.user_phase user.user_phase
#   json.user_status user.user_status
#   json.building_id user.building_id
#   json.user_category_id user.user_category_id
#   json.user_address user.user_address
#   json.resident_type user.resident_type
#   json.membership_type user.membership_type
#   json.lives_here user.lives_here
#   json.allow_fitout user.allow_fitout
#   json.birth_date user.birth_date
#   json.anniversary user.anniversary
#   json.spouse_birth_date user.spouse_birth_date
#   json.email_1 user.email_1
#   json.email_2 user.email_2
#   json.landline_number user.landline_number
#   json.intercom_number user.intercom_number
#   json.gst_number user.gst_number
#   json.pan_number user.pan_number
#   json.ev_connection user.ev_connection
#   json.no_of_adults user.no_of_adults
#   json.no_of_childrens user.no_of_childrens
#   json.no_of_pets user.no_of_pets
#   json.differently_abled user.differently_abled
#   json.organization_id user.organization_id
#   json.vendor_id user.vendor_id
#   json.vendor_name user.vendor&.vendor_name
# end
