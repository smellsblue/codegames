module GameType
  def self.game_class(name)
    case name
    when "codelash"
      GameType::CodeLash
    when "fibonacci"
      GameType::FibOnacci
    else
      raise "Invalid game type: #{name}"
    end
  end
end
