require 'recognition_processor'

class Recognition
  attr_reader :bucket, :recognition_processor

  def initialize(args = {})
    @recognition_processor = RecognitionProcessor.new(collection_id: 'collection-faces')
    @bucket                = args[:bucket]
  end

  def recognize(image_name)
    recognition_processor.recognize(image_name, bucket_objects)
  end

  private

  def bucket_objects
    bucket.get_objects
  end
end