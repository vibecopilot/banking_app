class RecognitionProcessor
  attr_reader :client, :collection_id


  def initialize(args = {})
    @collection_id = args[:collection_id] || 'vibefms'
    @client        = Aws::Rekognition::Client.new(region: "ap-southeast-1",:access_key_id => ENV.fetch('AWS_ACCESS_KEY_ID'), :secret_access_key => ENV.fetch('AWS_SECRET_ACCESS_KEY'))
  end

  def create_collection
    client.create_collection({collection_id: collection_id}) unless collection_exists?
  end

  def collection_exists?
    client.list_collections.collection_ids.include? collection_id
  end

  def index_faces_from(bucket_objects)
    bucket_objects.contents.each do |object|
      index_faces(object_file_name: object.key, bucket_name: bucket_objects.name)
    end
  end

  def compare_faces_with_file(file)
    client.create_collection({collection_id: collection_id}) unless collection_exists?
    client.search_faces_by_image({
      collection_id: collection_id,
      face_match_threshold: 85,
      image: { bytes: file },
      max_faces: 3,
    })
  end

  # private
  def delete_face(faceid)
    client.delete_faces({
        collection_id: collection_id, 
        face_ids: [
          faceid
        ], 
      })
  end

  def index_faces(args = {})
    client.index_faces({
      collection_id: collection_id,
      detection_attributes: [
      ],
      external_image_id: get_name_from(args[:object_file_name]),
      image: {
        s3_object: {
          bucket: args[:bucket_name],
          name: args[:object_file_name],
        },
      },
    })
  end

  def get_name_from(file_name)
    # file_name.gsub(/\.(.*)/, '')
    file_name
  end


  def add_user_face(args = {})
    @object = User.find_by(id: args[:user_id])
    isadded = RecognitionProcessor.new(collection_id: collection_id).compare_faces_with_file(args[:face])
    if isadded.face_matches.count > 0
      eid = isadded.face_matches[0].face.external_image_id
      puts isadded
      RecognitionProcessor.new(collection_id: collection_id).delete_face(isadded.face_matches[0].face.face_id)
      puts 'delwted'
    end
    @s3 = Aws::S3::Resource.new(region:'ap-southeast-1',:access_key_id => ENV.fetch('AWS_ACCESS_KEY_ID'), :secret_access_key => ENV.fetch('AWS_SECRET_ACCESS_KEY'))
    key = "#{@object.id}"
    obj = @s3.bucket(args[:bucket_name] || "vibeface").object(key)
    local_path = args[:face].path
    obj.upload_file(local_path)
    RecognitionProcessor.new(collection_id: collection_id).index_faces(object_file_name: @object.id.to_s, bucket_name: (args[:bucket_name] || "vibeface"))
    bsf = Attachfile.create(image: args[:face], relation: "User", relation_id: @object.id, active: 1)
    @object.update_columns(face_added: true, user_face_url: bsf.document_url)
  end

end