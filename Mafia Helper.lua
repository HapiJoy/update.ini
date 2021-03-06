script_name('Imgui_Script')
script_author('SLAVIK')
script_description('Imgui')

require "lib.moonloader"
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local vkey = require 'vkeys'
local imgui = require 'imgui'
local fa = require 'fAwesome5'
local encoding = require 'encoding'
local sampev = require 'lib.samp.events'
local notify = import 'lib_imgui_notf.lua'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local imadd = require 'imgui_addons'

local directIni = "moonloader\\settings.ini"

local mainIni = inicfg.load(ini, directIni)
local stateIni = inicfg.save(mainIni, directIni)

local tag = "[My First Script]"
local lavel = 0
local main_color = 0x4169E1
local main_color_text = "{4169E1}"
local white_color = "{FFFFFF}"
local arr_str = {}
local image
size1 = false
imgui = require "imgui"
weapons = {"   ", 2, 3, 4, "Deagle", 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34 , 41, 42, 43, 46}

--combo_select = imgui.ImInt(0)
--combo_list = {u8"??", u8"??"}

show_main_window = imgui.ImBool(false)

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
    end
end

function imgui.NewInputText(lable, val, width, hint, hintpos)
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    local result = imgui.InputText(lable, val)
    if #val.v == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end

function imgui.AnimatedButton(label, size, speed, rounded)
    local size = size or imgui.ImVec2(0, 0)
    local bool = false
    local text = label:gsub('##.+$', '')
    local ts = imgui.CalcTextSize(text)
    speed = speed and speed or 0.4
    if not AnimatedButtons then AnimatedButtons = {} end
    if not AnimatedButtons[label] then
        local color = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
        AnimatedButtons[label] = {circles = {}, hovered = false, state = false, time = os.clock(), color = imgui.ImVec4(color.x, color.y, color.z, 0.2)}
    end
    local button = AnimatedButtons[label]
    local dl = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local c = imgui.GetCursorPos()
    local CalcItemSize = function(size, width, height)
        local region = imgui.GetContentRegionMax()
        if (size.x == 0) then
            size.x = width
        elseif (size.x < 0) then
            size.x = math.max(4.0, region.x - c.x + size.x);
        end
        if (size.y == 0) then
            size.y = height;
        elseif (size.y < 0) then
            size.y = math.max(4.0, region.y - c.y + size.y);
        end
        return size
    end
    size = CalcItemSize(size, ts.x+imgui.GetStyle().FramePadding.x*2, ts.y+imgui.GetStyle().FramePadding.y*2)
    local ImSaturate = function(f) return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f) end
    if #button.circles > 0 then
        local PathInvertedRect = function(a, b, col)
            local rounding = rounded and imgui.GetStyle().FrameRounding or 0
            if rounding <= 0 or not rounded then return end
            local dl = imgui.GetWindowDrawList()
            dl:PathLineTo(a)
            dl:PathArcTo(imgui.ImVec2(a.x + rounding, a.y + rounding), rounding, -3.0, -1.5)
            dl:PathFillConvex(col)

            dl:PathLineTo(imgui.ImVec2(b.x, a.y))
            dl:PathArcTo(imgui.ImVec2(b.x - rounding, a.y + rounding), rounding, -1.5, -0.205)
            dl:PathFillConvex(col)

            dl:PathLineTo(imgui.ImVec2(b.x, b.y))
            dl:PathArcTo(imgui.ImVec2(b.x - rounding, b.y - rounding), rounding, 1.5, 0.205)
            dl:PathFillConvex(col)

            dl:PathLineTo(imgui.ImVec2(a.x, b.y))
            dl:PathArcTo(imgui.ImVec2(a.x + rounding, b.y - rounding), rounding, 3.0, 1.5)
            dl:PathFillConvex(col)
        end
        for i, circle in ipairs(button.circles) do
            local time = os.clock() - circle.time
            local t = ImSaturate(time / speed)
            local color = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
            local color = imgui.GetColorU32(imgui.ImVec4(color.x, color.y, color.z, (circle.reverse and (255-255*t) or (255*t))/255))
            local radius = math.max(size.x, size.y) * (circle.reverse and 1.5 or t)
            imgui.PushClipRect(p, imgui.ImVec2(p.x+size.x, p.y+size.y), true)
            dl:AddCircleFilled(circle.clickpos, radius, color, radius/2)
            PathInvertedRect(p, imgui.ImVec2(p.x+size.x, p.y+size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]))
            imgui.PopClipRect()
            if t == 1 then
                if not circle.reverse then
                    circle.reverse = true
                    circle.time = os.clock()
                else
                    table.remove(button.circles, i)
                end
            end
        end
    end
    local t = ImSaturate((os.clock()-button.time) / speed)
    button.color.w = button.color.w + (button.hovered and 0.8 or -0.8)*t
    button.color.w = button.color.w < 0.2 and 0.2 or (button.color.w > 1 and 1 or button.color.w)
    color = imgui.GetStyle().Colors[imgui.Col.Button]
    color = imgui.GetColorU32(imgui.ImVec4(color.x, color.y, color.z, 0.2))
    dl:AddRectFilled(p, imgui.ImVec2(p.x+size.x, p.y+size.y), color, rounded and imgui.GetStyle().FrameRounding or 0)
    dl:AddRect(p, imgui.ImVec2(p.x+size.x, p.y+size.y), imgui.GetColorU32(button.color), rounded and imgui.GetStyle().FrameRounding or 0)
    local align = imgui.GetStyle().ButtonTextAlign
    imgui.SetCursorPos(imgui.ImVec2(c.x+(size.x-ts.x)*align.x, c.y+(size.y-ts.y)*align.y))
    imgui.Text(text)
    imgui.SetCursorPos(c)
    if imgui.InvisibleButton(label, size) then
        bool = true
        table.insert(button.circles, {animate = true, reverse = false, time = os.clock(), clickpos = imgui.ImVec2(getCursorPos())})
    end
    button.hovered = imgui.IsItemHovered()
    if button.hovered ~= button.state then
        button.state = button.hovered
        button.time = os.clock()
    end
    return bool
