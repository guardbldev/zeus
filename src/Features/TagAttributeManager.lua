-- Features/TagAttributeManager.lua
local OutputStream = require(script.Parent.Parent.OutputStream)
local CollectionService = game:GetService("CollectionService")

local TAG_SCHEMA = require(script.Parent.Parent.RuleConfig).attributeSchema

local TagAttrMgr = {}
TagAttrMgr.command = "attr.set"
TagAttrMgr.flags = {
    ["tag"] = true, -- Add tag
    ["untag"] = true, -- Remove tag
}
TagAttrMgr.description = "Bulk set tags or attribute values. Example: attr.set Health=100 --tag=Enemy"

function TagAttrMgr.run(ast, frame, context)
    local attrKey, attrValue
    for k,v in pairs(ast.flags) do
        if k~="tag" and k~="untag" then
            attrKey, attrValue = k, v
            break
        end
    end
    if not attrKey then
        OutputStream.Append(frame, "Usage: attr.set Health=100 --tag=Enemy", Color3.fromRGB(255,110,80))
        return
    end
    local expectedType = TAG_SCHEMA[attrKey]
    if expectedType then
        if expectedType=="number" then
            attrValue = tonumber(attrValue)
        elseif expectedType=="boolean" then
            attrValue = (attrValue == "true" or attrValue=="1")
        end
        if attrValue == nil then
            OutputStream.Append(frame, "Schema: "..attrKey.." expects "..expectedType, Color3.fromRGB(240,130,88))
            return
        end
    end
    local tagged = {}
    if ast.flags.tag then
        tagged = CollectionService:GetTagged(ast.flags.tag)
    else
        tagged = context.Selection or {}
    end
    local count = 0
    for _,obj in ipairs(tagged) do
        pcall(function()
            obj:SetAttribute(attrKey, attrValue)
            count = count+1
        end)
    end
    OutputStream.Append(frame, ("Attribute %s set to %s on %d object(s)."):format(attrKey,tostring(attrValue),count), Color3.fromRGB(110,255,180))
end

return TagAttrMgr