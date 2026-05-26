
# json.array! @image_data do |item|
#   json.set! item[:key] do
#     json.name item[:label]
#     json.url item[:value]
#   end
# end

json.success true
json.data @image_data unless @image_data.nil?