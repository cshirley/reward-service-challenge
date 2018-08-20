require 'spec_helper'
describe RewardService do

  REWARD_CHANNEL_MAP = { "SPORTS" => "CHAMPIONS_LEAGUE_FINAL_TICKET",
                      "MUSIC" => "KARAOKE_PRO_MICROPHONE",
                      "MOVIES" => "PIRATES_OF_THE_CARIBBEAN_COLLECTION" }
  TECHNICAL_ERROR_MESSAGE = "Technical Error"
  NOT_FOUND_ERROR_MESSAGE = "Account number is invalid"

  subject(:eligibility_service) {
    mock_eligibility_service = double("EligibilityService")
    allow(mock_eligibility_service).to receive(:is_eligable?).with(1) { "CUSTOMER_ELIGIBLE" }
    allow(mock_eligibility_service).to receive(:is_eligable?).with(2) { "CUSTOMER_INELIGIBLE" }
    allow(mock_eligibility_service).to receive(:is_eligable?).with(3) { raise AccountNotFoundError.new(NOT_FOUND_ERROR_MESSAGE) }
    allow(mock_eligibility_service).to receive(:is_eligable?).with(-1) { raise TechnicalError.new(TECHNICAL_ERROR_MESSAGE) }
    mock_eligibility_service
 }

  subject(:reward_repository) {
    RewardRepository.new(reward_map:REWARD_CHANNEL_MAP)
  }

  describe "Initialisation" do
    context "Should not initialise without reward repository " do
      it { expect{ RewardService.new }.to raise_exception ArgumentError }
      it { expect{ RewardService.new(eligibility_service:eligibility_service) }.to raise_exception ArgumentError }
    end
    context "success" do
       it  { expect(RewardService.new({eligibility_service: eligibility_service,
                                       reward_repository:reward_repository})).not_to eq(nil) }
    end
  end

  describe "features" do

    subject(:first_channel_key) { REWARD_CHANNEL_MAP.keys.first }
    subject(:reward_service) {
      RewardService.new({eligibility_service: eligibility_service,
                               reward_repository:reward_repository})
    }

    context "should return success and list of rewards for existing eligible user for single channel" do

      let(:response) { reward_service.rewards(1, [first_channel_key]) }
      it { expect(response.success).to eq(true) }
      it { expect(response.rewards.count).to eq(1) }
      it { expect(response.rewards.first).to eq(REWARD_CHANNEL_MAP[first_channel_key]) }

    end

    context "should return failure and no list of rewards for existing non-eligible user for single channel" do
      let(:response) { reward_service.rewards(2, [first_channel_key]) }
      it { expect(response.success).to eq(true) }
      it { expect(response.rewards.count).to eq(0) }

    end

    context "should return success and no list of rewards for existing eligible user for one or more channels that has no rewards" do
      let(:response) {reward_service.rewards(1, ["KIDS", "NEWS"]) }
      it { expect(response.success).to eq(true) }
      it { expect(response.rewards.count).to eq(0) }

    end

    context "should return success and list of rewards for existing eligible user for one or more channels that has rewards and one or more channels that have not rewards" do
      let(:response)  { reward_service.rewards(1, ["KIDS", "NEWS"] + REWARD_CHANNEL_MAP.keys) }
      it { expect(response.success).to eq(true) }
      it { expect(response.rewards.count).to eq(REWARD_CHANNEL_MAP.keys.count) }
      it { expect(response.rewards).to eq(REWARD_CHANNEL_MAP.values) }

    end

    context "should return success and list of rewards for existing eligible user for multiple channels" do

      let(:response)  { reward_service.rewards(1, REWARD_CHANNEL_MAP.keys) }
      it { expect(response.success).to eq(true) }
      it { expect(response.rewards.count).to eq(REWARD_CHANNEL_MAP.keys.count) }
      it { expect(response.rewards).to eq(REWARD_CHANNEL_MAP.values) }


    end

    context "should return failure and no list of rewards for existing non-eligible user for multiple channels" do
      let(:response)  { reward_service.rewards(2, REWARD_CHANNEL_MAP.keys) }
      it { expect(response.success).to eq(true) }
      it { expect(response.rewards.count).to eq(0) }

    end

    context "should return failure and no list of rewards and message for non-existing user" do

      let(:response)  { reward_service.rewards(3, REWARD_CHANNEL_MAP.keys) }
      it { expect(response.success).to eq(false) }
      it { expect(response.rewards.count).to eq(0) }
      it { expect(response.message).to eq(NOT_FOUND_ERROR_MESSAGE) }

    end

    context "should return failure, no list of rewards and non message for any technical failure" do

      let(:response)  { reward_service.rewards(-1, REWARD_CHANNEL_MAP.keys) }
      it { expect(response.success).to eq(false) }
      it { expect(response.rewards.count).to eq(0) }
      it { expect(response.message).to eq(TECHNICAL_ERROR_MESSAGE) }

    end

  end
end