end

local main_window_state = imgui.ImBool(false)
local text_buffer = imgui.ImBuffer(256)

local main_window_state = imgui.ImBool(false)
local text_buffer2 = imgui.ImBuffer(256)

local main_window_state = imgui.ImBool(false)
local text_buffer3 = imgui.ImBuffer(256)

local main_window_state = imgui.ImBool(false)
local text_buffer4 = imgui.ImBuffer(256)

local main_window_state = imgui.ImBool(false)
local text_buffer5 = imgui.ImBuffer(256)

local main_window_state = imgui.ImBool(false)
local text_buffer6 = imgui.ImBuffer(256)

local main_window_state = imgui.ImBool(false)
local text_buffer7 = imgui.ImBuffer(256)

local main_window_state = imgui.ImBool(false)
local text_buffer8 = imgui.ImBuffer(256)

local main_window_state = imgui.ImBool(false)
local text_buffer9 = imgui.ImBuffer(256)

local main_window_state = imgui.ImBool(false)
local text_buffer10 = imgui.ImBuffer(256)



-- For Chackbox
local checked_test = imgui.ImBool(false)
local checked_test_5 = imgui.ImBool(false)

--for Radio
local checked_radio = imgui.ImInt(1)

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

update_state = false

local script_vers = 3
local script_vers_text = "1.2"

local update_url = "https://raw.githubusercontent.com/HapiJoy/update.ini/main/update.ini" -- ??? ???? ???? ??????
local update_path = getWorkingDirectory() .. "/update.ini" -- ? ??? ???? ??????

local script_url = "https://github.com/HapiJoy/update.ini/blob/main/Mafia%20Helper.lua?raw=true" -- ??? ???? ??????
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    res = false

    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if myid then id = myid end

    _, health = sampGetPlayerHealth(myHEALTH)
    if myHEALTH then health = myHEALTH end

    img = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\images\\??????????.jpg")

    notify.addNotify("{fe4749}[Mafia helper]", "{d5dedd}????? ??????? ???? ??????? ?????? {fe4749}F5", 2, 4, 6)
    notify.addNotify("{fe4749}[Mafia helper]", "            {d5dedd}?????? ???????: {fe4749}v.Beta 1.2", 2, 4, 6)

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                notify.addNotify("???????????", "???? ??????????! ??????: " .. updateIni.info.vers_text, 2, 4, 6) --????? ?????? ? ????
                update_state = true
            end
            os.remove(update_path)
        end
    end)

    nick = sampGetPlayerNickname(id)
    lvl = sampGetPlayerScore(id)
    ping = sampGetPlayerPing(id)
    skinid = getCharModel(PLAYER_PED)
    health = getCharHealth(PLAYER_PED)
    armour = getCharArmour(PLAYER_PED)

    score = sampGetPlayerScore(id)

    sampRegisterChatCommand("adm", cmd_adm)

	imgui.Process = false
	while true do

        if res == false and os.date( "%M", os.time()) == "40" then
            if os.date( "%S", os.time()) == "00" then
                notify.addNotify("{FFFFFF}???????????", "               ????? 20 ????? {FF0000}PayDay!", 2, 4, 5)
                res = true
            elseif os.date( "%S", os.time()) == "01" then
                res = false
            end
        end
        
        if res == false and os.date( "%M", os.time()) == "45" then
            if os.date( "%S", os.time()) == "00" then
                notify.addNotify("{FFFFFF}???????????", "               ????? 15 ????? {FF0000}PayDay!", 2, 4, 5)
                res = true
            elseif os.date( "%S", os.time()) == "01" then
                res = false
            end
        end
        
        if res == false and os.date( "%M", os.time()) == "50" then
            if os.date( "%S", os.time()) == "00" then
                notify.addNotify("{FFFFFF}???????????", "               ????? 10 ????? {FF0000}PayDay!", 2, 4, 5)
                res = true
            elseif os.date( "%S", os.time()) == "01" then
                res = false
            end
        end
        
        if res == false and os.date( "%M", os.time()) == "55" then
            if os.date( "%S", os.time()) == "00" then
                notify.addNotify("{FFFFFF}???????????", "               ????? 5 ????? {FF0000}PayDay!", 2, 4, 5)
                res = true
            elseif os.date( "%S", os.time()) == "01" then
                res = false
            end
        end
        
        if res == false and os.date( "%M", os.time()) == "59" then
            if os.date( "%S", os.time()) == "00" then
                notify.addNotify("{FFFFFF}???????????", "               ????? 1 ?????? {FF0000}PayDay!", 2, 4, 5)
                res = true
            elseif os.date( "%S", os.time()) == "01" then
                res = false
            end
        end
        

        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    notify.addNotify("{fe4749}[Mafia helper]", "?????? ??????? ????????!", 2, 4, 6)
                    notify.addNotify("{fe4749}[Mafia helper]", "?????????? ?????? ??????? {fe4749}v.Beta 1.2", 2, 4, 6)
                    thisScript():reload()
                end
            end)
            break
        end

        wait(0)
        imgui.Process = main_window_state.v or main_window_state.v

        if wasKeyPressed(vkey.VK_F5) then
            main_window_state.v = not main_window_state.v
        end
	end

