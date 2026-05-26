  json.id @newuser.id
  json.email @newuser.email
  json.firstname @newuser.firstname
  json.lastname @newuser.lastname
  json.created_at @newuser.created_at
  json.updated_at @newuser.updated_at
  json.provider @newuser.provider
  json.uid @newuser.uid
  json.api_key @newuser.api_key
  json.user_type @newuser.user_type
  json.company_id @newuser.company_id
  json.mobile @newuser.mobile
  json.profession @newuser.profession
  json.moving_date @newuser.moving_date&.strftime("%d/%m/%Y")
  json.building_id @newuser.building_id
  json.floor_id @newuser.floor_id
  json.created_by_id @newuser.created_by_id
  
  # Add user_sites data
  json.user_sites @newuser.user_sites, partial: 'user_sites/user_site', as: :user_site
  json.unit_id @newuser.unit_id
  @unit = Unit.find_by(id: @newuser.unit_id)
  json.unit_name @unit.try(:name)
  if @unit
    json.unit do
      json.id @unit.id
      json.name @unit.name
      json.unit_configuration_id @unit.unit_configuration_id
      json.unit_configuration_name @unit.unit_configuration_name
      json.unit_configuration @unit.unit_configuration, :id, :name if @unit.unit_configuration
    end
  else
    json.unit nil
  end

  json.pets_details @newuser.pets, partial: "pets/pet", as: :pet
  json.user_vendor @newuser.user_vendors
  json.user_members @newuser.user_members
  json.vehicle_details @newuser&.vehicle_details
  json.full_unit_name @newuser.full_unit_name
  json.mgl_customer_number @newuser.mgl_customer_number
  json.adani_electricity_account_no @newuser.adani_electricity_account_no
  json.net_provider_name @newuser.net_provider_name
  json.net_provider_id @newuser.net_provider_id
  json.current_site_id @newuser.current_site_id
  json.rotary_club @newuser.rotary_club
  json.wedding_date @newuser.wedding_date&.strftime("%d/%m/%Y")
  json.business_name @newuser.business_name
  json.business_category @newuser.business_category
  json.education_qualification @newuser.education_qualification
  json.office_address @newuser.office_address
  json.rbm_by_id @newuser.rbm_by_id
  json.member_of_rmb @newuser.member_of_rmb
  json.facebook_link @newuser.facebook_link
  json.instagram_link @newuser.instagram_link
  json.linkedin_profile @newuser.linkedin_profile
  json.date_of_joining @newuser.date_of_joining&.strftime("%d/%m/%Y")
  json.blood_group @newuser.blood_group
  json.face_added @newuser.face_added
  json.user_face_url @newuser.profile_image
  json.active @newuser.active
  json.user_courtesy @newuser.user_courtesy
  json.user_phase @newuser.user_phase
  json.user_status @newuser.user_status
  json.building_id @newuser.building_id
  json.user_category_id @newuser.user_category_id
  json.user_address @newuser.user_address
  json.resident_type @newuser.resident_type
  json.membership_type @newuser.membership_type
  json.lives_here @newuser.lives_here
  json.allow_fitout @newuser.allow_fitout
  json.birth_date @newuser.birth_date
  json.anniversary @newuser.anniversary
  json.spouse_birth_date @newuser.spouse_birth_date
  json.email_1 @newuser.email_1
  json.email_2 @newuser.email_2
  json.landline_number @newuser.landline_number
  json.intercom_number @newuser.intercom_number
  json.gst_number @newuser.gst_number
  json.pan_number @newuser.pan_number
  json.ev_connection @newuser.ev_connection
  json.no_of_adults @newuser.no_of_adults
  json.no_of_childrens @newuser.no_of_childrens
  json.no_of_pets @newuser.no_of_pets
  json.differently_abled @newuser.differently_abled
  json.organization_id @newuser.organization_id
  json.vendor_id @newuser.vendor_id
  json.vendor_name @newuser.vendor&.vendor_name
  json.is_admin_approved @newuser&.is_admin_approved