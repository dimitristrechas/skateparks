require 'open-uri'

# Create sample skateparks
10.times do |i|
  european_countries = ISO3166::Country.all.select { |c| c.continent == 'Europe' && c.subdivisions.any? }
  country = european_countries.sample
  subdivision = country.subdivisions.values.sample
  suffix = i + rand(10)

  subdivision_name = subdivision.name
  geo = subdivision.geo || {}
  lat = geo['latitude'] || 40.935657
  lng = geo['longitude'] || 24.402491

  skatepark = Skatepark.new(
    name_en: "#{subdivision_name} Skatepark #{suffix}",
    name_el: "#{subdivision_name} Skatepark #{suffix}",
    description_en: 'This is a sample skatepark description for park.',
    description_el: 'Αυτή είναι μια περιγραφή για το skatepark.',
    lat: lat,
    lng: lng,
    status: :published,
    country_code: country.alpha2,
    state: subdivision.code
  )

  cover_image_url = 'https://picsum.photos/200/300'
  cover_image = URI.open(cover_image_url)
  skatepark.cover_image.attach(
    io: cover_image,
    filename: "skatepark#{i + rand(10)}_cover.jpg",
    content_type: 'image/jpeg'
  )

  3.times do |j|
    image = URI.open(cover_image_url)
    skatepark.images.attach(
      io: image,
      filename: "skatepark#{i + rand(10)}_image#{j + rand(10)}.jpg",
      content_type: 'image/jpeg'
    )
  end

  skatepark.save!
  Rails.logger.debug { "Created skatepark: #{skatepark.name_en}" }
end
