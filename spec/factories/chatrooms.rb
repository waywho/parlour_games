FactoryBot.define do
  factory :chatroom do
    topic { "MyString" }
    public { false }
    trait :for_game do
    	association :gameaable, factory: :game
    end
  end
end
