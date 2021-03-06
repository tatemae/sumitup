require 'spec_helper'

describe Sumitup::Parser do
    
  describe "summarize" do
    before do
      @html = IO.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'basic.html'))
    end
    
    it "should used the default max_words" do
      content = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec est enim, accumsan sollicitudin convallis sed, tempor vel libero. Quisque nulla tortor, 
        rhoncus sit amet fermentum ut, imperdiet iaculis risus. Nunc vulputate arcu non turpis consequat molestie. Vestibulum ante ipsum primis in faucibus orci luctus 
        et ultrices posuere cubilia Curae; Nam blandit malesuada leo et posuere. Suspendisse potenti. '
      parser = Sumitup::Parser.new(:max_words => 10)
      result = parser.summarize(content)
      result.should == 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec est'
    end
    
    it "should summarize the content by number of words" do
      parser = Sumitup::Parser.new(:max_words => 1000)
      result = parser.summarize(@html, 5)
      result.should_not include('consectetur')
      result.should include('amet')
    end
    
    it "should keep permitted html in summary" do
      parser = Sumitup::Parser.new(:max_words => 1000)
      result = parser.summarize(@html, 5)
      result.should include('strong')
      result.should include('blockquote')
    end
    
    it "should remove empty tags after truncating text" do
      parser = Sumitup::Parser.new(:max_words => 5)
      result = parser.summarize(@html)
      result.should_not include('ul')
      result.should_not include('li')
      result.should_not include('<span></span>')
    end
    
    it "should be reusable" do
      parser = Sumitup::Parser.new(:max_words => 5)
      result = parser.summarize(@html)
      result2 = parser.summarize(@html)
      result.should == result2
    end
    
    describe "Sanitize options" do
      it "should remove html comments" do
        result = Sumitup::Parser.new.summarize(@html, 100000)
        result.should_not include('<!-- An html comment -->')
      end
    
      it "should remove the style tag" do
        result = Sumitup::Parser.new.summarize(@html, 100000)
        result.should_not include('<style type="text/css">')
      end
    end
        
    describe "word_transformer" do
      it "should remove empty tags" do
        result = Sumitup::Parser.new.summarize(@html, 100000)
        result.should_not include('<p></p>')
      end
      
      it "should remove tags with display:none" do
        result = Sumitup::Parser.new.summarize(@html, 100000)
        result.should_not include('display:none')
      end
    end
    
    describe "image_transformer" do
      it "should set the width to 240 if width is greater than 240" do
        parser = Sumitup::Parser.new(:image_width_limit => 240)
        result = parser.summarize(@html, 10000)
        result.should include(%Q{img src="http://www.example.com/big.jpg" width="240" height="240">})
      end
      
      it "should only allow 2 images" do
        parser = Sumitup::Parser.new(:max_images => 2)
        result = parser.summarize(@html, 10000)
        doc = Nokogiri::HTML(result)
        doc.css('img').length.should == 2
      end
      
      it "should not keep small images" do
        result = Sumitup::Parser.new.summarize(@html, 100000)
        result.should_not include('http://www.example.com/small.jpg')
      end
      
      it "should enlarge images that are not over the width limit" do
        parser = Sumitup::Parser.new(:max_images => 1000, :image_width_limit => 200)
        result = parser.summarize(@html, 100000)
        result.should include('<img src="http://www.example.com/photo.jpg" width="200" height="200" title="" alt="">')
      end
    end
    
  end
  
  describe "snippet" do
    before do
      @parser = Sumitup::Parser.new
    end
    it "should build a string 5 words long" do
      text = "Kimball was born to Solomon Farnham Kimball and Anna Spaulding in Sheldon, Franklin County, Vermont. Kimball's forefathers arrived in America from England and started"
      result, count = @parser.snippet(text, 5)
      result.should == "Kimball was born to Solomon"
      count.should == 5
    end
    
    it "should not crash if string is nil" do
      result, count = @parser.snippet(nil, 5)
      result.should == ''
      count.should == 0
    end
  end

  describe "is_blank?" do
    before do
      @parser = Sumitup::Parser.new
    end
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
  
  describe "request_image_size" do
    before do
      @parser = Sumitup::Parser.new
    end
    it "should get width and height from the remote image" do
      url = "http://upload.wikimedia.org/wikipedia/en/b/bc/Wiki.png"
      width, height = @parser.request_image_size(url)
      width.should == 135
      height.should == 155
    end
  end
  
  describe "image_height" do
    before do
      @parser = Sumitup::Parser.new
    end
    it "should calculate a smaller height based on the width change" do
      image_width_limit = 100
      existing_height = 1000
      existing_width = 1000
      height = @parser.image_height(existing_height, existing_width, image_width_limit)
      height.should == 100
    end
    it "should calculate a larger height based on the width change" do
      image_width_limit = 100
      existing_height = 10
      existing_width = 50
      height = @parser.image_height(existing_height, existing_width, image_width_limit)
      height.should == 20
    end
    it "should calculate new height based on width" do
      image_width_limit = 100
      existing_height = 143
      existing_width = 136
      height = @parser.image_height(existing_height, existing_width, image_width_limit)
      height.should == 105
    end
    it "should handle nil height" do
      image_width_limit = 100
      existing_height = nil
      existing_width = 200
      height = @parser.image_height(existing_height, existing_width, image_width_limit)
      height.should == 100
    end
    it "should handle nil width" do
      image_width_limit = 100
      existing_height = 200
      existing_width = nil
      height = @parser.image_height(existing_height, existing_width, image_width_limit)
      height.should == 200
    end
  end
  
end