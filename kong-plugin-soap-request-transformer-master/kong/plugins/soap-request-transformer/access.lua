local cjson = require("cjson")
local soap = require("kong.plugins.soap-request-transformer.soap")
local kong = kong
local pcall = pcall
local JSON = "application/json"
local insert = table.insert
local _M = {}

local function parse_json(body)
    if body then
        local status, res = pcall(cjson.decode, body)
        if status then
            return res
        end
    end
end


-- local function parse_entries(e, parent)
--     if type(e) == "table" then
--         for k, v in pairs(e) do
--             -- local el = { ['tag'] = k }
--             insert(parent, v)
--             parse_entries(v, el)
--         end
--     else
--         insert(parent, e)
--     end
-- end

local function parse_entries(e, parent)
    if type(e) == "table" then
        for k, v in pairs(e) do
            if type(v) == "table" then
                parent[k] = {}
                parse_entries(v, parent[k])
            else
                parent[k] = v
            end
        end
    else
        -- In case e is not a table, handle it accordingly (if needed)
        -- This could be an edge case based on your JSON structure
        -- insert(parent, e)  -- Uncomment if it is necessary to handle non-table values
    end
end


local function transform_json_body_into_soap(conf, body)
    local parameters = parse_json(body)
    if parameters == nil then
        return false, nil
    end

    local body = parameters.body[conf.method]
    local encode_args = {}
    local root = {}
    parse_entries(body, root)
    encode_args.namespace = conf.namespace
    encode_args.entries = root
    encode_args.soap_prefix = conf.soap_prefix
    encode_args.soap_version = conf.soap_version
    -- encode_args.xmlns_ser = conf.xmlns_ser
    -- encode_args.xmlns_xsd = conf.xmlns_xsd
    if conf.service_name == "soap_service" then
        local soap_doc = soap.encode(encode_args)
        kong.log.debug("Transformed request: " .. soap_doc)
        return true, soap_doc
    else
        local soap_doc = soap.encode(encode_args)  
        kong.log.debug("Transformed request: " .. soap_doc)
        return true, soap_doc  
    end
end

function _M.transform_body(conf, body, content_type)
    local is_body_transformed = false

    if content_type == JSON then
        is_body_transformed, body = transform_json_body_into_soap(conf, body)
    end

    return is_body_transformed, body
end

return _M
