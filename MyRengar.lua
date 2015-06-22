local version = "2.1"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Fret13103/Scripts/master/MyRengar.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>My Rengar:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST,"/Fret13103/Scripts/master/MyRengar.version")
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

if myHero.charName ~= "Rengar" then return end

local combotype = 1 --1 = Q, 2 = E
local ts
local eRange = 1100

require "VPrediction"
require "HPrediction"

--promptline = math.huge speed, delayline is normal lineskillshot.
--took me a day but I finally got close enough to the right speed of E for HPRED.

function OnLoad()
ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, eRange, true)

VP = VPrediction()
HP = HPrediction()
HP_E = HPSkillshot("E", "Rengar", {collisionM = true, collisionH = true, delay = 0, range = 1100, speed = 1800, type = "DelayLine", width = 90})

config = scriptConfig("My Rengar", "Rengar")
config:addParam("Pred", "Prediction Type", SCRIPT_PARAM_LIST, 2, {"VPrediction", "HPrediction"})
PredictionType = config.Pred
config:addSubMenu("Combo Setup", "ComboSettings")
config:addSubMenu("Keys", "Keys")
config:addSubMenu("Drawing Settings", "Drawing")
config.ComboSettings:addSubMenu("Empowered Control", "empCont")
config:addSubMenu("Harass", "harass")
config:addSubMenu("Farming", "Farming")

Farming = config.Farming
Drawing = config.Drawing

