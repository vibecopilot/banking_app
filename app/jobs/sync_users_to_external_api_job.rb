class SyncUsersToExternalApiJob < ApplicationJob
  queue_as :default

  def perform(company_id = 56)
    # Find all active users for the specified company
    users = User.where(company_id: company_id, active: true)
    
    results = {
      total: users.count,
      successful: 0,
      failed: 0,
      errors: []
    }

    users.find_each do |user|
      service = ExternalUserSyncService.new(user, company_id)
      result = service.sync

      if result[:success]
        results[:successful] += 1
        Rails.logger.info("User #{user.id} synced successfully")
      else
        results[:failed] += 1
        results[:errors] << { user_id: user.id, error: result[:error] }
        Rails.logger.error("Failed to sync user #{user.id}: #{result[:error]}")
      end
    end

    Rails.logger.info("Sync job completed: #{results.inspect}")
  end
end
