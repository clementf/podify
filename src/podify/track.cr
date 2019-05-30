class Track
  getter :title, :artist, :version, :label

  def initialize(@title : String, @artist : String, @version : String?, @label : String?)
  end

  def to_s(io)
    io << "#{@artist} - #{@title} (#{@version}) [#{@label}]"
  end
end
