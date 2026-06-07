# frozen_string_literal: true

require 'fileutils'

class Tee
  def initialize(path)
    FileUtils.mkdir_p(File.dirname(path))
    @console = $stdout
    @file = File.open(path, 'w')
  end

  def method_missing(name, *args, &block)
    @file.public_send(name, *args, &block) if @file.respond_to?(name)
    @console.public_send(name, *args, &block)
  end

  def respond_to_missing?(name, include_private = false)
    @console.respond_to?(name, include_private)
  end

  def close
    @file.close
  end
end
