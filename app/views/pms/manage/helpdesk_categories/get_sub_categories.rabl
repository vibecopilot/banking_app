object false
node :assigned_to do @assigned_to  end
child(@sub_categories => :sub_categories) do
  object @sub_categories
	attributes :id, :helpdesk_category_id, :name, :position, :helpdesk_text, :created_at, :updated_at
end
