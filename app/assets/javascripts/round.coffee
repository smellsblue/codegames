class Round
    constructor: (obj) ->
        obj = obj.round if obj.round
        @id = obj.id
        @game_type = obj.game_type
        @state = obj.state
        @data = obj.data
        @gameObject = GameType.construct(@)

    @started: (e) ->
        round = new Round(e)
        Round.current = round
        round.render()

    render: ->
        @gameObject.render()

    onEvent: (data) ->
        @gameObject.onEvent(data)

window.Round = Round
