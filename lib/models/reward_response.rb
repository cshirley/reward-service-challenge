class RewardResponse
  attr_accessor :success
  attr_accessor :rewards
  attr_accessor :message

  def initialize(options={})
    options.each do |k,v|
      send "#{k}=", v
    end
  end

end
