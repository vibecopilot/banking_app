class Transportation < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id', optional: true	

  def as_json(options = {})
    super(options.merge(
      methods: [:user_full_name, :created_by_full_name]
    ))
  end

  def user_full_name
    user&.full_name
  end

  def created_by_full_name
    created_by&.full_name
  end

end

=begin
class User < ApplicationRecord
  has_many :transportations
  has_many :created_transportations, class_name: 'Transportation', foreign_key: 'created_by_id'
end
	
=end