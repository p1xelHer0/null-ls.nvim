local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
    name = "chktex",
    method = DIAGNOSTICS,
    filetypes = { "tex" },
    generator_opts = {
        command = "chktex",
        to_stdin = true,
        args = {
            -- Disable printing version information to stderr
            "-q",
            -- Format output
            "-f%l:%c:%d:%k:%m\n",
        },
        format = "line",
        check_exit_code = function(code)
            return code <= 1
        end,
        on_output = h.diagnostics.from_pattern(
            [[(%d+):(%d+):(%d+):(%w+):(.+)]], --
            { "row", "col", "_length", "severity", "message" },
            {
                adapters = {
                    h.diagnostics.adapters.end_col.from_length,
                },
                severities = {
                    Error = h.diagnostics.severities["error"],
                    Warning = h.diagnostics.severities["warning"],
                },
            }
        ),
    },
    factory = h.generator_factory,
})
