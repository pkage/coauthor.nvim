" Title:        Coauthor
" Description:  A plugin to provide AI support while writing
" Last Change:  27 September 2022
" Maintainer:   Patrick Kage <patrick.r.kage@gmail.com>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_coauthor")
    finish
endif
let g:loaded_coauthor = 1

command! -nargs=0 CoauthorHealth lua require('coauthor').check_alive()
command! -nargs=0 CoauthorWrite lua require('coauthor').prompt()

nnoremap <leader>cw :CoauthorWrite<cr>

