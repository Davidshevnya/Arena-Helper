local sampev = require 'lib.samp.events'
local keysv = require 'lib.vkeys'
local wm = require("windows.message");
local imgui = require("lib.mimgui");
local encoding = require('encoding')
local notf = import('imgui_notf.lua')
local hotkey = require 'mimgui_hotkeys' -- подключаем библиотеку

script_name("ArenaHelper")


encoding.default = "CP1251"
u8 = encoding.UTF8
local tag = "{FF0010}[ARENA HELPER]: "
-- INI CFG
local inicfg = require("inicfg")
local directIni = "arena_helper.ini"
---@diagnostic disable-next-line: missing-parameter
local ini = inicfg.load(inicfg.load({
    main = {
        lovlyacchas = true,
        closedialog = true,
        lovlyacode = true,
        lovlyasunduka = true,
        bindNrg = "[81]",
        bindImgui = "[52]"
    },
}, directIni))
inicfg.save(ini, directIni)
-- INI CFG



local new = imgui.new

local winState = new.bool(false)
local tab = 1
local s = {
    lovlyacchas = new.bool(ini.main.lovlyacchas),
    closedialog = new.bool(ini.main.closedialog),
    lovlyacode = new.bool(ini.main.lovlyacode),
    lovlyasunduka = new.bool(ini.main.lovlyasunduka),
    

}

local Save = function()
    ini.main.lovlyacchas = s.lovlyacchas[0]
    ini.main.closedialog = s.closedialog[0]
    ini.main.lovlyacode = s.lovlyacode[0]
    ini.main.lovlyasunduka = s.lovlyasunduka[0]
    inicfg.save(ini, directIni)
end

local isCode = new.bool(false);
local isChas = new.bool(false);
local isBind = new.bool(false);
local isCaptcha = new.bool(false);
local code = "None"
local captcha = "None"
local nrgHotkey
local mimguiHotkey
imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    imgui.DarkTheme()

end)

imgui.OnFrame(function() return winState[0] end,
    function(player)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 500, 500
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
        imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.Always) --    
        imgui.Begin(u8'Arena Helper by Inchez', winState, imgui.WindowFlags.NoResize) --    ,    
        for numberTab,nameTab in pairs({'Основное','Настройки','Инфа'}) do -- создаём и парсим таблицу с названиями будущих вкладок
            if imgui.Button(u8(nameTab), imgui.ImVec2(90, 60)) then -- 2ым аргументом настраивается размер кнопок (подробнее в гайде по мимгуи)
                tab = numberTab -- меняем значение переменной tab на номер нажатой кнопки
            end
        end
        imgui.SetCursorPos(imgui.ImVec2(95, 28)) -- [Для декора] Устанавливаем позицию для чайлда ниже
        if imgui.BeginChild('Name##'..tab, imgui.ImVec2(500, 550), true) then -- [Для декора] Создаём чайлд в который поместим содержимое
        -- == [Основное] Содержимое вкладок == --
            if tab == 1 then -- если значение tab == 1
                -- == Содержимое вкладки №1
                if imgui.Checkbox(u8"Ловля /cchas", s.lovlyacchas) then
                    Save() 
                end
                imgui.SameLine()
                imgui.TextQuestion("( ? )", u8"Автоматически пропишет /cchas если будет найден в чате")
                if imgui.Checkbox(u8"Ловля /code", s.lovlyacode) then
                    if notf then
        
                        notf.addNotification(string.format("Код %s обнаружен!", code), 10)
                    end
                    Save() 
                end
                imgui.SameLine()
                imgui.TextQuestion("( ? )", u8"ловит /code с задержкой")
                if imgui.Checkbox(u8"Ловля сундука", s.lovlyasunduka) then
                    Save() 
                end
                imgui.SameLine()
                imgui.TextQuestion("( ? )", u8"Автоматически открывает сундук за секунду")
                
                if imgui.Checkbox(u8"Закрывать диалог при спавне", s.closedialog) then
                    Save() 
                end
                imgui.SameLine()
                imgui.TextQuestion("( ? )", u8"Закрывает надоедающий диалог при спавне")
                
                imgui.Text(u8"Бинд на НРГ (/vip):")
                imgui.SameLine()
                imgui.TextQuestion("( ? )", u8"Теперь тебе не нужно ебаться с командой, просто забинди клавишу и кайфуй!")
                imgui.SameLine()
                if hotkey.ShowHotKey('autoNRG') then
                    ini.main.bindNrg = encodeJson(nrgHotkey:GetHotKey())
                    Save()
                end-- отображаем первый хоткей, не будем указывать размер
            
            elseif tab == 2 then
                imgui.Text(u8("Открывать меню скрипта на клавишу:"))
                imgui.SameLine()
                if hotkey.ShowHotKey('openImgui') then 
                    ini.main.bindImgui = encodeJson(mimguiHotkey:GetHotKey())
                    Save()
                end

                
            elseif tab == 3 then
                imgui.Text(u8"Данный скрипт был разработан специально для Arizona Arena.")
            
            end
        end
        
        
        imgui.Separator()
        
        imgui.CenterText(u8"Автор скрипта Inchez")
        imgui.End()
    end
)
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

