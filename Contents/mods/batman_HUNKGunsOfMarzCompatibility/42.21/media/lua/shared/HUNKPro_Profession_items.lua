-- batman_HUNKGunsOfMarzCompatibility
-- Replaces H.U.N.K Profession 1.8 (3678932953) media/lua/shared/HUNKPro_Profession_items.lua.
-- Guns of Marz swaps vanilla guns, magazines, ammo and attachments through their OnCreate,
-- one tick after they reach a container, for random Guns of Marz models: the HUNK rifle and
-- pistol lost their attachments and loaded magazines, and random extra magazines and boxes
-- were dumped in the inventory. When that replacement is enabled, the kit is now built with
-- Guns of Marz items directly. Otherwise the original kit is unchanged.

local professionDictionary = {
    hunk = {
        inventory = {
            "Base.HuntingKnife",
            "Base.HuntingKnife",
            "Base.Canteen",
            "Base.KeyRing"
        },

        equip = {
            "Base.Umbrella_Corp_Jacket_Winter",
            "Base.Umbrella_Corp_Vest",
            "Base.Umbrella_Corp_Thermals",
            "Base.Umbrella_Corp_Pants",
            "Base.Umbrella_Corp_LegHolster_Right",
            "Base.Umbrella_Corp_Helmet",
            "Base.Umbrella_Corp_Gloves",
            "Base.Umbrella_Corp_GasMask",
            "Base.Umbrella_Corp_Boots",
            "Base.Umbrella_Corp_Balaclava",
            "Base.Umbrella_Corp_ElbowPads",
            "Base.WristWatch_Left_DigitalBlack",
            "Base.Belt2",
            "Base.Socks_Ankle_Black",
            "Base.Underpants_RedSpots"
        }
    },

    lady_hunk = {
        inventory = {
            "Base.HuntingKnife",
            "Base.HuntingKnife",
            "Base.Canteen",
            "Base.KeyRing"
        },

        equip = {
            "Base.Umbrella_Corp_Jacket_Winter",
            "Base.Umbrella_Corp_Vest",
            "Base.Umbrella_Corp_Shorts",
            "Base.Umbrella_Corp_LegHolster_Right",
            "Base.Umbrella_Corp_Helmet",
            "Base.Umbrella_Corp_Gloves",
            "Base.Umbrella_Corp_GasMask",
            "Base.Umbrella_Corp_Boots",
            "Base.Umbrella_Corp_Balaclava",
            "Base.Umbrella_Corp_ElbowPads",
            "Base.WristWatch_Left_DigitalBlack",
            "Base.Belt2",
            "Base.Shirt_CropTopNoArmTINT",
            "Base.Bra_Straps_Black",
            "Base.Socks_Ankle_Black",
            "Base.Underpants_Black"
        }
    }

};

local IFAK = {
    "Base.BathTowel",
    "Base.Pills",
    "Base.SutureNeedleHolder",
    "Base.Whiskey",
    "Base.PillsAntiDep",
    "Base.PillsBeta",
    "Base.PillsVitamins",
    "Base.Lighter",
    "Base.SutureNeedle",
    "Base.AlcoholBandage",
    "Base.AlcoholBandage",
    "Base.AlcoholBandage",
};

-- Guns of Marz equivalents of the vanilla kit (same models as its VanillaReplacerTable).
-- Rails come before the part that needs them (AttachmentsRequiredParts.lua).
local GOM_WEAPONS = {
    rifle = {
        type = "MarzGuns.M16A2",
        parts = {
            "MarzGuns.Picatinny_Rail_Up",
            "MarzGuns.EXPS3_Sight",
            "MarzGuns.Picatinny_Rail_Right",
            "MarzGuns.LRX-7_Laser",
        },
        magazine = "MarzGuns.556x45Magazine30_STANAG",
        ammoBox = "MarzGuns.556x45_Box",
    },
    pistol = {
        type = "MarzGuns.M92FS",
        parts = {
            "MarzGuns.Beretta_Mount",
            "MarzGuns.PS1_Sight",
            "MarzGuns.PX1_Laser",
        },
        magazine = "MarzGuns.9x19Magazine15_M92FS",
        ammoBox = "MarzGuns.9x19_Box",
    },
    revolver = {
        type = "MarzGuns.PYTHON",
        parts = {
            "MarzGuns.Heavy_Pistol_Rail",
            "MarzGuns.PS1_Sight",
        },
        rounds = "SWMG.357_Bullet",
        ammoBox = "MarzGuns.357_Box",
    },
}

