require File.dirname(__FILE__) + '/spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../lib/aqueduct')

describe "Aqueduct::Embed" do
  
  it "should raise EmbedSrcMissingOrInvalid exception if embed code is bad" do
    input = "rubbish"
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should raise_error(Aqueduct::Embed::EmbedSrcMissingOrInvalid)
  end
  
  it "should raise UnsupportedService exception if embed code's object movie param url is unsupported" do
    input = <<-EMBED_CODE
      <object width="425" height="344">
        <param name="movie" value="http://www.youtube.com/v/9M1LYOteNXQ&hl=en&fs=1&rel=0&color1=0x402061&color2=0x9461ca"></param>
        <param name="allowFullScreen" value="true"></param>
        <embed src="http://some-other.youtube.com/v/9M1LYOteNXQ&hl=en&fs=1&rel=0&color1=0x402061&color2=0x9461ca" type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344"></embed>
      </object>
    EMBED_CODE
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should raise_error(Aqueduct::Embed::UnsupportedService)
  end
  
  it "should resize the embed object it's width/height is higher than those set" do
    input = <<-EMBED_CODE
      <object width="425" height="344">
        <param name="movie" value="http://www.youtube.com/v/9M1LYOteNXQ&hl=en&fs=1&rel=0&color1=0x402061&color2=0x9461ca"></param>
        <param name="allowFullScreen" value="true"></param>
        <embed src="http://www.youtube.com/v/9M1LYOteNXQ&hl=en&fs=1&rel=0&color1=0x402061&color2=0x9461ca" type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344"></embed>
      </object>
    EMBED_CODE
    options = { :width => 300, :height => 200 }
    output = Hpricot(Aqueduct::Embed.new(input, options).sanitize)
    output.at("embed")[:width].should == "300"
    output.at("embed")[:height].should == "200"
  end  
  
  it "should pass if embed code is from Youtube" do
    input = <<-EMBED_CODE
      <object width="425" height="344">
        <param name="movie" value="http://www.youtube.com/v/9M1LYOteNXQ&hl=en&fs=1&rel=0&color1=0x402061&color2=0x9461ca"></param>
        <param name="allowFullScreen" value="true"></param>
        <embed src="http://www.youtube.com/v/9M1LYOteNXQ&hl=en&fs=1&rel=0&color1=0x402061&color2=0x9461ca" type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344"></embed>
      </object>
    EMBED_CODE
    options = {}
    lambda { output = Aqueduct::Embed.new(input, options).sanitize }.should_not raise_error
  end
  
  it "should pass if embed code is from Viddler" do
    input = <<-EMBED_CODE
      <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="437" height="370" id="viddler">
        <param name="movie" value="http://www.viddler.com/player/be728d65/" /><param name="allowScriptAccess" value="always" />
        <param name="allowFullScreen" value="true" />
        <embed src="http://www.viddler.com/player/be728d65/" width="437" height="370" type="application/x-shockwave-flash" allowScriptAccess="always" allowFullScreen="true" name="viddler" ></embed>
      </object>
    EMBED_CODE
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should_not raise_error
  end
  
  it "should pass if embed code is from Vimeo" do
    input = <<-EMBED_CODE
      <object width="400" height="225">
        <param name="allowfullscreen" value="true" />	<param name="allowscriptaccess" value="always" />
        <param name="movie" value="http://www.vimeo.com/moogaloop.swf?clip_id=1264493&amp;server=www.vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" />
        <embed src="http://www.vimeo.com/moogaloop.swf?clip_id=1264493&amp;server=www.vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="400" height="225"></embed>
      </object>
      <br /><a href="http://www.vimeo.com/1264493?pg=embed&sec=1264493">Here & There - (2008)</a> from <a href="http://www.vimeo.com/kidney?pg=embed&sec=1264493">Eoghan Kidney</a> on <a href="http://vimeo.com?pg=embed&sec=1264493">Vimeo</a>.
    EMBED_CODE
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should_not raise_error
  end
  
  it "should pass if embed code is from Google Video" do
    input = <<-EMBED_CODE
      <embed id="VideoPlayback" style="width:400px;height:326px" allowFullScreen="true" src="http://video.google.com/googleplayer.swf?docid=3738248642864400317&hl=en&fs=true" type="application/x-shockwave-flash"></embed>
    EMBED_CODE
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should_not raise_error
  end
  
  it "should pass if embed code is from SlideShare" do
    input = <<-EMBED_CODE
      <div style="width:425px;text-align:left" id="__ss_503277">
        <object style="margin:0px" width="425" height="355">
          <param name="movie" value="http://static.slideshare.net/swf/ssplayer2.swf?doc=openidopentech-1215468812901101-9"/>
          <param name="allowFullScreen" value="true"/><param name="allowScriptAccess" value="always"/>
          <embed src="http://static.slideshare.net/swf/ssplayer2.swf?doc=openidopentech-1215468812901101-9" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="355"></embed>
        </object>
        <div style="font-size:11px;font-family:tahoma,arial;height:26px;padding-top:2px;">
          <a href="http://www.slideshare.net/?src=embed"><img src="http://static.slideshare.net/swf/logo_embd.png" style="border:0px none;margin-bottom:-5px" alt="SlideShare"/></a> | 
          <a href="http://www.slideshare.net/simon/openid-at-open-tech-2008?src=embed" title="View OpenID at Open Tech 2008 on SlideShare">View</a> | 
          <a href="http://www.slideshare.net/upload?src=embed">Upload your own</a>
        </div>
      </div>
    EMBED_CODE
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should_not raise_error
  end
  
  it "should pass if embed code is from Scribd" do
    input = <<-EMBED_CODE
      <object codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" id="doc_581746353795770" name="doc_581746353795770" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" align="middle"	height="500" width="100%">
        <param name="movie"	value="http://documents.scribd.com/ScribdViewer.swf?document_id=2522842&access_key=key-1c2d9x8zhgw4so6sndvl&page=&version=1&auto_size=true">
        <param name="quality" value="high">
        <param name="play" value="true">
        <param name="loop" value="true">
        <param name="scale" value="showall">
        <param name="wmode" value="opaque">
        <param name="devicefont" value="false">
        <param name="bgcolor" value="#ffffff">
        <param name="menu" value="true">
        <param name="allowFullScreen" value="true">
        <param name="allowScriptAccess" value="always">
        <param name="salign" value="">
        <embed src="http://documents.scribd.com/ScribdViewer.swf?document_id=2522842&access_key=key-1c2d9x8zhgw4so6sndvl&page=&version=1&auto_size=true" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" play="true" loop="true" scale="showall" wmode="opaque" devicefont="false" bgcolor="#ffffff" name="doc_581746353795770_object" menu="true" allowfullscreen="true" allowscriptaccess="always" salign="" type="application/x-shockwave-flash" align="middle" height="500" width="100%"></embed>
      </object>
      <div style="font-size:10px;text-align:center;width:100%">
        <a href="http://www.scribd.com/doc/2522842/Ed-Rosenthals-Marijuana-Growing-Tips">Ed Rosenthal's Marijuana Growing Tips</a> - 
        <a href="http://www.scribd.com/upload">Upload a Document to Scribd</a>
      </div>
      <div style="display:none"> Read this document on Scribd: 
        <a href="http://www.scribd.com/doc/2522842/Ed-Rosenthals-Marijuana-Growing-Tips">Ed Rosenthal's Marijuana Growing Tips</a> 
      </div>
    EMBED_CODE
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should_not raise_error
  end
  
  it "should pass if embed code is from Project Playlist" do
    input = <<-EMBED_CODE
      <div style="text-align: center; margin-left: auto; visibility:visible; margin-right: auto; width:450px;">
        <embed style="width:435px; visibility:visible; height:270px;" allowScriptAccess="never" src="http://www.musicplaylist.us/mc/mp3player-othersite.swf?config=http://www.musicplaylist.us/mc/config/config_black.xml&mywidth=435&myheight=270&playlist_url=http://www.musicplaylist.us/loadplaylist.php?playlist=40318225" menu="false" quality="high" width="435" height="270" name="mp3player" wmode="transparent" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" border="0"/>
        <BR><a href=http://www.musicplaylist.us><img src=http://www.musicplaylist.us/mc/images/create_black.jpg border=0></a>
        <a href=http://www.musicplaylist.us/standalone/40318225 target=_blank><img src=http://www.musicplaylist.us/mc/images/launch_black.jpg border=0></a>
        <a href=http://www.musicplaylist.us/download/40318225><img src=http://www.musicplaylist.us/mc/images/get_black.jpg border=0></a>
      </div>
    EMBED_CODE
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should_not raise_error
  end
  
  it "should pass if embed code is from Veoh" do
    input = <<-EMBED_CODE
      <div id="viewport" style="background-color: rgb(0, 0, 0);">
      <embed id="viewportflashPlayer" width="540" height="438" align="middle" flashvars="contentRatingId=1&pFamilyFilter=on&dc_intel=true&dc_login=no&dc_publisher=RIPETV&dc_hasPublished=&dc_pro=&dc_age18=no&pGender=&isFwTest=false&pvrn=87295305&dc_ucategory=Entertainment&dc_site=video&dc_tile=1&dc_target=250&dc_videopermalink=v14678923K4bFBGtK&dc_veohtv=no&dc_sexy=false&dc_planguage=&pageUrl=http://www.veoh.com/videos/v14678923K4bFBGtK&searchTerm=&player=videodetails&permalinkId=v14678923K4bFBGtK&id=anonymous&playAuto=1&external=0&affiliateId=&pageUID=33316798&pcategory=pcategory=;&veohVisitorId=283646f3-aab6-4c62-ac11-2cda99884003&pPubStat=Studio" allowscriptaccess="always" allowfullscreen="true" wmode="opaque" quality="high" bgcolor="#000000" name="viewportflashPlayer" style="" src="http://www.veoh.com/static/flash/players/veohplayer.swf" type="application/x-shockwave-flash"/>
      </div>
    EMBED_CODE
    options = {}
    lambda { Aqueduct::Embed.new(input, options).sanitize }.should_not raise_error
  end
  
end
