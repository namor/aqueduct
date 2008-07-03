require File.dirname(__FILE__) + '/css/document_handler'

class Aqueduct::CSS
  
  # Options
  #   :append => 'z3_' # Used to scope CSS selectors.
  #   :filters => Filters to run when sanitizing. Use Aqueduct::CSS.filters to see the list of filters available
  #   :formatted => true # Adds whitespace/line breaks to format CSS nicely by default
  def initialize(options={})
    @options = options    
    @options[:formatted] = true unless @options[:formatted] == false # Format output by default
  end

  # Sanitize a CSS file
  def sanitize(input)
    return "" if input.nil? or input.empty?
      
    # Sanitize to CSS2.1
    parser = CSS::SAC::Parser.new
    doc = parser.parse(input).to_css
    
    # Sandbox CSS
    parser = CSS::SAC::Parser.new(Aqueduct::CSS::DocumentHandler.new(@options))
    parser.parse(doc).to_css
  
  rescue
    return ""
  end
  
  # List of filters available
  def self.filters
    Aqueduct::CSS::Filters.public_instance_methods
  end
  
end

#remove_tags(self.blacklisted_tags - option[:allowed_tags])