Farming:addParam("LaneClear", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
Farming:addParam("LastHit", "Lasthit key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
Farming:addParam("UseQ", "Use Q to farm/lasthit", SCRIPT_PARAM_ONOFF, true)
Farming:addParam("UseW", "Use W to farm/lasthit", SCRIPT_PARAM_ONOFF, true)
Farming:addParam("UseE", "Use E to farm/lasthit", SCRIPT_PARAM_ONOFF, true)
Farming:addParam("info", "Wont use empowered abilities to farm", SCRIPT_PARAM_INFO, "")

config.harass:addParam("UseW", "Use W to harass", SCRIPT_PARAM_ONOFF, true)
config.harass:addParam("UseE", "Use E to harass", SCRIPT_PARAM_ONOFF, true)
config.harass:addParam("EmpE", "Use Empowered E to harass", SCRIPT_PARAM_ONOFF, false)

config.ComboSettings:addParam("info", "type 1 = Q combo, type 2 = E combo", SCRIPT_PARAM_INFO, "")
--config.ComboSettings:addParam("comboTypeShow", "Combo Type:", SCRIPT_PARAM_INFO, "".. combotype)
config.ComboSettings.empCont:addParam("AutoHeal", "Auto Heal at health %", SCRIPT_PARAM_SLICE, 25,0,100,0)

config.Keys:addParam("ComboKey", "Combo Key:", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
config.Keys:addParam("Harass", "Harass Key:", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
config.Keys:addParam("infoo", "Z toggle emp farm", SCRIPT_PARAM_INFO, "")
config.Keys:addParam("infooo", "Arrow keys(left right) set combo type", SCRIPT_PARAM_INFO, "")

config.Drawing:addParam("draw", "Do drawing", SCRIPT_PARAM_ONOFF, true)
config.Drawing:addParam("drawType", "Draw combo and prediction type", SCRIPT_PARAM_ONOFF, true)
config.Drawing:addParam("drawSpells", "Draw Spell Ranges", SCRIPT_PARAM_ONOFF, true)
Drawing:addParam("drawW", "Draw W", SCRIPT_PARAM_ONOFF , true)
Drawing:addParam("drawE", "Draw E", SCRIPT_PARAM_ONOFF , true)
Drawing:addParam("drawAA", "Draw AA range", SCRIPT_PARAM_ONOFF , true)

if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then ign = SUMMONER_1
elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then ign = SUMMONER_2
else ign = nil end

LoadOrbwalker()

print("My Rengar(v:"..version..") is:<font> <font color = \"#FF0000\">Loaded! </font>")
end

function OnDraw()
fight = config.Keys.ComboKey
ComboType = combotype
PredictionType = config.Pred
	if config.Drawing.draw then
		if Drawing.drawAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, range, 0xffffff)
		end
		if ValidTarget(target) then
		DrawCircle(target.x, target.y, target.z, 200, 0xff0000)
		if ComboWillKill(target) then
		local startLeft = WorldToScreen(D3DXVECTOR3(target.x, target.y, target.z))
		DrawText("Combo Will kill", 18, startLeft.x, startLeft.y, 0xFF0000FF)
		else
		local startLeft = WorldToScreen(D3DXVECTOR3(target.x, target.y, target.z))
		DrawText("Combo probably wont kill", 18, startLeft.x, startLeft.y, 0xFF000000)
		end
		end
		if config.Drawing.drawType then
			if ComboType == 1 then
				local startLeft = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
        DrawText("Combo Type = Kill Combo(Q)", 18, startLeft.x, (startLeft.y), 0xFFFFFFFF)
			elseif ComboType == 2 then
				local startLeft = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
        DrawText("Combo Type = Snare Combo(E)", 18, startLeft.x, (startLeft.y), 0xFFFFFFFF)
			end
			if PredictionType == 1 then
				local startLeft = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
        DrawText("VPrediction", 18, startLeft.x, (startLeft.y - 20), 0xFFFFFFFF)
			elseif PredictionType == 2 then
				local startLeft = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
        DrawText("HPrediction", 18, startLeft.x, (startLeft.y - 20), 0xFFFFFFFF)
			end
			if empFarming then
				local startLeft = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
        DrawText("EMPOWERED FARMING ENABLED", 18, startLeft.x, (startLeft.y - 40), 0xFACC2E0F)
			end
		end
		if config.Drawing.drawSpells then
			if CanCast(_W) and Drawing.drawW then
			DrawCircle(myHero.x, myHero.y, myHero.z, 500, 0xffffff)
			end
			if CanCast(_E) and Drawing.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0xffffff)
			end
		end
	end
end

function OnTick()
	Farming = config.Farming
	ComboSettings = config.ComboSettings
	ComboType = config.ComboSettings.comboType
	empCont = config.ComboSettings.empCont
	HealHealth = config.ComboSettings.empCont.AutoHeal
  harass = config.Keys.Harass
	Harass()
	AutoHeal()
  ts:update()
  target = ReturnTarget()
	fury = myHero.mana
	range = myHero.range + GetDistance(myHero.maxBBox)
	AutoHeal() -- More heals!
	HighFuryCombo()
	LowFuryCombo()
	Ignite()
	GetItemSlot()
	UseItems()
	LaneClear()
	LastHit()
end
local count = 0
function LoadOrbwalker()
   if _G.Reborn_Initialised then
      print("My Rengar:<font> <font color = \"#FF0000\">SAC loaded and authed! </font>")
      isSac = true
      loaded = true
      config:addSubMenu("Rengar: Orbwalker", "Orbwalker")
      config.Orbwalker:addParam("info", "SAC:R detected", SCRIPT_PARAM_INFO, "")
   elseif _G.Reborn_Loaded and not _G.Reborn_Initialised and count < 30 then
      if printedWaiting == false then
      print("My Rengar:<font> <font color = \"#FF0000\">Waiting SAC auth. </font>")      printedWaiting = true
      end
      DelayAction(LoadOrbwalker, 1)
      count = count + 1
   else
      if count >= 30 then
      print("My Rengar:<font> <font color = \"#FF0000\">SAC AUTH FAILED! </font>")
      end
      require 'SxOrbWalk'
      print("SxOrbWalk: Loading...")
      config:addSubMenu("My Rengar: Orbwalker", "Orbwalker")
      SxOrb:LoadToMenu(config.Orbwalker)
      isSx = true
			print("SxOrbWalk: Loaded")
      loaded = true
   end
end

function CanCast(spell)
return myHero:CanUseSpell(spell) == READY
end

function HighFuryCombo()
if fight then
	if combotype == 1  and fight then --=================COMBOTYPE 1
		if myHero.y > 120 then
			if ValidTarget(target) then
				if fury == 5 then
					if CanCast(_Q) then
						CastSpell(_Q)
					end
				elseif fury == 4 then
					if CanCast(_W) then
						if CanCast(_Q) and GetDistance(target) < 500 then
							CastSpell(_W)
							CastSpell(_Q)
						end
					elseif CanCast(_Q) then
						CastSpell(_Q)
					end
				end
			end
		else
			if ValidTarget(target) then
				if fury == 5 then
					if CanCast(_Q) and GetDistance(target) < range then
						CastSpell(_Q)
						myHero:Attack(target)
					end
				elseif fury == 4 then
					if CanCast(_Q) then
						if CanCast(_W) then
							if GetDistance(target) < range then
								CastSpell(_W)
								CastSpell(_Q)
								myHero:Attack(target)
							end
						end
					end
				end
			end
		end
	elseif combotype == 2  and fight then --=================COMBOTYPE 2
		if myHero.y > 120 then
			if ValidTarget(target) then
				if fury == 5 then
					if CanCast(_E) then
						if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= eRange then
								CastSpell(_E, CastPosition.x,CastPosition.z)
								combotype = 1
							end
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
								ComboType = 1
							end
						end
					end
				elseif fury == 4 then
					if CanCast(_W) then
						if CanCast(_E) and GetDistance(target) < 500 then
							CastSpell(_W)
							if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= eRange then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
						end
						end
					elseif CanCast(_E) then
						if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= eRange then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
						end
					end
				end
			end
		else
			if ValidTarget(target) then
				if fury == 5 then
					if CanCast(_E) and GetDistance(target) < eRange then
						if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= eRange then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
						end
					end
				elseif fury == 4 then
					if CanCast(_E) then
							if GetDistance(target) < eRange then
								if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= eRange then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
							DelayAction(function() local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= eRange then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end end, .1)
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
							DelayAction(function() local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end end, .1)
						end
						end
					end
				end
			end
		end
	end
end
end

function LowFuryCombo()
if config.Keys.ComboKey then
	if ValidTarget(target) and config.Keys.ComboKey then
		if fury < 5 then
			if myHero.y > 120 then
				if CanCast(_Q) and fury ~= 5 then
					CastSpell(_Q)
				end
				if CanCast(_W) and GetDistance(target) < 500 and fury ~= 5then
					CastSpell(_W)
				end
				if CanCast(_E) and fury ~= 5 then
					if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= eRange then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
						end
				end
			else
				if CanCast(_Q) and GetDistance(target) < range and fury ~= 5 then
					CastSpell(_Q)
					myHero:Attack(target)
				end
				if CanCast(_W) and GetDistance(target) < 500 and fury ~= 5 then
					CastSpell(_W)
				end
				if CanCast(_E) and ValidTarget(target, eRange) and fury ~= 5 then
					if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= eRange then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
						end
				end
			end
		end
	end
end
end

empFarming = false

function OnWndMsg(Msg, Key)
	if Msg == KEY_DOWN and Key == GetKey("%") then
		if combotype == 2 then combotype = 1 end
	elseif Msg == KEY_DOWN and Key == GetKey("'") then
		if combotype == 1 then combotype = 2 end
	elseif Msg == KEY_DOWN and Key == GetKey("Z") then
		if empFarming == false then empFarming = true else empFarming = false end
	elseif Msg == KEY_DOWN and Key == GetKey("(16)") then
		if combotype == 1 then combotype = 2 else combotype = 1 end
	end
	if Msg == WM_LBUTTONDOWN then
		closest = ReturnClosestTo(mousePos)
		if GetDistance(mousePos, closest) < 125 and ValidTarget(closest) then
			clickTarget = ReturnClosestTo(mousePos)
		end
	end
end

function AutoHeal()
	if myHero.health < myHero.maxHealth / 100 * config.ComboSettings.empCont.AutoHeal and CanCast(_W) and fury == 5 then
		CastSpell(_W)
	end
	if myHero.health <= myHero.maxHealth / 100 * 10 and fury == 5 and CanCast(_W) then
		CastSpell(_W)
	end
end

function Ignite()
	if ign ~= nil and CanCast(ign) then
		local igniteDamage = 50 + 20 * myHero.level
		for i = 1, heroManager.iCount, 1 do
			local target = heroManager:getHero(i)
			if ValidTarget(target, 600) and target.team ~= myHero.team then
				if igniteDamage > (target.health - (20)) then --Just to give it some redundancy vs pots
					CastSpell(ign, target)
				end
			end
		end
	end
end

local Hydra
local Ghostblade
local BORK

function GetItemSlot()
        for slot = ITEM_1, ITEM_7 do
                local currentItemName = myHero:GetSpellData(slot).name
                if currentItemName == "ItemTiamatCleave" then
                Hydra = slot
                elseif currentItemName  == "YoumusBlade" then
                Ghostblade = slot
                elseif currentItemName == "ItemSwordOfFeastAndFamine" then
                BORK = slot
                elseif currentItemName == "BilgewaterCutlass" then
                BORK = slot
                end
        end
end

function UseItems()
	if ValidTarget(target, 400) and Hydra and CanCast(Hydra) and fight then
		if SxOrb then
			if SxOrb:CanMove() then
				CastSpell(Hydra)
			end
		elseif isSac then
			if not _G.AutoCarry.Orbwalker:IsShooting() then
				CastSpell(Hydra)
			end
		end
	end
	if ValidTarget(target, 600) and BORK and CanCast(BORK) and fight then
		if SxOrb and SxOrb:CanMove() then
			CastSpell(BORK, target)
		end
		if isSac and not _G.AutoCarry.Orbwalker:IsShooting() then
			CastSpell(BORK, target)
		end
	end
	if fight and ValidTarget(target) and Ghostblade and CanCast(Ghostblade) and GetDistance(target) < (1250) then
		CastSpell(Ghostblade)
	end
end


function Harass()
  if harass and ValidTarget(target) then
		if config.harass.UseW and fury ~= 5 and CanCast(_W) and GetDistance(target) < 500 then
			CastSpell(_W)
		end
		if fury < 5 then
			if CanCast(_E) and GetDistance(target) < 1100 and config.harass.UseE then
				if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= 1100 then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
						end
			end
		else if config.harass.UseE and CanCast(_E) and GetDistance(target) < 1100 and config.harass.EmpE then
			if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(target) <= 1100 then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, target, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
						end
			end
		end
	end
end

function LaneClear()
local lowestMinion = nil
for i, v in ipairs(minionManager(MINION_ENEMY,range,player, MINION_SORT_HEALTH_ASC).objects) do
        if lowestMinion == nil then
                lowestMinion = v
        elseif v.health < lowestMinion.health then
                lowestMinion = v
        end
end
for i, v in ipairs(minionManager(MINION_JUNGLE,1000,player,MINION_SORT_HEALTH_ASC).objects) do
        if lowestMinion == nil then
                lowestMinion = v
        elseif v.health < lowestMinion.health then
                lowestMinion = v
        end
end

if ValidTarget(lowestMinion) and Farming.LaneClear then
if fury < 5 then
	qDmg = myHero:GetSpellData(_Q).level * 30 + (myHero.totalDamage / 100 * (myHero:	GetSpellData(_Q).level * 5))
	wDmg = myHero:GetSpellData(_W).level * 24  + 50 + myHero.ap / 100 * 80
	eDmg = myHero:GetSpellData(_E).level * 50 + myHero.totalDamage / 100 * 70
else
	qDmg = (myHero:GetSpellData(_Q).level * 42) + 30 + (myHero.totalDamage / 100 * 50)
	wDmg = myHero:GetSpellData(_W).level * 50 + myHero.ap / 100 * 80 --about right
	eDmg = myHero:GetSpellData(_E).level * 58 + 50 + myHero.totalDamage / 100 * 70
end
if CanCast(_Q) and Farming.UseQ and GetDistance(lowestMinion) < range and lowestMinion.health < qDmg or lowestMinion.health > qDmg + 25 and Farming.LaneClear then
if isSac then
	if not _G.AutoCarry.Orbwalker:IsShooting() and _G.AutoCarry.Orbwalker:CanMove() then
		if fury == 5 then
			if empFarming then
				CastSpell(_Q)
				myHero:Attack(lowestMinion)
			end
		else
			CastSpell(_Q)
			myHero:Attack(lowestMinion)
		end
	end
elseif isSx then
	if SxOrb:CanMove() then
		if fury == 5 then
			if empFarming then
				CastSpell(_Q)
				myHero:Attack(lowestMinion)
			end
		else
			CastSpell(_Q)
			myHero:Attack(lowestMinion)
		end
	end
end
end
if CanCast(_W) and Farming.UseW and GetDistance(lowestMinion) < 500 and lowestMinion.health < wDmg or lowestMinion.health > wDmg + 25 then
if fury == 5 then
	if empFarming then
		CastSpell(_W)
	end
else
	CastSpell(_W)
end
end
if isQ and ValidTarget(lowestMinion, range) then
	if isSac then
		if not _G.AutoCarry.Orbwalker:IsShooting() then
			myHero:Attack(lowestMinion)
		end
	elseif isSx then
		if SxOrb:CanMove() then
			myHero:Attack(lowestMinion)
		end
	end
end
if CanCast(_E) and Farming.UseE and GetDistance(lowestMinion) < 1100 and lowestMinion.health < eDmg or lowestMinion.health > eDmg + 25 and fury < 5 then
if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(lowestMinion, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(lowestMinion) <= eRange and fury < 5 then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
						elseif PredictionType == 2 and fury < 5 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, lowestMinion, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
						end
end
end
end

function LastHit()
local lowestMinion = nil
for i, v in ipairs(minionManager(MINION_ENEMY,range,player, MINION_SORT_HEALTH_ASC).objects) do
        if lowestMinion == nil then
                lowestMinion = v
        elseif v.health < lowestMinion.health then
                lowestMinion = v
        end
end
for i, v in ipairs(minionManager(MINION_JUNGLE,1000,player,MINION_SORT_HEALTH_ASC).objects) do
        if lowestMinion == nil then
                lowestMinion = v
        elseif v.health < lowestMinion.health then
                lowestMinion = v
        end
end

if ValidTarget(lowestMinion) and Farming.LastHit then
if fury < 5 then
	qDmg = myHero.totalDamage + myHero:GetSpellData(_Q).level * 30 + (myHero.totalDamage / 100 * (myHero:	GetSpellData(_Q).level * 5))
	wDmg = myHero:GetSpellData(_W).level * 24  + 50 + myHero.ap / 100 * 80
	eDmg = myHero:GetSpellData(_E).level * 50 + myHero.totalDamage / 100 * 70
else
	qDmg = (myHero:GetSpellData(_Q).level * 42) + 30 + (myHero.totalDamage / 100 * 50)
	wDmg = myHero:GetSpellData(_W).level * 50 + myHero.ap / 100 * 80 --about right
	eDmg = myHero:GetSpellData(_E).level * 58 + 50 + myHero.totalDamage / 100 * 70
end
if CanCast(_Q) and Farming.UseQ and GetDistance(lowestMinion) < range and lowestMinion.health < qDmg and Farming.LastHit then
if isSac then
	if not _G.AutoCarry.Orbwalker:IsShooting() and _G.AutoCarry.Orbwalker:CanMove() then
		if fury == 5 then
		if empFarming then
		CastSpell(_Q)
		myHero:Attack(lowestMinion)
		end
		else
		CastSpell(_Q)
		myHero:Attack(lowestMinion)
		end
	end
elseif isSx then
	if SxOrb:CanMove() then
		if fury == 5 then
		if empFarming then
		CastSpell(_Q)
		myHero:Attack(lowestMinion)
		end
		else
		CastSpell(_Q)
		myHero:Attack(lowestMinion)
		end
	end
end
end
if isQ and ValidTarget(lowestMinion, range) then
	if isSac then
		if not _G.AutoCarry.Orbwalker:IsShooting() then
			myHero:Attack(lowestMinion)
		end
	elseif isSx then
		if SxOrb:CanMove() then
			myHero:Attack(lowestMinion)
		end
	end
end
if CanCast(_W) and Farming.UseW and GetDistance(lowestMinion) < 500 and lowestMinion.health < wDmg then
if fury == 5 then
if empFarming then
CastSpell(_W)
end
else
CastSpell(_W)
end
end
if CanCast(_E) and Farming.UseE and GetDistance(lowestMinion) < 1100 and lowestMinion.health < eDmg and fury < 5 then
if PredictionType == 1 then
							local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(lowestMinion, 0, 80, eRange, 1100, myHero, true)
							if HitChance >= 2 and GetDistance(lowestMinion) <= eRange then
								CastSpell(_E, CastPosition.x,CastPosition.z)
							end
						elseif PredictionType == 2 then
							local QCastPos, QHitChance = HP:GetPredict(HP_E, lowestMinion, myHero) -- is actually E
							if QHitChance >= 2 then
								CastSpell(_E, QCastPos.x, QCastPos.z)
							end
						end
end
end
end

function ReturnTarget()
	if ValidTarget(clickTarget) and GetDistance(clickTarget) < 2000 then
		idealTarget = clickTarget
	elseif ValidTarget(ts.target) then
		idealTarget = ts.target
	end
	return idealTarget
end

function ReturnClosestTo(Position)
	ClosestTarget = nil
	for i = 1, heroManager.iCount, 1 do
		local targeta = heroManager:getHero(i)
		if targeta.team ~= myHero.team and ValidTarget(targeta) then
			if ClosestTarget == nil then ClosestTarget = targeta
			elseif GetDistance(targeta, mousePos) < GetDistance(ClosestTarget, mousePos) then ClosestTarget = targeta
			end
		end
	end
	return ClosestTarget
end

function OnRemoveBuff(unit, buff, stacks)
if unit == myHero and buf == "rengarqemp" or "rengarqbase" then
isQ = false
end
end

function OnProcessSpell(unit, spell)
if unit == myHero and spell.name == "RengarQ" then
isQ = true
end
end

function ComboWillKill(unit)
	local furycount = nil
		qDmg = myHero.totalDamage + myHero:GetSpellData(_Q).level * 30 + (myHero.totalDamage / 100 * (myHero:GetSpellData(_Q).level * 5))
		wDmg = myHero:GetSpellData(_W).level * 24  + 50 + myHero.ap / 100 * 80
		eDmg = myHero:GetSpellData(_E).level * 50 + myHero.totalDamage / 100 * 70
		EmpQDmg = (myHero:GetSpellData(_Q).level * 42) + 30 + ((myHero.totalDamage / 100) * 150)
		EmpWDmg = myHero:GetSpellData(_W).level * 50 + myHero.ap / 100 * 80 --about right
		EmpEDmg = myHero:GetSpellData(_E).level * 58 + 50 + myHero.totalDamage / 100 * 70
	local usedQ = false
	local usedW = false
	local usedE = false
	local HealthAfter = unit.health
	if combotype == 1 then
		if fury == 5 then
			if CanCast(_Q) and CanCast(_W) and CanCast(_E) then
				HealthAfter = HealthAfter - (EmpQDmg + (qDmg / 100 * 110) + wDmg + eDmg)
			end
		elseif fury < 5 and fury > 1 then
			furycount = fury
			if CanCast(_Q) then
				furycount = furycount + 1
				HealthAfter = HealthAfter - qDmg
			end
			if CanCast(_W) then
				furycount = furycount + 1
				HealthAfter = HealthAfter - wDmg
			end
			if CanCast(_E) then
				furycount = furycount + 1
				HealthAfter = HealthAfter - eDmg
			end
			if furycount >= 5 then
				HealthAfter = HealthAfter - EmpQDmg
			end
		else
			if CanCast(_Q) then
				HealthAfter = HealthAfter - qDmg
			end
			if CanCast(_E) then
				HealthAfter = HealthAfter - eDmg
			end
			if CanCast(_W) then
				HealthAfter = HealthAfter - wDmg
			end
			if HealthAfter < 0 then return true else return false end
		end
	elseif combotype == 2 then
		if fury == 5 then
			if CanCast(_Q) and CanCast(_W) and CanCast(_E) then
				HealthAfter = HealthAfter - (EmpEDmg + qDmg + wDmg + eDmg)
				if HealthAfter <= 0 then return true end
			end
		elseif fury < 5 and fury > 1 then
			furycount = fury
			if CanCast(_Q) then
				furycount = furycount + 1
				HealthAfter = HealthAfter - qDmg
			end
			if CanCast(_W) then
				furycount = furycount + 1
				HealthAfter = HealthAfter - wDmg
			end
			if CanCast(_E) then
				furycount = furycount + 1
				HealthAfter = HealthAfter - eDmg
			end
			if furycount >= 5 then
				HealthAfter = HealthAfter - EmpEDmg
			end
		else
			if CanCast(_Q) then
				HealthAfter = HealthAfter - qDmg
			end
			if CanCast(_E) then
				HealthAfter = HealthAfter - eDmg
			end
			if CanCast(_W) then
				HealthAfter = HealthAfter - wDmg
			end
			if HealthAfter < 0 then return true else return false end
		end
	end
end








