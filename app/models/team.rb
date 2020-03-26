class Team < ApplicationRecord
	has_one :score, as: :scoreable
end
