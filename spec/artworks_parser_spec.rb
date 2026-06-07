# frozen_string_literal: true

require "artworks_parser"

RSpec.describe ArtworksParser do
  let(:fixtures_dir) { File.expand_path("fixtures", __dir__) }
  let(:van_gogh_html) { File.read(File.join(fixtures_dir, "van-gogh-paintings.html")) }

  describe ".parse" do
    it "returns a hash with an artworks array" do
      result = described_class.parse(van_gogh_html)

      expect(result).to be_a(Hash)
      expect(result["artworks"]).to be_an(Array)
    end
  end
end
