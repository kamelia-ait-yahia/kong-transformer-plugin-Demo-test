local typedefs = require "kong.db.schema.typedefs"

return {
    name = "soap-request-transformer",
    fields = {
        {
            consumer = typedefs.no_consumer
        },
        {
            config = {
                type = "record",
                fields = {
                    {
                        method = {
                            type = "string",
                            required = false,
                        },
                    },
                    {
                        namespace = {
                            type = "string",
                            required = false,
                        },
                    },
                    {
                        remove_attr_tags = {
                            type = "boolean",
                            required = false,
                        },
                    },
                    {
                        soap_version = {
                            type = "string",
                            default = "1.1",
                            one_of = {
                                "1.1",
                                "1.2"
                            },
                        },
                    },
                    {
                        soap_prefix = {
                            type = "string",
                            default = "soap",
                        },
                    },
                    {
                        service_name = {
                            type = "string",
                            required = true,
                        },
                    },
                    -- {
                    --     xmlns_ser = {
                    --         type = "string",
                    --         required = false,
                    --     },
                    -- },
                    -- {
                    --     xmlns_xsd = {
                    --         type = "string",
                    --         required = false,
                    --     },
                    -- },
                },
            },
        },
    }
}
