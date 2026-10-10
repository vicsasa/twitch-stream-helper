obs = obslua

local exe_path = "D:\\bouyomi\\BouyomiChan.exe"

local function dirname(path)
    return path:match("^(.*)\\[^\\]-$") or "."
end

local function is_running(exe_name)
    local handle = io.popen('tasklist /FI "IMAGENAME eq ' .. exe_name .. '" /NH')
    if not handle then return false end
    local result = handle:read("*a")
    handle:close()
    return result:find(exe_name, 1, true) ~= nil
end

local function launch_bouyomi()
    if exe_path == "" then
        return
    end
    local exe_name = exe_path:match("([^\\]+)$")
    if is_running(exe_name) then
        obs.script_log(obs.LOG_INFO, exe_name .. " is already running, skipping launch")
        return
    end
    local dir = dirname(exe_path)
    local cmd = string.format('start "" /D "%s" "%s"', dir, exe_path)
    os.execute(cmd)
    obs.script_log(obs.LOG_INFO, "launched: " .. exe_path)
end

function script_description()
    return "OBS起動時に棒読みちゃんが起動していなければ自動で起動します。\n" ..
           "下の「棒読みちゃんのexeパス」を自分の環境に合わせて設定してください。"
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_path(props, "exe_path", "棒読みちゃんのexeパス",
        obs.OBS_PATH_FILE, "Executable (*.exe)", exe_path)
    local btn = obs.obs_properties_add_button(props, "launch_now", "今すぐ起動",
        function() launch_bouyomi() return true end)
    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "exe_path", exe_path)
end

function script_update(settings)
    exe_path = obs.obs_data_get_string(settings, "exe_path")
end

function script_load(settings)
    launch_bouyomi()
end
