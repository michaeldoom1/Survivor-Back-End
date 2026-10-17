# A named set of league members (e.g. "Family") used to focus the League
# Race chart. Everyone in the group can see it; only the owner can change it.
# Groups aren't tied to a season, so they carry over from year to year.
class UserGroup < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :user_group_memberships, dependent: :destroy
  has_many :members, through: :user_group_memberships, source: :user

  validates :name, presence: true, length: { maximum: 50 }

  before_validation :include_owner_as_member

  scope :visible_to, ->(user) {
    where(owner_id: user.id).or(where(id: UserGroupMembership.where(user_id: user.id).select(:user_group_id)))
  }

  def as_json_for(user)
    {
      id: id,
      name: name,
      owner_id: owner_id,
      owner_name: "#{owner.first_name} #{owner.last_name}",
      is_owner: owner_id == user.id,
      members: members.sort_by(&:first_name).map { |member|
        { id: member.id, name: "#{member.first_name} #{member.last_name}" }
      }
    }
  end

  private

  def include_owner_as_member
    self.members = members.to_a | [ owner ] if owner
  end
end
