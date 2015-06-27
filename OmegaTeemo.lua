local version = "1.0"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Fret13103/Scripts/master/OmegaTeemo.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
range = myHero.range + GetDistance(myHero.maxBBox)

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Omega Teemo:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST,"/Fret13103/Scripts/master/OmegaTeemo.version")
	--print(ServerData)
	if ServerData then
		--print("Has server Data")
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		print(ServerVersion)
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				print("Updating")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 2)
				--print("Updated")
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
				AutoupdaterMsg("If your local version > server version then please report this")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end



if myHero.charName ~= "Teemo" then return end

local qRange = myHero.range + 150
local eDOT = ((myHero:GetSpellData(_E).level * 6 ) + ( myHero.ap / 100 * 10 ))
local eOnHit = (myHero.ap / 3 ) + (10 * myHero:GetSpellData(_R).level)
local rDamage = ((myHero:GetSpellData(_R).level * 31.25) + (myHero.ap / 100 * 12.5))
--local qDmg = getDmg("Q", target, myHero)
local aaRange = myHero.range
local user = GetUser()
local isSac
local isSx
local isDagget = false
local spamlaugh = false
local handyMan = false
--local aaDmg = myHero.damage


positions = {One = {x = 3548, y = 20, z = 9286, importance = 5}, Two = {x = 3752, y = -45, z = 9437, importance = 7}, Three = {x = 4703, y = -71, z = 10063, importance = 9}, Four = {x = 3183, y = 52, z = 7686, importance = 6}, Five = {x = 4749, y = 51, z = 8022, importance = 9}, Six = {x = 8589, y = -68, z = 5752, importance = 5}, Seven = {x = 10097, y = -71, z = 4972, importance = 7}, Eight = {x = 9702, y = -40, z = 6319, importance = 5}, Nine = {x = 10081, y = 50, z = 6590, importance = 7}, Ten = {x = 10623, y = 52.7, z = 3049, importance = 8}, Eleven = {x = 10407, y = 50, z = 3091, importance = 4}, Twelve = {x = 11730, y = -71, z = 4091, importance = 7}, Thirteen = {x =11296, y = 11, z = 5568, importance = 8}, Fourteen = {x = 12611, z = 5318, y = 51.73, importance = 6}, Fifteen = {x = 11627, z = 7103, y = 52, importance = 5}, Sixteen = { x = 3067, z = 10899, y = -67, importance = 7}, Seventeen = {x = 2992, z = 12541, y = 53, importance = 7}, Eighteen = { x = 4391, z = 11841, y = 54.6, importance = 9}, Nineteen = { x = 6325, z = 9006, y = -71, importance = 5}, Twenty = {x = 7262, z = 6326, y = 52.45, importance = 5}, Twentyone = { x = 2853, z = 7748, y = 52, importance = 5}, Twenttwo = {x = 7045, z = 9448, y = 53, importance = 7}, Twentythree = {x = 8280, z = 10208, y = 50, importance = 9}, Twentyfour = {x = 7166, z = 12392, y = 52, importance = 6}, Twentyfive = {x = 4487, z = 12183, y = 57, importance = 7}, Twentysix = {x = 13499, z = 2837, y = 52, importance = 6}, Twentyseven = {x = 11024, z = 3883, y = -65, importance = 7}}

bluepositions = {One = {x = 7834, y = 57, z = 11814, importance = 7}, Twp = {x = 6780, y = 56, z = 12911, importance = 7}, Three = {x = 3804, z = 11489, y = -47, importance = 7}, Four = { x = 6337, z = 11358, y = 56, importance = 8}, Five = { x = 9371, z = 11345, y = 53, importance = 6}, Six = { x = 9845, z = 12060, y = 56, importance = 8}, Seven = {x = 12063, z = 9974, y = 52, importance = 8}, Eight = { x = 12133, z = 8821, y = 51, importance = 7}, Nine = { x = 11873, z = 7530, y = 52, importance = 6}, Ten = { x = 10070, z = 7299, y = 51, importance = 6}}

redpositions = {One = {x = 7968, y = 51, z = 2197, importance = 7}, Two = {x = 2742, y = 53, z= 4959, importance = 8}, Three = {x = 6594, z = 3077, y = 50, importance = 6}, Four = {x = 4972, z = 2882, y = 51, importance = 8}, Five = {x = 5716, z = 3505, y = 51, importance = 7}, Six = {x = 7973, y = 52, z = 3362, importance = 5}, Seven = {x = 6546, z = 4723, y = 49, importance = 7}, Eight = { x = 4698, z = 6140, y = 51, importance = 9 }, Nine = {x = 4779, y = 50, z = 7452, importance = 8}, Ten = {x = 2997, z = 7597, y = 52, importance = 6}, Eleven = {x = 3157, z = 7206, y = 52, importance = 6}}


