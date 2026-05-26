class CostApproval < ApplicationRecord

	validates :resource_id, :resource_type, :related_to, presence: true
	validate :validate_cost_range
	belongs_to :resource, polymorphic: true
	belongs_to :category, foreign_key: :category_id, class_name: "HelpdeskCategory", optional: true
	has_many :cost_approval_levels, dependent: :destroy

	accepts_nested_attributes_for :cost_approval_levels, reject_if: :all_blank, allow_destroy: true

	scope :approvals_for, -> (company_id) {where(resource_type: 'Pms::CompanySetup', resource_id: company_id)}
	scope :fm,-> {where(related_to: 'FM')}
	scope :project, -> {where(related_to: 'Project')}

	scope :active, -> {where(active: true)}

	scope :applicable_approvals, -> (related_to, level) {where(related_to: related_to, level: level)}


	def cost_range
  	if self.cost_unit == "between"
	    "#{self.cost_from} - #{self.cost_to}"
	    elsif self.cost_unit == "greater_than"
	    	"> #{cost_to}"
	    elsif self.cost_unit == "greater_than_equal"
	      ">= #{cost_to}"
	    end
	 end


	def self.matched_cost_approval_for(cost)
		cost_approval_id = nil
		all.each do |ca|
			if ca.cost_unit == 'between' && cost.between?(ca.cost_from, ca.cost_to)
				cost_approval_id = ca.id
			elsif ca.cost_unit == 'greater_than' && cost > ca.cost_to
				cost_approval_id = ca.id
			elsif ca.cost_unit == 'greater_than_equal' && cost >= ca.cost_to
				cost_approval_id = ca.id
			end
		end
		cost_approval_id 	 
	end


	def validate_cost_range
    ca = CostApproval.active.applicable_approvals(self.related_to, "user_level").approvals_for(self.resource_id).order(created_at: :desc).limit(1).last
	  if ca.present?	
	  	if self.cost_unit == 'between' && self.cost_from <= ca.cost_to
			errors.add :base , "Cost approval rule created should be greater than last added cost."
	  	elsif self.cost_to <= ca.cost_to
	  		errors.add :base , "Cost approval rule created should be greater than last added cost."
	  	end
	 end
  end

end
