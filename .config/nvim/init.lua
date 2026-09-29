vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_commit = "306a05526ada86a7b30af95c5cc81ffba93fef97"
if not vim.uv.fs_stat(lazypath) then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--no-checkout",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("lazy.nvim bootstrap failed:\n" .. result)
  end
  result = vim.fn.system({ "git", "-C", lazypath, "checkout", lazy_commit })
  if vim.v.shell_error ~= 0 then
    error("lazy.nvim pinned checkout failed:\n" .. result)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      pcall(telescope.load_extension, "fzf")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      for _, server in ipairs({ "clangd", "pyright", "ruff", "ts_ls", "eslint" }) do
        vim.lsp.config(server, { capabilities = capabilities })
      end
      local jdtls_root = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "settings.gradle", "settings.gradle.kts", ".git" })
        or vim.fn.getcwd()
      local jdtls_data = vim.fn.stdpath("state") .. "/jdtls/" .. vim.fn.sha256(jdtls_root):sub(1, 16)
      vim.fn.mkdir(jdtls_data, "p")
      vim.lsp.config("jdtls", {
        capabilities = capabilities,
        cmd = { "jdtls", "-data", jdtls_data },
      })
      vim.lsp.enable({ "clangd", "pyright", "ruff", "ts_ls", "eslint", "jdtls" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, action, description)
            vim.keymap.set("n", keys, action, { buffer = event.buf, desc = description })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", vim.lsp.buf.references, "References")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>e", vim.diagnostic.open_float, "Diagnostics")
        end,
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" } }, {
          { name = "buffer" }, { name = "path" },
        }),
      })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dap_python = require("dap-python")
      dapui.setup({})
      local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      if vim.fn.executable(debugpy_python) == 1 then
        dap_python.setup(debugpy_python)
        for _, configuration in ipairs(dap.configurations.python or {}) do
          configuration.pythonPath = function()
            local project_python = vim.fn.getcwd() .. "/.venv/bin/python"
            if vim.fn.executable(project_python) == 1 then
              return project_python
            end
            return vim.fn.exepath("python")
          end
        end
      end
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
      dap.adapters.lldb = {
        type = "executable",
        command = "/usr/bin/lldb-dap",
        name = "lldb",
      }
      dap.configurations.cpp = {
        {
          name = "Launch executable",
          type = "lldb",
          request = "launch",
          program = function() return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file") end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.c = dap.configurations.cpp
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug step over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug step into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug step out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    end,
  },
}, {
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
  change_detection = { notify = false },
  install = { colorscheme = { "habamax" } },
})

vim.cmd.colorscheme("habamax")
