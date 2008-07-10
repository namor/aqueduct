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
      before_save do |record|
        case processor
        when :html
          aqueduct_html_options[:append] = record.send(aqueduct_html_options[:append]) if aqueduct_html_options[:append].is_a? Symbol
          parser = Aqueduct::HTML.new( aqueduct_html_options )
          record.send(aqueduct_html_options[:before]) if aqueduct_html_options[:before].is_a? Symbol
          record[attr_name.to_sym] = parser.sanitize(record[attr_name.to_sym])
          record.send(aqueduct_html_options[:after]) if aqueduct_html_options[:after].is_a? Symbol
        when :css
          parser = Aqueduct::CSS.new(aqueduct_css_options)
          record[attr_name.to_sym] = parser.sanitize(content)
        when :embed
          parser = Aqueduct::Embed.new(aqueduct_embed_options)
          record[attr_name.to_sym] = parser.sanitize(content)
        end
      end
    end
  end
end
