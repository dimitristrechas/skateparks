require Rails.root.join('lib/sitemap_locale_helper')

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = SitemapLocaleHelper::DEFAULT_HOST

SitemapGenerator::Sitemap.create do
  extend SitemapLocaleHelper

  add_localized '/'
  add_localized '/skateparks'
  add_localized '/about'
  add_localized '/contact'
  add_localized '/privacy'

  Skatepark.published.find_each do |skatepark|
    add_localized skatepark_path(skatepark), lastmod: skatepark.updated_at
  end
end
