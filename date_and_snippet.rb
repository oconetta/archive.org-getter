#class to hold dates and text from snippets
class DateAndSnippet
  include Comparable
  attr_reader :date
  attr_reader :text

  #store date and text attributes
  def initialize(date, text)
    @date = Date.parse date
    @text = text
  end

  def <=> other
    self.date <=> other.date
  end
end