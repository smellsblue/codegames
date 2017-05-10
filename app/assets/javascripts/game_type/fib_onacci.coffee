class FibOnacci
    constructor: (round) ->
        @round = round

    needAnswer: ->
        @round.data.need_answer

    answerAtIndex: (index) ->
        if index == -1
            @round.roundData.answer
        else
            @round.data.answers[index]

    playerAtIndex: (index) ->
        if index == -1
            -1
        else
            @round.data.players[index]

    render: ->
        if Game.role == "creator"
            @renderForCreator()
        else
            @renderForPlayer()

    renderForCreator: ->
        switch @round.state
            when "pending"
                $("#game-content").html tmpl("tmpl-fibonacci-pending", @round)
            when "guessing"
                $("#game-content").html tmpl("tmpl-fibonacci-guessing", @round)
            when "guessed"
                $("#game-content").html tmpl("tmpl-fibonacci-guessed", @round)
                @showResults()

    renderForPlayer: ->
        switch @round.state
            when "pending"
                $("#game-content").html tmpl("tmpl-fibonacci-question", @round)
            when "guessing"
                $("#game-content").html tmpl("tmpl-fibonacci-guessing", @round)

    showResults: ->
        return unless Game.role == "creator"
        delay = 0

        for player in Player.all
            guessFor = @round.data.guesses[player.id]
            node = $(tmpl("tmpl-fibonacci-guess-from-player", player))
            parent = $(".answer-tags[data-answer-index='#{guessFor}']")
            node.hide().appendTo(parent).delay(delay).fadeIn(100)
            parent.append(" ")
            delay += 200

        delay += 2000

        $.timeout delay, =>
            $(".answer-label[data-correct='true']").removeClass("label-default").addClass("label-success")

        delay += 200

        $.timeout delay, =>
            guessFor = @round.data.guesses[player.id]
            node = $(tmpl("tmpl-fibonacci-correct", {}))
            parent = $(".answer-tags[data-correct='#{true}']")
            node.hide().appendTo(parent).fadeIn(300)
            parent.append(" ")

        delay += 2000

        for player in Player.all
            parent = $(".answer-tags[data-from-player-id='#{player.id}']")
            amountOfGuesses = parent.find(".guess").size()
            node = $(tmpl("tmpl-fibonacci-score-for-guesses", { player: player, guesses: amountOfGuesses }))
            node.hide().appendTo(parent).delay(delay).fadeIn(100)
            parent.append(" ")
            delay += 200

        delay += 5000

        $.timeout delay, =>
            form = $ tmpl("tmpl-fibonacci-finished-form", @round)
            form.appendTo "body"
            form.submit()

    updatePlayerStates: (players) ->
        return unless Game.role == "creator"

        for player in players
            Player.find(player.id).setRoundState(player.round_state)

    renderNewRound: (data) ->
        Round.current = new Round(data)
        Round.current.render()

    clearPlayerStates: ->
        for player in Player.all
            player.setRoundState("none")

    onEvent: (data) ->
        switch data.round_event
            when "answer_submitted"
                @updatePlayerStates(data.players)
            when "guess_submitted"
                @updatePlayerStates(data.players)
            when "guessing"
                @renderNewRound(data)
                @updatePlayerStates(data.players)
            when "guessed"
                @renderNewRound(data)
                @clearPlayerStates()

window.GameType.FibOnacci = FibOnacci
