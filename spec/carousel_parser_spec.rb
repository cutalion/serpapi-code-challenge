# frozen_string_literal: true

require 'carousel_parser'

RSpec.describe CarouselParser do
  let(:fixtures_dir) { File.expand_path('fixtures', __dir__) }
  let(:van_gogh_html) { File.read(File.join(fixtures_dir, 'van-gogh-paintings.html')) }

  describe '.parse' do
    it 'returns a hash with an artworks array' do
      result = described_class.parse(van_gogh_html)

      expect(result).to be_a(Hash)
      expect(result['artworks']).to be_an(Array)
    end

    it 'returns all 47 artworks from the carousel' do
      result = described_class.parse(van_gogh_html)

      expect(result['artworks'].size).to eq(47)
    end

    it 'extracts the name of the first artwork' do
      result = described_class.parse(van_gogh_html)

      expect(result['artworks'].first['name']).to eq('The Starry Night')
    end

    it 'extracts the extensions of the first artwork' do
      result = described_class.parse(van_gogh_html)

      expect(result['artworks'].first['extensions']).to eq(['1889'])
    end

    it 'omits the extensions key for an artwork with no date' do
      result = described_class.parse(van_gogh_html)
      sunflowers = result['artworks'].find { |a| a['name'] == 'Sunflowers' }

      expect(sunflowers).not_to have_key('extensions')
    end

    it 'extracts the absolute, entity-decoded link of the first artwork' do
      result = described_class.parse(van_gogh_html)

      expect(result['artworks'].first['link']).to eq(
        'https://www.google.com/search?sca_esv=c2e426814f4d07e9&gl=us&hl=en' \
        '&q=The+Starry+Night&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLFMzC3jC7' \
        'WUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxYtYBUIyUhWCSxKLiioV_DLTM0oAdKX0-E' \
        '4AAAA&sa=X&ved=2ahUKEwjK-K-JwLWKAxXcQTABHePpOFoQtq8DegQIMxAD'
      )
    end

    it 'extracts the gstatic thumbnail url for an eagerly-loaded artwork' do
      result = described_class.parse(van_gogh_html)
      artwork = result['artworks'].find { |a| a['name'] == 'Self-Portrait with Bandaged Ear' }

      expect(artwork['image']).to start_with('https://encrypted-tbn0.gstatic.com/images?q=tbn:')
    end

    it 'extracts the inline base64 thumbnail for a deferred artwork' do
      result = described_class.parse(van_gogh_html)

      expect(result['artworks'].first['image']).to start_with('data:image/jpeg;base64,')
    end
  end

  describe '.parse with a movies carousel layout' do
    let(:deniro_html) { File.read(File.join(fixtures_dir, 'deniro-movies.html')) }

    it 'returns all 12 movies from the carousel' do
      result = described_class.parse(deniro_html)

      expect(result['artworks'].size).to eq(12)
    end

    it 'extracts the name of the first movie' do
      result = described_class.parse(deniro_html)

      expect(result['artworks'].first['name']).to eq('Taxi Driver')
    end

    it 'extracts the release year as extensions' do
      result = described_class.parse(deniro_html)

      expect(result['artworks'].first['extensions']).to eq(['1976'])
    end

    it 'extracts the absolute link of the first movie' do
      result = described_class.parse(deniro_html)

      expect(result['artworks'].first['link']).to start_with(
        'https://www.google.com/search?'
      )
      expect(result['artworks'].first['link']).to include('q=Taxi+Driver+1976')
    end

    it 'extracts the inline base64 thumbnail of the first movie' do
      result = described_class.parse(deniro_html)

      expect(result['artworks'].first['image']).to start_with('data:image/jpeg;base64,')
    end
  end

  describe '.parse with a third artworks carousel layout' do
    let(:bosch_html) { File.read(File.join(fixtures_dir, 'bosch-artworks.html')) }

    it 'returns all 48 artworks from the carousel' do
      result = described_class.parse(bosch_html)

      expect(result['artworks'].size).to eq(48)
    end

    it 'extracts the name of the first artwork' do
      result = described_class.parse(bosch_html)

      expect(result['artworks'].first['name']).to eq('The Garden of Earthly Delights')
    end

    it 'extracts the extensions of the first artwork' do
      result = described_class.parse(bosch_html)

      expect(result['artworks'].first['extensions']).to eq(['1515'])
    end

    it 'extracts the inline base64 thumbnail of the first artwork' do
      result = described_class.parse(bosch_html)

      expect(result['artworks'].first['image']).to start_with('data:image/jpeg;base64,')
    end
  end

  describe '.parse with a tv shows carousel layout' do
    let(:tv_shows_html) { File.read(File.join(fixtures_dir, 'deniro-tv-shows.html')) }

    it 'returns all 12 tv shows from the carousel' do
      result = described_class.parse(tv_shows_html)

      expect(result['artworks'].size).to eq(12)
    end

    it 'extracts the name of the first tv show' do
      result = described_class.parse(tv_shows_html)

      expect(result['artworks'].first['name']).to eq('Zero Day')
    end

    it 'extracts a non-year date string as extensions' do
      result = described_class.parse(tv_shows_html)

      expect(result['artworks'].first['extensions']).to eq(['Since 2025'])
    end

    it 'extracts the inline base64 thumbnail of the first tv show' do
      result = described_class.parse(tv_shows_html)

      expect(result['artworks'].first['image']).to start_with('data:image/jpeg;base64,')
    end
  end

  describe '.parse with a books carousel layout' do
    let(:books_html) { File.read(File.join(fixtures_dir, 'shinkai-books.html')) }

    it 'returns all 12 books from the carousel' do
      result = described_class.parse(books_html)

      expect(result['artworks'].size).to eq(12)
    end

    it 'extracts the name of the first book' do
      result = described_class.parse(books_html)

      expect(result['artworks'].first['name']).to eq('Your Name')
    end

    it 'extracts the publication year as extensions' do
      result = described_class.parse(books_html)

      expect(result['artworks'].first['extensions']).to eq(['2016'])
    end

    it 'extracts the inline base64 thumbnail of the first book' do
      result = described_class.parse(books_html)

      expect(result['artworks'].first['image']).to start_with('data:image/jpeg;base64,')
    end
  end

  describe '.parse with a non-latin (Georgian) page' do
    let(:georgian_html) { File.read(File.join(fixtures_dir, 'shinkai-movies-ge.html')) }

    it 'returns all 12 movies from the carousel' do
      result = described_class.parse(georgian_html)

      expect(result['artworks'].size).to eq(12)
    end

    it 'extracts a non-latin name in its original script' do
      result = described_class.parse(georgian_html)

      expect(result['artworks'].first['name']).to eq('შენი სახელი')
    end

    it 'extracts the extensions of the first movie' do
      result = described_class.parse(georgian_html)

      expect(result['artworks'].first['extensions']).to eq(['2016'])
    end

    it 'omits the extensions key for a movie with no date' do
      result = described_class.parse(georgian_html)
      cross_road = result['artworks'].find { |a| a['name'] == 'Cross Road' }

      expect(cross_road).not_to have_key('extensions')
    end

    it 'extracts the inline base64 thumbnail of the first movie' do
      result = described_class.parse(georgian_html)

      expect(result['artworks'].first['image']).to start_with('data:image/jpeg;base64,')
    end
  end

  describe '.parse with a non-latin (Georgian) artworks page' do
    let(:georgian_artworks_html) { File.read(File.join(fixtures_dir, 'van-gogh-artworks-ge.html')) }

    it 'returns all 48 artworks from the carousel' do
      result = described_class.parse(georgian_artworks_html)

      expect(result['artworks'].size).to eq(48)
    end

    it 'extracts a non-latin name in its original script' do
      result = described_class.parse(georgian_artworks_html)

      expect(result['artworks'].first['name']).to eq('ვარსკვლავებიანი ღამე')
    end

    it 'extracts the extensions of the first artwork' do
      result = described_class.parse(georgian_artworks_html)

      expect(result['artworks'].first['extensions']).to eq(['1889'])
    end

    it 'omits the extensions key for an artwork with no date' do
      result = described_class.parse(georgian_artworks_html)
      sunflowers = result['artworks'].find { |a| a['name'] == 'Sunflowers' }

      expect(sunflowers).not_to have_key('extensions')
    end

    it 'extracts the inline base64 thumbnail of the first artwork' do
      result = described_class.parse(georgian_artworks_html)

      expect(result['artworks'].first['image']).to start_with('data:image/jpeg;base64,')
    end
  end
end
