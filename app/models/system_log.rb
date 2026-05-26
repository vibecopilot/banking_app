class SystemLog < ApplicationRecord
	belongs_to :user, class_name: "Spree::User", foreign_key: :changed_by
	serialize :changed_attr
	def self.newlog(obj, type, changes, abt)
	  if changes.present?
	  	changes = SystemLog.trimchanges(changes)
	  end
      # SystemLog.create(log_of: obj.class.to_s, log_of_id: obj.id, changed_attr: changes, changed_by: User.current.try(:id), about: abt.try(:class).to_s, about_id: abt.try(:id), log_type: type)
	end

	 def self.trimchanges(changes)
    ka = changes.keys
    ka.each do |k|
      if !changes[k][1].present?
        changes.delete(k)
      end  
    end
    return changes
  end


end
