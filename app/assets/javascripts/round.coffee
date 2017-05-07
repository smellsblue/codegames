class Round
    constructor: (obj) ->
        obj = obj.round if obj.round
        @id = obj.id
        @game_type = obj.game_type
        @state = obj.state
        @data = obj.data
        @game_object = GameType.construct(@)

    @started: (e) ->
        round = new Round(e)
        Round.current = round
        round.render()

    render: ->
        @game_object.render()

window.Round = Round
