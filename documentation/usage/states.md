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

The following are boolean properties representing the tween's state:

* `Playing`



Example:

{% code title="Script1" %}
```lua
local tween = Tween(workspace.Part, {Transparency = 1}, {Time = 2})
shared.MyTween = tween -- Share the tween with other scripts.
task.wait(1)
tween:Start()
```
{% endcode %}

{% code title="Script2" %}
```lua
task.wait(5)
if shared.MyTween.Playing then
	print("Tween is still playing, wow!")
else
	print("Tween is not playing anymore :(")
end
```
{% endcode %}

{% hint style="info" %}
Note that this is a rather useless example.\
There are actually good examples of use.
{% endhint %}
