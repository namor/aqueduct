require File.expand_path(File.dirname(__FILE__) + '/filters')

class Aqueduct::CSS 
  class DocumentHandler < CSS::SAC::DocumentHandler
  
    include Aqueduct::CSS::Filters
  
    # List of selectors that should be removed or sanitized
    @@bad_selectors = %w(body html script doctype)
    
    def initialize(options)
      @options = options
      @options[:filters] ||= Aqueduct::CSS::Filters.public_instance_methods
      @output = ""
      @properties = []
    end
  
    def start_selector(selectors)
      # Defer processing selectors until end_selector callback
    end
  
    def end_selector(selectors)
      # Find bad selectors
      bad_selectors = find_bad_selectors(selectors)
    
      # If all selectors are bad, don't scope at all
      if has_only_bad_selectors?(selectors, bad_selectors)
        processed_selectors = selectors.map { |s| s.to_css }
      else
        good_selectors = selectors - bad_selectors
        processed_selectors = good_selectors.map { |s| scope_selectors(s.to_css, @options[:append]) }
      end
    
      @output += processed_selectors.join(", ") + " {#{ @options[:formatted] ? "\n" : "" }"
    
      # Remove all properties if all selectors are bad, else just comment out bad properties
      if has_only_bad_selectors?(selectors, bad_selectors)
        @output += " /* Don't do this */#{ @options[:formatted] ? "\n" : "" }"
      else    
        unless @properties.empty?
          @properties.each do |property|
            property[:valid] = is_a_valid?(property)
            @output += " /*" unless property[:valid]
            @output += " #{property[:name]}: #{property[:value].join(' ')}#{property[:important] ? " !important" : ""};"
            @output += " - Don't do this */" unless property[:valid]
            @output += "\n" if @options[:formatted]
          end
        end
      end
      @output += @options[:formatted] ? "}\n\n" : " }"
      @properties.clear
    end

    def property(name, value, important)
      @properties << { :name => name, :value => value, :important => important, :valid => true }
    end
  
    def to_css
      return @output
    end
  
  private
  
    def scope_selectors(selector, append=nil)
      return selector if append.nil?
      selector.gsub!("#", "#{append}_")
      return append + " " + selector
    end
  
    def has_only_bad_selectors?(selectors, bad_selectors)
      selectors.size == bad_selectors.size
    end
  
    def find_bad_selectors(selectors)
      bad_selectors = []
      selectors.each do |selector|
        selector.to_css.split(" ").each { |s| bad_selectors << selector if @@bad_selectors.include?(s) }
      end
      return bad_selectors.uniq
    end

    def is_a_valid?(property)  
      for filter in @options[:filters]
        return false unless send(filter, property)
      end
      return true
    end
  
  end
end