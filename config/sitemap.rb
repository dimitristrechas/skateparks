require 'aws-sdk-s3'

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.skateparks.gr"

SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new('skateparks.gr',
  acl: 'public-read', # Optional. This is the default.
  cache_control: 'private, max-age=0, no-cache', # Optional. This is the default.
  access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
  secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
  region: 'eu-central-1'
)

SitemapGenerator::Sitemap.create do

  add '/about'
  add '/contact'

  Skatepark.published.each do |skatepark|
    add skatepark_path(skatepark), :lastmod => skatepark.updated_at
  end
end
 