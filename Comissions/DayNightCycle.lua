--[[
	By TimerHotel
	//TR
--]]

local Settings = require(script.Settings) --Settings in here

local InsertService = game:GetService("InsertService")

local DayNightTime = 24/(Settings.DayNightTime*60)
local UpdateTime = Settings.UpdateTime

local CurrentStamp = Settings.Day 
local Lighting = game.Lighting
local PassedTime = 0

function UpdateStamp(Time)
	Lighting.Ambient = Settings.TimeStamps[Time].Ambient
	Lighting.ColorShift_Bottom = Settings.TimeStamps[Time].ColorShift_Bottom
	Lighting.ColorShift_Top = Settings.TimeStamps[Time].ColorShift_Top
	Lighting.OutdoorAmbient = Settings.TimeStamps[Time].OutdoorAmbient
	Lighting.FogColor = Settings.TimeStamps[Time].FogColor
	Lighting.FogEnd = Settings.TimeStamps[Time].FogEnd
	Lighting.FogStart = Settings.TimeStamps[Time].FogStart
	Lighting.ClockTime = Settings.TimeStamps[Time].TimeBegin
	Lighting.Brightness = Settings.TimeStamps[Time].Brightness
	if Settings.TimeStamps[Time].Skybox then
		for i,v in pairs(Lighting:GetChildren()) do
			if v.ClassName == "Sky" then v:Destroy() end
		end
		local Sky = Settings.TimeStamps[Time].Skybox:Clone()
		Sky.Parent = Lighting
	end
end

function Interpolate(Time)
	local Before 
	if Time == 1 then
		Before = Settings.TimeStamps[#Settings.TimeStamps]
	else
		Before = Settings.TimeStamps[Time-1]
	end
	
	local TimeTable = Settings.TimeStamps[Time]
	local Normalized = (Lighting.ClockTime-TimeTable.TimeBegin)/(TimeTable.TimeEnd-TimeTable.TimeBegin)
	
	Lighting.Ambient = Before.Ambient:lerp(Settings.TimeStamps[Time].Ambient,Normalized)
	Lighting.ColorShift_Bottom = Before.ColorShift_Bottom:lerp(Settings.TimeStamps[Time].ColorShift_Bottom,Normalized)
	Lighting.ColorShift_Top = Before.ColorShift_Top:lerp(Settings.TimeStamps[Time].ColorShift_Top,Normalized)
	Lighting.OutdoorAmbient = Before.OutdoorAmbient:lerp(Settings.TimeStamps[Time].OutdoorAmbient,Normalized)
	Lighting.FogColor = Before.FogColor:lerp(Settings.TimeStamps[Time].FogColor,Normalized)
	Lighting.FogEnd = Before.FogEnd + (Settings.TimeStamps[Time].FogEnd - Before.FogEnd)*Normalized
	Lighting.FogStart = Before.FogStart + (Settings.TimeStamps[Time].FogStart - Before.FogStart)*Normalized
	Lighting.Brightness = Before.Brightness + (Settings.TimeStamps[Time].Brightness - Before.Brightness)*Normalized
	
	if Settings.TimeStamps[Time].Skybox then
		for i,v in pairs(Lighting:GetChildren()) do
			if v.ClassName == "Sky" then v:Destroy() end
		end
		local Sky = Settings.TimeStamps[Time].Skybox:Clone()
		Sky.Parent = Lighting
	end
end

UpdateStamp(Settings.StartTime)

while true do
	local ToAdd = DayNightTime*UpdateTime
	if ToAdd == 0 then
		ToAdd = 0.013333333333333
	end
	PassedTime = PassedTime + UpdateTime
	Lighting.ClockTime = Lighting.ClockTime + ToAdd
	for i,v in pairs(Settings.TimeStamps) do
		if v.TimeBegin < Lighting.ClockTime and v.TimeEnd > Lighting.ClockTime then
			Interpolate(i)
		end
		if i == "Night" then
			if v.TimeBegin < Lighting.ClockTime or v.TimeEnd > Lighting.ClockTime then
				Interpolate(i)
			end
		end
	end
	wait(UpdateTime)
end
