json.extract! user_device, :id, :user_id, :device_id, :device_type, :gcm_key, :device_name, :device_os_version, :ios_sound, :app_id, :call, :full_screen ,:created_at, :updated_at
json.url user_device_url(user_device, format: :json)
