class UserGroupMembership < ApplicationRecord
  belongs_to :user_group
  belongs_to :user

  validates :user_id, uniqueness: { scope: :user_group_id }
end
