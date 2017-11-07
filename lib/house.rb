require_relative 'action_archive'

class House < ActionArchive
  has_many :humans
end
