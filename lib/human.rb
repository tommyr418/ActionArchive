require_relative 'action_archive'

class Human < ActionArchive
  self.table_name = 'humans'
  self.finalize!

  has_many :cats, foreign_key: :owner_id
  belongs_to :house
end
