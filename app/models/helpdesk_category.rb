class HelpdeskCategory < ApplicationRecord

  serialize :response_tat

  has_many :complaints, foreign_key: :category_type_id
	has_many :helpdesk_sub_categories
  has_one :complaint_worker, foreign_key: :category_id
  # belongs_to :issue_type, :foreign_key => :issue_type_id, class_name: "IssueType"
  # belongs_to :society
  has_attached_file :icon
  validates_attachment :icon, :content_type => {:content_type => %w(image/jpeg image/jpg image/png)}, default_url: "/images/upload.svg"
	# validates_uniqueness_of :name, :scope => [:issue_type_id, :active, :of_phase, :society_id], conditions:->{where("active is null")}
  scope :post_possession, ->{ where(of_phase: "post_possession") }
  scope :post_sale, ->{ where(of_phase: "post_sale") }
  scope :pms, ->{ where(of_phase: "pms") }
  scope :support, ->{ where(of_phase: "support") }
  has_many :category_emails, foreign_key: :cat_id, class_name: "CategoryEmail"

  delegate :assignee_id, to: :complaint_worker, allow_nil: true
  delegate :building_name, to: :society, allow_nil: true, prefix: true
  
	def self.active
		where("active is null or active !=0")
	end


  def response_tat_json
    JSON.parse(self.response_tat || "{}")
  end

  def resp_tat(urgency)
    response_tat_json["#{urgency}"].to_i
  end

  	def self.issue_types_to_categories(complaints, statuses, helpdesk_categories, issue_types, params)
	  	@highchart_category_data_array = []
	  	issue_types.each do |it|
	      basehash = Hash.new
	      basehash[:name] = it.name
	      htcgs = helpdesk_categories.where(issue_type_id: it.id)
	      basehash[:data] = []
	      htcgs.map{|s|
	        
	      }
	      @highchart_category_data_array << basehash
    	end
    end

    def category_hash(name, drilldown, params)
      sample = Hash.new
      sample["name"] = "#{name}"
      if drilldown.present?
	      sample["drilldown"] = "#{drilldown}"
	    end
      ct = self.complaints.ransack(params).result.count
      sample["y"] = ct
      return {ct: ct, hs: sample}
    end

    def self.statuses_hash(name, id, statuses, drilldown, params)
      sample = Hash.new
      sample["name"] = "#{name}"
      if id.present?
      	sample["id"] = "#{id}"
      end
      if drilldown.present?
      	sample["drilldown"] = "#{drilldown}"
      end
      sample["data"] = statuses.map{|st| ["#{st.name}" ,st.complaints.ransack(params).result.count] }
      return sample
    end

    def self.subcategories_hash(name, id, subcategories, drilldown, params)
      sample = Hash.new
      sample["name"] = "#{name}"
      if id.present?
        sample["id"] = "#{id}"
      end
      if drilldown.present?
        sample["drilldown"] = "#{drilldown}"
      end
      sample["data"] = subcategories.map{|st| ["#{st.name}" ,Complaint.where(sub_category_id: st.id).ransack(params).result.count] }
      return sample
    end


    def self.sites_hash(name, id, sites, drilldown,params)
      sample = Hash.new
      sample["name"] = "#{name}"
      if id.present?
        sample["id"] = "#{id}"
      end
      if drilldown.present?
        sample["drilldown"] = "#{drilldown}"
      end
      sample["data"] = sites.map{|st| ["#{st.name}" ,Complaint.pms.where(site_id: st.id).ransack(params).result.count] }
      return sample
    end

    def self.status_count_hash(name, id, status, drilldown, params)
      sample = Hash.new
      sample["name"] = "#{name}"
      if id.present?
      	sample["id"] = "#{id}"
      end
      if drilldown.present?
      	sample["drilldown"] = "#{drilldown}"
      end
      ct = status.complaints.ransack(params).result.count
      if ct > 0
	      sample["y"] = ct
  	  end
  	  return {ct: ct, hs: sample}
    end

    def self.compare_response_chart_logic(curuser_society_id,helpdesk_categories,date_range1,date_range2)

    	@complaints_left = Complaint.where(id_society: curuser_society_id).ransack(date_range1).result
      ops = HelpdeskOperation.soc_ops(curuser_society_id)

    	@responsetat_achieved_left_id = []
	    @responsetat_breached_left_id = []
	    @responsetat_undefined_left_id = []
	    @responsetat_notapplicable_left_id = []

	    helpdesk_categories.each do |hc|
	      clogs = @complaints_left.present? ? ComplaintLog.ransack(complaint_id_in: @complaints_left.pluck(:id), complaint_category_type_id_eq: hc.id).result.where("complaint_status_id is not null").group_by {|c| c.complaint_id} : {}
	      clogs.each do |complaint_id,clog|
	        # byebug
	        @complaint = Complaint.where(id: complaint_id).take
	        crtime = clog.first.created_at.to_time
	        if !@complaint.tat.present?
	          @responsetat_undefined_left_id << @complaint.id
	          next
	        elsif clog.second.present?
	          clogtime = clog.second.created_at.to_time
	        else
	          now = Time.zone.now
	          clogtime = now.to_time
	        end

	        resptime = nil 
          if clog.present? && clog.second.present? 
            if ops.present? 
              resptime = HelpdeskOperation.op_time_diff(crtime, clog.second.created_at, ops).to_i
            else
              clogtime = clog.second.created_at
              resptime = ((clogtime - crtime) / 60).to_i
            end
          end
          if now.present? && resptime.to_i <= @complaint.tat.to_i
	          @responsetat_notapplicable_left_id << @complaint.id 
	        elsif resptime.to_i <=  @complaint.tat.to_i
	          @responsetat_achieved_left_id << @complaint.id
	        elsif resptime.to_i >  @complaint.tat.to_i
	          @responsetat_breached_left_id << @complaint.id
	        end
	      end
	    end

	    @ResponseTatAcheivedLeft = @responsetat_achieved_left_id
	    @ResponseTatBreachedLeft = @responsetat_breached_left_id
	    @ResponseUndefinedLeft =  @responsetat_undefined_left_id
	    @ResponseNotApplicableLeft =  @responsetat_notapplicable_left_id


	    @respachieved_left = Complaint.where(id: @ResponseTatAcheivedLeft)
      @respbreached_left = Complaint.where(id: @ResponseTatBreachedLeft)
      @responsetat_undefined_left = Complaint.where(id: @ResponseUndefinedLeft)
      @responsetat_notapplicable_left = Complaint.where(id: @ResponseNotApplicableLeft)


      @highchart_responsetat_data_array_left = []
      @highchart_responsetat_drill_left = []

      response_tat_drill_grouping_hash_left= @respachieved_left.count > 0 ? {name: "Response Achieved",drilldown: "respAchievedCurrent",y: @respachieved_left.count,color: '#398439'} : {},
                                  @respbreached_left.count > 0 ? {name: "Response Breached",drilldown: "respBreachedCurrent",y: @respbreached_left.count,color: '#dd4b39'} : {},
                                  @responsetat_undefined_left.count > 0 ? {name: "Response Undefined",drilldown: "resndefined",y: @responsetat_undefined_left.count,color: '#e08e0b'} : {},
                                  @responsetat_notapplicable_left.count > 0 ? {name: "Response Not Applicable",drilldown: "respNotApplicable",y: @responsetat_notapplicable_left.count,color: '#999999'} : {}

      @highchart_responsetat_data_array_left = response_tat_drill_grouping_hash_left

      response_tat_drill_grouping_hash_left={name: "Achieved Category",id: "respAchievedCurrent",data: @respachieved_left.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
                                   {name: "Breached Category",id: "respBreachedCurrent",data: @respbreached_left.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
                                   {name: "Undefined Category",id: "respUndefined",data: @responsetat_undefined_left.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
                                   {name: "Not Applicable Category",id: "respNotApplicable",data: @responsetat_notapplicable_left.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'}

      @highchart_responsetat_drill_left = response_tat_drill_grouping_hash_left



      @complaints_right = Complaint.where(id_society: curuser_society_id).ransack(date_range2).result

    	@responsetat_achieved_right_id = []
	    @responsetat_breached_right_id = []
	    @responsetat_undefined_right_id = []
	    @responsetat_notapplicable_right_id = []

	    helpdesk_categories.each do |hc|
	      clogs = @complaints_right.present? ? ComplaintLog.ransack(complaint_id_in: @complaints_right.pluck(:id), complaint_category_type_id_eq: hc.id).result.where("complaint_status_id is not null").group_by {|c| c.complaint_id} : {}
	      clogs.each do |complaint_id,clog|
	        # byebug
	        @complaint = Complaint.where(id: complaint_id).take
	        crtime = clog.first.created_at.to_time
	        if !@complaint.tat.present?
	          @responsetat_undefined_right_id << @complaint.id
	          next
	        elsif clog.second.present?
	          clogtime = clog.second.created_at.to_time
	        else
	          now = Time.zone.now
	          clogtime = now.to_time
	        end

	        resptime = nil 
          if clog.present? && clog.second.present? 
            if ops.present? 
              resptime = HelpdeskOperation.op_time_diff(crtime, clog.second.created_at, ops).to_i
            else
              clogtime = clog.second.created_at
              resptime = ((clogtime - crtime) / 60).to_i
            end
          end
          if now.present? && resptime.to_i <= @complaint.tat.to_i
	          @responsetat_notapplicable_right_id << @complaint.id 
	        elsif resptime.to_i <=  @complaint.tat.to_i
	          @responsetat_achieved_right_id << @complaint.id
	        elsif resptime.to_i >  @complaint.tat.to_i
	          @responsetat_breached_right_id << @complaint.id
	        end
	      end
	    end


	    @ResponseTatAcheivedRight = @responsetat_achieved_right_id
	    @ResponseTatBreachedRight = @responsetat_breached_right_id
	    @ResponseUndefinedRight =  @responsetat_undefined_right_id
	    @ResponseNotApplicableRight =  @responsetat_notapplicable_right_id



	    @respachieved_right = Complaint.where(id: @ResponseTatAcheivedRight)
      @respbreached_right = Complaint.where(id: @ResponseTatBreachedRight)
      @responsetat_undefined_right = Complaint.where(id: @ResponseUndefinedRight)
      @responsetat_notapplicable_right = Complaint.where(id: @ResponseNotApplicableRight)


      @highchart_responsetat_data_array_right = []
      @highchart_responsetat_drill_right = []

      response_tat_drill_grouping_hash_right= @respachieved_right.count > 0 ? {name: "Response Achieved",drilldown: "respAchievedCurrent",y: @respachieved_right.count,color: '#398439'} : {},
                                  @respbreached_right.count > 0 ? {name: "Response Breached",drilldown: "respBreachedCurrent",y: @respbreached_right.count,color: '#dd4b39'} : {},
                                  @responsetat_undefined_right.count > 0 ? {name: "Response Undefined",drilldown: "respUndefined",y: @responsetat_undefined_right.count,color: '#e08e0b'} : {},
                                  @responsetat_notapplicable_right.count > 0 ? {name: "Response Not Applicable",drilldown: "respNotApplicable",y: @responsetat_notapplicable_right.count,color: '#999999'} : {}

      @highchart_responsetat_data_array_right = response_tat_drill_grouping_hash_right

      response_tat_drill_grouping_hash_right={name: "Achieved Category",id: "respAchievedCurrent",data: @respachieved_right.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
                                   {name: "Breached Category",id: "respBreachedCurrent",data: @respbreached_right.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
                                   {name: "Undefined Category",id: "respUndefined",data: @responsetat_undefined_right.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
                                   {name: "Not Applicable Category",id: "respNotApplicable",data: @responsetat_notapplicable_right.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'}

      @highchart_responsetat_drill_right = response_tat_drill_grouping_hash_right

      return {"response_data_left": @highchart_responsetat_data_array_left, "response_drill_left": @highchart_responsetat_drill_left,"response_data_right": @highchart_responsetat_data_array_right, "response_drill_right": @highchart_responsetat_drill_right}

    end



    def self.compare_resolution_chart_logic(curuser_society_id,resolution_date_range1,resolution_date_range2)


  	  @resolution_complaints_left = Complaint.where(id_society: curuser_society_id).ransack(resolution_date_range1).result

      # @resolutionbreached_left = @resolution_complaints_left.ransack(esc_histories_escalation_matrix_complaint_worker_esc_type_eq: "resolution").result.uniq
      # @resolutionachieved_left = @resolution_complaints_left.where.not(id: @resolutionbreached_left.pluck(:id))

      @resolution_left_breached_id  = []
      @resolution_left_achieved_id  = []

      @resolution_complaints_left.each  do |soc|
        clog = soc.complaint_logs.where("complaint_status_id is not null").try(:second)
        crtime = soc.created_at
        resolutime = nil #resolution time
        lastlog = soc.complaint_logs.where("complaint_status_id is not null").try(:last)
        elapsed_time = nil

        escalations = EscalationMatrix.joins(:complaint_worker).active.where("complaint_workers.esc_type = 'resolution' or complaint_workers.esc_type is null").
            ransack({complaint_worker_issue_type_id_eq: soc.issue_type_id, complaint_worker_category_id_eq: soc.category_type_id, complaint_worker_society_id_eq: soc.id_society}).result.first
            
        eh_resolution = soc.esc_histories.ransack({m: "or",escalation_matrix_complaint_worker_esc_type_eq: "resolution", escalation_matrix_complaint_worker_esc_type_null: 1}).result

        if lastlog.present? && lastlog.complaint_status_id.present? && lastlog.complaint_status.try(:fixed_state) == "closed"
          lasttime = lastlog.created_at
          resolutime = ((lasttime - crtime) / 60).to_i

          elapsed_time = escalations.present? ? escalations.elapsed(soc.priority) : nil
          (elapsed_time.present? && elapsed_time > 0) && (elapsed_time < resolutime) ? (@resolution_left_breached_id  <<  soc.id) : (@resolution_left_achieved_id  <<  soc.id)
        else
          resolution_breached = eh_resolution.present? ? (@resolution_left_breached_id  <<  soc.id) : (@resolution_left_achieved_id  <<  soc.id)
        end
      end

      @resolutionbreached_left = Complaint.where(id: @resolution_left_breached_id)
      @resolutionachieved_left = Complaint.where(id: @resolution_left_achieved_id)


      @highchart_resolutiontat_data_array_left = []
      @highchart_resolutiontat_drill_left = []

      resolutiontat_grouping_hash_left= @resolutionachieved_left.count > 0 ? {name: "Resolution Achieved",drilldown: "resolutionAchieved",y: @resolutionachieved_left.count,color: '#398439'} : {},
                                  @resolutionbreached_left.count > 0 ? {name: "Resolution Breached",drilldown: "resolutionBreached",y: @resolutionbreached_left.count,color: '#dd4b39'} : {}

      @highchart_resolutiontat_data_array_left = resolutiontat_grouping_hash_left


      resolution_tat_drill_grouping_hash_left={name: "Achieved Category",id: "resolutionAchieved",data: @resolutionachieved_left.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
                                   {name: "Breached Category",id: "resolutionBreached",data: @resolutionbreached_left.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'}


      @highchart_resolutiontat_drill_left = resolution_tat_drill_grouping_hash_left


      @resolution_complaints_right = Complaint.where(id_society: curuser_society_id).ransack(resolution_date_range2).result

      # @resolutionbreached_right = @resolution_complaints_right.ransack(esc_histories_escalation_matrix_complaint_worker_esc_type_eq: "resolution").result.uniq
      # @resolutionachieved_right = @resolution_complaints_right.where.not(id: @resolutionbreached_right.pluck(:id))


      @resolution_right_breached_id  = []
      @resolution_right_achieved_id  = []

      @resolution_complaints_right.each  do |soc|
        clog = soc.complaint_logs.where("complaint_status_id is not null").try(:second)
        crtime = soc.created_at
        resolutime = nil #resolution time
        lastlog = soc.complaint_logs.where("complaint_status_id is not null").try(:last)
        elapsed_time = nil

        escalations = EscalationMatrix.joins(:complaint_worker).active.where("complaint_workers.esc_type = 'resolution' or complaint_workers.esc_type is null").
            ransack({complaint_worker_issue_type_id_eq: soc.issue_type_id, complaint_worker_category_id_eq: soc.category_type_id, complaint_worker_society_id_eq: soc.id_society}).result.first
            
        eh_resolution = soc.esc_histories.ransack({m: "or",escalation_matrix_complaint_worker_esc_type_eq: "resolution", escalation_matrix_complaint_worker_esc_type_null: 1}).result

        if lastlog.present? && lastlog.complaint_status_id.present? && lastlog.complaint_status.try(:fixed_state) == "closed"
          lasttime = lastlog.created_at
          resolutime = ((lasttime - crtime) / 60).to_i

          elapsed_time = escalations.present? ? escalations.elapsed(soc.priority) : nil
          (elapsed_time.present? && elapsed_time > 0) && (elapsed_time < resolutime) ? (@resolution_right_breached_id  <<  soc.id) : (@resolution_right_achieved_id  <<  soc.id)
        else
          resolution_breached = eh_resolution.present? ? (@resolution_right_breached_id  <<  soc.id) : (@resolution_right_achieved_id  <<  soc.id)
        end
      end

      @resolutionbreached_right = Complaint.where(id: @resolution_right_breached_id)
      @resolutionachieved_right = Complaint.where(id: @resolution_right_achieved_id)
      

      @highchart_resolutiontat_data_array_right = []
      @highchart_resolutiontat_drill_right = []
    
      resolutiontat_grouping_hash_right= @resolutionachieved_right.count > 0 ? {name: "Resolution Achieved",drilldown: "resolutionAchieved",y: @resolutionachieved_right.count,color: '#398439'} : {},
                                  @resolutionbreached_right.count > 0 ? {name: "Resolution Breached",drilldown: "resolutionBreached",y: @resolutionbreached_right.count,color: '#dd4b39'} : {}

      @highchart_resolutiontat_data_array_right = resolutiontat_grouping_hash_right


      resolution_tat_drill_grouping_hash_right={name: "Achieved Category",id: "resolutionAchieved",data: @resolutionachieved_right.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
                                   {name: "Breached Category",id: "resolutionBreached",data: @resolutionbreached_right.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'}

      @highchart_resolutiontat_drill_right = resolution_tat_drill_grouping_hash_right

      return {"resolution_data_left": @highchart_resolutiontat_data_array_left, "resolution_drill_left": @highchart_resolutiontat_drill_left,"resolution_data_right": @highchart_resolutiontat_data_array_right, "resolution_drill_right": @highchart_resolutiontat_drill_right}



    end

    def self.get_dynamic_header(aging_rules)
      if aging_rules.present?
        ["Open Cases"]*(aging_rules.count+3) + ["Closed Cases"]*(aging_rules.count+3)
      else
        []
      end
    end

    def self.get_dynamic_rowspan(aging_rules)
      if aging_rules.present?
        next_val = "C"
        (aging_rules.count + 3).times  do |c|
          next_val = next_val.next
        end
        open_next_val = nil
        if next_val.present? && next_val.length > 1
          if next_val.last.include? "A"
            open_next_val = "#{next_val}" + "2"
          elsif next_val.last(2).include? "AA"
            open_next_val = "#{next_val}" + "3"
          elsif next_val.last(3).include? "AAA"
            open_next_val = "#{next_val}" + "4"
          end
        else
          open_next_val = "#{next_val}" + "1"
        end
        "D1:#{open_next_val}"

        previous_cell_value = open_next_val[0].next + open_next_val[1]
        new_next_val = open_next_val[0].first
        (aging_rules.count + 3).times  do |c|
          new_next_val = new_next_val.next
        end
        closed_next_val = nil
        if new_next_val.present? && new_next_val.length > 1
          if new_next_val.last.include? "A"
            closed_next_val = "#{new_next_val}" + "2"
          elsif new_next_val.last(2).include? "AA"
            closed_next_val = "#{new_next_val}" + "3"
          elsif new_next_val.last(3).include? "AAA"
            closed_next_val = "#{new_next_val}" + "4"
          end
        else
          closed_next_val = "#{new_next_val}" + "1"
        end
        "#{previous_cell_value}:#{closed_next_val}"

        return {open_cell_header_values: "D1:#{open_next_val}",closed_cell_header_values: "#{previous_cell_value}:#{closed_next_val}"}
      end
    end
  
end
