---------------------------------------------------------------------
-- LuaSoap implementation for Lua.
--
-- See Copyright Notice in license.html
---------------------------------------------------------------------

local assert, pairs, tonumber, tostring, type = assert, pairs, tonumber, tostring, type
local table = require "table"
local tconcat, tinsert, tremove = table.concat, table.insert, table.remove
local string = require "string"
local gsub, strformat = string.gsub, string.format
local lom = require "lxp.lom"
local parse = lom.parse

local tescape = {
    ['&'] = '&amp;',
    ['<'] = '&lt;',
    ['>'] = '&gt;',
    ['"'] = '&quot;',
    ["'"] = '&apos;',
}

---------------------------------------------------------------------
-- Escape special characters.
---------------------------------------------------------------------
local function escape(text)
    return (gsub(text, "([&<>'\"])", tescape))
end

local tunescape = {
    ['&amp;'] = '&',
    ['&lt;'] = '<',
    ['&gt;'] = '>',
    ['&quot;'] = '"',
    ['&apos;'] = "'",
}

---------------------------------------------------------------------
-- Unescape special characters.
---------------------------------------------------------------------
local function unescape(text)
    return (gsub(text, "(&%a+;)", tunescape))
end

local serialize

---------------------------------------------------------------------
-- Serialize the table of attributes.
-- @param a Table with the attributes of an element.
-- @return String representation of the object.
---------------------------------------------------------------------
local function attrs(a)
    if not a then
        return "" -- no attributes
    else
        local c = {}
        for i, v in pairs(a) do
            c[#c + 1] = strformat('%s="%s"', i, escape(tostring(v)))
        end
        if #c > 0 then
            return " " .. tconcat(c, " ")
        else
            return ""
        end
    end
end

---------------------------------------------------------------------
-- Serialize the children of an object.
-- @param obj Table with the object to be serialized.
-- @return String representation of the children.
---------------------------------------------------------------------
local function contents(obj)
    if not obj[1] then
        return ""
    else
        local c = {}
        for i = 1, #obj do
            c[i] = serialize(obj[i])
        end
        return tconcat(c)
    end
end

---------------------------------------------------------------------
-- Serialize an object.
-- @param obj Table with the object to be serialized.
-- @return String with representation of the object.
---------------------------------------------------------------------
serialize = function(obj)
    local tt = type(obj)
    if tt == "string" then
        return escape(unescape(obj))
    elseif tt == "number" then
        return tostring(obj)
    elseif tt == "table" then
        local t = obj.tag
        assert(t, "Invalid table format (no `tag' field)")
        local attr = attrs(obj.attr)
        local content = contents(obj)
        if content == "" then
            return strformat("<%s%s />", t, attr) -- Balise auto-fermante
        else
            return strformat("<%s%s>%s</%s>", t, attr, content, t)
        end
    else
        return ""
    end
end

---------------------------------------------------------------------
-- Add header element (if it exists) to object.
-- Cleans old header element anyway.
---------------------------------------------------------------------
local header_template = {
    tag = "soapenv:Header",
}

local function insert_header(obj, header)
    -- Supprime l'ancien header s'il existe
    for i = #obj, 1, -1 do
        if obj[i].tag == "soapenv:Header" then
            table.remove(obj, i)
        end
    end

    -- Insère le nouveau header si celui-ci n'est pas vide
    if header and next(header) ~= nil then
        local header_template = {
            tag = "soapenv:Header",
            header,
        }
        table.insert(obj, 1, header_template)
    else
        -- Insère simplement la balise fermante si le header est vide
        table.insert(obj, 1, {
            tag = "soapenv:Header",
        })
    end
end



local xmlns_soap = "http://schemas.xmlsoap.org/soap/envelope/"
local xmlns_ser = "http://serviceobject.service.callisto.newsys.altares.fr"
local xmlns_xsd = "http://request.callisto.newsys.altares.fr/xsd"

---------------------------------------------------------------------
-- Converts a LuaExpat table into a SOAP message.
-- @param args Table with the arguments, which could be:
-- namespace: String with the namespace of the elements.
-- method: String with the method's name;
-- entries: Table of SOAP elements (LuaExpat's format);
-- header: Table describing the header of the SOAP envelope (optional);
-- internal_namespace: String with the optional namespace used
--    as a prefix for the method name (default = "");
-- soap_version: Number of SOAP version (default = 1.1);
-- @return String with SOAP envelope element.
---------------------------------------------------------------------
local function encode(args)
    local soap_prefix = "soapenv"

    -- Build SOAP envelope with correct elements
    local envelope_template = {
        tag = soap_prefix .. ":Envelope",
        attr = {
            ["xmlns:" .. soap_prefix] = xmlns_soap,
            ["xmlns:ser"] = xmlns_ser,
            ["xmlns:xsd"] = xmlns_xsd,
        },
        {
            tag = soap_prefix .. ":Header",
            
        },
        {
            tag = soap_prefix .. ":Body",
            {
                tag = "ser:getIdentiteAltaN4Etablissement",
                {
                    tag = "ser:request",
                    {
                        tag = "xsd:identification",
                        args.entries["identification"],
                    },
                    {
                        tag = "xsd:refClient",
                        args.entries["refClient"],
                    },
                    {
                        tag = "xsd:sirenSiret",
                        args.entries["sirenSiret"],
                    },
                },
            },
        },
    }

    -- Insert header if defined in args
    insert_header(envelope_template, args.header)

    return serialize(envelope_template)
end

---------------------------------------------------------------------
-- Iterates over the children of an object.
-- It will ignore any text, so if you want all of the elements, use ipairs(obj).
-- @param obj Table (LOM format) representing the XML object.
-- @param tag String with the matching tag of the children
--    or nil to match only structured children (single strings are skipped).
-- @return Function to iterate over the children of the object
--    which returns each matching child.
---------------------------------------------------------------------
local function list_children(obj, tag)
    local i = 0
    return function()
        i = i + 1
        local v = obj[i]
        while v do
            if type(v) == "table" and (not tag or v.tag == tag) then
                return v
            end
            i = i + 1
            v = obj[i]
        end
        return nil
    end
end

---------------------------------------------------------------------
-- Converts a SOAP message into Lua objects.
-- @param doc String with SOAP document.
-- @return String with namespace, String with method's name and
--    Table with SOAP elements (LuaExpat's format).
---------------------------------------------------------------------
local function decode(doc)
    local obj = assert(parse(doc))
    assert(obj.tag, "Not a SOAP document")
    local ns = assert(obj.tag:match("^(.-):Envelope"), "Not a SOAP Envelope: " .. obj.tag)
    local lc = list_children(obj)
    local o = lc()
    local headers = {}
    -- Store SOAP:Headers separately
    while o and (o.tag == ns .. ":Header" or o.tag == "SOAP-ENV:Header") do
        headers[#headers + 1] = list_children(o)()
        o = lc()
    end
    if o and (o.tag == ns .. ":Body" or o.tag == "SOAP-ENV:Body") then
        obj = list_children(o)()
    else
        error("Couldn't find SOAP Body!")
    end

    local namespace = find_xmlns(obj.attr)
    local method = obj.tag:match("%:([^:]*)$") or obj.tag
    local entries = {}
    for i = 1, #obj do
        entries[i] = obj[i]
    end
    return namespace, method, entries, headers
end

------------------------------------------------------------------------------
-- @export
return {
    _COPYRIGHT = "Copyright (C) 2004-2020 Kepler Project",
    _DESCRIPTION = "LuaSOAP provides a very simple API that converts Lua tables to and from XML documents",
    _VERSION = "LuaSOAP 4.0.2",

    decode = decode,
    encode = encode,
    escape = escape,
    unescape = unescape,
    serialize = serialize,
    attrs = attrs,
}