-- import gitlinker plugin
local setup, gl = pcall(require, "gitlinker")
if not setup then
    return
end

-- configure/enable gitsigns
gl.setup()
