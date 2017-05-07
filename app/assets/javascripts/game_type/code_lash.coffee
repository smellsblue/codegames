class CodeLash
    constructor: (round) ->
        @round = round

    render: ->
        $("#game-content").html tmpl("tmpl-codelash-questions", @round)

window.GameType.CodeLash = CodeLash
