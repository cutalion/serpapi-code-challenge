# frozen_string_literal: true

require 'memory_profiler'
require 'carousel_parser'
require_relative 'parsers'
require_relative 'tee'

fixture = ARGV[0] || 'van-gogh-paintings.html'
backend = (ARGV[1] || 'nokolexbor').to_sym
parser = Parsers::ALL.fetch(backend)

html = File.read(File.expand_path("../spec/fixtures/#{fixture}", __dir__))

report_name = "memory_profile-#{File.basename(fixture, '.html')}-#{backend}.txt"
$stdout = Tee.new(File.expand_path("reports/#{report_name}", __dir__))

carousel = CarouselParser.new(parser: parser)
carousel.parse(html)

report = MemoryProfiler.report { carousel.parse(html) }

puts "Memory profile: #{fixture} via #{backend} (#{html.bytesize / 1024} KB input)\n\n"
report.pretty_print(scale_bytes: true)

$stdout.close
