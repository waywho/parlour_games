FactoryBot.define do
  factory :game do
    name { "Fishbowl" }
    set { "" }
    started { false }
    ended { false }
    team_mode { false }

    trait :for_user do
    	association :playerable, factory: :user, strategy: :build
    end
  end

  factory :fishbowl, parent: :game do
  	name { "Fishbowl" }
  end
end
