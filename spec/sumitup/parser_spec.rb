require 'spec_helper'

describe Sumitup::Parser do
  before do
    @image_width_limit = 200
    @parser = Sumitup::Parser.new(:max_images => 1000, :image_width_limit => @image_width_limit)
  end
  describe "summarize" do
    before do
      @html = %Q{
        <div class="entry clear"><!--more--><!-- BlogGlue Cache: No -->
        <p style="display:none;">Can't see this!</p>
        <p></p>
        <p>It's now a bit more than two weeks since I had an unfortunate incident with a serpent.  While the leg is actually healing quite nicely I the joy of 
        bending my knee has become a distant memory and a luxury I look forward to each day.  The antibiotics I am forced to continue leave my body in a semi d
        ebilitated state.  Each visit to the restroom is a vile reminder of my body's current inability to properly digest food.  At least I'm not allergic to the drug this time.  
        The last regiment of antibiotics set my skin on fire and made me appreciate the leper's state.</p>
        <p>My leg is healing and I think that the only permanent damage will be a pretty nasty scar.  I can live with that.  One of the truly odd 
        uirks of cyclists besides constant attempts to trim down to super model anorexic status and the tight shorts is the customary shaving of legs.  
        While some might contend the traditionally feminine activity helps reduce aerodynamic drag I have read that the true purpose is to aid in repairs and 
        healing in the event of an accident.  This is a true fact.  I don't shave my legs (my wife would never let me live that down).  The surgeon told 
        me that he spent most of his time picking hair out of the wound.  I'll let you judge. </p>
        <p>Be warned these pictures are gross, disturbing and bloody.  I think one of the nurses even got a bit squeamish.  As bad as the pictures are my 
        youngest daughter had to sit in the room with us the entire time.  She said, "Daddy's owie was really gross.  I like it when they cover it with 
        something so you can't see it."  She's 4 so suck it up.</p>
        <img src="http://www.example.com/test.jpg" width="600" height="600" />
        <img src="http://www.example.com/nowidth.jpg" />
        <p>
        		<style type="text/css">
        			.gallery {
        				margin: auto;
        			}
        			.gallery-item {
        				float: left;
        				margin-top: 10px;
        				text-align: center;
        				width: 33%;			}
        			.gallery img {
        				border: 2px solid #cfcfcf;
        			}
        			.gallery-caption {
        				margin-left: 0;
        			}
        		</style>
        		<!-- see gallery_shortcode() in wp-includes/media.php -->
        		</p><div class="gallery"><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-22-09-57-18/" title="2008-08-22-09-57-18"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-22-09-57-18-150x150-1-img738.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				Flesh always loses against asphalt
        				</dd></dl><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-22-09-57-19/" title="2008-08-22-09-57-19"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-22-09-57-19-150x150-1-img739.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				My leg is straight so it is harder to see, but if I bend it you can see the tendons
        				</dd></dl><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-22-09-57-42/" title="2008-08-22-09-57-42"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-22-09-57-42-150x150-1-img741.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				Drugs make you happy
        				</dd></dl><br style="clear: both"><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-22-09-57-52/" title="2008-08-22-09-57-52"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-22-09-57-52-150x150-1-img742.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				Joel stuck around to offer moral support
        				</dd></dl><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-22-11-06-34/" title="2008-08-22-11-06-34"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-22-11-06-34-150x150-1-img743.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				After they cleaned it up
        				</dd></dl><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-22-11-07-21/" title="2008-08-22-11-07-21"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-22-11-07-21-150x150-1-img745.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				This isn't as much fun as it looks
        				</dd></dl><br style="clear: both"><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-22-11-07-53/" title="2008-08-22-11-07-53"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-22-11-07-53-150x150-1-img746.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				Irrigating the wound - like its a crop or something
        				</dd></dl><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-27-09-47-17/" title="2008-08-27-09-47-17"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-27-09-47-17-150x150-1-img747.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				After they took the bandage off the first time - 5 days later
        				</dd></dl><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-27-09-47-22/" title="2008-08-27-09-47-22"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-27-09-47-22-150x150-1-img748.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				After they took the bandage off the first time - 5 days later
        				</dd></dl><br style="clear: both"><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/2008-08-29-10-43-49/" title="2008-08-29-10-43-49"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-29-10-43-49-150x150-1-img749.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				After 7 days.  Still not pretty, but it is amazing how the human body heals
        				</dd></dl><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/photo/" title="wound"><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/photo-150x150-1-img750.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				This is from my iPhone.  It was taken 5 days after the accident at the doctor's office.  I have a few more shots below.
        				</dd></dl><dl class="gallery-item">
        			<dt class="gallery-icon">
        				<a href="http://www.justinball.com/2008/09/08/why-cyclists-shave-their-legs-the-most-disgusting-post-i-will-ever-make/photo1/" title="The wound after "><img src="http://www.justinball.com/wp-content/uploads/photojar/cache/photo1-150x150-1-img753.jpg" width="150" height="150" title="" alt=""></a>
        			</dt>
        				<dd class="gallery-caption">
        				Here's what it looks like today 9/8.  They took out one stitch, but it will still e quite a while before they can take out the main ones.
        				</dd></dl><br style="clear: both">
        			<br style="clear: both;">
        		</div>
        <br>
        <!--more--><!-- BlogGlue Cache: No --><p></p>
      </div>}
      @short_result = @parser.summarize(@html, 5)
      @long_result = @parser.summarize(@html, 100000)
    end
    it "should summarize the content by number of words" do
      @short_result.should_not include('than')
      @short_result.should include('more')
    end
    it "should remove html comments" do
      @short_result.should_not include('<!--more--><!-- BlogGlue Cache: No -->')
    end
    it "should keep the image tag" do
      @long_result.should include(%Q{<img src="http://www.justinball.com/wp-content/uploads/photojar/cache/2008-08-22-09-57-18-150x150-1-img738.jpg" width="#{@image_width_limit}" title="" alt="">})
    end
    it "should remove the style tag" do
      @long_result.should_not include('<style type="text/css">')
    end
    it "should remove empty tags" do
      @long_result.should_not include('<p></p>')
    end
    it "should remove tags with display:none" do
      @long_result.should_not include('display:none')
    end
    it "should set the width to 240 if width is greater than 240" do
      parser = Sumitup::Parser.new(:image_width_limit => 240)
      result = parser.summarize(@html, 10000)
      result.should include('<img src="http://www.example.com/test.jpg" width="240">')
    end
    it "should only allow 2 images" do
      parser = Sumitup::Parser.new(:max_images => 2)
      result = parser.summarize(@html, 10000)
      doc = Nokogiri::HTML(result)
      doc.css('img').length.should == 2
    end
    it "should add a width to images that don't have one" do
      @long_result.should include(%Q{<img src="http://www.example.com/nowidth.jpg" width="#{@image_width_limit}">})
    end
  end
  
  describe "snippet" do
    it "should build a string 157 chars long" do
      text = "Kimball was born to Solomon Farnham Kimball and Anna Spaulding in Sheldon, Franklin County, Vermont. Kimball's forefathers arrived in America from England and started"
      @parser.snippet(text, 5, '...').should == "Kimball was born to Solomon ..."
    end
    it "should not crash if string is nil" do
      text = nil
      @parser.snippet(text, 5, '...').length.should == 0
    end
  end

  describe "is_blank?" do
    it "should be true if text is nil" do
      @parser.is_blank?(nil).should be_true
    end
    it "should be true if text is ''" do
      @parser.is_blank?('').should be_true
    end
    it "should be false if text is 'valid'" do
      @parser.is_blank?('valid').should be_false
    end
  end
  
end