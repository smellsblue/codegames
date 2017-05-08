class Player
    @by_id = {}
    @all = []

    constructor: (obj) ->
        obj = obj.player if obj.player
        @id = obj.id
        @name = obj.name
        @roundState = obj.round_state

    @find: (obj) ->
        obj = obj.player if obj.player
        obj = obj.id if obj.id
        @by_id[obj]

    @left: (e) ->
        @find(e).remove()

    @joined: (e) ->
        new Player(e).add()

    add: ->
        Player.by_id[@id] = @
        Player.all.push @
        @render()

    render: ->
        if @select().size() == 0
            $("#players").append tmpl("tmpl-player", @)
        else
            @select().replaceWith tmpl("tmpl-player", @)

    remove: ->
        @select().remove()
        delete Player.by_id[@id]
        Player.all.splice Player.all.indexOf(@), 1

    select: ->
        $(".player[data-id='#{@id}']")

    setRoundState: (state) ->
        return if state == @roundState
        @roundState = state
        @render()

window.Player = Player
