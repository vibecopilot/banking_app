if payment
  json.extract! payment, :id, :resource_id, :resource_type, :total_amount, :paid_amount, :user_id, :payment_method, :transaction_id, :paymen_date, :created_at, :updated_at, :notes
  json.url payment_url(payment, format: :json)
else
  json.null!
end
