# frozen_string_literal: true

require 'benchmark/ips'
require 'carousel_parser'
require_relative 'tee'

$stdout = Tee.new(File.expand_path('reports/parse_benchmark.txt', __dir__))

FIXTURES_DIR = File.expand_path('../spec/fixtures', __dir__)

fixtures = Dir[File.join(FIXTURES_DIR, '*.html')].sort.to_h do |path|
  [File.basename(path), File.read(path)]
end

total_kb = fixtures.sum { |_, html| html.bytesize } / 1024
puts "Parsing #{fixtures.size} fixtures (#{total_kb} KB total)\n\n"

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  fixtures.each do |name, html|
    x.report(name) { CarouselParser.new.parse(html) }
  end

  x.compare!
end

puts "\nEnd-to-end parse across all fixtures, by html parser backend\n\n"

parsers = CarouselParser::HTML_PARSERS.to_h { |backend| [backend, CarouselParser.new(html_parser: backend)] }

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  parsers.each do |backend, parser|
    x.report(backend) { fixtures.each_value { |html| parser.parse(html) } }
  end

  x.compare!
end

$stdout.close
