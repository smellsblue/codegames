class CodeLash
    constructor: (round) ->
        @round = round

    render: ->
        $("#game-content").html tmpl("tmpl-codelash-questions", @round)

    nextQuestion: ->
        for question in @round.data.questions
            return question.text unless question.answer

        null

window.GameType.CodeLash = CodeLash
