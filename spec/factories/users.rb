FactoryBot.define do
  factory :user do
    name { "MyString" }
    email { "MyString" }
    password_digest { "MyString" }
    admin { false }
    avatar { "MyString" }
  end
end
