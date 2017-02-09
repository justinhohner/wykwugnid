class UserJoinSource < ApplicationRecord
  belongs_to :user, inverse_of: :user_join_sources
  belongs_to :source, inverse_of: :user_join_sources
end
