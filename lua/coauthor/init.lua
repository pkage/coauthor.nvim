-- coauthor lua entrypoint

local config = require('coauthor.config')
local request = require('coauthor.request')

-- export table
local coauthor = {}

-- config for packer
coauthor.setup = function(user_configs)
  config.set(user_configs or {})
end

-- make a writing request
coauthor.make_request = request.make_request

-- health check
coauthor.check_alive = request.check_alive
coauthor.prompt = request.prompt

return coauthor
