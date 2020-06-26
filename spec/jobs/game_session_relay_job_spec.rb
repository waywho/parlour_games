require 'rails_helper'

RSpec.describe GameSessionRelayJob, type: :job do
  it "matches with enqued job" do
  	ActiveJob::Base.queue_adapter = :test
  	expect {
  		GameSessionRelayJob.perform_later
  	}.to have_enqueued_job(GameSessionRelayJob)
  end
end
