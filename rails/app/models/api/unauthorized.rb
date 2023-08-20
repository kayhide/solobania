class Api::Unauthorized < Api::BaseError
  def status
    :unauthorized
  end

  def message
    "Not authorized"
  end
end
