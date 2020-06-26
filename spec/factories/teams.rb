FactoryBot.define do
  factory :team do
    sequence(:name)  { |n| "MyTeam#{n}" }
    game
  end
end
