require 'rails_helper'

RSpec.describe ChatroomRelayJob, type: :job do
  it "matches with enqued job" do
  	ActiveJob::Base.queue_adapter = :test
  	expect {
  		ChatroomRelayJob.perform_later
  	}.to have_enqueued_job(ChatroomRelayJob)
  end
end
