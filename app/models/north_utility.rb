class NorthUtility < Utility
  def short?(length)
    length <= 50
  end

  def medium?(length)
    length > 50 && length <= 100
  end
end
