App.cable.subscriptions.create { channel: "CreatorChannel" },
    received: (data) ->
        switch data.event
            when "player_left"
                Player.left(data)
            when "player_joined"
                Player.joined(data)
