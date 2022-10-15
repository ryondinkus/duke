local json = include("json")

function DukeHelpers.FindByProperties(t, props)
    local found
    for _, value in pairs(t) do
        local notEquals = false
        for propKey, propValue in pairs(props) do
            if value[propKey] ~= propValue then
                notEquals = true
                break
            end
        end

        if not notEquals then
            found = value
            break
        end
    end

    return found
end

function DukeHelpers.CountByProperties(t, props)
    local found = 0
    for _, value in pairs(t) do
        local notEquals = false
        for propKey, propValue in pairs(props) do
            if value[propKey] ~= propValue then
                notEquals = true
                break
            end
        end

        if not notEquals then
            found = found + 1
        end
    end

    return found
end

function DukeHelpers.ForEach(t, func)
    for k, v in pairs(t) do
        func(v, k)
    end
end

function DukeHelpers.Map(t, func)
    local mapped = {}
    for k, v in pairs(t) do
        mapped[k] = func(v, k)
    end

    return mapped
end

function DukeHelpers.Filter(t, func)
    local filtered = {}
    local isArray = DukeHelpers.IsArray(t)
    for k, v in pairs(t) do
        if func(v, k) then
            if isArray then
                table.insert(filtered, v)
            else
                filtered[k] = v
            end
        end
    end

    return filtered
end

function DukeHelpers.Find(t, func)
    for k, v in pairs(t) do
        if func(v, k) then
            return v
        end
    end
end

function DukeHelpers.LengthOfTable(t)
    local num = 0
    for _ in pairs(t) do
        num = num + 1
    end
    return num
end

function DukeHelpers.IsArray(t)
    if t == nil or type(t) ~= "table" then
        return false
    end
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

function DukeHelpers.IntegerToBinary(n)
    local binNum = ""
    if n ~= 0 then
        while n >= 1 do
            if n % 2 == 0 then
                binNum = binNum .. "0"
                n = n / 2
            else
                binNum = binNum .. "1"
                n = (n - 1) / 2
            end
        end
    else
        binNum = "0"
    end
    return binNum
end

function DukeHelpers.PercentageChance(percent, max, rng)
    local value
    if percent > (max or 100) then
        value = max or 100
    else
        value = percent
    end

    if not rng then
        rng = DukeHelpers.rng
    end

    return rng:RandomInt(99) + 1 <= value
end

function DukeHelpers.GetWeightedIndex(t, weightTag, filters, rng)
    if not rng then
        rng = DukeHelpers.rng
    end

    local elements = DukeHelpers.Filter(t,
        function(element) return element[weightTag] and (not filters or filters(element)) end)

    if DukeHelpers.LengthOfTable(t) > 0 then
        local csum = 0
        local outcome = elements[1]
        for _, element in pairs(elements) do
            local weight = element[weightTag]
            local r = rng:RandomInt(csum + weight)

            if r >= csum then
                outcome = element
            end
            csum = csum + weight
        end
        return outcome
    end
end

function DukeHelpers.PrintJson(obj)
    print(json.encode(obj))
end

function DukeHelpers.DebugJson(obj)
    Isaac.DebugString(json.encode(obj))
end

function DukeHelpers.Sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

function DukeHelpers.ConvertBitSet64ToBitSet128(x)
    return x >= 64 and BitSet128(0, 1 << (x - 64)) or BitSet128(1 << x, 0)
end

function DukeHelpers.Stagger(tag, player, interval, occurences, callback, onEnd, noAutoDecrement)
    local data = DukeHelpers.GetDukeData(player)
    if data[tag] and (type(data[tag]) ~= "number" or data[tag] > 0) then
        local timerTag = tag .. "Timer"
        local counterTag = tag .. "Counter"
        if not data[timerTag] then data[timerTag] = 0 end
        if not data[counterTag] then data[counterTag] = occurences end

        data[timerTag] = data[timerTag] - 1
        if data[timerTag] <= 0 then
            local previousResult

            for _ = 1, data[tag] or 1 do
                previousResult = callback(counterTag, previousResult)
            end

            data[timerTag] = interval
            if not noAutoDecrement then
                data[counterTag] = data[counterTag] - 1
            end
            if data[counterTag] <= 0 then
                DukeHelpers.StopStagger(player, tag)
                if onEnd then
                    onEnd()
                end
            end
        end
    end
end

function DukeHelpers.StopStagger(player, tag)
    local data = DukeHelpers.GetDukeData(player)

    data[tag] = nil
    data[tag .. "Timer"] = nil
    data[tag .. "Counter"] = nil
end

function DukeHelpers.CountOccurencesInTable(table, value)
    local found = 0
    for _, v in pairs(table) do
        if v == value then
            found = found + 1
        end
    end
    return found
end

function DukeHelpers.OffsetIdentifier(heart)
    local identifier = heart.subType

    if heart.variant and heart.variant ~= PickupVariant.PICKUP_HEART then
        identifier = heart.variant
    end

    return DukeHelpers.SUBTYPE_OFFSET + identifier
end

function DukeHelpers.Clamp(num, min, max)
    local output = num

    if min then
        output = math.max(min, output)
    end

    if max then
        output = math.min(max, output)
    end

    return output
end

function DukeHelpers.PrintIfSomething(value, target)
    if target then
        if value == target then
            print(value)
        end
    else
        if value ~= nil and value ~= 0 and value ~= "" then
            print(value)
        end
    end
end

function DukeHelpers.CombineArrays(first, second)
    local combined = {}
    for i = 1, #first do
        combined[i] = first[i]
    end
    for i = 1, #second do
        combined[#combined + 1] = second[i]
    end
    return combined
end