function main()

    while not isSampAvailable() do
        wait(0)
    end
    sampRegisterChatCommand('arenahelp', function()
        winState[0] = not winState[0]
        Save()
    end)
    sampAddChatMessage(tag .. "{FFFFFF}Скрипт загружен. Приятной игры!!",
        0)
    sampAddChatMessage(tag .. "{FFFFFF}Автор скрипта: {FF0000}David_Inchez {FFFfff}aka {FF0000} Inchez", 0)
    nrgHotkey = hotkey.RegisterHotKey('autoNRG', false, decodeJson(ini.main.bindNrg), function() 
        if not sampIsCursorActive() then
            isBind[0] = true
            sampSendChat("/vip")
        end
        
    end) -- регистрируем хоткей 1
    mimguiHotkey = hotkey.RegisterHotKey("openImgui", false, decodeJson(ini.main.bindImgui), function() 
        if not sampIsCursorActive() then
            winState[0] = not winState[0]
        end
    end)
    hotkey.CancelKey = 0x2E -- изменяет клавишу, отвечающую за отмену изменения комбинации клавиш хоткея. По умолчанию: 0x1B (Клавиша ESCAPE).
    hotkey.RemoveKey = 0x1B -- изменяет клавишу, отвечающую за полное удаление бинда у хоткея. По умолчанию: 0x08 (Клавиша BACKSPACE).
    hotkey.Text.NoKey = u8'Пусто' -- изменяет текст, который появляется у хоткея, когда бинд пуст. По умолчанию: '< Свободно >'.
    hotkey.Text.WaitForKey = u8'Ожидание клавиши...' -- изменяет текст, который появляется у хоткея, когда пользователь изменяет бинд.
    
    while true do
        if s.lovlyasunduka[0] then 
            if sampTextdrawIsExists(2071) then
                if sampTextdrawGetString(2071) == "0:00" then
                    sampSendClickTextdraw(2074)
                    wait(150)
                end
            end
        end
        if isCaptcha[0] then
            wait(2400);
            sampProcessChatInput("/vr " .. captcha);
            isCaptcha[0] = false;
        end
		if isCode[0] then
			wait(2200)
            if code:len() > 15 or code:len() > 10 then wait(1000) end
			sampProcessChatInput("/code " .. code);
			isCode[0] = not isCode[0];
		
		end
		if isChas[0] then
			sampSendChat("/cchas")
			isChas[0] = not isChas[0];
		end
		
            
        wait(0)
    end
end

function sampev.onServerMessage(color, data)
	local text = data:gsub("{......}", "")
    if text:lower():find('/cchas') or text:lower():find('cchas') or text:lower():find("ccgas") then
		isChas[0] = not isChas[0]
        
    elseif(text:lower():find(".* .*: капча на .*:%s*(.*)")) then
        
        captcha = text:lower():match(".* .*: капча на .*:%s*(.*)")
        isCaptcha[0] = true;
        if notf then
            notf.addNotification(string.format("Капча  %s обнаружена!", captcha), 10)
        end
        sampAddChatMessage(captcha, -1)
    elseif(text:lower():find(".* .*: капча на .*:(.*)")) then
        
        captcha = text:match(".* .*: капча на .*:(.*)")
        isCaptcha[0] = true;
        if notf then
            notf.addNotification(string.format("Капча  %s обнаружена!", captcha), 10)
        end
        sampAddChatMessage(captcha, -1)
        
    elseif(text:find(".+ .*: Создал код (.+) %[Активаций: %d+%] с призом .+ .+.")) then
        code = text:match(".+ .*: Создал код (.+) %[Активаций: %d+%] с призом .+ .+");
        code:gsub(" ", "")
        sampAddChatMessage(code, -1)
		isCode[0] = not isCode[0]
	elseif text:find(".* .*: /code (.*)%s*$") then
        
		code = text:match(".* .*: /code (.*)%s*$");
        sampAddChatMessage(code, -1)
        if notf then
            notf.addNotification(string.format("Код %s обнаружен!", code), 10)
        end
		isCode[0] = not isCode[0]
		
	end
	 

end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if dialogId == 15378 then
        return false
    end
	
	if dialogId == 7760 then
        if isBind[0] then 
            isBind[0] = false
            sampSendDialogResponse(7760, 1, 3, "");
		    return false;
        end
	end
	
end

function imgui.DarkTheme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end