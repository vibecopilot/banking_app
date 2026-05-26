object @helpdesk_category
attributes :id, :society_id, :name, :position, :created_at, :updated_at
node :icon_url do root_object.icon.present? ? (root_object.icon.url) : "" end
node :doc_type do root_object.icon_content_type end