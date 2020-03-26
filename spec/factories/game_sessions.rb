FactoryBot.define do
  factory :game_session do
    game { nil }
    user { nil }
    host { false }
  end
end
