# frozen_string_literal: true

require "nokogiri"

module CarouselParser
  THUMBNAIL_SELECTOR = "img[data-deferred], img[data-src]"
  CAROUSEL_LINK_MARKER = "stick="

  GOOGLE_BASE_URL = "https://www.google.com"
  DEFERRED_IMAGE_REGEX = /var s='(data:image\/[^']*)';var ii=\[([^\]]*)\]/

  module_function

  def parse(html)
    doc = Nokogiri::HTML(html)
    deferred = deferred_images(html)

    items = carousel_items(doc).map do |img, link|
      name, date = labels(link)

      item = { "name" => name }
      item["extensions"] = [date] unless date.nil? || date.empty?
      item["link"] = GOOGLE_BASE_URL + link["href"]
      item["image"] = img["data-src"] || deferred[img["id"]]
      item
    end
    { root_key => items }
  end

  # We might want to make this configurable in the future,
  # because Google shows the same carousel for different content types.
  # Like, movies, books, tv shows, etc.
  def root_key
    "artworks"
  end

  def carousel_items(doc)
    doc.css(THUMBNAIL_SELECTOR).filter_map do |img|
      link = img.ancestors("a").first
      [img, link] if link && link["href"].to_s.include?(CAROUSEL_LINK_MARKER)
    end
  end

  def labels(link)
    divs = link.css("div").select { |d| d.children.all?(&:text?) && !d.text.strip.empty? }
    divs.first(2).map { |d| d.text.gsub("\u00A0", " ").strip }
  end

  def deferred_images(html)
    html.scan(DEFERRED_IMAGE_REGEX).each_with_object({}) do |(data, ids), map|
      image = unescape_js(data)
      ids.scan(/'([^']*)'/).each { |(id)| map[id] = image }
    end
  end

  def unescape_js(string)
    string.gsub(/\\x([0-9a-fA-F]{2})/) { $1.to_i(16).chr }
  end
end
