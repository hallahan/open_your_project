module FedWiki
  module RandomId
    class << self
      def generate
        (0..15).collect { (rand*16).to_i.to_s(16) }.join
      end
    end
  end
end
