# frozen_string_literal: true

require "carousel_parser"

RSpec.describe CarouselParser do
  let(:fixtures_dir) { File.expand_path("../fixtures", __dir__) }
  let(:van_gogh_html) { File.read(File.join(fixtures_dir, "van-gogh-paintings.html")) }
  let(:expected) { JSON.parse(File.read(File.join(fixtures_dir, "expected-array.json"))) }

  describe ".parse" do
    it "matches the expected array exactly" do
      result = described_class.parse(van_gogh_html)

      expect(result).to eq(expected)
    end
  end
end
