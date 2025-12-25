require 'rails_helper'

# rubocop:disable RSpec/VerifiedDoubles
RSpec.describe SchemaHelper do
  let(:skatepark) do
    instance_double(
      Skatepark,
      name: 'Test Skatepark',
      slug: 'test-skatepark',
      lat: 37.9838,
      lng: 23.7275,
      country_code: 'GR',
      state: 'I',
      cover_image: double(url: 'https://example.com/cover.jpg'),
      images: double(attached?: true, map: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg']),
      description: double(to_plain_text: 'A great skatepark in Athens')
    )
  end

  let(:skateparks) do
    double(total_count: 42, size: 10)
  end

  before do
    allow(helper).to receive_messages(
      controller_name: 'skateparks',
      action_name: 'index',
      root_url: 'https://skateparks.gr/',
      skateparks_url: 'https://skateparks.gr/skateparks',
      skatepark_url: 'https://skateparks.gr/skateparks/test-skatepark',
      url_for: 'https://skateparks.gr/current-page',
      image_url: 'https://skateparks.gr/og_image.png'
    )
    allow(helper).to receive(:t).with('application.title', locale: :en).and_return('skateparks.gr')
    allow(helper).to receive(:t).with('application.meta_description', locale: :en).and_return('Discover skateparks')
  end

  describe '#json_ld_schema' do
    it 'generates script tag with JSON-LD' do
      result = helper.json_ld_schema(skateparks: skateparks)
      expect(result).to include('<script type="application/ld+json">')
      expect(result).to include('</script>')
    end

    it 'includes organization schema' do
      result = helper.json_ld_schema(skateparks: skateparks)
      parsed = JSON.parse(result.match(%r{>(.+)</script>}m)[1])
      org_schema = parsed.find { |s| s['@type'] == 'Organization' }
      expect(org_schema).to be_present
      expect(org_schema['name']).to eq('skateparks.gr')
    end

    it 'includes website schema' do
      result = helper.json_ld_schema(skateparks: skateparks)
      parsed = JSON.parse(result.match(%r{>(.+)</script>}m)[1])
      website_schema = parsed.find { |s| s['@type'] == 'WebSite' }
      expect(website_schema).to be_present
      expect(website_schema['inLanguage']).to eq(%w[el en])
    end

    context 'for skateparks#show' do
      before do
        allow(helper).to receive_messages(controller_name: 'skateparks', action_name: 'show')
      end

      it 'includes skatepark schema' do
        result = helper.json_ld_schema(skatepark: skatepark)
        parsed = JSON.parse(result.match(%r{>(.+)</script>}m)[1])
        sp_schema = parsed.find { |s| s['@type'] == 'SportsActivityLocation' }
        expect(sp_schema).to be_present
        expect(sp_schema['name']).to eq('Test Skatepark')
      end
    end

    context 'for skateparks#index' do
      before do
        allow(helper).to receive_messages(controller_name: 'skateparks', action_name: 'index')
      end

      it 'includes collection page schema' do
        result = helper.json_ld_schema(skateparks: skateparks)
        parsed = JSON.parse(result.match(%r{>(.+)</script>}m)[1])
        collection_schema = parsed.find { |s| s['@type'] == 'CollectionPage' }
        expect(collection_schema).to be_present
      end
    end

    context 'for other pages' do
      before do
        allow(helper).to receive_messages(controller_name: 'home', action_name: 'about')
      end

      it 'includes webpage schema' do
        result = helper.json_ld_schema(title: 'About', meta_description: 'About us')
        parsed = JSON.parse(result.match(%r{>(.+)</script>}m)[1])
        webpage_schema = parsed.find { |s| s['@type'] == 'WebPage' }
        expect(webpage_schema).to be_present
        expect(webpage_schema['name']).to eq('About')
      end
    end
  end

  describe '#organization_schema' do
    it 'generates organization schema' do
      schema = helper.send(:organization_schema)
      expect(schema[:@context]).to eq('https://schema.org')
      expect(schema[:@type]).to eq('Organization')
      expect(schema[:name]).to eq('skateparks.gr')
      expect(schema[:url]).to eq('https://skateparks.gr/')
    end
  end

  describe '#website_schema' do
    it 'generates website schema' do
      schema = helper.send(:website_schema)
      expect(schema[:@context]).to eq('https://schema.org')
      expect(schema[:@type]).to eq('WebSite')
      expect(schema[:name]).to eq('skateparks.gr')
      expect(schema[:inLanguage]).to eq(%w[el en])
    end

    it 'includes search action' do
      schema = helper.send(:website_schema)
      expect(schema[:potentialAction][:@type]).to eq('SearchAction')
      expect(schema[:potentialAction][:target][:urlTemplate]).to include('search={search_term_string}')
    end
  end

  describe '#webpage_schema' do
    it 'generates webpage schema with provided title' do
      schema = helper.send(:webpage_schema, title: 'Test Page', meta_description: 'Test description', meta_image: 'https://example.com/img.jpg')
      expect(schema[:@type]).to eq('WebPage')
      expect(schema[:name]).to eq('Test Page')
      expect(schema[:description]).to eq('Test description')
      expect(schema[:image]).to eq('https://example.com/img.jpg')
    end

    it 'uses defaults when values are blank' do
      schema = helper.send(:webpage_schema, title: '', meta_description: '', meta_image: '')
      expect(schema[:name]).to eq('skateparks.gr')
      expect(schema[:description]).to eq('Discover skateparks')
      expect(schema[:image]).to eq('https://skateparks.gr/og_image.png')
    end

    it 'includes isPartOf reference' do
      schema = helper.send(:webpage_schema)
      expect(schema[:isPartOf][:@id]).to eq('https://skateparks.gr/#website')
    end
  end

  describe '#skatepark_schema' do
    it 'generates skatepark schema with basic info' do
      schema = helper.send(:skatepark_schema, skatepark)
      expect(schema[:@type]).to eq('SportsActivityLocation')
      expect(schema[:name]).to eq('Test Skatepark')
      expect(schema[:description]).to eq('A great skatepark in Athens')
    end

    it 'includes geo coordinates' do
      schema = helper.send(:skatepark_schema, skatepark)
      expect(schema[:geo][:@type]).to eq('GeoCoordinates')
      expect(schema[:geo][:latitude]).to eq(37.9838)
      expect(schema[:geo][:longitude]).to eq(23.7275)
    end

    it 'includes address with country code' do
      schema = helper.send(:skatepark_schema, skatepark)
      expect(schema[:address][:@type]).to eq('PostalAddress')
      expect(schema[:address][:addressCountry]).to eq('GR')
    end

    it 'includes address region when state is present' do
      schema = helper.send(:skatepark_schema, skatepark)
      expect(schema[:address][:addressRegion]).to be_present
    end

    it 'includes cover image and images' do
      schema = helper.send(:skatepark_schema, skatepark)
      expect(schema[:image]).to include('https://example.com/cover.jpg')
      expect(schema[:image]).to include('https://example.com/img1.jpg')
    end

    it 'limits images to first 5' do
      images_double = double(attached?: true, map: (1..10).map { |i| "https://example.com/img#{i}.jpg" })
      allow(skatepark).to receive(:images).and_return(images_double)
      schema = helper.send(:skatepark_schema, skatepark)
      expect(schema[:image].size).to eq(5)
    end

    context 'without geo coordinates' do
      before do
        allow(skatepark).to receive_messages(lat: nil, lng: nil)
      end

      it 'does not include geo field' do
        schema = helper.send(:skatepark_schema, skatepark)
        expect(schema[:geo]).to be_nil
      end
    end

    context 'without country code' do
      before do
        allow(skatepark).to receive(:country_code).and_return(nil)
      end

      it 'does not include address field' do
        schema = helper.send(:skatepark_schema, skatepark)
        expect(schema[:address]).to be_nil
      end
    end

    context 'without images attached' do
      before do
        allow(skatepark).to receive_messages(cover_image: nil, images: double(attached?: false))
      end

      it 'has empty images array' do
        schema = helper.send(:skatepark_schema, skatepark)
        expect(schema[:image]).to eq([])
      end
    end
  end

  describe '#collection_page_schema' do
    it 'generates collection page schema' do
      schema = helper.send(:collection_page_schema, skateparks)
      expect(schema[:@type]).to eq('CollectionPage')
      expect(schema[:name]).to eq('Skateparks')
      expect(schema[:url]).to eq('https://skateparks.gr/skateparks')
    end

    it 'includes item list with total count' do
      schema = helper.send(:collection_page_schema, skateparks)
      expect(schema[:mainEntity][:@type]).to eq('ItemList')
      expect(schema[:mainEntity][:numberOfItems]).to eq(42)
    end

    it 'uses size when total_count is not available' do
      simple_skateparks = [double, double, double]
      schema = helper.send(:collection_page_schema, simple_skateparks)
      expect(schema[:mainEntity][:numberOfItems]).to eq(3)
    end

    it 'includes isPartOf reference' do
      schema = helper.send(:collection_page_schema, skateparks)
      expect(schema[:isPartOf][:@id]).to eq('https://skateparks.gr/#website')
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
