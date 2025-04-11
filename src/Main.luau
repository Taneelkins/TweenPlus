--!optimize 2
--!native

--[[

=============== ====      ====      ====  ========================   ====       ====                
=============== =====    ======    =====  ========================   ======     ====        :::     
     ====        ====    ======    ====   ====                       =======    ====        :::     
     ====         ====  ========  ====    ====                       ========   ====        :::     
     ====         ====  ===  ===  ====    =======================    ==== ===== ====   :::::::::::::
     ====          ========  ========     ====                       ====   ========        :::     
     ====          =======    =======     ====                       ====    =======        :::     
     ====           ======    ======      ========================   ====     ======        :::     
     ====            ====      ====       ========================   ====       ====                

v1.1.0

An open-source tweening module for Roblox, featuring advanced
datatypes, accurate color interpolation and more customization.


GitHub:
https://github.com/AlexanderLindholt/TweenPlus

Devforum:
https://devforum.roblox.com/t/3599638


--------------------------------------------------------------------------------
MIT License

Copyright (c) 2025 AlexanderLindholt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--------------------------------------------------------------------------------

]]--

local RunService = game:GetService("RunService")

local dataTypes = require(script.DataTypes)
local normalDataTypes = dataTypes.Normal
local advancedDataTypes = dataTypes.Advanced

local easingFunctions = require(script.EasingFunctions)

local signalPlus = require(script.SignalPlus)

-- Defaults.
local defaultInverseTime = 1 -- 1/time.

local defaultEasingStyle = "Linear"
local defaultEasingDirection = "In"

local defaultUpdateEvent = RunService.PostSimulation

-- Types.
export type Tween = {
	Start: typeof(
		-- Starts or resumes playback of the tween.
		function(tween: Tween) end
	),
	Stop: typeof(
		-- Stops playback of the tween.
		-- Can be resumed with <code>Start()</code>.
		function(tween: Tween) end
	),
	Reset: typeof(
		-- Stops playback of the tween, and resets to starting values.
		function(tween: Tween) end
	),
	Destroy: typeof(
		-- Makes the tween unusable, and ensures it's stopped.
		function(tween: Tween) end
	),
	
	Updated: signalPlus.Signal<number>,
	Started: signalPlus.Signal,
	Stopped: signalPlus.Signal,
	Completed: signalPlus.Signal
}
export type Customization = {
	Time: number,
	
	EasingStyle:
		"Linear" |
		"Quad" |
		"Cubic" |
		"Quart" |
		"Quint" |
		"Sine" |
		"Exponential" |
		"Circular" |
		"Elastic" |
		"Back" |
		"Bounce",
	EasingDirection:
		"In" |
		"Out" |
		"InOut" |
		"OutIn",
	
	RepeatCount: number,
	Reverses: boolean,
	DelayTime: number,
	
	FPS: number,
	
	UpdateEvent: "PostSimulation" | "PreSimulation" | "PreRender"
}
type CreateTween = typeof(
	-- Creates a new tween.
	function(instance: Instance, values: {[string]: any}, customization: Customization): Tween end
)

-- List for validity checks.
local updateEvents = {
	PostSimulation = true,
	PreSimulation = true,
	PreRender = true
}

-- Module.
local instanceTweens = {}

local function propertyExists(instance, name)
	local _, result = pcall(function()
		local property = instance[name] -- If no property or instance is found, this will error.
		if typeof(property) == "Instance" then return end -- Ensure it's a property, not a child.
		return true
	end)
	return result
end

local function cancel(tween)
	-- Set playing to false, stopping playback.
	tween.Playing = false
	
	-- Tween removal.
	local instance = tween.Instance
	local tweens = instanceTweens[instance]
	tweens[tween] = nil
	if not next(tweens) then
		instanceTweens[instance] = nil
	end
	
	-- Fire stopped signal.
	tween.Stopped:Fire()
end

