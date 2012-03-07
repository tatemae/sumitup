module Sumitup
  class Parser
    
    attr_accessor :word_count, :max_words
    attr_accessor :image_count, :image_width_limit, :max_images, :min_image_size
    attr_accessor :elements, :attributes, :protocols, :remove_contents
    attr_accessor :omission
    
    def initialize(options = {})
      
      self.omission = options[:omission] || ''
      
      self.word_count = 0
      self.max_words = options[:max_words] || 100
      
      self.image_count = 0
      self.min_image_size = options[:min_image_size] || 40
      self.image_width_limit = options[:image_width_limit] || 230
      self.max_images = options[:max_images] || 1
                  
      # White listed elements
      self.elements = options[:elements] || %w(
        a abbr b blockquote cite code dfn em i kbd mark q samp small s strike strong sub sup time u var
        br dd dl dt li ol p pre ul img span
      )

      self.attributes = options[:attributes] || {
        'a'          => ['href', 'title'],
        'blockquote' => ['cite'],
        'img'        => ['alt', 'src', 'title', 'width', 'height']
      }

      self.protocols = options[:protocols] || {
        'a' => {'href' => ['http', 'https', 'mailto']}
      }

      self.remove_contents = options[:remove_contents] || %w(
        style script 
      )
      
    end
    
    # Removes html and generate a summary
    def summarize(html, max = nil)
      return '' if is_blank?(html)
      unclean = Nokogiri::HTML::DocumentFragment.parse(html.dup)
      summarize_fragment(unclean, max).to_html
    end

    def summarize_fragment(node, max = nil)
      # Always reset counts
      self.word_count = 0
      self.image_count = 0
      clean = Sanitize.clean_node!(node, 
        :elements => elements, 
        :attributes => attributes, 
        :protocols => protocols, 
        :remove_contents => remove_contents, 
        :transformers => [word_transformer, image_transformer])
      summarize_node(clean, max)
    end
     
    def summarize_node(node, max = nil)
      max ||= self.max_words
      
      # summarize all children of the node
      node.children.each do |child|
        summarize_node(child, max)
      end
      
      if node.text?
        if self.word_count > max
          node.remove
        else
          # if the text of the current node makes us go over then truncate it
          result, count = snippet(node.inner_text, max - self.word_count)
          if count == 0 || is_blank?(result)
            node.remove
          else
            self.word_count += count
            node.content = result
          end
        end
      else
        # Remove empty nodes
        if node.text.empty? && node.children.empty? && !['img', 'br'].include?(node.name)
          node.remove
        end
      end
      
      node
    end

    # Truncates text at a word boundry
    # Parameters:
    #   text      - The text to truncate
    #   wordcount - The number of words
    def snippet(text, max)
      result = ''
      count = 0
      return [result, count] if is_blank?(text)
      text.split.each do |word|
        return [result.strip!, count] if count >= max
        result << "#{word} "
        count += 1
      end
      [result.strip!, count]
    end
         
    def is_blank?(text)
      text.nil? || text.empty?
    end

    def word_transformer
      me = self
      lambda do |env|
      
        node = env[:node]
        name = env[:node_name]
        return if !node.element?
      
        # Remove nodes with display none
        if node['style'] && node['style'] =~ /display\s*:\s*none/
          node.remove
          return
        end
      
        # Remove empty nodes
        if node.text.empty? && node.children.empty? && !['img', 'br'].include?(name)
          node.remove
          return
        end
      
      end
    end
  
    def image_transformer
      me = self
      lambda do |env|
        node = env[:node]
        return unless ['img'].include?(env[:node_name])
      
        if (me.image_count+1) > me.max_images # We add a new image below so we have to make sure we won't go over the limit
          node.remove
        else
          keep_it = false
        
          if node.attributes['width']
            width = node.attributes['width'].value.to_i rescue 0
            keep_it = true if width > me.min_image_size
          else
            width = nil
            keep_it = true
          end

          if keep_it
            me.image_count += 1
            if width == nil || width > me.image_width_limit
              node['width'] = me.image_width_limit.to_s
              node.attributes['height'].remove if node.attributes['height']
            end
          else
            node.remove
          end
        
        end
      
      end
    end
    
  end
end