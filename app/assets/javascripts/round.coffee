class Round
    constructor: (obj) ->
        obj = obj.round if obj.round
        @id = obj.id
        @game_type = obj.game_type
        @state = obj.state
        @data = obj.data
        @roundData = obj.round_data
        @gameObject = GameType.construct(@)

    @started: (e) ->
        round = new Round(e)
        Round.current = round
        round.render()
        round

    render: ->
        @gameObject.render()

    onEvent: (data) ->
        @gameObject.onEvent(data)

    @render: ->
        if Round.current
            Round.current.render()
        else
            $("#game-content").html tmpl("tmpl-no-round", {})

window.Round = Round