local function play(tween, instance, tweens)
	-- Gather information.
	local updated = tween.Updated
	
	local updateFunctions = tween.UpdateFunctions
	
	local inverseTweenTime = tween.InverseTweenTime
	local getValue = tween.GetValue
	local repeatCount = tween.RepeatCount
	local reverses = tween.Reverses
	local delayTime = tween.DelayTime
	local interval = tween.Interval
	
	local updateEvent = tween.UpdateEvent
	
	-- Play loop.
	while true do
		-- Calculate raw alpha.
		local alpha = (time() - tween.StartTime)*inverseTweenTime
		
		local phaseCompleted = alpha >= 1
		
		if phaseCompleted then alpha = 1 end
		
		if tween.Reverse then
			alpha = 1 - alpha
			if alpha < 0 then
				alpha = 0
			end
		else
			if alpha > 1 then
				alpha = 1
			end
		end
		
		-- Get eased alpha and call value update functions.
		local easedAlpha = getValue(alpha)
		for _, update in updateFunctions do
			update(easedAlpha)
		end
		
		-- Fire updated signal with raw alpha.
		updated:Fire(alpha)
		
		-- Phase completion stuff.
		if phaseCompleted then
			if tween.Reverse then
				if repeatCount == -1 or tween.Repetitions < repeatCount then
					tween.Repetitions += 1
					if delayTime then
						tween.Waited = time()
						task.wait(delayTime)
						tween.Waited = nil
						if not tween.Playing then return end
					end
					tween.Reverse = nil
					tween.StartTime = time()
				else
					break
				end
			else
				if reverses then
					if delayTime then
						tween.Waited = time()
						task.wait(delayTime)
						tween.Waited = nil
						if not tween.Playing then return end
					end
					tween.Reverse = true
					tween.StartTime = time()
				else
					if repeatCount == -1 or tween.Repetitions < repeatCount then
						tween.Repetitions += 1
						if delayTime then
							tween.Waited = time()
							task.wait(delayTime)
							tween.Waited = nil
							if not tween.Playing then return end
						end
						tween.StartTime = time()
					else
						break
					end
				end
			end
		end
		
		-- Yield.
		if interval then -- If FPS inputted.
			local intervalStart = time()
			while true do
				updateEvent:Wait()
				if time() - intervalStart >= interval then break end
			end
		else
			updateEvent:Wait()
		end
		
		-- Ensure tween is still supposed to play.
		if not tween.Playing then return end
	end
	
	-- Tween removal.
	tweens[tween] = nil
	if not next(tweens) then
		instanceTweens[instance] = nil
	end
	
	-- Set playing boolean.
	tween.Playing = false
	
	-- Fire completed signal.
	tween.Completed:Fire()
end

local tweenClass = table.freeze({__index = table.freeze({
	Start = function(tween)
		-- Gather information.
		local instance = tween.Instance
		local values = tween.Values
		
		local paused = tween.Paused
		
		-- Get instance's tweens.
		local tweens = instanceTweens[instance]
		
		-- Handle instance tweens.
		if tweens then
			-- Handle any conflicts.
			for otherTween, otherValues in tweens do
				for value in otherValues do
					if values[value] then
						cancel(otherTween)
						tweens[otherTween] = nil
						break
					end
				end
			end
			tweens[tween] = values
		else
			-- Initialize instance tweens storage.
			tweens = {[tween] = values}
			instanceTweens[instance] = tweens
		end
		
		-- Initialization.
		if paused then
			-- Account for waiting.
			local waited = tween.Waited
			if waited then
				task.wait(tween.DelayTime - paused + waited)
				tween.Waited = nil
			end
			
			-- Remove paused marker.
			tween.Paused = nil
			
			-- Adjust start time.
			tween.StartTime = tween.StartTime + time() - paused
		else
			-- Ensure no playback.
			if tween.Playing then cancel(tween) end
			
			-- Delay.
			if tween.DelayTime then
				task.wait(tween.DelayTime)
			end
			
			-- Initialize/reset tracking values.
			tween.StartTime = time()
			tween.Repetitions = 0
			tween.Reverse = false
		end
		
		-- Set playing boolean.
		tween.Playing = true
		
		-- Fire started signal.
		tween.Started:Fire()
		
		-- Start tween playback.
		coroutine.resume(coroutine.create(play), tween, instance, tweens)
	end,
	Stop = function(tween)
		-- Verify playback.
		if not tween.Playing then return end
		
		-- Save the current time as a marker for the pause.
		tween.Paused = time()
		-- Stop playback.
		cancel(tween)
	end,
	Reset = function(tween)
		-- Ensure no playback.
		if tween.Playing then cancel(tween) end
		
		-- Call all value reset functions.
		for _, reset in tween.ResetFunctions do
			reset()
		end
	end,
	Destroy = function(tween)
		-- Ensure no playback.
		if tween.Playing then cancel(tween) end
		
		-- Destroy signals.
		tween.Updated:Destroy()
		tween.Started:Destroy()
		tween.Stopped:Destroy()
		tween.Completed:Destroy()
		
		-- Clear tween data.
		table.clear(tween)
	end
})})

