class ComplaintStatus < ApplicationRecord
  validates_length_of :name, :maximum => 50, :allow_blank => false, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" } 

	has_many :complaints, foreign_key: :issue_status
  scope :pms, ->{ where(of_phase: "pms") }

	def self.active
		where("active is null or active !=0")
	end

	def self.dhmop(min)
    if min > 0
      hh, mm = min.divmod(60)
      dd, hh = hh.divmod(24)
      mt, dd = dd.divmod(30)
      return {mt: mt, dd: dd, hh: hh, mm: mm.to_i}
    else
      return {mt: nil, dd: nil, hh: nil, mm: nil}
    end
  end

  def dhm(min)
   if min > 0
     hh, mm = min.divmod(60)
     dd, hh = hh.divmod(24)
     mt, dd = dd.divmod(30)
     str = ""
     str += "#{mt} months, " if mt > 0
     str += "#{dd} day, "
     str += "#{hh} hour, "
     str += "#{mm.to_i} minute "
     return str
   else
     return ""
   end
 end

end
