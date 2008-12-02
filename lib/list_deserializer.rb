module ListDeserializer
  class SyntaxError < Exception

  end

  def self.deserialize(string)
    raise SyntaxError.new("Can't deserialize null") if string.nil?
    raise SyntaxError.new("Can't deserialize empty string") if string.empty?
    raise SyntaxError.new("Serialized list has no starting [") if string[0..0] != "["
    raise SyntaxError.new("Serialized list has no ending ]") if string[-1..-1] != "]"
    Deserializer.new(string).deserialize
  end

  class Deserializer
    def initialize(string)
      @string = string;
    end

    def deserialize
      @pos = 1;
      @list = []
      number_of_items = get_length
      number_of_items.times do
        length_of_item = get_length
        item = @string[@pos...@pos+length_of_item]
        @pos += length_of_item+1
        begin
          sublist = ListDeserializer.deserialize(item)
          @list << sublist
        rescue ListDeserializer::SyntaxError
          @list << item
        end
      end
      @list
    end

    def get_length
      length = @string[@pos...@pos+6].to_i
      @pos += 7
      length
    end
  end
end