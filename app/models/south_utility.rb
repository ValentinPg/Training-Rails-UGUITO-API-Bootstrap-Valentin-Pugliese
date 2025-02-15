class SouthUtility < Utility
  def short?(length)
    length < 60
  end

  def medium?(length)
    length > 60 && length < 120
  end

  def long?(length)
    length > 120
  end
end
