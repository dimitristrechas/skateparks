require 'open-uri'

return if Rails.env.production?

if User.where(role: :admin).none? && ENV['ADMIN_EMAIL'].present? && ENV['ADMIN_PASSWORD'].present?
  admin = User.create!(
    email_address: ENV.fetch('ADMIN_EMAIL', nil),
    password: ENV.fetch('ADMIN_PASSWORD', nil),
    password_confirmation: ENV.fetch('ADMIN_PASSWORD', nil),
    role: :admin
  )
  Rails.logger.debug { "Created admin user: #{admin.email_address}" }
end

COVER_IMAGE_URL = 'https://picsum.photos/200/300'.freeze

def skatepark_name(subdivision_name, suffix)
  "#{subdivision_name} Skatepark #{suffix}"
end

def random_european_location
  european_countries = ISO3166::Country.all.select { |c| c.continent == 'Europe' && c.subdivisions.any? }
  country = european_countries.sample
  subdivision = country.subdivisions.values.sample
  geo = subdivision.geo || {}

  {
    country: country,
    subdivision: subdivision,
    lat: geo['latitude'] || 40.935657,
    lng: geo['longitude'] || 24.402491,
  }
end

def build_skatepark(location, suffix)
  Skatepark.new(
    name_en: skatepark_name(location[:subdivision].name, suffix),
    name_el: skatepark_name(location[:subdivision].name, suffix),
    description_en: 'This is a sample skatepark description for park.',
    description_el: 'Αυτή είναι μια περιγραφή για το skatepark.',
    lat: location[:lat],
    lng: location[:lng],
    status: :published,
    country_code: location[:country].alpha2,
    state: location[:subdivision].code
  )
end

def attach_images(skatepark, index)
  uri = URI.parse(COVER_IMAGE_URL)
  options = { open_timeout: 10, read_timeout: 30 }

  begin
    cover_image = uri.open(**options)
    skatepark.cover_image.attach(io: cover_image, filename: "skatepark#{index}_cover.jpg", content_type: 'image/jpeg')
  rescue OpenURI::HTTPError, Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error { "Failed to download cover image: #{e.message}" }
  end

  rand(3..5).times do |j|
    image = uri.open(**options)
    skatepark.images.attach(io: image, filename: "skatepark#{index}_image#{j}.jpg", content_type: 'image/jpeg')
  rescue OpenURI::HTTPError, Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error { "Failed to download image #{j}: #{e.message}" }
  end
end

10.times do |i|
  location = random_european_location
  skatepark = build_skatepark(location, i + rand(10))
  attach_images(skatepark, i)
  skatepark.save!
  Rails.logger.debug { "Created skatepark: #{skatepark.name_en}" }
end
