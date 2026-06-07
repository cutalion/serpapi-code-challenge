# frozen_string_literal: true

require 'nokolexbor'
require 'nokogiri'

# Catalog of html parser backends to compare in benchmarks.
module Parsers
  ALL = {
    nokolexbor: ->(html) { Nokolexbor::HTML(html) },
    nokogiri: ->(html) { Nokogiri::HTML(html) },
    nokogiri5: ->(html) { Nokogiri::HTML5(html) }
  }.freeze
end
