require_relative 'action_archive'

class Cat < ActionArchive
  belongs_to :human, foreign_key: :owner_id
end
