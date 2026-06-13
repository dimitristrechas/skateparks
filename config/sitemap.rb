# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://www.skateparks.gr'

SitemapGenerator::Sitemap.create do
  add '/about'
  add '/contact'
  add '/privacy'

  Skatepark.published.each do |skatepark|
    add skatepark_path(skatepark), lastmod: skatepark.updated_at
  end
end
