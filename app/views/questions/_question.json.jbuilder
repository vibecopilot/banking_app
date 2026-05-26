json.extract! question, 
  :id, :checklist_id, :name, :qtype, 
  :option1, :value_type1, :option2, 
  :value_type2, :option3, :value_type3, 
  :option4, :value_type4, :question_mandatory, 
  :image_mandatory, :created_at, :updated_at, 
  :help_text,:weightage,  :help_text_enbled,:rating,:reading,:group_id
  json.group question.group.try(:name)
file = question.hint_attachment
json.helptext_image file.document_url if file.present?
