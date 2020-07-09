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

  factory :fishbowl, parent: :game, class: 'Fishbowl' do
  	name { "Fishbowl" }
  end

  factory :ghost, parent: :game, class: 'Ghost' do
    name { "Ghost" }
  end

  factory :wink_murder, parent: :game, class: 'WinkMurder' do
    name { "WinkMurder" }
  end
end
