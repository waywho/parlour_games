require 'rails_helper'

RSpec.describe MessageRelayJob, type: :job do
  it "matches with enqued job" do
  	ActiveJob::Base.queue_adapter = :test
  	expect {
  		MessageRelayJob.perform_later
  	}.to have_enqueued_job(MessageRelayJob)
  end
end
