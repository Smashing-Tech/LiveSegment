# LiveSegment Documentation

**LiveSegment** helps you generate segments at runtime. It requires the use of a few patches to Smash Hit, but provides better support than the default `mgBox`, `mgObstacle` and `mgPowerup` functions.

We do this by enabling the Lua `io` module, which allow us to write files, and also allowing the loading of segments from anywhere Smash Hit can read files instead of just the `assets/segments` folder.

As you can probably guess, we write segments to a file so it's just like loading a regular segment file to the game, but instead of being made in an editor (like SHBT), it's been dynamically generated at runtime!

## Installing

First, you need to get the Smash Hit patching tool v0.1.1 or later. After that, run it on your `libsmashhit.so` and make sure to select "Load package, io and os modules in scripts".

After this, we still need to patch the binary a bit more. Find the string `"segments/"` in the binary (EXACTLY that string, no less no more), then replace the first character with a null byte. (There is a fix coming soon to make it possible in the patcher. If you don't know how to do this then just wait.)

After that, copy the [`include.lua`](include.lua) in the repo over the one that you have in your APK.

You should now be ready to use LiveSegment!

## Create a new segment

To create a segment, call:

```lua
Segment(name, length)
```

* `name`: Name of the segment. Make sure it is a valid file name, and make sure it is *not* `progress` to avoid overwriting your save file.
* `length`: Length of the segment, in units.

For example:

```lua
seg = Segment("new_segment", 16, "org.knot126.smashhit.newgen")
```

## Add boxes, obstacles, etc. to a segment

To add boxes, obstacles or any other type of entity to a segment, simpily use one of the functions:

### Boxes

```lua
seg:box(position, size, colour)
```

* `position`: The position of the box, given as a table with three number entries. (e.g. `{1.0, 2.0, 4.0}`)
* `size`: The size of the box, again given as a table with three number entries.
* `colour`: A colour for the box. This is, again, given as a table with three entries.

For example:

```lua
seg:box({0.0, 0.0, -8.0}, {4.0, 1.0, 8.0}, {1.0, 0.5, 0.25})
```

### Obstacles

```lua
seg:obstacle(position, kind, params)
```

* `position`: The position of the obstacle.
* `kind`: The type of obstacle that will be placed.
* `params`: Table with strings for all keys and values which specify the parameters to be passed.

For example:

```lua
seg:obstacle({0.0, 0.5, -8.0}, "rotor", {color = "0.5 0.25 0.125", endplate = "true"})
```

### Decals

```lua
seg:decal(segment, position, tile, size, colour)
```

* `position`: The position of the decal.
* `tile`: The tile number of the decal.
* `size`: Optional size of the decal as a table with two numbers.
* `colour`: Optional colour attribute for the decal.

Example:

```lua
seg:decal({0.0, 0.5, -4.0}, 15)
seg:decal({1.0, 0.5, -6.0}, 27, {5.0, 0.5}, {1.0, 0.0, 0.0})
```

### Power-ups

```lua
seg:powerup(position, kind)
```

* `position`: The position of the powerup.
* `kind`: The type of powerup to be placed.

Example:

```lua
seg:powerup({0.0, 0.5, -12.0}, "ballfrenzy")
```

### Water

```lua
seg:water(position, size)
```

* `position`: The position of the water, given as a three number table.
* `size`: Size of the water, given as a two number table.

For example:

```lua
seg:water({0.0, 0.0, -12.0}, {3.0, 5.0})
```

## Save and load the segment

To make the segment work, you need to mark it as done in order to save it. After that, you can load it like a normal segment.

To mark as done, just call:

```lua
seg:done()
```

> TIP: You can't add anything to a segment once you have called done().

Then, to load it, use `confSegment` but make sure that you use `seg:path()` instead of any normal filename:

```lua
confSegment(seg:path(), 1)
```

## Full example

Here is an example of a room that I made using LiveSegment:

```lua
function init()
	mgMusic("25")
	mgFogColor(0.1, 0.2, 0.3, 0.5, 0.6, 0.7)
	
	seg = Segment("generated", 16)
	seg:box({0.0, -1.0, -8.0}, {4.0, 0.5, 8.0}, {0.25, 0.75, 0.25})
	seg:obstacle({0.0, 0.5, -8.0}, "rotor", {color = "0.5 0.25 0.125", endplate = "true"})
	seg:decal({0.0, 0.5, -4.0}, 15)
	seg:decal({1.0, 0.5, -6.0}, 27, {5.0, 0.5}, {1.0, 0.0, 0.0})
	seg:powerup({0.0, 0.5, -12.0}, "ballfrenzy")
	seg:water({0.0, 0.0, -12.0}, {3.0, 5.0})
	seg:done()
	confSegment(seg:path(), 1)
	
	l = 0
	
	local targetLen = 80
	while l < targetLen do
		s = nextSegment()
		l = l + mgSegment(s, -l)
	end
	
	mgLength(l)
end

function tick()
end
```

## Using the default room feature

If you don't want to create multipule segments per room, you can call `beginRoom(length)`, then use the `room` variable as if it were a segment.

As an example:

```lua
function init()
	mgMusic("25")
	mgFogColor(0.1, 0.2, 0.3, 0.5, 0.6, 0.7)
	
	beginRoom(120)
	
	room:box({0.0, 0.0, 0.0}, {0.1, 0.1, 0.1}, {0.0, 0.0, 0.0})
	room:obstacle({0.0, 0.0, -4.0}, "scoretop", {})
	room:powerup({0.0, 0.0, -12.0}, "ballfrenzy")
	
	for z = 15.0, 100.0, 5.0 do
		room:obstacle({0.0, 0.0, -z}, "scorestar", {})
	end
	
	endRoom()
end

function tick()
end
```

## Using the `pumpSegments` helper function

**LiveSegment** also provides a function called `pumpSegments`. It essentially replaces the drawn out ending that uses a while loop and is complex for beginers with a single function call to `pumpSegments(length)`.

For example:

```lua
function init()
	mgMusic("25")
	mgFogColor(0.1, 0.2, 0.3, 0.5, 0.6, 0.7)
	
	seg = Segment("1", 16)
	seg:box({0.0, -1.0, -8.0}, {4.0, 0.5, 8.0}, {0.25, 0.75, 0.25})
	seg:obstacle({0.0, 0.5, -8.0}, "rotor", {color = "0.5 0.25 0.125", endplate = "true"})
	seg:decal({0.0, 0.5, -4.0}, 15)
	seg:decal({1.0, 0.5, -6.0}, 27, {5.0, 0.5}, {1.0, 0.0, 0.0})
	seg:powerup({0.0, 0.5, -12.0}, "ballfrenzy")
	seg:water({0.0, 0.0, -12.0}, {3.0, 5.0})
	seg:done()
	confSegment(seg:path(), 1)
	
	pumpSegments(80)
end

function tick()
end
```
