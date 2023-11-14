json.extract! skatepark, :id, :name, :images, :lat, :lng, :created_at, :updated_at
json.url skatepark_url(skatepark, format: :json)
json.images do
  json.array!(skatepark.images) do |image|
    json.id image.id
    json.url url_for(image)
  end
end
