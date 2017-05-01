class Game
    @ended: (e) ->
        if Player.current && window.location.pathname == "/games/#{e.game.id}"
            window.location.href = "/games/#{e.game.id}/ended"

window.Game = Game
