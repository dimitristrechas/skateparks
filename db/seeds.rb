require 'open-uri'

# Create sample skateparks
5.times do |i|
  skatepark = Skatepark.new(
    name_en: "Sample Skatepark #{i+rand(1000)}",
    name_el: "Sample Skatepark #{i+rand(1000)}",
    description_en: "This is a sample skatepark description for park #{i+1}.",
    description_el: "This is a sample skatepark description for park #{i+1}.",
    lat: 40.935657,
    lng: 24.402491,
    status: :published
  )

  cover_image_url = "https://picsum.photos/200/300"
  cover_image = URI.open(cover_image_url)
  skatepark.cover_image.attach(
    io: cover_image,
    filename: "skatepark#{i+rand(1000)}_cover.jpg",
    content_type: "image/jpeg"
  )

  3.times do |j|
    image = URI.open(cover_image_url)
    skatepark.images.attach(
      io: image,
      filename: "skatepark#{i+rand(1000)}_image#{j+rand(1000)}.jpg",
      content_type: "image/jpeg"
    )
  end

  skatepark.save!
  puts "Created skatepark: #{skatepark.name_en}"
end
