App.cable.subscriptions.create { channel: "PlayerChannel" },
    received: (data) ->
        switch data.event
            when "game_ended"
                Game.ended(data)
            when "round_started"
                Round.current = Round.started(data)
            when "round_event"
                Round.current.onEvent(data)
            when "round_ended"
                Round.current = null
                Round.render()
