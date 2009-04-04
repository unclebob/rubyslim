require 'jcode'
module ListSerializer
  def self.serialize(list)
    result = "["
    result += length_string(list.length)
    list.each do |item|
      item = "null" if item.nil?
      item = serialize(item) if item.is_a?(Array)
      item = item.to_s
      result += length_string(item.jlength)
      result += item + ":"
    end
    result += "]"
  end

  def self.length_string(length)
    sprintf("%06d:",length)
  end
end