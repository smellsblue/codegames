App.cable.subscriptions.create { channel: "PlayerChannel" },
    received: (data) ->
        console.log(data)
