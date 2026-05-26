class VisitorDeviceLogsController < ApplicationController

  # GET /visitor_device_logs
def index
  visitor_device_logs = VisitorDeviceLog
                          .order(created_at: :desc)
                          .paginate(
                            page: params[:page] || 1,
                            per_page: params[:per_page] || 20
                          )

  render json: {
    status: "success",
    data: visitor_device_logs,
    pagination: {
      current_page: visitor_device_logs.current_page,
      total_pages: visitor_device_logs.total_pages,
      total_count: visitor_device_logs.total_entries
    },
    message: "Visitor device logs retrieved successfully"
  }, status: :ok

rescue StandardError => e
  render json: {
    status: "error",
    message: "An error occurred: #{e.message}"
  }, status: :internal_server_error
end



  # GET /visitor_device_logs/:employee_no
  def show_by_employee
    employee_no = params[:employee_no]

    if employee_no.blank?
      render json: { success: false, message: "Employee ID is required" }, status: :unprocessable_entity
      return
    end

    logs = VisitorDeviceLog.where(employee_no: employee_no).order(in_time: :asc)

    if logs.exists?
      render json: { success: true, data: logs }, status: :ok
    else
      render json: { success: false, message: "No logs found for employee ID #{employee_no}" }, status: :not_found
    end
  end

  #
  def create
    acs_event = params[:AcsEvent]

    if acs_event.blank? || acs_event[:InfoList].blank?
      render json: { success: false, message: "No valid data provided" }, status: :unprocessable_entity
      return
    end

    logs = acs_event[:InfoList]
    created_logs = []
    errors = []

    logs.each do |log|
      next unless log[:employeeNoString].present? && log[:time].present?

      employee_no = log[:employeeNoString]
      name = log[:name]
      time = log[:time]
      door_no = log[:doorNo]
      device_serial_no = log[:serialNo]

      # Check the last log for the employee
      last_log = VisitorDeviceLog.where(employee_no: employee_no).order(created_at: :desc).first
      if last_log.nil? || last_log.out_time.present?
        # No existing "in" entry or the last log is complete (both "in" and "out" exist)
        existing_log = VisitorDeviceLog.find_by(employee_no: employee_no, in_time: time, out_time: nil)
        if existing_log
          errors << { log: log, message: "Duplicate log entry for in_time" }
          next
        end

        new_log = VisitorDeviceLog.new(
          employee_no: employee_no,
          name: name,
          in_time: time,
          door_no: door_no,
          device_serial_no: device_serial_no
        )

        if new_log.save
          created_logs << new_log
        else
          errors << { log: log, errors: new_log.errors.full_messages }
        end
      else
        # Existing "in" entry without an "out" time
        if last_log.update(out_time: time)
          created_logs << last_log
        else
          errors << { log: log, errors: last_log.errors.full_messages }
        end
      end
    end

    if errors.empty?
      render json: { success: true, message: "Logs processed successfully", data: created_logs }, status: :created
    else
      render json: { success: false, message: "Some logs failed to process", errors: errors }, status: :unprocessable_entity
    end
  end
end
