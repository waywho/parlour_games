FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "MyString#{n}" }
    sequence(:email) { |n| "MyString#{n}@test.com" }
    password { "MyString" }
    password_confirmation { "MyString" }
    avatar { "MyString" }

    trait :admin do
    	admin { true }
    end

    factory :admin_user, traits: [:admin]
  end
end
