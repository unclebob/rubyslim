require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require 'table_to_hash_converter'

def shouldNotChange(string)
  TableToHashConverter.convert(string).should == string
end

describe TableToHashConverter do
  [
    ["some string", "not a table"],
    ["<table>blah", "incomplete table"],
    ["<table><tr><td>hi</td></tr></table>", "too few columns"],
    ["<table><tr><td>hi</td><td>med</td><td>lo</td></tr></table>", "too many columns"]
  ].each do |string, reason|
    it "#{reason}: should not change '#{string}'" do
      shouldNotChange(string)
    end
  end
end

describe TableToHashConverter do
  [
    ["<table><tr><td>name</td><td>bob</td></tr></table>", {:name=>"bob"}],
    [" <table> <tr> <td> name </td> <td> bob </td> </tr> </table> ", {:name=>"bob"}],
    ["<table><tr><td>name</td><td>bob</td></tr><tr><td>addr</td><td>here</td></tr></table>", {:name=>'bob', :addr=>'here'}]
  ].each do |table, hash|
    it "should match #{table} to #{hash}" do
      TableToHashConverter.convert(table).should == hash
    end
  end
end