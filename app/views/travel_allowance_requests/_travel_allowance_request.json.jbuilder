json.extract! travel_allowance_request, :id, :employee_id, :employee_name, :expense_category, :date_of_expense, :amount_spent, :approval_status, :reimbursement_amount, :reimbursement_method, :manager_approval, :reimbursement_confirmation_email, :description_of_expense, :created_at, :updated_at,:mobile_no
json.url travel_allowance_request_url(travel_allowance_request, format: :json)

@cover_images = Attachfile.where(relation: 'TravelAllowanceRequest', relation_id: travel_allowance_request.id)
json.attachments do
  json.array!(@cover_images) do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
  