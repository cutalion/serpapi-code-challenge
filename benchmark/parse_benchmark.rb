# frozen_string_literal: true

require 'benchmark/ips'
require 'carousel_parser'
require_relative 'parsers'
require_relative 'tee'

$stdout = Tee.new(File.expand_path('reports/parse_benchmark.txt', __dir__))

FIXTURES_DIR = File.expand_path('../spec/fixtures', __dir__)

fixtures = Dir[File.join(FIXTURES_DIR, '*.html')].sort.to_h do |path|
  [File.basename(path), File.read(path)]
end

puts "End-to-end parse across all fixtures, by html parser backend\n\n"

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  Parsers::ALL.each do |name, parser|
    x.report(name) { fixtures.each_value { |html| CarouselParser.parse(html, parser: parser) } }
  end

  x.compare!
end

$stdout.close
