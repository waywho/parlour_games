FactoryBot.define do
  factory :message do
    user { nil }
    chatroom { nil }
    content { "MyString" }
  end
end
