module Halfpipe
  module Strings
    def self.deform(s)
      s.strip.downcase.gsub(/[[:punct:]]/, "").gsub(/\s+/, "_")
    end
  end
end
