class User < ApplicationRecord
	has_one :score, as: :scoreable
end
