class Track
  def initialize(@name : String, @artist : String, @version : String?, @label : String?)

  end

  def to_s(io)
    io << "#{@artist} - #{@name}"
  end
end
