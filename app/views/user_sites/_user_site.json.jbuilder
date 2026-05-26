# app/views/user_sites/_user_site.json.jbuilder
unit = user_site.unit
building = unit&.building
floor = unit&.floor

json.id user_site.id
json.user_id user_site.user_id
json.site_id user_site.site_id
json.unit_id user_site.unit_id
json.build_id user_site.build_id || user_site.unit&.building_id
json.floor_id user_site.floor_id || user_site.unit&.floor_id
json.ownership user_site.ownership
json.ownership_type user_site.ownership_type
json.is_approved user_site.is_approved
json.lives_here user_site.lives_here

json.hierarchy "#{unit&.building&.name} - #{unit&.floor&.name} - #{unit&.name} "
