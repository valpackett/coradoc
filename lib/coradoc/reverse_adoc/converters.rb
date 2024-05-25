module Coradoc::ReverseAdoc
  module Converters
    def self.register(tag_name, converter)
      @@converters ||= {}
      @@converters[tag_name.to_sym] = converter
    end

    def self.unregister(tag_name)
      @@converters.delete(tag_name.to_sym)
    end

    def self.lookup(tag_name)
      @@converters[tag_name.to_sym] or default_converter(tag_name)
    end

    # Note: process won't run plugin hooks
    def self.process(node, state)
      lookup(node.name).convert(node, state)
    end

    def self.process_coradoc(node, state)
      plugins = state[:plugin_instances] || {}
      process = proc { lookup(node.name).to_coradoc(node, state) }
      plugins.each do |i|
        prev_process = process
        process = proc { i.html_tree_run_hooks(node, state, &prev_process) }
      end
      process.(node, state)
    end

    def self.default_converter(tag_name)
      case Coradoc::ReverseAdoc.config.unknown_tags.to_sym
      when :pass_through
        Coradoc::ReverseAdoc::Converters::PassThrough.new
      when :drop
        Coradoc::ReverseAdoc::Converters::Drop.new
      when :bypass
        Coradoc::ReverseAdoc::Converters::Bypass.new
      when :raise
        raise UnknownTagError, "unknown tag: #{tag_name}"
      else
        raise InvalidConfigurationError,
              "unknown value #{Coradoc::ReverseAdoc.config.unknown_tags.inspect} for Coradoc::ReverseAdoc.config.unknown_tags"
      end
    end
  end
end
