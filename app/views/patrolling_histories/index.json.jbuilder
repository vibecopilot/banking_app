# Efficient attachment preloading - only for the current page
@attachments_by_history = @patrolling_histories.any? ? 
  Attachfile.where(relation: 'PatrollingHistory', relation_id: @patrolling_histories.map(&:id))
            .group_by(&:relation_id) : {}


  current_page = (params[:page] || 1).to_i
  per_page = (params[:per_page] || 10).to_i
  per_page = 10 if per_page <= 0
  per_page = [per_page, 50].min
  
  json.current_page current_page
  # json.per_page per_page
  
  # Get total count efficiently - this will be cached by the controller context
  total_count = PatrollingHistory.joins(:patrolling)
                                .where(patrollings: { site_id: @user&.current_site_id })
                                .count
  json.total_count total_count
  json.total_pages (total_count.to_f / per_page).ceil

json.patrolling_histories do
  json.array! @patrolling_histories, partial: "patrolling_histories/patrolling_history", as: :patrolling_history
end
