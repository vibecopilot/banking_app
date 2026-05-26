class Task < ApplicationRecord
  ransacker :search do |parent|
    adapter = ActiveRecord::Base.connection.adapter_name.downcase

    fields = [
      parent.table[:id],
      parent.table[:name],
      parent.table[:description],
      parent.table[:status]
    ]

    if adapter =~ /mysql|maria/
      segments = []
      fields.each_with_index do |field, index|
        segments << field
        segments << Arel.sql("' '") unless index == fields.size - 1
      end
      Arel::Nodes::NamedFunction.new('CONCAT', segments)
    else
      concatenated = fields.shift
      fields.each do |field|
        concatenated = Arel::Nodes::InfixOperation.new(
          '||',
          concatenated,
          Arel::Nodes::InfixOperation.new('||', Arel.sql("' '"), field)
        )
      end
      concatenated
    end
  end

	belongs_to :project
	has_many :comments
	validates_presence_of :name
	default_scope { order("priority asc, tat asc") } 
end
