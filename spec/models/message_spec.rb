require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'Associations' do
  	it { should belong_to(:speakerable) }
  	it { should belong_to(:chatroom) }
  end
end
