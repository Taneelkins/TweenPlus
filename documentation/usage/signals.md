# Signals

After creating a new tween, you can listen to the following [signals](https://alexanderlindholt.gitbook.io/signalplus/api-reference):

* [**Updated**](#user-content-fn-1)[^1]
* [**Started**](#user-content-fn-2)[^2]
* [**Stopped**](#user-content-fn-3)[^3]
* [**Completed**](#user-content-fn-4)[^4]



Example:

```lua
local tween = Tween(workspace.Part, {Transparency = 1}, {Time = 2})
tween.Updated:Connect(function(alpha)
	-- Alpha is a value in the range 0-1.
	-- That's why we multiply by 100 to convert to percentage.
	print("Progress: "..tostring(alpha*100).."%") -- For example "Progress: 50%".
end)
tween:Start()
```

[^1]: Fires every iteration of playback; every time the instance's values are updated.

    \
    It provides the current alpha (linear) at every update.



    _`alpha` is the progress from start to finish in the range 0-1. With reversing and repeats it will actually go back and forth._

[^2]: Fires when the playback is started or resumed.

[^3]: Fires when playback is stopped.

    Also fires when playback finishes.

[^4]: Fires when playback finishes.

    Does not fire when playback is stopped.
