class Bucket
  attr_reader :name, :client

  def initialize(args = {})
    @client = Aws::S3::Client.new(region: 'ap-south-1')
    @name   = args[:name]
  end

  def get_objects
    client.list_objects_v2({
      bucket: name,
    })
  end
end