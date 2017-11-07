require_relative 'action_archive'

class Human < ActionArchive
  has_many :cats, foreign_key: :owner_id
  belongs_to :house
end
