module Aqueduct
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def html_sanitizer(*attr_names)
      options = attr_names.last.is_a?(Hash) ? attr_names.pop : {}
      write_inheritable_attribute(:aqueduct_html_options, options)
      class_inheritable_reader :aqueduct_html_options

      attr_names.each { |attr_name| setup_callbacks_for(:html, attr_name) }

    end
    
    def css_sanitizer(*attr_names)
      options = attr_names.last.is_a?(Hash) ? attr_names.pop : {}
      write_inheritable_attribute(:aqueduct_css_options, options)
      class_inheritable_reader :aqueduct_css_options

      attr_names.each { |attr_name| setup_callbacks_for(:css, attr_name) }
    end
    
    def embed_sanitizer(*attr_names)
      options = attr_names.last.is_a?(Hash) ? attr_names.pop : {}
      write_inheritable_attribute(:aqueduct_embed_options, options)
      class_inheritable_reader :aqueduct_embed_options

      attr_names.each { |attr_name| setup_callbacks_for(:embed, attr_name) }
    end
    
    def setup_callbacks_for(processor, attr_name, options = {})
      case processor
      when :html
        parser = Aqueduct::HTML.new( aqueduct_html_options )
      when :css
        parser = Aqueduct::CSS.new(aqueduct_css_options)
      when :embed
        parser = Aqueduct::Embed.new(aqueduct_embed_options)
      end
      before_save do |record|
        record[attr_name.to_sym] = parser.sanitize(record[attr_name.to_sym])
      end
    end
  end
end
