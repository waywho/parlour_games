FactoryBot.define do
  factory :message do
    chatroom
    content { "MyString" }

    trait :for_user do
    	association :speakerable, factory: :user
    end

    trait :for_player do
    	association :speakerable, factory: :game_session
    end
  end
end
