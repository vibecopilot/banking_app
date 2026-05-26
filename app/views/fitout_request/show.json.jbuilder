json.extract! @fitout_request, :id, :unit_id, :user_id, :description, :selected_date, :created_at, :building_id, :floor_id, :supplier_id

if @fitout_request.supplier
  json.supplier do
    json.extract! @fitout_request.supplier, :id, :vendor_name, :company_name, :email, :mobile
  end
else
  json.supplier nil
end

json.fitout_request_categories @fitout_request.fitout_request_categories do |category|
  json.extract! category, :id, :name

  json.attachfile do
    if category.attachfile
      json.extract! category.attachfile, :id, :relation, :relation_id
      json.document_url category.attachfile.document_url
    else
      json.nil!
    end
  end

  json.category_type do
    if category.category_type
      json.extract! category.category_type, :id, :name
    else
      json.nil!
    end
  end
end

if @fitout_request.unit
  json.unit do
    json.partial! 'units/unit_associate', unit: @fitout_request.unit
  end
else
  json.unit nil
end
