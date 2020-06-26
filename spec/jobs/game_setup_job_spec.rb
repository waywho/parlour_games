require 'rails_helper'

RSpec.describe GameRelayJob, type: :job do
  it "matches with enqued job" do
  	ActiveJob::Base.queue_adapter = :test
  	expect {
  		GameRelayJob.perform_later
  	}.to have_enqueued_job(GameRelayJob)
  end
end
