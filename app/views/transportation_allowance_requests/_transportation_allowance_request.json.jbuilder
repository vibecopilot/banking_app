json.extract! transportation_allowance_request, :id, :employee_name, :mobile_no, :employee_id, :expense_category, :date_of_expense, :description_of_expense, :amount_spent, :approval_status, :reimbursement_amount, :reimbursement_method, :manager_approval, :reimbursement_confirmation_email, :created_at, :updated_at
@attached_files = Attachfile.where(relation: 'TransportationAllowanceRequest', relation_id: transportation_allowance_request.id)
json.attachments do
  json.array! @attached_files do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end
json.url transportation_allowance_request_url(transportation_allowance_request, format: :json)
