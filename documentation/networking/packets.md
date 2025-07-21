# Packets

Create a new ModuleScript and name it `Packets`.

Then drag the `Packet` module (the network library) inside of this new module.

The `Packets` module shall contain all of the packet definitions.\
It is crucial that you include these exact packets in the module for the Tween+ networking to work:

```lua
local Packet = require(script.Packet)

return {
	GetAPIMap = Packet():Response(Packet.Any),
	TweenReady = Packet(),
	CreateTween = Packet(Packet.NumberU8, Packet.Instance, Packet.Any, Packet.Any),
	StartTween = Packet(Packet.NumberU8, Packet.Any, Packet.Any),
	StopTween = Packet(Packet.NumberU8),
	ResetTween = Packet(Packet.NumberU8),
	DestroyTween = Packet(Packet.NumberU8)
}
```

{% hint style="success" %}
You can of course add any more packets at any time for your own use in your game.
{% endhint %}
