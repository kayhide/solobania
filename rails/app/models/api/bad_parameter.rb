class Api::BadParameter < Api::BaseError
  def initialize(params)
    @params = params
  end

  def status
    :unprocessable_entity
  end

  def message
    "Bad parameter: #{@params}"
  end
end
