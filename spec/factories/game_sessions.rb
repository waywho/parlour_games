FactoryBot.define do
  factory :game_session do
    game
    team
    host { false }
    sequence(:player_name) { |n| "MyString#{n}" }
    ip_address { "MyString" }

    trait :for_user do
    	association :playerable, factory: :user
    end
  end
end
