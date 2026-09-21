require "nvchad.options"

-- Flash the cursor, matching the terminal's cursor blink. Nvim only requests
-- "blinking on" (DECSCUSR); Ghostty owns the blink rate, so it uses the same
-- frequency as every other blinking cursor in the terminal. Styles are
-- unchanged: Normal/Visual/Command stay a block, Insert a bar, Replace an
-- underline, Terminal a block. Ghostty still draws the hollow box when the
-- window is unfocused.
vim.opt.guicursor = "n-v-c-sm:block-blinkon500-blinkoff500,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
