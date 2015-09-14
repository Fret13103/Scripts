if myHero.charName ~= "Teemo" then return end
local version = "1.4"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Fret13103/Scripts1/master/Teemo.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local positions = {}
qRange = 800

function OnLoad()
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,  (qRange + 200), true)
	if GetSave("TEEMOPOSITIONS").positions ~= nil then
		positions = GetSave("TEEMOPOSITIONS").positions
	end
	
	config = scriptConfig("Omega Teemo: Resurrected", "lol, noticing a pattern here?")
	config:addSubMenu("Teemo: Keys", "Keys")
	config.Keys:addParam("shroomKey", "Place, Draw traps", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	config.Keys:addParam("harass", "Harass key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	config.Keys:addParam("combo", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
	
	config:addSubMenu("Teemo: Drawing", "drawing")
	config.drawing:addParam("draw", "Draw text + circles", SCRIPT_PARAM_ONOFF, true)
	config.drawing:addParam("drawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	config.drawing:addParam("drawKS", "Draw Can Kill", SCRIPT_PARAM_ONOFF, true)
	config.drawing:addParam("quality", "Draw quality", SCRIPT_PARAM_SLICE, 10,0,50,0)
	
	config:addSubMenu("Teemo: Harass", "harass")
	config.harass:addParam("useQ", "Use Q in harass?", SCRIPT_PARAM_ONOFF, true)
	config.harass:addParam("harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	config.harass:addParam("useR", "Use R to harass using minions", SCRIPT_PARAM_ONOFF, true)
	
	config:addSubMenu("Teemo: Combo", "combo")
	config.combo:addParam("useQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("useW", "Use W to get chase", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("useR", "Ult in combo", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("Ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("ksQ", "Use Q to ks", SCRIPT_PARAM_ONOFF, true)
	
	config: addSubMenu("Teemo: LaneClear", "laneclear")
	config.laneclear:addParam("LaneClear", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	config.laneclear:addParam("useR", "Use ult in Laneclear", SCRIPT_PARAM_ONOFF, true)
	config.laneclear:addParam("rMana", "Min mana to ult", SCRIPT_PARAM_SLICE, 25,0,100,0)
	config.laneclear:addParam("numR", "Min minions hit to ult", SCRIPT_PARAM_SLICE, 3, 0, 10, 0)
	
		if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then ign = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then ign = SUMMONER_2
  else ign = nil
	end
	
	ignite = ign
end

local count = 0
	function LoadOrbwalker()
   if _G.Reborn_Initialised then
      print("Omega Teemo: Reborn loaded and authed")
			isSac = true
			loaded = true
			config:addSubMenu("Orbwalker", "Orbwalker")
			config.Orbwalker:addParam("infoooo", "SAC:R detected", SCRIPT_PARAM_INFO, "")
   elseif _G.Reborn_Loaded and not _G.Reborn_Initialised and count < 20 then
			if printedWaiting == false then
      print("Omega Teemo: Waiting for Reborn auth")
			printedWaiting = true
			end
      DelayAction(LoadOrbwalker, 1)
			count = count + 1
   else
			if count >= 30 then
			print("Omega Teemo: SAC failed to auth")
			end
			require 'SxOrbWalk'
      print("SxOrbWalk: Loading...")
				config:addSubMenu("Orbwalker", "Orbwalker")
				SxOrb:LoadToMenu(config.Orbwalker)
				isSx = true
			print("SxOrbWalk: Loaded")
			loaded = true
   end
end
lastPos = nil
function AddPosition(PositionVector, priority)
-- 255, 1, 128 = max priority, min priority, neutral priority
	if positions[1] then
	for i, v in pairs(positions) do
		if GetDistance(PositionVector, Vector(v.x, v.y, v.z)) > 100 then
			posMade = false
		else 
			posMade = true
		end
	end
	else posMade = false end
	if posMade == false then
		new = table.insert(positions, {x = PositionVector.x, y = PositionVector.y, z = PositionVector.z, Priority = priority, used = false})
		lastPos = new
		print("added to table")
		GetSave("TEEMOPOSITIONS").positions = positions
		GetSave("TEEMOPOSITIONS").positions = positions
	end
end

function RemovePosition(pos)
	print("remove")
	GetSave("TEEMOPOSITIONS").positions = positions
end

function OnWndMsg(Msg, Key)
	if Msg == KEY_DOWN and Key == GetKey("P") then 
		DevMode = true 
	elseif Key == GetKey("I") then 
		DevMode = false 
	elseif Key == GetKey("O") then
		print("Do you want to clear positions? If so press Y")
		NextButtonClear = true
	elseif Key == GetKey("Y") then
		GetSave("TEEMOPOSITIONS").positions = {}
		positions = {}
		GetSave("TEEMOPOSITIONS").positions = positions
	end
	
	if Msg == WM_LBUTTONDOWN and DevMode then
		AddPosition(mousePos, 128)
	elseif Msg == WM_RBUTTONDOWN and DevMode then
		count = 0
		for i, v in pairs(positions) do
			count = count + 1
		end
		r = positions[count]
		table.remove(positions, count)
		print("removed")
	end
end

function OnDraw()
if config.drawing.draw then
	if positions ~= nil and positions[1] and config.Keys.shroomKey then
		for i, v in ipairs(positions) do
			DrawCircle3D(v.x, v.y, v.z, 100, 1, RGB(v.Priority, v.Priority, v.Priority), config.drawing.quality)
			if GetDistance(mousePos, Vector(v.x, v.y, v.z)) <= 100 then
				PlaceShroom(Vector(v.x, v.y, v.z), v)
			end
		end
	end
	if config.drawing.DrawQ and CanCast(_Q) then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero:GetSpellData(_Q).range, 5, RGB(0,0,255), config.drawing.quality) 
	end
AutoKill()
DrawKS()
end
end

function OnUnload()
GetSave("TEEMOPOSITIONS").positions = positions
end

function OnDeleteObj(Obj)
	if Obj.name == "Noxious Trap" or "Teemo_Base_R_tar.troy" then
		for i = 1, heroManager.iCount, 1 do
      local hero = heroManager:getHero(i)
			if ValidTarget(hero) and hero.team ~= myHero.team and GetDistanceSqr(Obj, hero) <= 300 then 
				hit = true
			end
			for i, v in pairs(positions) do
				Pos = Vector(v.x, v.y, v.z)
				if GetDistanceSqr(Pos, Obj) <= 300 then
					v.Used = false
					if hit == true then 
						v.Priority = v.Priority + 15
					else
						v.Priority = v.Priority - 15
					end
				end
			end
		end
	--[[elseif Obj.name:lower():find("teemo") then print(Obj.name)]] end
end

function PlaceShroom(VectorPos, position)
	--if position.used == false then
		if CanCast(_R) then CastSpell(_R, VectorPos.x, VectorPos.z) position.used = true end
	--end
end

function WalkToPos(VectorPos, position)
	myHero:MoveTo(VectorPos.x, VectorPos.z)
	PlaceShroom(VectorPos, position)
end

function Harass()
	if config.Keys.harass then
		if config.harass.UseR and ValidTarget(target) then
			for _, minion in pairs(minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_HEALTH_ASC).objects) do
			local rRange = myHero:GetSpellData(_R).range
			if ValidTarget(minion, rRange) and not attacking() then
				if GetDistance(target, minion) <= 300 and CanCast(_R) then
					CastSpell(_R, minion.x, minion.z)
				end
			end
			end
		end
		if config.harass.UseQ then
			UseQ()
		end
	end
end

function attacking()
	if isSac then
		if _G.AutoCarry.Orbwalker:IsShooting() then
			return true
		end
	elseif isSx then
		if not SxOrb:CanMove() then
			return true
		end
	end
	return false
end

function UseQ()
	if config.Keys.combo or config.Keys.harass and CanCast(_Q) then
		if ValidTarget(target, myHero:GetSpellData(_Q).range) and not attacking() then
			CastSpell(_Q, target)
		end
	end
end


function combo()
	if config.Keys.combo and ValidTarget(target) then
		if config.combo.UseQ and CanCast(_Q) and ValidTarget(target) then
			UseQ()
		end
		if config.combo.UseW and CanCast(_W) and ValidTarget(target) then
			if GetDistance(target) > (myHero.range + GetDistance(myHero.maxBBox)) then
				CastSpell(_W)
			end
		end
		if config.combo.UseR and CanCast(_R) and ValidTarget(target) then
			for i, v in pairs(minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_HEALTH_ASC).objects) do
				if GetDistance(minion, target) <= 300 then CastSpell(_R, minion.x, minion.z) end
			end
			if CanCast(_R) and ValidTarget(Target, 300) then CastSpell(_R, target.x, target.z) end
		end
	end
end


function AutoKill()
Ignite()
	for i = 1, heroManager.iCount, 1 do
		local targeta = heroManager:getHero(i)
		if targeta.team ~= myHero.team then
			qDmg = getDmg("Q", targeta, myHero)
			if targeta.health < qDmg and CanCast(_Q) and config.combo.ksQ and ValidTarget(targeta, 1000) then
				CastSpell(_Q, targeta)
			end
		end
	end
end

function Ignite()
local igniteDmg = nil
igniteDmg = 20 + (20 * myHero.level)
for i = 1, heroManager.iCount, 1 do
		local targeta = heroManager:getHero(i)
		if targeta.team ~= myHero.team and ignite then
		if targeta.health < igniteDmg and CanCast(ignite) and ValidTarget(targeta, 800) then CastSpell(ignite, targeta) end
		end
end
end

function DrawKS()
	for i = 1, heroManager.iCount, 1 do
		local current = heroManager:GetHero(i)
		if current.team ~= myHero.team then
			local qDmg = getDmg("Q", current, myHero)
			if qDmg > current.health then
				
			end
		end
	end
end

function DrawCircle(x, y, z, range, color)
	DrawCircle3D(x, y, z, range, 1, color, config.drawing.quality)
end

function OnTick()
ts:update()
target = ts.target
Harass()
combo()
Ignite()
AutoKill()
UseQ()
LaughSpam()
LaneClear()
end

function CanCast(spell)
return myHero:CanUseSpell(spell) == READY
end

function LaughSpam()
SendChat("/l")
DelayAction(function() LaughSpam() end, .1)
end

function LaneClear()
local inRangeOfV = 0
	if config.laneclear.LaneClear and config.laneclear.useR and myHero.mana / myHero.maxMana * 100 >= config.laneclear.rMana then
	for _, v in ipairs(minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_MAXHEALTH_DEC).objects) do
		for _, x in ipairs(minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_MAXHEALTH_DEC).objects) do
			if GetDistance(x, v) < 200 and inRangeOfV then inRangeOfV = inRangeOfV + 1 end
		end
	if inRangeOfV >= config.laneclear.numR and CanCast(_R) then CastSpell(_R, v.x, v.z) else inRangeOfV = 0	end
	end
end
end
