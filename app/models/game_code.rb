class GameCode
  LETTERS = ("a".."z").to_a.freeze.each(&:freeze)

  def self.random
    Array.new(4) { LETTERS.sample }.join
  end
end
