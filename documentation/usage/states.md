---
layout:
  width: default
  title:
    visible: true
  description:
    visible: false
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
  metadata:
    visible: true
---

# States

The following are properties representing the tween's state:

* `Playing`: boolean?
* `Repetitions`: number
* `Reverses`: boolean?



Example:

{% code title="Script1" %}
```lua
local tween = Tween(workspace.Part, {Transparency = 1}, {Time = 2, Repetitions = 5, Reverses = true})
shared.MyTween = tween -- Share the tween with other scripts.
tween:Start()
```
{% endcode %}

{% code title="Script2" %}
```lua
task.wait(5)
if shared.MyTween.Playing then
	print("Tween is still playing, wow!")
	-- Let's print some information about the progress!
	print("Tween is going "..(if shared.MyTween.Reverses then " in reverse" else "forward").."!")
	print("Tween has done "..shared.MyTween.Repetitions.." repetitions!")
else
	print("Tween is not playing anymore :(")
end
```
{% endcode %}

{% hint style="info" %}
Note that this is a rather useless example, simply to give an idea of what it does.\
There are actually good use cases for this of course!
{% endhint %}
