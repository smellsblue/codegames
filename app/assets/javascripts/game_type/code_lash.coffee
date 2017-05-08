class CodeLash
    constructor: (round) ->
        @round = round

    render: ->
        if Game.role == "creator"
            @renderForCreator()
        else
            @renderForPlayer()

    renderForCreator: ->
        $("#game-content").html tmpl("tmpl-codelash-vote", @round)

    renderForPlayer: ->
        $("#game-content").html tmpl("tmpl-codelash-questions", @round)

    nextQuestion: ->
        for question in @round.data.questions
            return question unless question.answer

        null

    onEvent: (data) ->
        switch data.round_event
            when "answer_submitted"
                for player in data.players
                    Player.find(player.id).setRoundState(player.round_state)
            when "voting"
                Round.current = new Round(data)

                for player in data.players
                    Player.find(player.id).setRoundState(player.round_state)

                Round.current.render()

window.GameType.CodeLash = CodeLash
