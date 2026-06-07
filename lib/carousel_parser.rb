# frozen_string_literal: true

require 'nokolexbor'

# Extracts a Google Knowledge Graph carousel (artworks, movies, books, etc.)
# from a saved SERP HTML page, with no additional HTTP requests.
class CarouselParser
  THUMBNAIL_SELECTOR = 'img[data-deferred], img[data-src]'
  CAROUSEL_LINK_MARKER = 'stick='
  DEFERRED_IMAGE_REGEX = %r{var s='(data:image/[^']*)';var ii=\[([^\]]*)\]}
  GOOGLE_BASE_URL = 'https://www.google.com'
  DEFAULT_PARSER = ->(html) { Nokolexbor::HTML(html) }

  def self.parse(html, parser: DEFAULT_PARSER)
    new(parser: parser).parse(html)
  end

  def initialize(parser: DEFAULT_PARSER)
    @parser = parser
  end

  def parse(html)
    doc = @parser.call(html)
    deferred = deferred_images(html)

    items = carousel_items(doc).map do |img, link|
      build_item(img, link, deferred)
    end

    { root_key => items }
  end

  private

  def deferred_images(html)
    html.scan(DEFERRED_IMAGE_REGEX).each_with_object({}) do |(data, ids), map|
      image = unescape_js(data)
      ids.scan(/'([^']*)'/).each { |(id)| map[id] = image }
    end
  end

  def carousel_items(doc)
    doc.css(THUMBNAIL_SELECTOR).filter_map do |img|
      link = img.ancestors('a').first
      [img, link] if link && link['href'].to_s.include?(CAROUSEL_LINK_MARKER)
    end
  end

  def build_item(img, link, deferred)
    name, date = labels(link)

    item = { 'name' => name }
    item['extensions'] = [date] if !date.nil? && !date.empty?
    item['link'] = GOOGLE_BASE_URL + link['href']
    item['image'] = img['data-src'] || deferred[img['id']]
    item
  end

  def labels(link)
    divs = link.css('div').select { |d| d.children.all?(&:text?) && !d.text.strip.empty? }
    divs.map { |d| d.text.gsub("\u00A0", ' ').strip }
  end

  # We might want to make this configurable in the future,
  # because Google shows the same carousel for different content types.
  # Like, movies, books, tv shows, etc.
  def root_key
    'artworks'
  end

  # Google escapes certain bytes in Base64 encoded images, like "=" symbols.
  def unescape_js(string)
    string.gsub(/\\x([0-9a-fA-F]{2})/) { ::Regexp.last_match(1).to_i(16).chr }
  end
end
