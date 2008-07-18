class Aqueduct::HTML

   # Options
   #   :append => 'z3_' # Used to scope HTML id attribute.
   def initialize(options={})
     @options = { }.merge options
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
    append_id(@options[:append]) unless @options[:append].nil?

    @options[:formatted] == false ? @doc.to_html.gsub(/\r|\n/i,'') : @doc.to_html 
  end
  
  def sandbox(input, appendum)
    return "" if input.empty?
    @doc = Hpricot(input)
    append_id(appendum) unless appendum.empty?
    @doc.to_html
  end
  
protected
  
  def append_id(appendum)
    (@doc/'[@id]').each { |e| e.set_attribute('id', appendum.to_s + "_#{e.attributes['id']}" )  }
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