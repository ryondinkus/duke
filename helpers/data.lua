local json = include("json")

function DukeHelpers.SaveData(data)
    dukeMod:SaveData(json.encode(data))
end

function DukeHelpers.LoadData()
    if dukeMod:HasData() then
        return json.decode(dukeMod:LoadData())
    end
end

function DukeHelpers.SaveKey(key, value)
    local savedData = DukeHelpers.LoadData() or {}
    DukeHelpers.SetNestedValue(savedData, key, value)
    DukeHelpers.SaveData(savedData)
end

function DukeHelpers.LoadKey(key)
    local savedData = DukeHelpers.LoadData()

    if savedData then
        return savedData[key]
    end
end

function DukeHelpers.FlattenEntityData(data)
    if data ~= nil then
        if type(data) == "userdata" then
            if data.InitSeed then
                return { _type = "userdata", initSeed = tostring(data.InitSeed) }
            end
        elseif type(data) == "table" then
            local output = {}
            for key, item in pairs(data) do
                output[key] = DukeHelpers.FlattenEntityData(item)
            end
            return output
        else
            return data
        end
    end
end

function DukeHelpers.RehydrateEntityData(data)
    if data ~= nil and type(data) == "table" then
        if DukeHelpers.IsArray(data) or data._type ~= "userdata" then
            local output = {}
            for key, item in pairs(data) do
                output[key] = DukeHelpers.RehydrateEntityData(item)
            end
            return output
        else
            return DukeHelpers.GetEntityByInitSeed(data.initSeed)
        end
    else
        return data
    end
end

function DukeHelpers.SaveGame()
    local data = {
        seed = Game():GetSeeds():GetPlayerInitSeed(),
        players = {},
        familiars = {},
        global = dukeMod.global,
        mcmOptions = dukeMod.mcmOptions or {},
        unlocks = dukeMod.unlocks or {}
    }

    DukeHelpers.ForEachDuke(function(duke)
        data.players[tostring(duke.InitSeed)] = DukeHelpers.GetDukeData(duke)
    end)

    DukeHelpers.ForEachEntityInRoom(function(familiar)
        data.familiars[tostring(familiar.InitSeed)] = familiar:GetData()
    end, EntityType.ENTITY_FAMILIAR)

    DukeHelpers.SaveData(DukeHelpers.FlattenEntityData(data))
end