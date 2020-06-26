require 'rails_helper'

RSpec.describe ChatroomUser, type: :model do
  describe "Associations" do
  	it { should belong_to(:chatroom) }
  	it { should belong_to(:user) }
  end
end
