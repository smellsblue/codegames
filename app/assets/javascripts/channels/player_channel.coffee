App.cable.subscriptions.create { channel: "PlayerChannel" },
    received: (data) ->
        switch data.event
            when "game_ended"
                Game.ended(data)
