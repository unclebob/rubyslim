require 'rexml/document'

class TableToHashConverter
  def self.convert(string)
    begin
      doc = REXML::Document.new(string.strip)
      return html_to_hash(doc)
    rescue
      return string
    end
  end

  def self.html_to_hash(doc)
    table = doc.elements['table']
    raise ArgumentError if table.nil?
    create_hash_from_rows(table)
  end

  def self.create_hash_from_rows(rows)
    hash = {}
    rows.elements.each('tr') do |row|
      add_row_to_hash(hash, row)
    end
    hash
  end

  def self.add_row_to_hash(hash, row)
    columns = row.get_elements('td')
    raise ArgumentError if columns.size != 2
    hash[columns[0].text.strip.to_sym] = columns[1].text.strip
  end
end
