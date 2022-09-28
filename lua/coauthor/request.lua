-- the core of the plugin
-- makes a request to the server with some specified prompt

local curl = require('plenary.curl')
local config = require("coauthor.config")

local M = {}

-- local function visual_selection_range()
--     local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
--     local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))

--     if csrow < cerow or (csrow == cerow and cscol <= cecol) then
--         return csrow - 1, cscol - 1, cerow - 1, cecol
--     else
--         return cerow - 1, cecol - 1, csrow - 1, cscol
--     end
-- end


-- local function get_range()
--     srow, scol, erow, ecol = visual_selection_range()

--     -- this is dumb but here we are
--     -- if the end col is 2^31 - 1, then subtract one
--     -- and it will become a valid range
--     line = vim.api.nvim_buf_get_lines(0, erow, erow+1, false)
--     if ecol >= #line or (scol == 0 and ecol == 0) then 
--         ecol = #line - 1
--     end


    
--     text = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})

--     text = table.concat(text,'\n')
    
--     return text, { srow, scol, erow, ecol }
-- end


local function make_request(prompt, callback)
    -- prepare body
    body = {
        max_length = config.get('max_length'),
        prompt = prompt
    }

    print('baking... '..prompt)

    -- make request
    resp = curl.post({
        url = config.get('server_uri')..'/api/v0/generate',
        body = vim.json.encode(body),
        callback = function(resp) 
            out = vim.json.decode(resp.body)

            vim.schedule( function() callback(out['result']) end)
        end
    })
end

M.prompt = function()
    -- line only right now
    text = vim.api.nvim_get_current_line()
    linenr = vim.api.nvim_win_get_cursor(0)[1]

    -- save the buffer number
    buf_num = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_set_lines(0, linenr-1, linenr, false, { 'loading...' })

    callback = function(cont)
        print(cont)


        t = {}
        if string.find(cont, '\n') ~= nil then
            for str in string.gmatch(cont, "\n") do
                table.insert(t, str)
            end
        else
            t = { cont }
        end

        vim.api.nvim_buf_set_lines(0, linenr-1, linenr, false, { '' })
        vim.api.nvim_win_set_cursor(0, {linenr, 0})
        vim.api.nvim_paste(cont, true, -1)
        -- print(unpack(range))
    end

    make_request(text, callback)
end

M.check_alive = function()
    print('Running health check...')
    resp = curl.get({
        url = config.get('server_uri')..'/api/v0/alive',

        callback = function(resp)
            out = vim.json.decode(resp.body)

            if out['ok'] then
                print('Coauthor server is healthy!')
            else
                print('Coauthor server is reachable, but not healthy!')
            end
        end
    })

end


return M
