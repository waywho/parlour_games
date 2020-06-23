FactoryBot.define do
  factory :game_session do
    game
    team
    host { false }
    player_name { "MyString" }
    ip_address { "MyString" }
    scores { nil }

    trait :for_user do
    	association :playerable, factory: :user
    end
  end
end
