class IrcDate
  attr_accessor :date

  def initialize(date)
    self.date = date
  end

  def day
    self.date.match(/(^\d{4}-\d{2}-\d{2})/)[1]
  end

end
