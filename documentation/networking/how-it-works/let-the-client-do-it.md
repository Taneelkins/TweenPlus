# Let the client do it

The Roblox server is limited to 60 FPS, and sending large amounts of data every frame is expensive, as not all clients have the bandwidth to handle it efficiently. To address this, we can give the hard work to the client. But how do we ensure the client knows what to do?

The solution is to synchronize tween data between the server and client. Instead of sending the tween's output, the server only shares the internal tween parameters — such as those provided via an API like Tween+. Whenever the server creates, plays, resets, stops, or destroys a tween, it notifies the client with the necessary details.

This approach minimizes what the server has to do. But the server still needs to track tween states to handle cases like players joining mid-tween. Additionally, server code might expect the tween output to match the client's. Instead of actually tweening on the server, we can update the relevant values only when a tween stops. This way, the server stays in sync enough for most cases, while avoiding constant updates.

The client will of course have to do the hard work itself. But that's exactly what we want. You see, this way, server (global) tweens will appear as smooth on every client as local tweens.

This technique ultimately reduces server and network usage by a lot, while also making tweens smoother for the clients. The only downside is the server not actually ever playing the tween — but depending on how you look at it, that can be seen as an advantage.
