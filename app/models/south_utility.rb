class SouthUtility < Utility
  def short?(length)
    length < 60
  end

  def medium?(length)
    length > 50 && length < 100
  end

  def long?(length)
    length > 100
  end
end
