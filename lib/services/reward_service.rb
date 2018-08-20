class RewardService

  DEFAULTS = {eligibility_service:nil, reward_repository:nil}

  def initialize(options={})
    options = DEFAULTS.merge(options)
    raise ArgumentError.new(":eligibility_service should not be nil") unless options[:eligibility_service]

    raise ArgumentError.new(":reward_repository should not be nil") unless options[:reward_repository]

    @eligibility_service = options[:eligibility_service]
    @reward_repository = options[:reward_repository]
  end

  def rewards(account_id, portfolio)

    response = RewardResponse.new( success:false, rewards:[], message:"" )

    begin

        if @eligibility_service.is_eligable?(account_id) == "CUSTOMER_ELIGIBLE"

          portfolio.each do |portfolio_channel|
            reward = @reward_repository.find_by_channel(portfolio_channel)
            response.rewards << reward if reward
          end

        end

        response.success = true

    rescue TechnicalError => technical_error
       response.message = technical_error.message || ""
    rescue AccountNotFoundError
       response.message = "Account number is invalid"
    end

    response
  end

end

class RewardRepository


  CHANNEL_REWARDS = { "SPORTS" => "CHAMPIONS_LEAGUE_FINAL_TICKET",
                      "MUSIC" => "KARAOKE_PRO_MICROPHONE",
                      "MOVIES" => "PIRATES_OF_THE_CARIBBEAN_COLLECTION" }

  DEFAULTS = { reward_map:CHANNEL_REWARDS }

  def initialize(options={})
    options = DEFAULTS.merge(options)
    raise ArgumentError.new(":reward_map should not be nil") unless options[:reward_map]
    @reward_map = options[:reward_map]
  end

  def find_by_channel(channel)
    key = channel.upcase
    @reward_map.has_key?(key) ? @reward_map[key] : nil
  end

end