local loaded = false
local printedWaiting = false

function OnLoad()

	if GetGameTimer() < 30 then print("Game has started!") end

	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,  (qRange + 200), true)

	print("Fret's Omega Squad Teemo:<font> <font color = \"#FF0000\">Loaded! </font>")
	print("<font> <font color = \"#ff0000\">Good luck " .. user .. " have fun! </font>")
	print("SCRIPT IS USABLE WITH SAC")

	config = scriptConfig("Fret's Omega Teemo", "Fret's Omega Teemo")

	config:addParam("info", "Made By", SCRIPT_PARAM_INFO, "Fret13103")

	config:addSubMenu("Teemo: Combo", "combo")
	config.combo:addParam("combo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
	config.combo:addParam("pos", "pos Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	config.combo:addParam("shroom", "Shroom placement Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	config.combo:addParam("useQ", "Use Q in combo?", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("useW", "Use W to get closer to target?", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("useR", "Use R in combo?", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("Ignite", "Auto Ignite?", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("ksQ", "Use Q to ks?", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("autoShroom", "Automatically place shrooms", SCRIPT_PARAM_ONOFF, true)
	config.combo:addParam("Infoo", "Enjoy the laugh spammer tool", SCRIPT_PARAM_INFO, "")

	config:addSubMenu("Teemo: Harass", "harass")
	config.harass:addParam("useQ", "Use Q in harass?", SCRIPT_PARAM_ONOFF, true)
	config.harass:addParam("harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	config.harass:addParam("useR", "Use R to harass using minions", SCRIPT_PARAM_ONOFF, true)
	config.harass:addParam("Inf", "Care, useR to harass is new feature!", SCRIPT_PARAM_INFO, "")

	config: addSubMenu("Teemo: LaneClear", "laneclear")
	config.laneclear:addParam("LaneClear", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	config.laneclear:addParam("useR", "Use ult in Laneclear", SCRIPT_PARAM_ONOFF, true)
	config.laneclear:addParam("rMana", "Min mana to ult", SCRIPT_PARAM_SLICE, 25,0,100,0)
	config.laneclear:addParam("numR", "Min minions hit to ult", SCRIPT_PARAM_SLICE, 3, 0, 10, 0)

	config:addSubMenu("Teemo: Drawing", "drawing")
	config.drawing:addParam("draw", "Draw text + circles", SCRIPT_PARAM_ONOFF, true)
	config.drawing:addParam("drawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	config.drawing:addParam("drawKS", "Draw Can Kill", SCRIPT_PARAM_ONOFF, true)
	config.drawing:addParam("drawDag", "Draw Dagett combo range", SCRIPT_PARAM_ONOFF, true)

	config:addSubMenu("Teemo: Bonus Features", "bonus")
	config.bonus:addParam("escape", "Escapemode Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	config.bonus:addParam("useR", "Use ult in escape mode", SCRIPT_PARAM_ONOFF, true)
	config.bonus:addParam("dagCombo", "DaggetCombo - ';' key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(186))
	config.bonus:addParam("save", "Use Zhonyas if health below %", SCRIPT_PARAM_SLICE, 25,0,100,0)
	config.bonus:addParam("laugh", "Chain laugh anims", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("2"))
	config.bonus:addParam("laughtoggle", "Chain laugh anims: toggle", SCRIPT_PARAM_ONOFF, false)

  LoadOrbwalker()
	loadHandyMan()

	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then ign = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then ign = SUMMONER_2
  else ign = nil
	end

	if myHero.team == TEAM_BLUE then
		config:addParam("infooo", "Team is:", SCRIPT_PARAM_INFO, "Blue team!")
	elseif myHero.team == TEAM_RED then
		config:addParam("infoooo", "Team is:", SCRIPT_PARAM_INFO, "Red team!")
	end

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

function loadHandyMan()
if _G.HandyMan_isLoaded then
print("Teemo's handyman detected, freelo mode enabled!")
handyMan = true
config:addParam("Infoooo", "HandyMan detected", SCRIPT_PARAM_INFO, "Enjoy!")
end
end

function UseQ()
	if isSac then
		if not isDagget and config.combo.combo and config.combo.useQ or config.harass.harass and config.harass.useQ then
			if CanCast(_Q) and ValidTarget(target, qRange) and _G.AutoCarry.Orbwalker:CanMove() and not _G.AutoCarry.Orbwalker:IsShooting() then
				CastSpell(_Q, target)
			end
		end
	elseif isSx then
		if config.combo.combo and config.combo.useQ then
			if CanCast(_Q) and ValidTarget(target, qRange) and SxOrb:CanMove() then
				CastSpell(_Q, target)
			end
		end
	end
end

function UseR()
	if config.combo.combo and config.combo.useR then
		if CanCast(_R) and ValidTarget(target) then
			Dist = GetDistance(target)
			if Dist <= 200 then
			CastSpell(_R, target.x, target.z)
			end
		end
	end
end

function OnTick()
HarassWithUlt()
MLGlaugh()
ClosestEnemy()
SaveMe()
DaggetCombo()
getItemSlot()
EscapeMode()
LaneClear()
ts:update()
target = ts.target
if isSx then
SxOrb:ForceTarget(target)
elseif isSac then
_G.AutoCarry.Crosshair:ForceTarget(target)
else
if loaded == true then
print("No orbwalker detected")
end
end

Combo()
AutoKill()
if config.combo.pos then
--print("X = " .. mousePos.x .. " Z =" .. mousePos.z .. " Y = " .. mousePos.y)
end
end

function Combo()
	GetCloseToTarget()
	UseQ()
	UseR()
	AutoKill()
end

function CanCast(spell)
return myHero:CanUseSpell(spell) == READY
end

function DrawShroom()
	if config.combo.shroom then
	for _, shroom in pairs(positions) do
		DrawCircle(shroom.x, shroom.y, shroom.z, 10 * shroom.importance, 0xffffff)
	end
	for _, shroom in pairs(redpositions) do
		DrawCircle(shroom.x, shroom.y, shroom.z, 10 * shroom.importance, 0xff0000)
	end
	for _, shroom in pairs(bluepositions) do
		DrawCircle(shroom.x, shroom.y, shroom.z, 10 * shroom.importance, 0x0000ff)
	end
	end
end

function OnDraw()
if config.drawing.draw then
DrawShroom()
PlaceShroom()
DrawQ()
DrawIgnite()
AutoKill()
DrawQign()
end
end

function PlaceShroom()
if config.combo.autoShroom then
for _, shroom in pairs(positions) do
			if GetDistance(myHero, shroom) <= 100 and CanCast(_R) then
			DrawCircle(shroom.x, shroom.y, shroom.z, 125, 0xff0000)
			DrawCircle(shroom.x, shroom.y, shroom.z, 130, 0xff0000)
			DrawCircle(shroom.x, shroom.y, shroom.z, 135, 0xff0000)
					CastSpell(_R, shroom.x, shroom.z)
			end
		end
	end
	if config.combo.shroom then
		for _, shroom in pairs(positions) do
			if GetDistance(mousePos, shroom) <= 100 and CanCast(_R) then
			DrawCircle(shroom.x, shroom.y, shroom.z, 125, 0xff0000)
			DrawCircle(shroom.x, shroom.y, shroom.z, 130, 0xff0000)
			DrawCircle(shroom.x, shroom.y, shroom.z, 135, 0xff0000)
					CastSpell(_R, shroom.x, shroom.z)
			end
		end
		for _, shroom in pairs(redpositions) do
			if GetDistance(mousePos, shroom) <= 100 and CanCast(_R) then
				DrawCircle(shroom.x, shroom.y, shroom.z, 125, 0xff0000)
				DrawCircle(shroom.x, shroom.y, shroom.z, 130, 0xff0000)
				DrawCircle(shroom.x, shroom.y, shroom.z, 135, 0xff0000)
				CastSpell(_R, shroom.x, shroom.z)
			end
		end
		for _, shroom in pairs(bluepositions) do
			if GetDistance(mousePos, shroom) <= 100 and CanCast(_R) then
			DrawCircle(shroom.x, shroom.y, shroom.z, 125, 0xff0000)
			DrawCircle(shroom.x, shroom.y, shroom.z, 130, 0xff0000)
			DrawCircle(shroom.x, shroom.y, shroom.z, 135, 0xff0000)
					CastSpell(_R, shroom.x, shroom.z)
			end
		end
	end
end

function AutoKill()
Ignite()
	for i = 1, heroManager.iCount, 1 do
		local targeta = heroManager:getHero(i)
		if targeta.team ~= myHero.team then
			qDmg = getDmg("Q", targeta, myHero)
			if targeta.health < qDmg and CanCast(_Q) and config.combo.ksQ and ValidTarget(targeta, qRange) then
				CastSpell(_Q, targeta)
			end
		end
	end
end

function Ignite()
	if config.combo.Ignite and ign ~= nil and CanCast(ign) then
		local igniteDamage = 50 + 20 * myHero.level
		for i = 1, heroManager.iCount, 1 do
			local targeta = heroManager:getHero(i)
			if ValidTarget(targeta, 600) and targeta.team ~= myHero.team then
				if igniteDamage > (targeta.health - 25) then
					CastSpell(ign, targeta)
					spamlaugh = true
					DelayAction(function() spamlaugh = false end, 1)
				end
			end
		end
	end
end

function DrawIgnite()
if config.drawing.draw then
if config.combo.Ignite and ign ~= nil then
		local igniteDamage = 50 + 20 * myHero.level
		for i = 1, heroManager.iCount, 1 do
			local targeta = heroManager:getHero(i)
			if ValidTarget(targeta, 600) and targeta.team ~= myHero.team then
				if igniteDamage > (targeta.health - 25) then
					local ignLeft = WorldToScreen(D3DXVECTOR3(targeta.x, targeta.y, targeta.z))
					DrawText("Ignite to kill", 18, ignLeft.x, ignLeft.y, 0xFFFF0000)
				end
			end
		end
	end
if CanCast(_R) then
	local startLeft = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
	DrawText("You can place your shroom now", 18, startLeft.x, startLeft.y, 0xFFFF0000)
else
	local startLeft = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
	if myHero:GetSpellData(_R).level ~= 0 then
	local rCD = myHero:GetSpellData(_R).currentCd
	if rCD == 0 and not CanCast(_R) then
	DrawText("You don't have any shrooms", 18, startLeft.x, startLeft.y, 0xFFFF0000)
	else
	DrawText("shroom cd = " .. rCD .. "", 18, startLeft.x, startLeft.y, 0xFFFF0000)
	end
	end
end
if myHero.isStealthed then
	local startLeft = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
	DrawText("You are stealthed", 18, startLeft.x, (startLeft.y-20), 0xFFFF0000)
end
if Zhonyas and CanCast(Zhonyas) then
	local startLeft = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
	DrawText("You can Zhonyas", 18, startLeft.x, (startLeft.y+20), 0xFFFF0000)
	DrawText("You can do Dagget combo", 18, startLeft.x, (startLeft.y+40), 0xFFFF0000)
end
end
end

function DrawQ()
	for i = 1, heroManager.iCount, 1 do
		local targeta = heroManager:getHero(i)
		if targeta.team ~= myHero.team then
			qDmg = getDmg("Q", targeta, myHero)
			if targeta.health < qDmg and ValidTarget(targeta) and config.drawing.drawKS and config.drawing.draw then
				local startLeft = WorldToScreen(D3DXVECTOR3(targeta.x, targeta.y, targeta.z))
				DrawText("Q to kill", 18, startLeft.x, startLeft.y+20, 0xFFFF0000)
			end
		end
	end
	if CanCast(_Q) and config.drawing.draw and config.drawing.drawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xff0000)
	end
	if CanCast(_Q) and Zhonyas and CanCast(Zhonyas) and config.drawing.drawDag then
		DrawCircle(myHero.x, myHero.y, myHero.z, 300, 0xffffff)
	end
end

function DrawQign()
	if config.combo.Ignite and ign ~= nil and config.combo.ksQ then
	for i = 1, heroManager.iCount, 1 do
		local targeta = heroManager:getHero(i)
		if targeta.team ~= myHero.team then
			local qDmg = getDmg("Q", targeta, myHero)
			local igniteDamage = 50 + 20 * myHero.level
			local totalDmg = qDmg + igniteDamage
			if targeta.health < totalDmg and ValidTarget(targeta) then
				local startLeft = WorldToScreen(D3DXVECTOR3(targeta.x, targeta.y, targeta.z))
				DrawText("Q + ign to kill", 18, startLeft.x, startLeft.y, 0xFFFF0000)
				if GetDistance(targeta) <= 600 then
					if CanCast(_Q) and CanCast(ign) and ValidTarget(targeta) then
						CastSpell(_Q, targeta)
						CastSpell(ign, targeta)
						spamlaugh = true
						DelayAction(function() spamlaugh = false end, 1)
					end
				end
			end
		end
	end
	end
end

local inRangeOfV = 0

function LaneClear()
	if config.laneclear.LaneClear and config.laneclear.useR and myHero.mana / myHero.maxMana * 100 >= config.laneclear.rMana then
	for _, v in ipairs(minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_MAXHEALTH_DEC).objects) do
		for _, x in ipairs(minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_MAXHEALTH_DEC).objects) do
			if GetDistance(x, v) < 200 then inRangeOfV = inRangeOfV + 1 end
		end
	if inRangeOfV >= config.laneclear.numR and CanCast(_R) then CastSpell(_R, v.x, v.z) else inRangeOfV = 0	end
	end
end
end

function GetCloseToTarget()
	if ValidTarget(target) and config.combo.useW and config.combo.combo and CanCast(_W) then
		local dist = GetDistance(target)
		if dist > myHero.range and dist < myHero.range + 150 then
			CastSpell(_W)
		end
	end
end

local isDagget = false
local closestEnemy = nil
--local DaggetDelay = config.bonus.DagDelay

function DaggetCombo()
	if config.bonus.dagCombo then
		myHero:MoveTo(mousePos.x, mousePos.z)
		isDagget = true
		if Zhonyas and CanCast(Zhonyas) and CanCast(_Q) and ValidTarget(closestEnemy) and CanCast(_R) and GetDistance(closestEnemy) <= 300 then
			if CanCast(_Q) and GetDistance(closestEnemy) <= qRange then CastSpell(_Q, closestEnemy)
			DelayAction(function() CastSpell(_R, myHero.x, myHero.z) DelayAction(function() CastSpell(Zhonyas) end,  .4) isDagget = false end, .1)
			end
		end
	else
		isDagget = false
	end
end

function ClosestEnemy()
closestEnemy = nil
for i = 1, heroManager.iCount, 1 do
	local targeta = heroManager:getHero(i)
	if targeta.team ~= myHero.team then
	local Dist = GetDistance(targeta)
	if closestEnemy == nil then
		closestEnemy = targeta
	else
		if Dist < GetDistance(closestEnemy) then
		closestEnemy = targeta
		end
	end
end
end
end

function EscapeMode()
	if config.bonus.escape then
		if CanCast(_W) then CastSpell(_W) end
		myHero:MoveTo(mousePos.x, mousePos.z)
		if CanCast(_R) and config.bonus.useR and ValidTarget(closestEnemy, qRange) then CastSpell(_R, myHero.x, myHero.z) end
	end
end

function SaveMe()
if Zhonyas and CanCast(Zhonyas) and (myHero.health / myHero.maxHealth) * 100 < config.bonus.save then CastSpell(Zhonyas) end
end

local laughed = false

function MLGlaugh()
if config.bonus.laugh or config.bonus.laughtoggle and loaded then
if laughed == false then
if isSx then
	if SxOrb:CanMove() then
	SendChat("/l")
	end
elseif isSac then
	if not _G.AutoCarry.Orbwalker:IsShooting() then
	SendChat("/l")
	end
end
laughed = true
DelayAction(function() laughed = false end, 2.1)
end
end
if spamlaugh == true then
SendChat("/l")
end
end

function getItemSlot()
for slot = ITEM_1, ITEM_7 do
local currentItemName = myHero:GetSpellData(slot).name
if currentItemName == "ZhonyasHourglass" then
Zhonyas = slot
elseif currentItemName  == "YoumusBlade" then
Ghostblade = slot
elseif currentItemName == "BilgewaterCutlass" then
BORK = slot
elseif currentItemName == "ItemSwordOfFeastAndFamine" then
BORK = slot
end
end
end

function HarassWithUlt()
	for _, minion in pairs(minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_HEALTH_ASC).objects) do
	if ValidTarget(minion, 300) and ValidTarget(closestEnemy, 900) and CanCast(_R) and not isDagget and not _G.AutoCarry.Orbwalker:IsShooting() then
		if GetDistance(minion, closestEnemy) <= 200 and config.harass.useR and config.harass.harass or config.combo.combo and config.combo.useR then
			CastSpell(_R, minion.x, minion.z)
	end

end
end
end




