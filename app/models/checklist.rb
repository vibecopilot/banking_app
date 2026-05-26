require 'roo'
class Checklist < ApplicationRecord
  # default_scope { where(ctype: "routine") }
  has_many :questions, dependent: :destroy
  belongs_to :site, optional: true
  belongs_to :user
  has_many :activities
  has_many :checklist_users, class_name: "ChecklistUser", foreign_key: "checklist_id"
  has_many :users, through: :checklist_users
  belongs_to :vendor, class_name: "Vendor", foreign_key: "supplier_id", optional: true
  belongs_to :group, class_name: "GenericInfo", foreign_key: "group_id", optional: true

  has_one :checklist_cron

  after_update :update_checklist_cron, if: -> { saved_change_to_start_date? || saved_change_to_end_date? }

  def send_creation_email
    ChecklistMailer.checklist_created(self, self.user).deliver_now
  end

  def send_creation_email_later
    ChecklistMailer.checklist_created(self, self.user).deliver_later
  end

  def send_update_email
    ChecklistMailer.checklist_updated(self, self.user).deliver_now
  end

  def send_update_email_later
    ChecklistMailer.checklist_updated(self, self.user).deliver_later
  end


  def update_checklist_cron
    if self.checklist_cron.present?
      self.checklist_cron.after_update_cron
    end
  end

  # def checklist_cron
  #   ChecklistCron.find_by(checklist_id: self.id)
  # end

  def set_timings
    cron = self.checklist_cron&.expression
    if cron.present?
      return parse_cron_expression(cron)
    else
      fyst = self.start_date
      endt = self.end_date
      if self.frequency == "one_time"
        return [fyst]
      end
      std = fyst
      datetimes = []
      case self.frequency
      when "hourly"
        adder = 1.hour
      when "daily"
        adder = 1.day
      when "weekly"
        adder = 1.week
      when "monthly"
        adder = 1.month
      when "quarterly"
        adder = 3.month
      when "half_yearly"
        adder = 6.month
      when "yearly"
        adder = 1.year
      end

      freq_end = nil
      if self.occurs.present? && self.frequency == "hourly"
        occud = self.occurs.split(",")
      else
        occud = nil
      end

      if adder.present?
        while true
          str = std
          etr = std + adder

          freq_end = etr
          std = freq_end
          if occud.present?
            datetimes << str if occud.include?str.strftime("%H").to_i.to_s
          else
            datetimes << str
          end
          break if std > endt
        end
      end
      return datetimes
    end
  end

  def parse_cron_expression(cron_expression)
    cron = Fugit::Cron.parse(cron_expression)

    # Convert start and end time to UTC to match the cron evaluation
    start_time = self.start_date.to_time.in_time_zone('Asia/Kolkata').utc
    end_time = self.end_date.to_time.in_time_zone('Asia/Kolkata').utc

    puts "Start Time (Adjusted UTC): #{start_time}"
    puts "End Time (Adjusted UTC): #{end_time}"

    timings = []
    next_time = cron.next_time(start_time)

    while next_time && next_time <= end_time
      # Convert EtOrbi::EoTime to Time using to_t and then to DateTime
      local_time = next_time.to_t.in_time_zone('Asia/Kolkata').to_datetime
      puts "Adding time: #{local_time}"  # Debugging output
      timings << local_time

      # Get the next occurrence
      next_time = cron.next_time(next_time)
    end

    puts "Generated Timings: #{timings}"  # Debugging output to see the final array
    return timings
  end

  # def self.import(file_path , user)
  #   spreadsheet = Roo::Spreadsheet.open(file_path)
  #   header = spreadsheet.row(1)

  #   (2..spreadsheet.last_row).each do |i|
  #     row = Hash[[header, spreadsheet.row(i)].transpose]
  #    checklist = Checklist.find_or_create_by!(
  #       name: row['Checklist Name'],
  #       site_id: row['Site Id'],
  #       frequency: row['Frequency'],
  #       start_date: row['Start Date'],
  #       end_date: row['End Date'],
  #       occurs: row['Occurs'],
  #       ctype: row['Ctype'],
  #       user_id: user.id
  #     )

  #     # Create a question and associate it with the checklist
  #     question = Question.new
  #     question.checklist_id = checklist.id
  #     question.name = row['Question Name']
  #     question.qtype = row['Type']
  #     question.option1 = row['Option 1']
  #     question.option2 = row['Option 2']
  #     question.option3 = row['Option 3']
  #     question.option4 = row['Option 4']
  #     question.question_mandatory = row['Question Mandatory'].to_s.downcase == 'true'
  #     question.image_mandatory = row['Image Mandatory'].to_s.downcase == 'true'
  #     question.save!
  #   end
  # end

  def self.import(file_path, user)
    spreadsheet = Roo::Spreadsheet.open(file_path)
    header = spreadsheet.row(1)

    checklist = nil
    supervisor_ids = []
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      if checklist.nil? || checklist.name != row['Checklist Name'] || checklist.site_id != row['Site Id']
        checklist = Checklist.find_or_create_by!(
          name: row['Checklist Name'],
          site_id: row['Site Id'],
          frequency: row['Frequency'],
          start_date: row['Start Date'],
          end_date: row['End Date'],
          occurs: row['Occurs'],
          ctype: row['Ctype'],
          user_id: user.id
        )
      end
      question = Question.new(
        checklist_id: checklist.id,
        group_id: row['Question Group'], # Assign to group based on column value
        name: row['Question Name'],
        qtype: row['Question Type'],
        option1: row['Option 1'],
        option2: row['Option 2'],
        option3: row['Option 3'],
        option4: row['Option 4'],
        value_type1: row['Value Type 1'],
        value_type2: row['Value Type 2'],
        value_type3: row['Value Type 3'],
        value_type4: row['Value Type 4'],
        question_mandatory: row['Mandatory'].to_s.downcase == 'true',
        image_mandatory: row['Image Mandatory'].to_s.downcase == 'true',
        help_text: row['Help Text'],
        rating: row['Rating'],
        weightage: row['Weightage'],
        reading: row['Reading']
      )
      question.save!
      supervisor_ids = row['Assigned Supervisors'].to_s.split(',').map(&:strip)
      checklist.update(supervisior_id: supervisor_ids.to_json) # Save supervisors as JSON
    end
  end

  def reset_future_activities!
    today = Time.zone.now.beginning_of_day

    future_activities = activities.where("start_time >= ?", today)
    last_asset_ids = future_activities.where.not(asset_id: nil).pluck(:asset_id).uniq
    last_service_ids = future_activities.where.not(soft_service_id: nil).pluck(:soft_service_id).uniq
    last_patrolling_ids = future_activities.where.not(patrolling_id: nil).pluck(:patrolling_id).uniq
    assigned_user_ids = checklist_users.pluck(:user_id).uniq

    # Destroy only future activities
    future_activities.delete_all

    # Get fresh timing slots from updated checklist
    timings = self.set_timings.select { |t| t >= today }

    activities_to_create = []
    checklist_users_to_create = []

    last_asset_ids.each do |aid|
      timings.each do |tm|
        activities_to_create << {
          asset_id: aid,
          checklist_id: self.id,
          start_time: tm,
          status: "pending"
        }
      end

      assigned_user_ids.each do |assignee|
        checklist_users_to_create << {
          checklist_id: self.id,
          user_id: assignee,
          resource_id: aid,
          resource_type: "SiteAsset"
        }
      end
    end

    last_service_ids.each do |sid|
      timings.each do |tm|
        activities_to_create << {
          soft_service_id: sid,
          checklist_id: self.id,
          start_time: tm,
          status: "pending"
        }
      end

      assigned_user_ids.each do |assignee|
        checklist_users_to_create << {
          checklist_id: self.id,
          user_id: assignee,
          resource_id: sid,
          resource_type: "SoftService"
        }
      end
    end

    last_patrolling_ids.each do |pid|
      assigned_user_ids.each do |assignee|
        timings.each do |tm|
          activities_to_create << {
            patrolling_id: pid,
            checklist_id: self.id,
            start_time: tm,
            status: "pending",
            assigned_to: assignee
          }
        end
      end
    end

    # Save activities and checklist users safely in a transaction
    ActiveRecord::Base.transaction do
      # binding.pry
      if activities_to_create.any?
        if Activity.respond_to?(:insert_all)
          Activity.insert_all(activities_to_create)
        else
          activities_to_create.each { |attrs| Activity.create!(attrs) }
        end
      end
      # ChecklistUser.import(checklist_users_to_create.uniq) if checklist_users_to_create.any?
      # unless ChecklistUser.exists?(
      #     checklist_id: self.id,
      #     user_id: user_id,
      #     resource_id: asset_id,
      #     resource_type: resource_type
      #   )
      #   ChecklistUser.create!(
      #     checklist_id: self.id,
      #     user_id: user_id,
      #     resource_id: asset_id,
      #     resource_type: resource_type
      #   )
      # end
    end
  end
end
