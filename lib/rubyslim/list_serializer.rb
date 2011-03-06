require 'jcode'

module ListSerializer
  # Serialize a list according to the SliM protocol.
  #
  # Lists are enclosed in square-brackets '[...]'. Inside the opening
  # bracket is a six-digit number indicating the length of the list
  # (number of items), then a colon ':', then the serialization of each
  # list item. For example:
  #
  #   []         => "[000000:]"
  #   ["hello"]  => "[000001:000005:hello:]"
  #   [1]        => "[000001:000001:1:]"
  #
  # Strings are preceded by a six-digit sequence indicating their length:
  #
  #   ""         => "000000:"
  #   "hello"    => "000005:hello"
  #   nil        => "000004:null"
  #
  # See spec/list_serializer_spec.rb for more examples.
  #
  def self.serialize(list)
    result = "["
    result += length_string(list.length)

    # Serialize each item in the list
    list.each do |item|
      item = "null" if item.nil?
      item = serialize(item) if item.is_a?(Array)
      item = item.to_s
      result += length_string(item.jlength)
      result += item + ":"
    end

    result += "]"
  end


  # Return the six-digit prefix for an element of the given length.
  def self.length_string(length)
    sprintf("%06d:",length)
  end
end

