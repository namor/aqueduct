class Aqueduct::HTML

  # Options
   #   :append => 'z3_' # Used to scope CSS selectors.
   #   :filters => ['remove_javascript_from_url'] # Filter javascript from url()
   def initialize(options={})
     @options = { :append => "" }.merge options
     Aqueduct::RailsSanitizer.sanitized_allowed_attributes = "id"
   end

  # Sanitize a HTML file
  def sanitize(input, options={})
    return "" if input.nil? or input.empty?
    
    # Only take elements inside of <body>
    @doc = Hpricot(input)
    @doc = Hpricot(@doc.at("body").inner_html) if @doc.at("body")
    sanitized = Aqueduct::RailsSanitizer.white_list_sanitizer.sanitize(@doc.to_html)

    # Start parsing sanitized doc
    @doc = Hpricot(sanitized)

    # Rewrite all id's to appened network_key
    append_id(@options[:append]) unless @options[:append].empty?

    @options[:formatted] == false ? @doc.to_html.gsub(/\r|\n/i,'') : @doc.to_html 
  end
=begin
  # Use tidy to clean up HTML (Not needed)
  # Fix </noembed> blogger hack (should work)
  # Fix </div> hack (should work)
  # Clean up HTML before parsing
  # Strip all tags that are used outside of <body>
  def tidy_up(html)
    cleaned_up = Tidy.open(:show_warnings=>true) do |tidy|
      tidy.options.show_body_only = true
      tidy.options.output_xhtml = true
      tidy.options.indent = 'auto'
      tidy.options.wrap = 0
      tidy.options.input_encoding = 'utf8'
      tidy.options.char_encoding = 'utf8'
      tidy.options.output_encoding = 'utf8'
      
      # Unicode / Escape Stuff
      #tidy.options.clean = true
      tidy.options.escape_cdata = true
      tidy.options.punctuation_wrap = true  # Line Wrap Unicode 
      tidy.options.qoute_marks = true       # Change " to &qout;
      
      cleaned_up = tidy.clean(html)
      puts tidy.errors
      puts tidy.diagnostics
      cleaned_up
    end
  end
=end
protected
  
  def append_id(id)
    (@doc/'[@id]').each { |e| e.set_attribute('id', @options[:append].to_s + "_#{e.attributes['id']}" )  }
  end
  
  def remove_attributes(attributes = [] )
    attributes.each { |a| (@doc/"[@#{a}]").each { |e| e.remove_attribute(a) } }
    @doc
  end
  
  def remove_javascript_events
    js = %w(onload onunload onchange onsubmit onreset onselect onblur onfocus onkeydown onkeypress onkeyup onclick ondblclick onmousedown onmousemove onmouseover onmouseout onmouseup onactivate onafterprint onafterupdate onbeforeactivate onbeforecopy onbeforecut onbeforedeactivate onbeforeeditfocus onbeforepaste onbeforeprint onbeforeunload onbeforeupdate onbounce oncontextmenu oncontrolselect oncopy oncut ondataavailable ondatasetchanged ondeactivate ondrag ondragend ondragenter ondragleave ondragover ondragstart ondrop onerror onerrorupdate onfilterchange onfinish onfocusin onfocusout onhelp onlayoutcomplete onlosecapture onmouseenter onmouseleave onmousewheel onmove onmoveend onmovestart onpaste onpropertychange onreadystatechanged onresize onresizeend onresizestart onrowenter onrowexit onrowsdelete onrowsinserted onscroll onselectionchange onstart onstop ontimeerror)
    remove_attributes(js)
  end
  
  def remove_tags(tags = [])
    (@doc/tags.join(',')).remove
  end
  
end


# HTML Tags
=begin    
  <head> 	
  <title> 
  <meta> 	
  <base> 	
  <basefont>
  <style>
  <!DOCTYPE>  
  <html> 
  <body>
=end
    
    # Javascript events
=begin
    onload
    onunload
    onchange
    onsubmit
    onreset
    onselect
    onblur
    onfocus
    onkeydown
    onkeypress
    onkeyup
    onclick
    ondblclick
    onmousedown
    onmousemove
    onmouseover
    onmouseout
    onmouseup
=end
    
    # Extended Javascript Events
=begin
    onactivate
    onafterprint
    onafterupdate
    onbeforeactivate
    onbeforecopy
    onbeforecut
    onbeforedeactivate
    onbeforeeditfocus
    onbeforepaste
    onbeforeprint
    onbeforeunload
    onbeforeupdate
    onbounce
    oncontextmenu
    oncontrolselect
    oncopy
    oncut
    ondataavailable
    ondatasetchanged
    ondeactivate
    ondrag
    ondragend
    ondragenter
    ondragleave
    ondragover
    ondragstart
    ondrop
    onerror
    onerrorupdate
    onfilterchange
    onfinish
    onfocusin
    onfocusout
    onhelp
    onlayoutcomplete
    onlosecapture
    onmouseenter
    onmouseleave
    onmousewheel
    onmove
    onmoveend
    onmovestart
    onpaste
    onpropertychange
    onreadystatechanged
    onresize
    onresizeend
    onresizestart
    onrowenter
    onrowexit
    onrowsdelete
    onrowsinserted
    onscroll
    onselectionchange
    onstart
    onstop
    ontimeerror
=end