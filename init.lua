local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')
Plug 'tpope/vim-sensible'
Plug 'huggingface/llm-ls'
Plug 'huggingface/llm.nvim'
vim.call('plug#end')

local llm = require('llm')

llm.setup({
  api_token = nil, -- cf Install paragraph
  -- model = "bigcode/starcoder", -- can be a model ID or an http(s) endpoint
  model = "http://codellama-34b-hf-tgi-ls.srv.aisuite.navercorp.com",
  --model_eos = "<|endoftext|>", -- needed to clean the model's output
  model_eos = "<EOT>", -- needed to clean the model's output
  -- parameters that are added to the request body
  query_params = {
	  return_full_text = false,
	  repetition_penalty = 1.1,
    max_new_tokens = 512,
    temperature = 0.2,
    top_p = 0.95,
    stop_tokens = nil,
  },
  -- set this if the model supports fill in the middle
  fim = {
    enabled = true,
    prefix = "<PRE> ",
    middle = " <MID>",
    suffix = " <SUF>",
  },
  debounce_ms = 150,
  accept_keymap = "<Tab>",
  dismiss_keymap = "<S-Tab>",
  max_context_after = 5000,
  max_context_before = 5000,
  tls_skip_verify_insecure = false,
  -- llm-ls integration
  lsp = {
    enabled = true,
    bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/llm_nvim/bin/llm-ls",
  },
  tokenizer_path = nil, -- when setting model as a URL, set this var
  --tokenizer_path = "/Users/jihoonc/Downloads/tokenizer/tokenizer.model",
  context_window = 4096, -- max number of tokens for the context window
})
