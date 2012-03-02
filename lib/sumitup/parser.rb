module Sumitup
  class Parser
    
    IMAGE_WIDTH_LIMIT = 230
    
    attr_accessor :word_count, :max_words
    attr_accessor :image_count, :image_width_limit, :max_images
    attr_accessor :elements, :attributes, :protocols, :remove_contents
    attr_accessor :omission
    
    def initialize(options = {})
      
      self.omission = options[:omission] || ''
      
      self.word_count = options[:word_count] || 0
      self.max_words = options[:max_words] || 100
      
      self.image_count = options[:image_count] || 0
      self.image_width_limit = options[:image_width_limit] || 230
      self.max_images = options[:max_images] || 2
      
      self.elements = options[:elements] || %w(
        a abbr b blockquote br cite code dd dfn dl dt em i kbd li mark ol p pre
        q s samp small strike strong sub sup time u ul var img span
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
      
      self.max_words = max unless max.nil?
      
      Sanitize.clean(html, 
        :elements => elements, 
        :attributes => attributes, 
        :protocols => protocols, 
        :remove_contents => remove_contents, 
        :transformers => [no_display_transformer, empty_transformer],
        :transformers_breadth => [summarizer, image_transformer])
    end

    def summarizer
      me = self
      lambda do |env|
        
        node = env[:node]
        
        return if !node.element?
        
        if node.text? || (node.children && node.children.first && node.children.first.text?)
          if me.word_count > me.max_words
            # if we are already over then just remove the item
            node.remove
          else
            # if the text of the current node makes us go over then truncate it
            node.text.scan(/\b\S+\b/) { me.word_count += 1 }
            if me.word_count > me.max_words
              node.content = snippet(node.text, me.max_words, '...')
            end
          end
        end
        
      end
    end
    
    def image_transformer
      me = self
      lambda do |env|
        node = env[:node]
        if ['img'].include?(env[:node_name])
          me.image_count += 1
          if me.image_count > me.max_images
            node.remove
          else
            # Force width of images
            node['width'] = me.image_width_limit.to_s
            node.attributes['height'].remove if node.attributes['height']
          end
        end
      end
    end
    
    def empty_transformer
      lambda do |env|
        node = env[:node]
        if node.text.empty? && node.children.empty? && !['img', 'br'].include?(env[:node_name])
          node.remove 
        end
      end
    end
    
    def no_display_transformer 
      lambda do |env|
        node = env[:node]
        if node['style'] && node['style'] =~ /display\s*:\s*none/
          node.remove
        end
      end
    end
    
    # Truncates text at a word boundry
    # Parameters:
    #   text      - The text to truncate
    #   wordcount - The number of words
    #   omission  - Text to add when the text is truncated ie 'read more' or '...
    def snippet(text, wordcount, omission)
      return '' if is_blank?(text)
      text.split[0..(wordcount-1)].join(" ") + (text.split.size > wordcount ? " " + omission : "")
    end

    def is_blank?(text)
      text.nil? || text.empty?
    end

  end
end