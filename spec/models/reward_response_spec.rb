require 'spec_helper'

describe RewardResponse do

 it "Should create an empty instance of an RewardResponse" do
   response = RewardResponse.new
   expect(response.success).to eq(nil)
   expect(response.rewards).to eq(nil)
   expect(response.message).to eq(nil)
 end

 it "Should create an instance of an RewardResponse" do
   response = RewardResponse.new( success:false, rewards:[], message:"" )
   expect(response.success).to eq(false)
   expect(response.rewards).to eq([])
   expect(response.message).to eq("")
 end

end