end

function chatSet(arg)
    sampSetChatInputEnabled(true)
    sampSetChatInputText(arg)
end

local f = io.open("file/path.ext", "r")
if f then -- ???? ???? ??????????
   local c = f:read("*all")
   -- ?????????? ? ?????-?????? ?????????? ??????????
end

function imgui.OnDrawFrame()
    
    if main_window_state then
        local sw, sh = getScreenResolution()
        local nick = sampGetPlayerNickname(myID)
        local _, myID = sampGetPlayerIdByCharHandle(PLAYER_PED)

        imgui.SetNextWindowSize(imgui.ImVec2(850,450), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin("Mafia helper (Beta 1.2)", main_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            imgui.BeginChild("BeginWindow12", imgui.ImVec2(250, 200), true)
                imgui.Text(fa.ICON_FA_USER.. u8' ?????????? ?? ??????')
                imgui.BeginChild("12345", imgui.ImVec2(-1, 155), true)
                    imgui.Text(fa.ICON_FA_ADDRESS_CARD.. u8' ???:')
                    imgui.SameLine()
                    imgui.TextColored(imgui.ImVec4(0.0, 80.0, 0.0, 100.0), sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
                    imgui.Text(fa.ICON_FA_BOOK.. u8' ???????:')
                    imgui.SameLine()
                    imgui.TextColored(imgui.ImVec4(0.0, 80.0, 0.0, 100.0), tostring(sampGetPlayerScore(myid)))
                    imgui.Text(fa.ICON_FA_COFFEE.. u8' ????:')
                    imgui.SameLine()
                    imgui.TextColored(imgui.ImVec4(0.0, 80.0, 0.0, 100.0), tostring(sampGetPlayerPing(myid)))
                    imgui.Text(fa.ICON_FA_HEARTBEAT.. u8' ?????:')
                    imgui.SameLine()
                    imgui.TextColored(imgui.ImVec4(0.0, 80.0, 0.0, 100.0 ), tostring(sampGetPlayerHealth(myid)))
                    imgui.Text(fa.ICON_FA_DEAF.. u8' ?????:')
                    imgui.SameLine()
                    imgui.TextColored(imgui.ImVec4(0.0, 80.0, 0.0, 100.0 ), tostring(sampGetPlayerArmor(myid)))
                imgui.EndChild()
            imgui.EndChild()

            imgui.BeginChild("BeginWindow", imgui.ImVec2(250, -1), true)
            
                if imgui.AnimatedButton(fa.ICON_FA_INFO.. u8' ??????????', imgui.ImVec2(220, 30)) then
                --if imgui.AnimatedButton(u8' ??????????', imgui.ImVec2(220, 30)) then
                    bool = true
                    bool2 = false
                    bool3 = false
                    bool4 = false
                end
                if imgui.AnimatedButton(fa.ICON_FA_QUESTION.. u8' ??????????', imgui.ImVec2(220, 30)) then
                --if imgui.AnimatedButton(u8' ??????????', imgui.ImVec2(220, 30)) then
                    bool = false
                    bool2 = true
                    bool3 = false
                    bool4 = false
                end
                if imgui.AnimatedButton(fa.ICON_FA_COGS.. u8' ??????', imgui.ImVec2(220, 30)) then
                --if imgui.AnimatedButton(u8' ??????', imgui.ImVec2(220, 30)) then    
                    bool = false
                    bool2 = false
                    bool3 = true
                    bool4 = false
                end
                if imgui.AnimatedButton(fa.ICON_FA_COG.. u8' ?????????', imgui.ImVec2(220, 30)) then
                --if imgui.AnimatedButton(u8' ?????????', imgui.ImVec2(220, 30)) then
                    bool = false
                    bool2 = false
                    bool3 = false
                    bool4 = true
                end
                --if imgui.AnimatedButton(u8'123') then
                    --window2 = true
                --end
            imgui.EndChild()
            
            imgui.SameLine()
                if bool then
                    imgui.SetCursorPos(imgui.ImVec2(270, 40))
                    imgui.BeginChild("BeginChild2", imgui.ImVec2(555, -1), true)
                        imgui.Text(u8'?????? ?????????? ?? ?????? ???? ????????????')
                        imgui.Text(u8'?????? ??????????? ?????????:')
                        imgui.Text(u8'??????????? ?????')
                        imgui.SameLine()
                        imgui.TextQuestion("( ? )", "https://vk.com/rodinarp1")
                        imgui.Text(u8'????????? ?????')
                        imgui.SameLine()
                        imgui.TextQuestion("( ? )", "https://vk.com/eastern_district")
                    imgui.EndChild()
                end
                if bool2 then
                    imgui.SetCursorPos(imgui.ImVec2(270, 40))
                    imgui.BeginChild("BeginChild2", imgui.ImVec2(555, -1), true)
                        --imgui.Image(img, imgui.ImVec2(220, 147))
                        --imgui.SetCursorPos(imgui.ImVec2(5, 5))
                        imgui.BeginChild("BeginChild12312312123", imgui.ImVec2(520, 35), true)
                            imgui.SetCursorPos(imgui.ImVec2(225, 10))
                            imgui.Text(u8'v.BETA 1.2')
                        imgui.EndChild()
                        imgui.Text(u8"- ??????????? ????? ??????????\n- ??????????? ????? ??????")
                        imgui.Text(u8"- ?????????? '??????? ?????'\n- ?????????? ????????? ??????")
                        imgui.BeginChild("BeginChild12312312", imgui.ImVec2(520, 35), true)
                            imgui.SetCursorPos(imgui.ImVec2(225, 10))
                            imgui.Text(u8'v.BETA 1.01')
                        imgui.EndChild()                        
                        imgui.Text(u8"- ????????? ?? ?????????\n- ????????? ??????? ?????")
                        imgui.Text(u8"- ????????? ??????????\n- ??????????? ????? ??????????")
                        --imgui.SetCursorPos(imgui.ImVec2(15, 130))
                        imgui.BeginChild("BeginChild120", imgui.ImVec2(520, 35), true)
                            imgui.SetCursorPos(imgui.ImVec2(225, 10))
                            imgui.Text(u8'v.ALPHA 30.6.22')
                        imgui.EndChild()                        
                        imgui.Text(u8"- ????????? ??????? - ??????????\n- ????????? ???????????")
                        imgui.Text(u8"- ????????? ??????????\n- ??????????? ????? ??????????\n- ??????????? ????? ???????")
                    imgui.EndChild()
                end
                if bool3 then
                    imgui.SetCursorPos(imgui.ImVec2(270, 40))
                    imgui.BeginChild("BeginChild3", imgui.ImVec2(555, -1), true)
                        imgui.SetCursorPos(imgui.ImVec2(0, 0))
                        imgui.BeginChild("BeginChild120", imgui.ImVec2(1000, 35), true)
                            imgui.SetCursorPos(imgui.ImVec2(240, 10))
                            imgui.Text(u8'????????')
                        imgui.EndChild()
                        if imgui.Button(fa.ICON_FA_GAVEL.. u8' ???? ??????', imgui.ImVec2(165, 80)) then
                            window2 = false
                            window3 = false
                            window4 = true
                        end
                        imgui.SameLine()
                        if imgui.Button(fa.ICON_FA_TH_LIST.. u8' ?????? ??????\n??????? ', imgui.ImVec2(165, 80)) then
                            window2 = false
                            window3 = true
                            window4 = false
                        end
                        imgui.SameLine()
                        if imgui.Button(fa.ICON_FA_TH_LIST.. u8'  ??????? ?????', imgui.ImVec2(165, 80)) then
                            window2 = true
                            window3 = false
                            window4 = false
                        end
                        imgui.SetCursorPos(imgui.ImVec2(0, 130))
                        imgui.BeginChild("BeginChild100", imgui.ImVec2(1000, 35), true)
                            imgui.SetCursorPos(imgui.ImVec2(235, 10))
                            imgui.Text(u8'?????????')
                            imgui.SameLine()
                            imgui.TextQuestion(u8"( ????? )", u8"????????? ????? ????. ?? ????????, /me, /do. ?????????? '???????? ???? /tie'")
                        imgui.EndChild()
                        if imgui.Button(u8'?????? ????? ?? ??????', imgui.ImVec2(256, 45)) then
                            lua_thread.create(function()
                                sampSendChat('/do ????? ?? ???????.')
                                wait(1500)
                                sampSendChat('/me ?????? ???????? ???? ?????? ????? ??-?? ??????')
                                wait(1500)
                                sampSendChat('/do ????? ? ?????.')
                                wait(1500)
                                sampSendChat('/me ??????? ????????? ???? ?????? ????? ???????? ?? ??????')
                           end) 
                        end
                        imgui.SameLine()
                        if imgui.Button(u8'????? ????? ? ??????', imgui.ImVec2(256, 45)) then
                            lua_thread.create(function()
                                sampSendChat('/do ????? ?? ?????? ? ???????? ?? ??????.')
                                wait(1500)
                                sampSendChat('/me ?????? ????????? ???? ???? ????? ? ?????? ?? ??????')
                                wait(1500)
                                sampSendChat('/do ????? ? ?????.')
                                wait(1500)
                                sampSendChat('/me ???????? ????? ? ???????')
                           end)
                        end
                        if imgui.Button(u8'???????? ????', imgui.ImVec2(256, 45)) then
                            window15 = true
                        end
                        imgui.SameLine()
                        if imgui.Button(u8'????????? ????', imgui.ImVec2(256, 45)) then
                            lua_thread.create(function()
                                sampSendChat('/me ?????? ???????? ???? ?????? ?????????? ??? ?? ???????')
                                wait(1500)
                                sampSendChat('/me ?????? ????????? ???? ??????? ??????? ?? ????? ???????? ?? ??????')
                                wait(1500)
                                sampSendChat('/me ??????? ???????? ??? ? ??????')
                                wait(1500)
                                sampSendChat('/do ???????? ??? ? ???????.')
                                wait(1500)
                                sampSendChat('/tie ' ..u8:decode(text_buffer6.v))
                           end)
                        end        
                        if imgui.Button(u8'???????? ? ????', imgui.ImVec2(256, 45)) then
                            lua_thread.create(function()
                                sampSendChat('/me ??????? ?????? ?? ?????? ???????? ?? ??????')
                                wait(1500)
                                sampSendChat('/me ??????? ?????? ???????? ?? ?????? ? ?????? ? ??????')
                           end)
                        end
                        imgui.SameLine()
                        if imgui.Button(u8'???????? ?? ????', imgui.ImVec2(256, 45)) then
                            lua_thread.create(function()
                                sampSendChat('/me ????????? ???? ???? ????? ?????? ???????? ?? ?????? ???????? ? ??????')
                                wait(1500)
                                sampSendChat('/me ?????? ??????? ??????? ?? ????')
                           end)
                        end
                        imgui.NewInputText('##SearchBar10', text_buffer10, 150, u8'???')
                        if imgui.Button(u8'?????????', imgui.ImVec2(150, 25)) then
                            notify.addNotify("???????????", "                        {FF0000}?????????!", 2, 4, 6) --????? ?????? ? ????
                            mainIni.config.name = text_buffer10.v
                            inicfg.save(mainIni, directIni)
                        end
                        imgui.SameLine()
                        if imgui.Button(u8'?????????????', imgui.ImVec2(150, 25)) then
                            lua_thread.create(function()
                                sampSendChat('???????????, ? ??????? ?????????..')
                                wait(1500)
                                sampSendChat('..???? ????? ' ..u8:decode(mainIni.config.name))
                                wait(1500)
                                sampSendChat('/me ???????? ????? ? ??????? ?????????? ????? ?????, ????? ??????? ???????')
                            end)
                        end
                        imgui.SetCursorPos(imgui.ImVec2(185 , 335))
                        imgui.TextQuestion(u8"( ?????????? )", u8"???? ?? ????? ??? ???? ??? ? ?????????, ?? ??????? ? ????????? ??? ?????? ?? ?????")
                    imgui.EndChild()
                end
                if bool4 then
                    imgui.SetCursorPos(imgui.ImVec2(270, 40))
                    imgui.BeginChild("BeginChild4", imgui.ImVec2(555, -1), true)
                        if  imgui.Combo(u8"????", ImInt, names) then
                            current_style = ImInt.v + 1 -- ? ?????? Lua ?????????? ? ???????, ??-????? ???????? ??.
                            styles[current_style]()
                            mainIni.config.style = current_style
                            inicfg.save(mainIni, directIni) 
                        end
                    imgui.EndChild()
                end
        imgui.End()
    end

    if window2 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 9.3, sh / 5.7))

        imgui.SetNextWindowSize(imgui.ImVec2(1100,500), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"??????? ?????", window2, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            if imgui.CollapsingHeader(u8'??????? ? ??????????? ?????? 1.1 - 1.15') then
                if doesFileExist(getWorkingDirectory().."\\TestFile4.txt") then
                    file4 = io.open(getWorkingDirectory().."\\TestFile4.txt", "r")
                    text_in_file4 = file4:read("*a")
                    file4:close()
                end
                imgui.Text((text_in_file4))
            end
            if imgui.CollapsingHeader(u8'??????? ? ??????????? ?????? 1.16 - 1.28') then
                if doesFileExist(getWorkingDirectory().."\\TestFile5.txt") then
                    file5 = io.open(getWorkingDirectory().."\\TestFile5.txt", "r")
                    text_in_file5 = file5:read("*a")
                    file5:close()
                end
                imgui.Text((text_in_file5))
            end
            if imgui.CollapsingHeader(u8'??????? ? ??????????? ?????? 1.29 - 1.47') then
                if doesFileExist(getWorkingDirectory().."\\TestFile6.txt") then
                    file6 = io.open(getWorkingDirectory().."\\TestFile6.txt", "r")
                    text_in_file6 = file6:read("*a")
                    file6:close()
                end
                imgui.Text((text_in_file6))
            end
            if imgui.CollapsingHeader(u8'??????? ????????? ? ???????????') then
                if doesFileExist(getWorkingDirectory().."\\TestFile7.txt") then
                    file7 = io.open(getWorkingDirectory().."\\TestFile7.txt", "r")
                    text_in_file7 = file7:read("*a")
                    file7:close()
                end
                imgui.Text((text_in_file7))
            end
            if imgui.CollapsingHeader(u8'??????????? ????????') then
                if doesFileExist(getWorkingDirectory().."\\TestFile8.txt") then
                    file8 = io.open(getWorkingDirectory().."\\TestFile8.txt", "r")
                    text_in_file8 = file8:read("*a")
                    file8:close()
                end
                imgui.Text((text_in_file8))
            end
            if imgui.CollapsingHeader(u8'??????? ??????? ????????') then
                if doesFileExist(getWorkingDirectory().."\\TestFile9.txt") then
                    file9 = io.open(getWorkingDirectory().."\\TestFile9.txt", "r")
                    text_in_file9 = file9:read("*a")
                    file9:close()
                end
                imgui.Text((text_in_file9))
            end
            if imgui.CollapsingHeader(u8'??????? ?????? ? ??????????? 5.1 - 5.10') then
                if doesFileExist(getWorkingDirectory().."\\TestFile10.txt") then
                    file10 = io.open(getWorkingDirectory().."\\TestFile10.txt", "r")
                    text_in_file10 = file10:read("*a")
                    file10:close()
                end
                imgui.Text((text_in_file10))
            end
            if imgui.CollapsingHeader(u8'??????? ?????? ? ??????????? 5.11 - 5.21') then
                if doesFileExist(getWorkingDirectory().."\\TestFile11.txt") then
                    file11 = io.open(getWorkingDirectory().."\\TestFile11.txt", "r")
                    text_in_file11 = file11:read("*a")
                    file11:close()
                end
                imgui.Text((text_in_file11))
            end
            if imgui.CollapsingHeader(u8'??????? ?????? ? ??????????? 5.22 - 5.26') then
                if doesFileExist(getWorkingDirectory().."\\TestFile12.txt") then
                    file12 = io.open(getWorkingDirectory().."\\TestFile12.txt", "r")
                    text_in_file12 = file12:read("*a")
                    file12:close()
                end
                imgui.Text((text_in_file12))
            end
            --imgui.SetCursorPos(imgui.ImVec2(15, 455))
            if imgui.Button(u8'??????? ????') then
                window2 = false
            end
            
        imgui.End() 

    end

    if window3 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 3.5, sh / 4.5))

        imgui.SetNextWindowSize(imgui.ImVec2(645,435), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"?????? ??????", window3, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            if doesFileExist(getWorkingDirectory().."\\TestFile.txt") then
                file = io.open(getWorkingDirectory().."\\TestFile.txt", "r")
                text_in_file = file:read("*a")
                file:close()
            end
            if doesFileExist(getWorkingDirectory().."\\TestFile2.txt") then
                file2 = io.open(getWorkingDirectory().."\\TestFile2.txt", "r")
                text_in_file2 = file2:read("*a")
                file2:close()
            end
            imgui.TextColoredRGB("{FF0000}?????? ?????? ?? ?????????? ?? ???????")
            imgui.Text((text_in_file))
            imgui.TextColoredRGB("{FF0000}??????????? ?? 8-? ? 9-? ?????")
            imgui.Text((text_in_file2))
            if imgui.Button(u8'??????? ????') then
                window3 = false
            end
        imgui.End()
    end

    if window4 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 3.3, sh / 2.5))

        imgui.SetNextWindowSize(imgui.ImVec2(550, 120), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"???? ??????", window4d, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            if imgui.Button(u8'???? ?????????????', imgui.ImVec2(165, 40)) then
                window5 = true
                window4 = false
            end

            imgui.SameLine()
            if imgui.Button(u8'???? ?????????', imgui.ImVec2(165, 40)) then
                window6 = true
                window4 = false
            end

            imgui.SameLine()
            if imgui.Button(u8'?????? ????', imgui.ImVec2(165, 40)) then
                window13 = true
                window4 = false
            end
                
            if imgui.Button(u8'??????? ????') then
                window4 = false
            end
        imgui.End()
    end

    if window5 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))

        imgui.SetNextWindowSize(imgui.ImVec2(350, 100), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"???? ?????????????", window5, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            imgui.NewInputText('##SearchBar1', text_buffer, -1, u8'id')
            if imgui.Button(u8'????? ' ..fa.ICON_FA_ARROW_RIGHT) then
                window5 = false
                window7 = true
            end
        imgui.End()
    end

    if window6 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))

        imgui.SetNextWindowSize(imgui.ImVec2(350,100), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"???? ?????????", window6, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            imgui.NewInputText('##SearchBar1', text_buffer2, -1, u8'id')
            if imgui.Button(u8'????? ' ..fa.ICON_FA_ARROW_RIGHT) then
                window6 = false
                window9 = true
            end
        imgui.End()
    end

    if window7 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 3.5))

        imgui.SetNextWindowSize(imgui.ImVec2(350,272), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"??????", window7, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            if imgui.Button(u8'????????? ????????', imgui.ImVec2(-1, 50)) then
                sampSendChat('???? ????, ???-?? ??? ???? ??????? ?? ????????.')
            end
            if imgui.Button(u8'?????????? ???.?????', imgui.ImVec2(-1, 50)) then
                sampSendChat('??? ??? ???? ???.?????.')
            end
            if imgui.Button(u8'????????? ????????', imgui.ImVec2(-1, 50)) then
                sampSendChat('??? ??? ???? ????????.')
            end
            if imgui.Button(u8'???????', imgui.ImVec2(155, 50)) then
                lua_thread.create(function()
                    sampSendChat(u8'/invite ' ..u8:decode(text_buffer.v))
                end)
                window7 = false
            end
            imgui.SameLine()
            if imgui.Button(u8'????????', imgui.ImVec2(155, 50)) then
                window7 = false
                window8 = true 
            end
        
        imgui.End()
    end

    if window8 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 3.5))

        imgui.SetNextWindowSize(imgui.ImVec2(250,275), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"??????? ??????", window8, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            if imgui.Button(u8'????????? ???????', imgui.ImVec2(-1, 50)) then
                window8 = false
                lua_thread.create(function()
                    sampSendChat('?????? ???????, ?? ? ???? ???? ???????.')
                    wait(1500)
                    sampSendChat('/b ? ???? ??????? ????????? ???????')
                end)
            end
            
            if imgui.Button(u8'???? ???.?????', imgui.ImVec2(-1, 50)) then
                window8 = false
                lua_thread.create(function()
                    sampSendChat('?????? ???????, ?? ? ???? ???? ???????.')
                    wait(1500)
                    sampSendChat('/b ? ???? ???? ???.?????')
                end)
            end

            if imgui.Button(u8'???? ????????', imgui.ImVec2(-1, 50)) then
                window8 = false
                lua_thread.create(function()
                    sampSendChat('?????? ???????, ?? ? ???? ???? ???????.')
                    wait(1500)
                    sampSendChat('/b ? ???? ???? ????????')
                end)
            end

            if imgui.Button(u8'???? ???????', imgui.ImVec2(-1, 50)) then
                window8 = false
                lua_thread.create(function()
                    sampSendChat('?????? ???????, ?? ? ???? ???? ???????.')
                    wait(1500)
                    chatSet('/b ')
                end)
            end
        imgui.End()
    end

    if window9 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))

        imgui.SetNextWindowSize(imgui.ImVec2(350,450), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"???? ?????????", window9, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            if imgui.Button(u8'??????', imgui.ImVec2(155, 50)) then
                window9 = false
                window10 = true
            end
            imgui.SameLine()
            if imgui.Button(u8'?????', imgui.ImVec2(155, 50)) then
                window9 = false
                sampSendChat(u8'/unfwarn ' ..u8:decode(text_buffer2.v))

            end
        imgui.End()
    end

    if window10 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))

        imgui.SetNextWindowSize(imgui.ImVec2(350, 350), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"???? ?????????", window10, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            imgui.NewInputText('##SearchBar4', text_buffer8, -1, u8'???????')
            if imgui.Button(u8'??', imgui.ImVec2(-1, 20)) then
                window10 = false
                lua_thread.create(function()
                    sampSendChat('/warn ' ..u8:decode(text_buffer.v).. '' ..u8:decode(text_buffer8.v))
                end)
            end
        imgui.End()
    end

    if window11 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
        
        imgui.SetNextWindowSize(imgui.ImVec2(350, 350), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"???? ??????", window11, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            imgui.NewInputText('##SearchBar1', text_buffer3, -1, u8'id')
            if imgui.Button(u8'????? ' ..fa.ICON_FA_ARROW_RIGHT) then
                window11 = false
                window9 = true
            end
        imgui.End()
    end

    if window13 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))

        imgui.SetNextWindowSize(imgui.ImVec2(350,100), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"???? ?????????", window13, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            imgui.NewInputText('##SearchBar1', text_buffer3, -1, u8'id')
            if imgui.Button(u8'????? ' ..fa.ICON_FA_ARROW_RIGHT) then
                window13 = false
                window12 = true
            end
        imgui.End()
    end

    if window12 then

        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 5.5))

        imgui.SetNextWindowSize(imgui.ImVec2(350, 500), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"???? ??????", window12, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8'1 ????', imgui.ImVec2(-1, 50)) then
                sampSendChat(u8'/giverank ' ..u8:decode(text_buffer3.v).. ' 1')
                window12 = false
            end

            if imgui.Button(u8'2 ????', imgui.ImVec2(-1, 50)) then
                sampSendChat(u8'/giverank ' ..u8:decode(text_buffer3.v).. ' 2')
                window12 = false
            end

            if imgui.Button(u8'3 ????', imgui.ImVec2(-1, 50)) then
                sampSendChat(u8'/giverank ' ..u8:decode(text_buffer3.v).. ' 3')
                window12 = false
            end

            if imgui.Button(u8'4 ????', imgui.ImVec2(-1, 50)) then
                sampSendChat(u8'/giverank ' ..u8:decode(text_buffer3.v).. ' 4')
                window12 = false
            end

            if imgui.Button(u8'5 ????', imgui.ImVec2(-1, 50)) then
                sampSendChat(u8'/giverank ' ..u8:decode(text_buffer3.v).. ' 5')
                window12 = false
            end

            if imgui.Button(u8'6 ????', imgui.ImVec2(-1, 50)) then
                sampSendChat(u8'/giverank ' ..u8:decode(text_buffer3.v).. ' 6')
                window12 = false
            end

            if imgui.Button(u8'7 ????', imgui.ImVec2(-1, 50)) then
                sampSendChat(u8'/giverank ' ..u8:decode(text_buffer3.v).. ' 7')
                window12 = false
            end

            if imgui.Button(u8'8 ????', imgui.ImVec2(-1, 50)) then
                sampSendChat(u8'/giverank ' ..u8:decode(text_buffer3.v).. ' 8')
                window12 = false
            end
            
        imgui.End()
    end

    if window15 then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))

        imgui.SetNextWindowSize(imgui.ImVec2(350,100), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"???????? ????", window15, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            imgui.NewInputText('##SearchBar1', text_buffer6, -1, u8'id')
            if imgui.Button(u8'?????? ' ..fa.ICON_FA_ARROW_RIGHT) then
                window15 = false
                lua_thread.create(function()
                    sampSendChat('/me ?????? ????????? ???? ?????? ??????? ?? ???????')
                    wait(1500)
                    sampSendChat('/do ??????? ? ????.')
                    wait(1500)
                    sampSendChat('/me ??????? ??????? ????? ?? ????? ? ???????? ?? ??????')
                    wait(1500)
                    sampSendChat('/do ???? ???????? ???????? ???????? ? ??????? ???? ? ????????.')
                    wait(1500)
                    sampSendChat('/tie ' ..u8:decode(text_buffer6.v))
               end)
            end
        imgui.End()
    end
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function aply_style_1()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec2 = imgui.ImVec2
    local ImVec4 = imgui.ImVec4
    
    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 1.5
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function aply_style_2()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec2 = imgui.ImVec2
    local ImVec4 = imgui.ImVec4
    
    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 1.5
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function aply_style_3()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec2 = imgui.ImVec2
    local ImVec4 = imgui.ImVec4
    
    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 1.5
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
    colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
    colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
    colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
    colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function aply_style_4()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec2 = imgui.ImVec2
    local ImVec4 = imgui.ImVec4
    
    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 1.5
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function aply_style_5()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec2 = imgui.ImVec2
    local ImVec4 = imgui.ImVec4
    
    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 1.5
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function aply_style_6()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec2 = imgui.ImVec2
    local ImVec4 = imgui.ImVec4
    
    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 1.5
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.Text]   = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.TextDisabled]   = ImVec4(0.24, 0.24, 0.24, 1.00)
    colors[clr.WindowBg]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.ChildWindowBg]         = ImVec4(0.96, 0.96, 0.96, 1.00)
    colors[clr.PopupBg]               = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.Border]                = ImVec4(0.86, 0.86, 0.86, 1.00)
    colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]               = ImVec4(0.88, 0.88, 0.88, 1.00)
    colors[clr.FrameBgHovered]        = ImVec4(0.82, 0.82, 0.82, 1.00)
    colors[clr.FrameBgActive]         = ImVec4(0.76, 0.76, 0.76, 1.00)
    colors[clr.TitleBg]               = ImVec4(0.00, 0.45, 1.00, 0.82)
    colors[clr.TitleBgCollapsed]      = ImVec4(0.00, 0.45, 1.00, 0.82)
    colors[clr.TitleBgActive]         = ImVec4(0.00, 0.45, 1.00, 0.82)  
    colors[clr.MenuBarBg]             = ImVec4(0.00, 0.37, 0.78, 1.00)
    colors[clr.ScrollbarBg]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ScrollbarGrab]         = ImVec4(0.00, 0.35, 1.00, 0.78)
    colors[clr.ScrollbarGrabHovered]  = ImVec4(0.00, 0.33, 1.00, 0.84)
    colors[clr.ScrollbarGrabActive]   = ImVec4(0.00, 0.31, 1.00, 0.88)
    colors[clr.ComboBg]               = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.CheckMark]             = ImVec4(0.00, 0.49, 1.00, 0.59)
    colors[clr.SliderGrab]            = ImVec4(0.00, 0.49, 1.00, 0.59)
    colors[clr.SliderGrabActive]      = ImVec4(0.00, 0.39, 1.00, 0.71)
    colors[clr.Button]                = ImVec4(0.00, 0.49, 1.00, 0.59)
    colors[clr.ButtonHovered]         = ImVec4(0.00, 0.49, 1.00, 0.71)
    colors[clr.ButtonActive]          = ImVec4(0.00, 0.49, 1.00, 0.78)
    colors[clr.Header]                = ImVec4(0.00, 0.49, 1.00, 0.78)
    colors[clr.HeaderHovered]         = ImVec4(0.00, 0.49, 1.00, 0.71)
    colors[clr.HeaderActive]          = ImVec4(0.00, 0.49, 1.00, 0.78)
    colors[clr.ResizeGrip]            = ImVec4(0.00, 0.39, 1.00, 0.59)
    colors[clr.ResizeGripHovered]     = ImVec4(0.00, 0.27, 1.00, 0.59)
    colors[clr.ResizeGripActive]      = ImVec4(0.00, 0.25, 1.00, 0.63)
    colors[clr.CloseButton]           = ImVec4(0.00, 0.35, 0.96, 0.71)
    colors[clr.CloseButtonHovered]    = ImVec4(0.00, 0.31, 0.88, 0.69)
    colors[clr.CloseButtonActive]     = ImVec4(0.00, 0.25, 0.88, 0.67)
    colors[clr.PlotLines]             = ImVec4(0.00, 0.39, 1.00, 0.75)
    colors[clr.PlotLinesHovered]      = ImVec4(0.00, 0.39, 1.00, 0.75)
    colors[clr.PlotHistogram]         = ImVec4(0.00, 0.39, 1.00, 0.75)
    colors[clr.PlotHistogramHovered]  = ImVec4(0.00, 0.35, 0.92, 0.78)
    colors[clr.TextSelectedBg]        = ImVec4(0.00, 0.47, 1.00, 0.59)
    colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35)
end

function aply_style_7()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec2 = imgui.ImVec2
    local ImVec4 = imgui.ImVec4
    
    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 1.5
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.Text]                 = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.44, 0.44, 0.44, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.06, 0.06, 0.06, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg]            = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.06, 0.06, 0.06, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.81, 0.83, 0.81, 1.00)
    colors[clr.CheckMark]            = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.Button]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.ButtonHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ButtonActive]         = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.Header]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.HeaderHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.HeaderActive]         = ImVec4(0.93, 0.65, 0.14, 1.00)
    colors[clr.Separator]            = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ResizeGripHovered]    = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ResizeGripActive]     = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.CloseButton]          = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end

    names = {u8"?????", u8"???????", u8"??????", u8"??????????(new)", u8"?????????(new)", u8"????-?????(new)", u8"?????????(new)"}
    styles = {aply_style_1, aply_style_2, aply_style_3, aply_style_4, aply_style_5, aply_style_6, aply_style_7}

    current_style = mainIni.config.style
    ImInt = imgui.ImInt(current_style - mainIni.config.style) -- ????????? ? ????? ? ???? ??????????, ?? ????? ??????? ????

    styles[current_style]()
