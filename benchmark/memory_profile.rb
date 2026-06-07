# frozen_string_literal: true

require 'memory_profiler'
require 'nokolexbor'
require 'nokogiri'
require 'carousel_parser'
require_relative 'tee'

fixture = ARGV[0] || 'van-gogh-paintings.html'
html_parser = (ARGV[1] || 'nokolexbor').to_sym

html = File.read(File.expand_path("../spec/fixtures/#{fixture}", __dir__))

report_name = "memory_profile-#{File.basename(fixture, '.html')}-#{html_parser}.txt"
$stdout = Tee.new(File.expand_path("reports/#{report_name}", __dir__))

parser = CarouselParser.new(html_parser: html_parser)
parser.parse(html)

report = MemoryProfiler.report { parser.parse(html) }

puts "Memory profile: #{fixture} via #{html_parser} (#{html.bytesize / 1024} KB input)\n\n"
report.pretty_print(scale_bytes: true)

$stdout.close
