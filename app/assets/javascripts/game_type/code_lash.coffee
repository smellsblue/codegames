class CodeLash
    constructor: (round) ->
        @round = round

    render: ->
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

window.GameType.CodeLash = CodeLash
