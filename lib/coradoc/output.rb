require "coradoc"

module Coradoc
  module Output
    @processors = {}
    extend Converter::CommonInputOutputMethods
  end
end

require "coradoc/output/adoc"
