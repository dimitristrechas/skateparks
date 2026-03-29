json.extract! skatepark, :id, :name, :lat, :lng, :created_at, :updated_at
json.url skatepark_url(skatepark, format: :json)
json.images do
  json.array!(skatepark.skatepark_images) do |skatepark_image|
    json.id skatepark_image.id
    json.position skatepark_image.position
    json.url url_for(skatepark_image.image)
  end
end
