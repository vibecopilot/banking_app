json.extract! pet, :id, :user_id, :pet_name, :owner_mobile_no, :pet_breed, :gender, :colour, :age, :dob, :is_pet_transfered, :brought, :stray_pet_adopted, :whether_brought_from_current_city, :pet_born_to_owner_dog, :is_approved, :approved_at, :rejection_reason, :approved_by_id,:created_at, :updated_at
json.url pet_url(pet, format: :json)

json.created_by pet.user&.full_name

json.approved_by pet.approved_by&.full_name

@docs_images = Attachfile.where("relation = 'PetsImage' and relation_id = ?", pet.id)
@docs_profile = Attachfile.where("relation = 'PetProfile' and relation_id = ?", pet.id)
json.documents do
      json.array!(@docs_images) do |doc|
        json.extract! doc, :id, :relation, :relation_id
        json.document doc.document_url
      end
end

json.documents do
      json.array!(@docs_profile) do |doc|
        json.extract! doc, :id, :relation, :relation_id
        json.document doc.document_url
      end
end