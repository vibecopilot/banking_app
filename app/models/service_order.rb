class ServiceOrder < ApplicationRecord
	belongs_to :vendor
	has_many :loi_services
	belongs_to :site, optional: true
	before_save :generate_pr_no

  	private

  	def generate_pr_no
  		#binding.pry
  		generic_code = GenericInfo.find_by(site_id: site_id, info_type: 'Generate_Service_No')
  		codeval = generic_code.try(:name) || ""
  		if generic_code
  			sub_generic_code =  generic_code.generic_sub_infos.try(:first)
  			new_val = (sub_generic_code.try(:name).present? ? (sub_generic_code.try(:name).to_i + 1) : self.id)
			self.pr_no = codeval.to_s + new_val.to_s
			if sub_generic_code.present?
				sub_generic_code.update(name: new_val)
			end
		else
			self.pr_no = "PR-#{self.id}"
		end		
  	end


#   	def get_generic_code
#   		#binding.pry
#   		generic = GenericInfo.find_by(site_id: site_id, info_type: 'Generate_Service_No')
#   		if generic
#     		name_to_number(generic.name) % 10000
#   		else
#     		0
#   		end
#   	end

#   	def get_sub_generic_code(generic_code)
#   		#binding.pry
#   		sub_generic = GenericSubInfo.find_by(generic_info_id: GenericInfo.find_by(site_id: site_id, info_type: 'Generate_Service_No')&.id)
#   		base_code = if sub_generic
#     		name_to_number(sub_generic.name) % 10000
#   		else
#     		1
#   		end

#   		# loop.reduce(base_code) do |code|
#   		# 	pr_number = "PR-#{generic_code}-#{code}"
#      	# 	existing_order = ServiceOrder.find_by(pr_no: pr_number)

#      	# 	break code unless existing_order

#       	# 	((code.to_i + 1) % 10000).to_s.rjust(4, '0')
#     	# end
#     	loop do
#     		pr_number = "-#{generic_code.to_s.rjust(4, '0')}-#{base_code.to_s.rjust(4, '0')}"
#     		existing_order = ServiceOrder.find_by(pr_no: pr_number)
#     	break base_code unless existing_order
#    			base_code = (base_code + 1) % 10000
# 		end
#   	end

# 	def name_to_number(name)
# 	  name.downcase.chars.map { |c| c.ord - 96 if c.between?('a', 'z') }
# 	    .compact
# 	    .join
# 	    .to_i
# 	end
end
