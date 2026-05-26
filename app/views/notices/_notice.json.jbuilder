json.extract! notice, :id, :site_id, :enabled ,:notice_title, :status, :send_email ,:notice_discription, :expiry_date, :created_at, :updated_at, :shared, :group_id, :important
json.url notice_url(notice, format: :json)
json.created_by notice&.user&.full_name
json.created_by_id notice&.created_by_id
json.notice_discription ActionController::Base.helpers.sanitize(
  notice.notice_discription,
  tags: %w[p br strong em a ul ol li h1 h2 h3 h4 h5 h6],
  attributes: %w[href target rel]
)
json.group_name notice&.group&.group_name
json.site_name notice.site&.name
json.users do
  json.array!(notice.notice_users) do |notice_user|
    json.extract! notice_user, :id, :user_id, :notice_id
    json.name notice_user&.user&.full_name
  end
end
@attachments = Attachfile.where("relation = 'NoticeImaage' and relation_id = ?", notice.id)
json.notice_image do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document_url doc.document_url
  end
end