# frozen_string_literal: true

require "nokogiri"

module ArtworksParser
  ITEM_SELECTOR = "div.iELo6"
  NAME_SELECTOR = "div.pgNMRc"
  EXTENSIONS_SELECTOR = "div.cxzHyb"
  LINK_SELECTOR = "a"
  IMAGE_SELECTOR = "img.taFZJe"

  GOOGLE_BASE_URL = "https://www.google.com"
  DEFERRED_IMAGE_REGEX = /var s='(data:image\/[^']*)';var ii=\[([^\]]*)\]/

  module_function

  def parse(html)
    doc = Nokogiri::HTML(html)
    deferred = deferred_images(html)

    artworks = doc.css(ITEM_SELECTOR).map do |item|
      artwork = { "name" => item.at_css(NAME_SELECTOR)&.text }

      ext = item.at_css(EXTENSIONS_SELECTOR)&.text
      artwork["extensions"] = [ext] unless ext.nil? || ext.empty?

      artwork["link"] = GOOGLE_BASE_URL + item.at_css(LINK_SELECTOR)["href"]

      img = item.at_css(IMAGE_SELECTOR)
      artwork["image"] = img["data-src"] || deferred[img["id"]]

      artwork
    end
    { "artworks" => artworks }
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
