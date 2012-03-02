$LOAD_PATH << File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'sanitize'

# Get index status:
# curl -XGET 'http://localhost:9200/_status'
module Sumitup

end

require 'sumitup/parser'