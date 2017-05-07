class GameType
    @construct: (round) ->
        switch round.game_type
            when "codelash"
                new GameType.CodeLash(round)
            when "fibonacci"
                new GameType.FibOnacci(round)
            else
                throw new Error("Invalid game type: #{round.game_type}")

window.GameType = GameType