-- Return tween creation function.
return function(instance, values, customization)
	-- Argument errors.
	if typeof(instance) ~= "Instance" then error("No instance provided.") end
	if type(values) ~= "table" or not next(values) then error("No values provided.") end
	
	-- Handle values.
	local updateFunctions = {}
	local resetFunctions = {}
	for name, value in values do
		if type(name) ~= "string" then error("Received invalid value name of type '"..typeof(name).."' instead of string.") end
		
		if name:sub(1, 1) == "@" then
			-- Attribute.
			local attributeName = name:sub(2)
			local original = instance:GetAttribute(attributeName)
			if original == nil then error("'"..attributeName.."' is not a valid attribute of '"..instance:GetFullName().."'.") end
			
			local dataType = normalDataTypes[typeof(value)]
			if not dataType then error(typeof(value).." data type is not supported.") end
			
			table.insert(updateFunctions, function(lerp)
				instance:SetAttribute(attributeName, dataType(original, value, lerp))
			end)
			table.insert(resetFunctions, function()
				instance:SetAttribute(attributeName, original)
			end)
		else
			-- Not attribute.
			local dataType = advancedDataTypes[name]
			if dataType then
				-- Advanced type.
				if not instance:IsA(dataType.Target) then error("'"..instance:GetFullName().."'' doesn't have data type '"..name.."'.") end
				
				local original = dataType.Get(instance)
				local set = dataType.Set
				table.insert(updateFunctions, function(lerp)
					set(instance, original, value, lerp)
				end)
				table.insert(resetFunctions, function()
					set(instance, original, value, 0)
				end)
			else
				-- Property.
				if propertyExists(instance, name) ~= true then error("'"..name.."' is not a valid property of '"..instance:GetFullName().."'.") end
				dataType = normalDataTypes[typeof(value)]
				if not dataType then error(typeof(value).." data type is not supported.") end
				
				local original = instance[name]
				table.insert(updateFunctions, function(lerp)
					instance[name] = dataType(original, value, lerp)
				end)
				table.insert(resetFunctions, function()
					instance[name] = original
				end)
			end
		end
	end
	
	-- Handle tween info.
	if type(customization) ~= "table" then
		-- Create and return tween.
		return setmetatable({
			-- Signals.
			Updated = signalPlus(),
			Started = signalPlus(),
			Stopped = signalPlus(),
			Completed = signalPlus(),
			
			-- Main arguments.
			Instance = instance,
			Values = values,
			
			-- Value functions.
			UpdateFunctions = updateFunctions,
			ResetFunctions = resetFunctions,
			
			-- Customization. None provided, so use defaults.
			InverseTweenTime = defaultInverseTime,
			GetValue = easingFunctions[defaultEasingStyle],
			RepeatCount = 0,
			UpdateEvent = defaultUpdateEvent,
			
			-- Playing tracker.
			Playing = false
		}, tweenClass)
	else
		-- Get customization.
		local tweenTime = customization.Time
		
		local easingStyle = customization.EasingStyle
		
		local delayTime = customization.DelayTime
		local reverses = customization.Reverses
		local repeatCount = customization.RepeatCount
		
		local fps = customization.FPS
		
		local updateEvent = customization.UpdateEvent
		
		-- Verify customization.
		if type(tweenTime) ~= "number" then
			tweenTime = defaultInverseTime
		elseif tweenTime < 0.01 then
			tweenTime = 100 -- 1/0.01
		else
			tweenTime = 1/tweenTime
		end
		
		local getValue = nil
		do
			local easing = easingFunctions[easingStyle]
			if not easing then
				easing = easingFunctions[defaultEasingStyle]
				easingStyle = defaultEasingStyle
			end
			if easingStyle == "Linear" then
				getValue = easing
			else
				getValue = easing[customization.EasingDirection]
				if not getValue then
					getValue = easing[defaultEasingDirection]
				end
			end
		end
		
		if type(delayTime) ~= "number" or delayTime <= 0 then
			delayTime = nil
		end
		if reverses ~= true then
			reverses = nil
		end
		if type(repeatCount) ~= "number" then
			repeatCount = 0
		elseif repeatCount < 0 then
			repeatCount = -1
		end
		
		local interval = nil
		if type(fps) == "number" then
			interval = 1/fps
		end
		
		if updateEvents[updateEvent] then
			updateEvent = RunService[updateEvent]
		else
			updateEvent = defaultUpdateEvent
		end
		
		-- Create and return tween.
		return setmetatable({
			-- Signals.
			Updated = signalPlus(),
			Started = signalPlus(),
			Stopped = signalPlus(),
			Completed = signalPlus(),
			
			-- Main arguments.
			Instance = instance,
			Values = values,
			
			-- Value functions.
			UpdateFunctions = updateFunctions,
			ResetFunctions = resetFunctions,
			
			-- Customization.
			InverseTweenTime = tweenTime,
			GetValue = getValue,
			DelayTime = delayTime,
			Reverses = reverses,
			RepeatCount = repeatCount,
			Interval = interval,
			UpdateEvent = updateEvent,
			
			-- Playing tracker.
			Playing = false
		}, tweenClass)
	end
end :: CreateTween
