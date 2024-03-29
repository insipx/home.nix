return {
  tools = {
    inlay_hints = {only_current_line = true, show_variable_name = true},
    hover_actions = {auto_focus = true},
    crate_graph = {backend = "cgimage"}
  },
  server = {
    -- on_attach = function(client) require("lsp-format").on_attach(client) end,
    settings = {
      ["rust_analyzer"] = {
        procMacro = {enable = false},
        diagnostics = {disabled = {"unresolved-proc-macro"}},
        checkOnSave = {command = "clippy"},
        cargo = { features = {"all"} },
        check = { features = {"all"} },
        check = { command = "clippy" }
      }
    }
  }
}
