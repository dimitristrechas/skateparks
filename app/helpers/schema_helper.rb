module SchemaHelper
  def json_ld_schema(skatepark: nil, skateparks: nil, title: nil, meta_description: nil, meta_image: nil)
    schemas = []
    schemas << organization_schema
    schemas << website_schema

    case "#{controller_name}##{action_name}"
    when 'skateparks#show'
      schemas << skatepark_schema(skatepark) if skatepark
    when 'skateparks#index'
      schemas << collection_page_schema(skateparks)
    else
      schemas << webpage_schema(title: title, meta_description: meta_description, meta_image: meta_image)
    end

    content_tag :script, schemas.to_json.html_safe, type: 'application/ld+json' # rubocop:disable Rails/OutputSafety
  end

  private

  def organization_schema
    {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      name: 'skateparks.gr',
      url: root_url(protocol: 'https'),
      description: t('application.meta_description', locale: :en),
      sameAs: [
        # Social media URLs here
      ],
    }
  end

  def website_schema
    {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      '@id': "#{root_url(protocol: 'https')}#website",
      name: 'skateparks.gr',
      url: root_url(protocol: 'https'),
      description: t('application.meta_description', locale: :en),
      inLanguage: %w[el en],
      potentialAction: {
        '@type': 'SearchAction',
        target: {
          '@type': 'EntryPoint',
          urlTemplate: "#{skateparks_url(protocol: 'https')}?search={search_term_string}",
        },
        'query-input': 'required name=search_term_string',
      },
    }
  end

  def webpage_schema(title: nil, meta_description: nil, meta_image: nil)
    {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      '@id': url_for(only_path: false, protocol: 'https'),
      name: title.presence || t('application.title', locale: :en),
      description: meta_description.presence || t('application.meta_description', locale: :en),
      image: meta_image.presence || image_url('og_image.png'),
      url: url_for(only_path: false, protocol: 'https'),
      isPartOf: {
        '@id': "#{root_url(protocol: 'https')}#website",
      },
    }
  end

  def skatepark_schema(skatepark)
    schema = {
      '@context': 'https://schema.org',
      '@type': 'SportsActivityLocation',
      '@id': skatepark_url(skatepark, protocol: 'https'),
      name: skatepark.name,
      description: skatepark.description&.to_plain_text,
      url: skatepark_url(skatepark, protocol: 'https'),
      image: skatepark_schema_images(skatepark),
    }

    schema[:geo] = skatepark_schema_geo(skatepark) if skatepark.lat.present? && skatepark.lng.present?
    schema[:address] = skatepark_schema_address(skatepark) if skatepark.country_code.present?

    schema
  end

  def skatepark_schema_images(skatepark)
    images = [skatepark.cover_image&.url].compact
    images += skatepark.skatepark_images.filter_map do |skatepark_image|
      skatepark_image.image.url if skatepark_image.image.attached?
    end
    images.first(5)
  end

  def skatepark_schema_geo(skatepark)
    {
      '@type': 'GeoCoordinates',
      latitude: skatepark.lat,
      longitude: skatepark.lng,
    }
  end

  def skatepark_schema_address(skatepark)
    address = {
      '@type': 'PostalAddress',
      addressCountry: skatepark.country_code,
    }

    address[:addressRegion] = skatepark_schema_region(skatepark) if skatepark.state.present?

    address
  end

  def skatepark_schema_region(skatepark)
    country = ISO3166::Country[skatepark.country_code]
    subdivision = country&.subdivisions&.[](skatepark.state)
    subdivision&.name || skatepark.state
  end

  def collection_page_schema(skateparks)
    {
      '@context': 'https://schema.org',
      '@type': 'CollectionPage',
      '@id': skateparks_url(protocol: 'https'),
      name: 'Skateparks',
      description: t('application.meta_description', locale: :en),
      url: skateparks_url(protocol: 'https'),
      isPartOf: {
        '@id': "#{root_url(protocol: 'https')}#website",
      },
      mainEntity: {
        '@type': 'ItemList',
        numberOfItems: skateparks.respond_to?(:total_count) ? skateparks.total_count : skateparks&.size,
      },
    }
  end
end
