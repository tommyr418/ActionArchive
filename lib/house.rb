require_relative 'action_archive'

class House < ActionArchive
  self.finalize!

  has_many :humans
end
