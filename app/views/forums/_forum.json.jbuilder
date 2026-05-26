json.extract! forum, :id, :thread_title, :thread_category, :thread_tags, :thread_creators, :date, :thread_description, :created_by_id, :created_at, :updated_at, :visible

# Check if 'forum.creator' exists before trying to fetch creator information
json.created_by_name forum.creator ? forum.creator.slice(:firstname, :lastname) : nil

# Attachments for forum images (use preloaded association)
json.forums_image do
  json.array!(forum.forum_documents) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

# Profile image for the forum (use preloaded association)
json.forums_profile_image do
  if forum.forum_profile.present?
    json.extract! forum.forum_profile, :id, :relation, :relation_id
    json.document forum.forum_profile.document_url
  else
    json.document nil  # If no profile image exists
  end
end

# Forum comments and other related data
json.forum_comments forum.forum_comments
json.url forum_url(forum, format: :json)

# Use preloaded likes to avoid COUNT queries
liked_likes = forum.likes.select { |like| like.status == 'liked' }
unliked_likes = forum.likes.select { |like| like.status == 'unliked' }

json.liked_count liked_likes.count
json.unliked_count unliked_likes.count
json.comment_count forum.forum_comments.size
json.likes do
  json.array! liked_likes do |like|
    json.user_id like.user_id
    json.full_name like.user&.full_name  
  end
end