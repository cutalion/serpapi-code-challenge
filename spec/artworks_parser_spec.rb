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

    it "returns all 47 artworks from the carousel" do
      result = described_class.parse(van_gogh_html)

      expect(result["artworks"].size).to eq(47)
    end

    it "extracts the name of the first artwork" do
      result = described_class.parse(van_gogh_html)

      expect(result["artworks"].first["name"]).to eq("The Starry Night")
    end

    it "extracts the extensions of the first artwork" do
      result = described_class.parse(van_gogh_html)

      expect(result["artworks"].first["extensions"]).to eq(["1889"])
    end

    it "omits the extensions key for an artwork with no date" do
      result = described_class.parse(van_gogh_html)
      sunflowers = result["artworks"].find { |a| a["name"] == "Sunflowers" }

      expect(sunflowers).not_to have_key("extensions")
    end

    it "extracts the absolute, entity-decoded link of the first artwork" do
      result = described_class.parse(van_gogh_html)

      expect(result["artworks"].first["link"]).to eq(
        "https://www.google.com/search?sca_esv=c2e426814f4d07e9&gl=us&hl=en" \
        "&q=The+Starry+Night&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLFMzC3jC7" \
        "WUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxYtYBUIyUhWCSxKLiioV_DLTM0oAdKX0-E" \
        "4AAAA&sa=X&ved=2ahUKEwjK-K-JwLWKAxXcQTABHePpOFoQtq8DegQIMxAD"
      )
    end

    it "extracts the gstatic thumbnail url for an eagerly-loaded artwork" do
      result = described_class.parse(van_gogh_html)
      artwork = result["artworks"].find { |a| a["name"] == "Self-Portrait with Bandaged Ear" }

      expect(artwork["image"]).to start_with("https://encrypted-tbn0.gstatic.com/images?q=tbn:")
    end

    it "extracts the inline base64 thumbnail for a deferred artwork" do
      result = described_class.parse(van_gogh_html)

      expect(result["artworks"].first["image"]).to start_with("data:image/jpeg;base64,")
    end
  end
end
