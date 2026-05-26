# app/models/cron_setting.rb
class CronSetting < ApplicationRecord

  belongs_to :cronnable, polymorphic: true
  belongs_to :soft_service, foreign_key: 'cronnable_id', optional: true

  validates :cronnable, presence: true

  before_validation :set_cronnable_association
  before_save :generate_cron_expression

  # belongs_to :soft_service

  RECURRENCE_TYPES = %w[yearly monthly weekly daily hourly minutely]

  validates :recurrence_type, inclusion: { in: RECURRENCE_TYPES }
  validates :year_interval, numericality: { greater_than: 0 }, allow_nil: true

  # before_save :generate_cron_expression
  # before_save :set_cronnable_id

  def self.array_fields
    [:month, :date, :day_of_week, :hour, :minute]
  end

  array_fields.each do |field|
    define_method(field) do
      self[field]&.split(',')&.map(&:to_i)
    end

    define_method("#{field}=") do |value|
      self[field] = value.is_a?(Array) ? value.reject(&:blank?).join(',') : value
    end
  end

  # def generate_cron_expression
  #   cron_parts = []

  #   case recurrence_type
  #   when 'minutely'
  #     cron_parts = ['*', '*', '*', '*', '*']
  #   when 'hourly'
  #     cron_parts = [minute.join(','), '*', '*', '*', '*']
  #   when 'daily'
  #     cron_parts = [minute.join(','), hour.join(','), '*', '*', '*']
  #   when 'weekly'
  #     cron_parts = [minute.join(','), hour.join(','), '*', '*', day_of_week.join(',')]
  #   when 'monthly'
  #     cron_parts = [minute.join(','), hour.join(','), date.join(','), '*', '*']
  #   when 'yearly'
  #     cron_parts = [minute.join(','), hour.join(','), date.join(','), month.join(','), '*']
  #   end

  #   self.cron_expression = cron_parts.join(' ')
  # end

  def validate_array_fields
    array_fields.each do |field|
      values = send(field)
      next unless values.is_a?(Array)

      valid_range = case field
                    when :month then 1..12
                    when :date then 1..31
                    when :day_of_week then 0..6
                    when :hour then 0..23
                    when :minute then 0..59
                    end

      values.each do |value|
        unless valid_range.include?(value.to_i)
          errors.add(field, "#{value} is not included in the valid range")
        end
      end
    end
  end

  private

  def generate_cron_expression
    cron_parts = []
    case recurrence_type
    when 'minutely'
      cron_parts = ['*', '*', '*', '*', '*']
    when 'hourly'
      cron_parts = [minute&.join(',') || '*', '*', '*', '*', '*']
    when 'daily'
      cron_parts = [minute&.join(',') || '*', hour&.join(',') || '*', '*', '*', '*']
    when 'weekly'
      cron_parts = [minute&.join(',') || '*', hour&.join(',') || '*', '*', '*', day_of_week&.join(',') || '*']
    when 'monthly'
      cron_parts = [minute&.join(',') || '*', hour&.join(',') || '*', date&.join(',') || '*', '*', '*']
    when 'yearly'
      cron_parts = [minute&.join(',') || '*', hour&.join(',') || '*', date&.join(',') || '*', month&.join(',') || '*', '*']
    end
    self.cron_expression = cron_parts.join(' ')
  end

  def set_cronnable_association
    self.cronnable_type = 'SoftService' if cronnable_type.blank?
    self.soft_service = cronnable if cronnable.is_a?(SoftService)
  end

end