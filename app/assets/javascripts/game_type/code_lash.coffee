class CodeLash
    constructor: (round) ->
        @round = round

    render: ->
        if Game.role == "creator"
            @renderForCreator()
        else
            @renderForPlayer()

    renderForCreator: ->
        switch @round.state
            when "pending"
                $("#game-content").html tmpl("tmpl-codelash-pending", @round)
            when "voting"
                $("#game-content").html tmpl("tmpl-codelash-vote", @round)
            when "voted"
                $("#game-content").html tmpl("tmpl-codelash-vote", @round)
                @showResults()

    renderForPlayer: ->
        switch @round.state
            when "pending"
                $("#game-content").html tmpl("tmpl-codelash-questions", @round)
            when "voting"
                $("#game-content").html tmpl("tmpl-codelash-vote", @round)
            when "voted"
                $("#game-content").html tmpl("tmpl-codelash-vote", @round)

    showResults: ->
        return unless Game.role == "creator"
        delay = 0

        for player in Player.all
            voteFor = @round.data.votes[player.id]
            continue unless voteFor?
            node = $(tmpl("tmpl-codelash-vote-from-player", player))
            parent = $("#answers-#{voteFor} .votes")
            node.hide().appendTo(parent).delay(delay).fadeIn(300)
            parent.append(" ")
            delay += 500

        delay += 1000
        scores = []

        for score in @round.data.scoring
            if score.type != "codelash"
                scores.push(score)

        for score in @round.data.scoring
            if score.type == "codelash"
                scores.push(score)

        for score in scores
            node = $(tmpl("tmpl-codelash-score-for-player", score))
            parent = $("#answers-#{score.player} .scores")
            node.hide().appendTo("#answers-#{score.player} .scores").delay(delay).fadeIn(300)
            parent.append(" ")
            delay += 500

        delay += 2500

        $.timeout delay, =>
            form = $ tmpl("tmpl-codelash-finished-form", @round)
            form.appendTo "body"
            form.submit()

    nextQuestion: ->
        for question in @round.data.questions
            return question unless question.answer

        null

    isVoting: ->
        for playerId in @round.data.players
            return false if playerId == Player.current.id

        !@round.data.votes[Player.current.id]?

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
            when "vote_submitted"
                @updatePlayerStates(data.players)
            when "voting"
                @renderNewRound(data)
                @updatePlayerStates(data.players)
            when "voted"
                @renderNewRound(data)
                @clearPlayerStates()

window.GameType.CodeLash = CodeLash
