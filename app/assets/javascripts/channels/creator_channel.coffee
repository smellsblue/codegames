App.cable.subscriptions.create { channel: "CreatorChannel" },
    received: (data) ->
        console.log(data)
