class Player
    constructor: (obj) ->
        obj = obj.player if obj.player
        @id = obj.id
        @name = obj.name

    @left: (e) ->
        player = new Player(e)
        $(".player[data-id='#{player.id}']").remove()

    @joined: (e) ->
        player = new Player(e)

        if $(".player[data-id='#{player.id}']").size() == 0
            $("#players").append tmpl("tmpl-player", player)

window.Player = Player
