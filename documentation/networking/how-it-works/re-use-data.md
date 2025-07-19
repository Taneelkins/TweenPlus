# Re-use data

Sometimes we can avoid sending certain data, as we can use other data to calculate that data.

For example, when a player joins mid-tween, we want to inform them of how many repetitions we've done already. You might think we should also inform the client of whether or not we're going in reverse at the moment. But actually, we can use some simple math in this case.

Since we have the repetition count already, we can use that to calculate whether or not we're going in reverse at the moment. It's just a simple check to see if the repetition count is odd or even — if it's odd, we're going in reverse, otherwise we're not.

This principle of re-using data can be applied in a lot of other cases too.
