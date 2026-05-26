class EscHistory < ApplicationRecord
	default_scope { where(eof: "EscalationMatrix") }
	serialize :esc_to 
	belongs_to :escalation_matrix, :foreign_key => :esc_id, class_name: "EscalationMatrix"
end