local function useGunsOfMarzKit()
    local vars = SandboxVars and SandboxVars.MarzGuns
    if not vars or not vars.VanillaWeaponReplacement then return false end
    return getScriptManager():FindItem(GOM_WEAPONS.rifle.type) ~= nil
        and getScriptManager():FindItem(GOM_WEAPONS.pistol.type) ~= nil
        and getScriptManager():FindItem(GOM_WEAPONS.revolver.type) ~= nil
end

-- Guns of Marz keeps one entry per round in ModData.AmmoList (Gunworks CustomSystemHooks.lua).
local function addLoadedMagazine(container, magazineType)
    local magazine = container:AddItem(magazineType)
    if not magazine then return nil end

    local count = magazine:getMaxAmmo()
    local round = magazine:getAmmoType():getItemKey()
    local ammoList = {}
    for i = 1, count do
        ammoList[i] = round
    end
    magazine:setCurrentAmmoCount(count)
    magazine:getModData().AmmoList = ammoList
    return magazine
end

-- MarzGuns_OnCreate.AttachParts rolls random optional parts and may insert a partly loaded
-- magazine. Keep only the required parts, empty the gun, then fit the HUNK parts.
local function createGunsOfMarzWeapon(def)
    local weapon = instanceItem(def.type)
    if not weapon then return nil end

    local pointsTable = require("MarzWeapons/OnCreate/AttachmentPointsTable")
    local entry = pointsTable and pointsTable.weaponAttachmentTablesAndChances[def.type]
    local required = {}
    for _, partType in ipairs(entry and entry.required or {}) do
        required[partType] = true
    end

    local installed = weapon:getAllWeaponParts()
    local toDetach = {}
    for i = 0, installed:size() - 1 do
        local part = installed:get(i)
        if not required[part:getFullType()] then
            toDetach[#toDetach + 1] = part
        end
    end
    for _, part in ipairs(toDetach) do
        weapon:detachWeaponPart(part)
    end

    local modData = weapon:getModData()
    modData.GW_BayonetDeployed = nil

    if def.magazine then
        local magazine = instanceItem(def.magazine)
        weapon:setContainsClip(false)
        weapon:setRoundChambered(false)
        weapon:setCurrentAmmoCount(0)
        weapon:setMagazineType(def.magazine)
        if magazine then
            weapon:setMaxAmmo(magazine:getMaxAmmo())
        end
        modData.MagazineType = nil
        modData.AmmoList = nil
    end

    for _, partType in ipairs(def.parts) do
        local part = instanceItem(partType)
        if part then
            weapon:attachWeaponPart(part)
        end
    end

    return weapon
end

local function giveGunsOfMarzWeapons(player, inventory, pouches, bagToEquip)
    local rifle = GOM_WEAPONS.rifle
    inventory:AddItem(createGunsOfMarzWeapon(rifle))
    addLoadedMagazine(inventory, rifle.magazine)
    for x=1,7 do
        addLoadedMagazine(pouches:getItemContainer(), rifle.magazine)
        bagToEquip:getItemContainer():AddItem(rifle.ammoBox)
    end

    if player:isFemale() then
        -- The Python comes loaded: AttachParts fills weapons that take no magazine.
        local revolver = GOM_WEAPONS.revolver
        inventory:AddItem(createGunsOfMarzWeapon(revolver))
        for x=1,21 do
            inventory:AddItem(revolver.rounds)
        end
        for x=1,7 do
            bagToEquip:getItemContainer():AddItem(revolver.ammoBox)
        end
    else
        local pistol = GOM_WEAPONS.pistol
        inventory:AddItem(createGunsOfMarzWeapon(pistol))
        addLoadedMagazine(inventory, pistol.magazine)
        for x=1,7 do
            addLoadedMagazine(pouches:getItemContainer(), pistol.magazine)
            bagToEquip:getItemContainer():AddItem(pistol.ammoBox)
        end
    end
end

local function giveVanillaWeapons(player, inventory, pouches, bagToEquip)
    local rifleToEquip = inventory:AddItem("Base.AssaultRifle");
    inventory:AddItem("Base.556Clip"):setCurrentAmmoCount(30);
    rifleToEquip:attachWeaponPart(instanceItem("Base.RedDot"));
    rifleToEquip:attachWeaponPart(instanceItem("Base.RecoilPad"));
    rifleToEquip:attachWeaponPart(instanceItem("Base.Laser"));
    for x=1,7 do
        pouches:getItemContainer():AddItem("Base.556Clip"):setCurrentAmmoCount(30);
        bagToEquip:getItemContainer():AddItem("Base.556Box");
    end

    if player:isFemale() then
        local pistolToEquip = inventory:AddItem("Base.Revolver");
        pistolToEquip:attachWeaponPart(instanceItem("Base.RedDot"));
        for x=1,21 do
            inventory:AddItem("Base.Bullets357")
        end
        for x=1,7 do
            bagToEquip:getItemContainer():AddItem("Base.Bullets357Box");
        end
    else
        local pistolToEquip = inventory:AddItem("Base.Pistol");
        pistolToEquip:attachWeaponPart(instanceItem("Base.RedDot"));
        pistolToEquip:attachWeaponPart(instanceItem("Base.Laser"));
        inventory:AddItem("Base.9mmClip"):setCurrentAmmoCount(15);
        for x=1,7 do
            pouches:getItemContainer():AddItem("Base.9mmClip"):setCurrentAmmoCount(15);
            bagToEquip:getItemContainer():AddItem("Base.Bullets9mmBox");
        end
    end
end


local function GearPlayer(_player)

    local activate_loadouts = SandboxVars.extraProfessions.Loadouts;
    local player = _player;
    local prof = player:getDescriptor():getCharacterProfession():getName();
    local playername = player:getFullName();
    local isLady = player:isFemale()


    print("------------- SANDBOX SETTINGS FOR GEAR: ", activate_loadouts);
    print("------------- PROFESSIONS CHOOSEN: ", prof);

    local function setupGear(prof)

        if not professionDictionary[prof] then
            print("Not Hunk: ", prof)
            return
        else
            if isLady then
                prof = "lady_hunk"
            end
        end

        player:getInventory():clear();
        player:clearWornItems();
        local inventory = player:getInventory();
        local professionCategories = {"inventory","equip"};

        for i,v in ipairs(professionCategories) do
            for index, value in ipairs(professionDictionary[prof][v]) do

                if v == "inventory" then
                    inventory:AddItem(value);
                end

                if v == "equip" then
                    local itemToEquip = inventory:AddItem(value);
                    player:setWornItem(itemToEquip:getBodyLocation(), itemToEquip);
                end
            end
        end

        -- PROFESSION HUNK
        if prof == "hunk" or prof == "lady_hunk" then

            local utilPouch = inventory:AddItem("Base.Umbrella_Corp_LegPouch_Left");
            local pouches = inventory:AddItem("Base.Umbrella_Corp_HipPouches");
            local bagToEquip = inventory:AddItem("Base.Umbrella_Corp_HydrationPack");

            inventory:AddItem("Base.Necklace_DogTag"):setName("Dog Tags: " .. playername);

            for i,item in ipairs(IFAK) do
                utilPouch:getItemContainer():AddItem(item);
            end
            bagToEquip:getItemContainer():AddItem("Base.CrowbarForged");
            for x=1,2 do
                pouches:getItemContainer():AddItem("Base.Molotov");
                pouches:getItemContainer():AddItem("Base.SmokeBomb");
            end

            if useGunsOfMarzKit() then
                giveGunsOfMarzWeapons(player, inventory, pouches, bagToEquip)
            else
                giveVanillaWeapons(player, inventory, pouches, bagToEquip)
            end
            player:setClothingItem_Back(bagToEquip);


        end

    end



    if activate_loadouts then
        setupGear(prof);
    end

end

if not isClient() then
    Events.OnNewGame.Add(GearPlayer);
end
