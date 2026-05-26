class HelpdeskOperation < ActiveRecord::Base
	scope :pms, ->{ where(of_phase: "pms") }
	scope :post_possession, ->{ where(of_phase: "post_possession") }
	scope :post_sale, ->{ where(of_phase: "post_sale") }
	def self.active
		where(active: true)
	end

	def self.op_time_diff(from_time, to_time, ops)
		cat = from_time
		nw = to_time
		cdate = cat.to_date
		days_passed = (nw.to_date - cdate).floor
		tp = 0
		if ops.present?
			(0..days_passed).each do |x|
				cdate = cat.to_date + x.days
				col = cdate.strftime("%A").downcase
				day_op = ops[col.to_sym]
				fstart = DateTime.new(cdate.year, cdate.month, cdate.mday, day_op[:start_hour].to_i, day_op[:start_min].to_i).in_time_zone -  5.hours - 30.minutes
				fend = DateTime.new(cdate.year, cdate.month, cdate.mday, day_op[:end_hour].to_i, day_op[:end_min].to_i).in_time_zone -  5.hours - 30.minutes
				puts fstart
				puts fend
				puts cat
				if fend > fstart
					if cat > fstart && fend > nw
						puts "first if"
						tp += (( nw - cat ) / 60)
					elsif cat > fstart && nw > fend && fend > cat
						puts "second if"
						tp += (( fend - cat ) / 60)
					elsif nw > fstart && fend > nw
						puts "third if"
						tp += (( nw - fstart ) / 60)	
					elsif fstart > cat && nw > fend
						puts "fourth if"
						tp += (( fend - fstart ) / 60)	
					end
				end
			end
		end
		return tp
	end
	def self.op_time_passed(cpt, ops)
		cat = cpt.created_at
		cdate = cat.to_date
		nw = Time.zone.now
		days_passed = (nw.to_date - cdate).floor
		tp = 0
		if ops.present?
			(0..(days_passed > 7 ? 7 : days_passed)).each do |x|
				cdate = cat.to_date + x.days
				col = cdate.strftime("%A").downcase
				day_op = ops[col.to_sym]
				fstart = DateTime.new(cdate.year, cdate.month, cdate.mday, day_op[:start_hour].to_i, day_op[:start_min].to_i).in_time_zone -  5.hours - 30.minutes
				fend = DateTime.new(cdate.year, cdate.month, cdate.mday, day_op[:end_hour].to_i, day_op[:end_min].to_i).in_time_zone -  5.hours - 30.minutes
				puts fstart
				puts fend
				puts cat
				nw = Time.zone.now
				if fend > fstart
					if cat > fstart && fend > nw
						tp += (( nw - cat ) / 60)
					elsif cat > fstart && nw > fend
						tp += (( fend - cat ) / 60)
					elsif cat > fstart && cat > fend
						tp += (( cat - fend ) / 60)	
					elsif fstart > cat && nw > fend
						tp += (( fend - fstart ) / 60)	
					end
				end
			end
		end
		puts "time_since_created ======= #{tp}"
		return tp
	end
	def self.soc_ops(id_society)
		ops = HelpdeskOperation.post_possession.active.where(op_of: "Society", op_of_id: id_society)
		hs = Hash.new
		ops.each do |o|
			ns = Hash.new
			if o.is_open == true
				ns[:start_hour] = o.start_hour
				ns[:start_min] = o.start_min
				ns[:end_hour] = o.end_hour
				ns[:end_min] = o.end_min
			else
				ns[:start_hour] = 23
				ns[:start_min] = 59
				ns[:end_hour] = 23
				ns[:end_min] = 59
			end
				hs[o.dayofweek.to_sym] = ns
		end
		return hs
	end

	def self.society_ops(society_id)
		ops = HelpdeskOperation.post_possession.active.where(op_of: "Society", op_of_id: society_id)
		hs = Hash.new
		ops.each do |o|
			ns = Hash.new
			if o.is_open == true
				ns[:start_hour] = o.start_hour
				ns[:start_min] = o.start_min
				ns[:end_hour] = o.end_hour
				ns[:end_min] = o.end_min
			end
				hs[o.dayofweek.to_sym] = ns
		end
		return hs
	end

	def self.site_ops(site_id)
		ops = HelpdeskOperation.active.where(op_of_id: site_id)
		hs = Hash.new
		ops.each do |o|
			ns = Hash.new
			if o.is_open == true
				ns[:start_hour] = o.start_hour
				ns[:start_min] = o.start_min
				ns[:end_hour] = o.end_hour
				ns[:end_min] = o.end_min
			else
				ns[:start_hour] = 23
				ns[:start_min] = 59
				ns[:end_hour] = 23
				ns[:end_min] = 59
			end
			hs[o.dayofweek.to_sym] = ns
		end
		return hs
	end

	def self.time_since_created(complaint)
		cat = complaint.created_at
		cdate = cat.to_date
		# days = (cdate..cdate+6.days).to_a.map{|d| d.strftime("%A").downcase}.cycle
		
		ops = HelpdeskOperation.post_possession.active.where(op_of: "Society", op_of_id: complaint.id_society)
		nw = Time.zone.now
		days_passed = (nw.to_date - cdate).floor
		tp = 0
		if ops.present?
			(0..(days_passed > 7 ? 7 : days_passed)).each do |x|
				cdate = cat.to_date + x.days
				col = cdate.strftime("%A").downcase
				day_op = ops.where(dayofweek: col).last
				fstart = DateTime.new(cdate.year, cdate.month, cdate.mday, day_op.start_hour.to_i, day_op.start_min.to_i).in_time_zone -  5.hours - 30.minutes
				fend = DateTime.new(cdate.year, cdate.month, cdate.mday, day_op.end_hour.to_i, day_op.end_min.to_i).in_time_zone -  5.hours - 30.minutes
				puts fstart
				puts fend
				puts cat
				nw = Time.zone.now
				if fend > fstart
					if cat > fstart && fend > nw
						tp += (( nw - cat ) / 60)
					elsif cat > fstart && nw > fend
						tp += (( fend - cat ) / 60)
					elsif cat > fstart && cat > fend
						tp += (( cat - fend ) / 60)	
					elsif fstart > cat && nw > fend
						tp += (( fend - fstart ) / 60)	
					end
				end
			end
		end
		puts "time_since_created ======= #{tp}"
		return tp
	end

	def showtimes
		(sprintf '%02d', self.start_hour || 0).try(:to_s) + ":" + (sprintf '%02d', self.start_min || 0).try(:to_s) + " to " + (sprintf '%02d', self.end_hour || 0).try(:to_s) + ":" + (sprintf '%02d', self.end_min || 0).try(:to_s)
	end


	def self.import(file,user)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    rowcomp = []
    (2..spreadsheet.last_row).each do |i|
      rowhs = Hash.new
      rowhs[:row_number] = i
      row = Hash[[header, spreadsheet.row(i)].transpose] 
      begin
        id = nil
        id = row["Id"] if row["Id"]
        if row['SiteId'].present? && user.allowed_sites.pluck(:id).include?(row['SiteId'].to_i)
          oday = HelpdeskOperation.find_or_initialize_by(dayofweek: row["Day"], op_of_id: row['SiteId'])
          oday.op_of = 'Pms::Site'
          oday.of_phase = 'pms'
          oday.start_hour = row["StartHour"]
          oday.start_min = row["StartMin"]
          oday.end_hour = row["EndHour"]
          oday.end_min = row["EndMin"]
          oday.is_open = row['Active']
          oday.active = true
          if oday.save
            rowhs[:message] = "success"
          else
            rowhs[:message] = oday.errors
          end
        end
      rescue Exception => e
        rowhs[:error] = e.to_s
      end
      rowcomp << rowhs
    end
    return rowcomp
  end
		
end