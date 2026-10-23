local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local ws = game:GetService("Workspace")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = (gethui and gethui()) or (cloneref and cloneref(game:GetService("CoreGui"))) or game:GetService("CoreGui")
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new
local rect = Rect.new
local cfr = CFrame.new

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer
local mouse = lp:GetMouse()
local gui_offset = gui_service:GetGuiInset().Y

local max = math.max
local floor = math.floor
local min = math.min
local abs = math.abs

if getgenv().library then
	getgenv().library:unload()
end

-- library init
getgenv().library = {
	flags = {},
	config_flags = {},
	connections = {},
	notifications = {},
	instances = {},
	main_frame = {},
	config_holder,
	current_tab,
	current_element_open,
	dock_button_holder,
	gui,
	sin = 0,
	keybind_path,
	panel_open = false,

	directory = "NVL_Private",
	folders = {
		"/fonts",
		"/configs",
		"/Character",
	},
	font,
}

local flags = library.flags
local config_flags = library.config_flags

local themes = {
	preset = {
		["outline"] = rgb(32, 32, 38), --
		["inline"] = rgb(60, 55, 75), --
		["accent"] = rgb(0, 150, 255), -- Neverlose signature blue
		["contrast"] = rgb(35, 35, 47),
		["text"] = rgb(170, 170, 170),
		["unselected_text"] = rgb(90, 90, 90),
		["text_outline"] = rgb(0, 0, 0),
		["glow"] = rgb(0, 150, 255),
	},

	utility = {
		["outline"] = {
			["BackgroundColor3"] = {},
			["Color"] = {},
		},
		["inline"] = {
			["BackgroundColor3"] = {},
		},
		["accent"] = {
			["BackgroundColor3"] = {},
			["TextColor3"] = {},
			["ImageColor3"] = {},
			["BorderColor3"] = {},
			["ScrollBarImageColor3"] = {},
		},
		["contrast"] = {
			["Color"] = {},
		},
		["text"] = {
			["TextColor3"] = {},
		},
		["text_outline"] = {
			["Color"] = {},
		},
		["glow"] = {
			["ImageColor3"] = {},
		},
	},
}

local keys = {
	[Enum.KeyCode.LeftShift] = "LS",
	[Enum.KeyCode.RightShift] = "RS",
	[Enum.KeyCode.LeftControl] = "LC",
	[Enum.KeyCode.RightControl] = "RC",
	[Enum.KeyCode.Insert] = "INS",
	[Enum.KeyCode.Backspace] = "BS",
	[Enum.KeyCode.Return] = "Ent",
	[Enum.KeyCode.LeftAlt] = "LA",
	[Enum.KeyCode.RightAlt] = "RA",
	[Enum.KeyCode.CapsLock] = "CAPS",
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.Nine] = "9",
	[Enum.KeyCode.Zero] = "0",
	[Enum.KeyCode.KeypadOne] = "Num1",
	[Enum.KeyCode.KeypadTwo] = "Num2",
	[Enum.KeyCode.KeypadThree] = "Num3",
	[Enum.KeyCode.KeypadFour] = "Num4",
	[Enum.KeyCode.KeypadFive] = "Num5",
	[Enum.KeyCode.KeypadSix] = "Num6",
	[Enum.KeyCode.KeypadSeven] = "Num7",
	[Enum.KeyCode.KeypadEight] = "Num8",
	[Enum.KeyCode.KeypadNine] = "Num9",
	[Enum.KeyCode.KeypadZero] = "Num0",
	[Enum.KeyCode.Minus] = "-",
	[Enum.KeyCode.Equals] = "=",
	[Enum.KeyCode.Tilde] = "~",
	[Enum.KeyCode.LeftBracket] = "[",
	[Enum.KeyCode.RightBracket] = "]",
	[Enum.KeyCode.RightParenthesis] = ")",
	[Enum.KeyCode.LeftParenthesis] = "(",
	[Enum.KeyCode.Semicolon] = ",",
	[Enum.KeyCode.Quote] = "'",
	[Enum.KeyCode.BackSlash] = "\\",
	[Enum.KeyCode.Comma] = ",",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Slash] = "/",
	[Enum.KeyCode.Asterisk] = "*",
	[Enum.KeyCode.Plus] = "+",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Backquote] = "`",
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
	[Enum.KeyCode.Escape] = "ESC",
	[Enum.KeyCode.Space] = "SPC",
}

library.__index = library

for _, path in next, library.folders do
	makefolder(library.directory .. path)
end

if not isfile(library.directory .. "/fonts/main.ttf") then
	writefile(
		library.directory .. "/fonts/main.ttf",
		game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/fs-tahoma-8px.ttf")
	)
end

local tahoma = {
	name = "SmallestPixel7",
	faces = {
		{
			name = "Regular",
			weight = 400,
			style = "normal",
			assetId = getcustomasset(library.directory .. "/fonts/main.ttf"),
		},
	},
}

if not isfile(library.directory .. "/fonts/main_encoded.ttf") then
	writefile(library.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(tahoma))
end

library.font = Font.new(getcustomasset(library.directory .. "/fonts/main_encoded.ttf"), Enum.FontWeight.Regular)
--

-- functions
-- misc functions
function library.to_screen_point(position)
	return camera:WorldToViewportPoint(position)
end

function library:unload()
	library.gui:Destroy()

	for _, connection in library.connections do
		connection:Disconnect()
	end

	for _, item in library.instances do
		item:Destroy()
	end

	getgenv().library = nil
end

function library:convert_string_rgb(str)
	local values = {}

	for value in string.gmatch(str, "[^,]+") do
		table.insert(values, tonumber(value))
	end

	if #values == 4 then
		local r, g, b, a = values[1], values[2], values[3], values[4]

		return r, g, b, a
	else
		library:notification({ text = "Input a correct RGBA value (in the format 255, 255, 255, 0.5)" })
	end
end

function library:connection(signal, callback)
	local connection = signal:Connect(callback)

	table.insert(library.connections, connection)

	return connection
end

function library:make_resizable(frame)
	local Frame = Instance.new("TextButton")
	Frame.Position = dim2(1, -10, 1, -10)
	Frame.BorderColor3 = rgb(0, 0, 0)
	Frame.Size = dim2(0, 10, 0, 10)
	Frame.BorderSizePixel = 0
	Frame.BackgroundColor3 = rgb(255, 255, 255)
	Frame.Parent = frame
	Frame.BackgroundTransparency = 1
	Frame.Text = ""

	local resizing = false
	local start_size
	local start
	local og_size = frame.Size

	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			start = input.Position
			start_size = frame.Size
		end
	end)

	Frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)

	library:connection(uis.InputChanged, function(input, game_event)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mouse_pos = vec2(mouse.X, mouse.Y)
			local viewport_x = camera.ViewportSize.X
			local viewport_y = camera.ViewportSize.Y

			current_size = dim2(
				start_size.X.Scale,
				math.clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, viewport_x),
				start_size.Y.Scale,
				math.clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, viewport_y)
			)
			frame.Size = current_size
		end
	end)
end

function library:make_smooth_draggable(frame, handle)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		local targetPos = dim2(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		tween_service:Create(frame, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = targetPos
		}):Play()
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	uis.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	library:connection(uis.InputChanged, function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function library:attach_word_caret(textbox, caret, padding_x, y_offset)
	padding_x = padding_x or 4
	y_offset = y_offset or -6

	local is_focused = false
	local pulse_thread = nil
	local last_type_time = 0
	local current_tween = nil

	caret.Size = UDim2.new(0, 1.5, 0, 12)
	caret.BorderSizePixel = 0
	caret.BackgroundTransparency = 1
	caret.BackgroundColor3 = caret.BackgroundColor3 or Color3.fromRGB(255, 255, 255)
	pcall(function()
		if not caret:FindFirstChildOfClass("UICorner") then
			local cr = Instance.new("UICorner", caret)
			cr.CornerRadius = UDim.new(0, 1)
		end
	end)

	local measure_label = nil
	pcall(function()
		measure_label = Instance.new("TextLabel")
		measure_label.Name = "CaretMeasureLabel"
		measure_label.BackgroundTransparency = 1
		measure_label.TextTransparency = 1
		measure_label.Size = UDim2.new(0, 0, 0, 0)
		measure_label.Position = UDim2.new(-10, 0, -10, 0)
		measure_label.ZIndex = -100
		measure_label.Visible = true
		measure_label.TextSize = textbox.TextSize or 12
		measure_label.FontFace = textbox.FontFace or library.font
		measure_label.Parent = textbox
	end)

	local function start_breathing_blink()
		if pulse_thread then task.cancel(pulse_thread) end
		pulse_thread = task.spawn(function()
			while is_focused do
				local time_since_type = os.clock() - last_type_time
				if time_since_type < 0.45 then
					caret.BackgroundTransparency = 0
					task.wait(0.45 - time_since_type)
				else
					local tw1 = tween_service:Create(caret, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						BackgroundTransparency = 0.95
					})
					tw1:Play()
					task.wait(0.45)
					if not is_focused then break end
					if os.clock() - last_type_time < 0.45 then
						caret.BackgroundTransparency = 0
					else
						local tw2 = tween_service:Create(caret, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
							BackgroundTransparency = 0
						})
						tw2:Play()
						task.wait(0.45)
					end
				end
			end
			caret.BackgroundTransparency = 1
		end)
	end

	local function stop_breathing_blink()
		if pulse_thread then
			task.cancel(pulse_thread)
			pulse_thread = nil
		end
		if current_tween then
			current_tween:Cancel()
			current_tween = nil
		end
		caret.BackgroundTransparency = 1
	end

	local function update_caret_position(skip_anim)
		if not is_focused then
			caret.BackgroundTransparency = 1
			return
		end

		local full_txt = textbox.Text or ""
		local full_len = string.len(full_txt)
		local box_w = (textbox.AbsoluteSize and textbox.AbsoluteSize.X > 0) and textbox.AbsoluteSize.X or 100
		local total_text_w = (textbox.TextBounds and textbox.TextBounds.X) or 0

		local cur_pos = textbox.CursorPosition
		if not cur_pos or cur_pos <= 0 or cur_pos > full_len + 1 then
			cur_pos = full_len + 1
		end

		local sub_txt = string.sub(full_txt, 1, math.max(0, cur_pos - 1))
		local sub_w = 0

		if full_txt == "" or sub_txt == "" then
			sub_w = 0
		elseif sub_txt == full_txt then
			sub_w = total_text_w
		else
			if measure_label then
				measure_label.Text = sub_txt
				measure_label.TextSize = textbox.TextSize or 12
				measure_label.FontFace = textbox.FontFace or library.font
				sub_w = measure_label.TextBounds.X
			end
			if (not sub_w or sub_w <= 0) and full_len > 0 then
				sub_w = math.floor((string.len(sub_txt) / full_len) * total_text_w)
			end
		end

		local parent_frame = caret.Parent
		local tb_x = 0
		if parent_frame and parent_frame ~= textbox then
			local ok, offset = pcall(function()
				return textbox.AbsolutePosition.X - parent_frame.AbsolutePosition.X
			end)
			if ok and offset and offset > 0 then
				tb_x = offset
			else
				tb_x = padding_x
			end
		else
			tb_x = padding_x
		end

		local align = textbox.TextXAlignment
		local text_start_x = 0
		if align == Enum.TextXAlignment.Center then
			if full_txt == "" then
				text_start_x = math.floor(box_w / 2)
			else
				text_start_x = math.floor((box_w - total_text_w) / 2)
			end
		elseif align == Enum.TextXAlignment.Right then
			if full_txt == "" then
				text_start_x = math.max(0, box_w - 4)
			else
				text_start_x = math.max(0, box_w - total_text_w - 2)
			end
		else
			text_start_x = 0
		end

		local caret_x = tb_x + text_start_x + sub_w
		local min_x = tb_x + 1
		local max_x = tb_x + math.max(1, box_w - 3)
		caret_x = math.clamp(caret_x, min_x, max_x)

		local target_pos = UDim2.new(0, caret_x, 0.5, y_offset)

		if skip_anim then
			if current_tween then current_tween:Cancel() end
			caret.Position = target_pos
		else
			if current_tween then current_tween:Cancel() end
			current_tween = tween_service:Create(caret, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Position = target_pos
			})
			current_tween:Play()
		end
	end

	textbox.Focused:Connect(function()
		is_focused = true
		last_type_time = os.clock()
		caret.BackgroundTransparency = 0
		update_caret_position(true)
		start_breathing_blink()
	end)

	textbox.FocusLost:Connect(function()
		is_focused = false
		stop_breathing_blink()
	end)

	textbox:GetPropertyChangedSignal("Text"):Connect(function()
		if not is_focused then
			caret.BackgroundTransparency = 1
			return
		end
		last_type_time = os.clock()
		caret.BackgroundTransparency = 0
		update_caret_position(false)
	end)

	textbox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		if not is_focused then
			caret.BackgroundTransparency = 1
			return
		end
		last_type_time = os.clock()
		caret.BackgroundTransparency = 0
		update_caret_position(false)
	end)

	return {
		update = update_caret_position,
		stop = stop_breathing_blink
	}
end
function library:new_item(class, properties)
	local ins = Instance.new(class)

	for _, v in next, properties do
		ins[_] = v
	end

	table.insert(library.instances, ins)

	return ins
end

function library:animation(text)
	local pattern = {}
	for i = 1, tonumber(text:len()) do
		table.insert(pattern, string.sub(text, 1, i))
	end
	for i = tonumber(text:len()) - 1, 0, -1 do
		table.insert(pattern, string.sub(text, 1, i))
	end
	return pattern
end

function library:convert_enum(enum)
	local enum_parts = {}

	for part in string.gmatch(enum, "[%w_]+") do
		table.insert(enum_parts, part)
	end

	local enum_table = Enum
	for i = 2, #enum_parts do
		local enum_item = enum_table[enum_parts[i]]

		enum_table = enum_item
	end

	return enum_table
end

function library:config_list_update()
	if not library.config_holder then
		return
	end

	local list = {}
	local dir = library.directory .. "/configs"

	if isfolder and not isfolder(dir) and makefolder then
		pcall(makefolder, library.directory)
		pcall(makefolder, dir)
	end

	-- Auto-migrate configs from old folders if not already copied
	pcall(function()
		for _, old_dir in ipairs({"inactivity/configs", "NVL/configs"}) do
			if isfolder and isfolder(old_dir) and listfiles and readfile and writefile then
				for _, old_file in ipairs(listfiles(old_dir)) do
					local cfg_name = string.match(old_file, "([^/\\]+%.cfg)$")
					if cfg_name and isfile and not isfile(dir .. "/" .. cfg_name) then
						local content = readfile(old_file)
						if content and content ~= "" then
							pcall(writefile, dir .. "/" .. cfg_name, content)
						end
					end
				end
			end
		end
	end)

	if isfolder and isfolder(dir) and listfiles then
		pcall(function()
			for _, file in next, listfiles(dir) do
				local name = string.match(file, "([^/\\]+)%.cfg$")
				if name then
					list[#list + 1] = name
				end
			end
		end)
	end

	if library.config_holder and library.config_holder.refresh_options then
		library.config_holder:refresh_options(list)
	end
end

function library:get_config()
	local Config = {}

	for flag_name, v in pairs(flags) do
		if typeof(v) == "Color3" then
			Config[flag_name] = { math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5) }
		elseif type(v) == "table" and v.key then
			Config[flag_name] = { active = v.active, mode = v.mode, key = tostring(v.key) }
		elseif type(v) == "table" and v["Color"] and typeof(v["Color"]) == "Color3" then
			local c = v["Color"]
			Config[flag_name] = {
				Color = { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) },
				Transparency = v["Transparency"] or 0
			}
		else
			Config[flag_name] = v
		end
	end

	-- Guaranteed capture for character, emote, and accessory configuration
	local explicit_flags = {
		"custom_character",
		"custom_char_model_type",
		"custom_char_id1",
		"custom_char_id2",
		"custom_char_userid",
		"custom_char_file",
		"misc_emote",
		"misc_emote_list",
		"misc_emote_bind",
		"misc_anim_speed",
		"misc_anim_lag",
		"misc_korblox",
		"misc_accessory_adder",
		"misc_accessory_list",
		"misc_hitsound_enabled",
		"misc_hitsound_voice",
		"misc_hitsound_volume",
	}
	for _, k in ipairs(explicit_flags) do
		if flags[k] ~= nil and Config[k] == nil then
			Config[k] = flags[k]
		end
	end

	if library.on_config_save then
		pcall(function()
			local extra = library.on_config_save()
			if type(extra) == "table" then
				for k, v in pairs(extra) do
					Config[k] = v
				end
			end
		end)
	end

	return http_service:JSONEncode(Config)
end

function library:save_config(name)
	if not name or name == "" then return end
	local dir = library.directory .. "/configs/"
	if isfolder and not isfolder(library.directory) then
		pcall(makefolder, library.directory)
	end
	if isfolder and not isfolder(dir) then
		pcall(makefolder, dir)
	end
	if writefile then
		pcall(writefile, dir .. name .. ".cfg", library:get_config())
		library:config_list_update()
		library:notification({ text = "Config '" .. name .. "' saved!" })
	end
end

function library:update_config(name)
	if not name or name == "" then return end
	library:save_config(name)
end

function library:load_config(name)
	if not name or name == "" then return end

	local dir = library.directory .. "/configs/"
	local path = dir .. name .. ".cfg"

	if not isfile or not isfile(path) or not readfile then
		library:notification({ text = "Config '" .. name .. "' not found!" })
		return
	end

	local ok_read, content = pcall(readfile, path)
	if not ok_read or not content then return end

	local ok_decode, config = pcall(function()
		return http_service:JSONDecode(content)
	end)

	if not ok_decode or type(config) ~= "table" then
		library:notification({ text = "Failed to parse config!" })
		return
	end

	for flag_name, info in pairs(config) do
		flags[flag_name] = info

		local function_set = library.config_flags[flag_name]
		if function_set then
			pcall(function()
				if type(info) == "table" and info.Color and type(info.Color) == "table" then
					local c_tab = info.Color
					function_set(Color3.fromRGB(c_tab[1], c_tab[2], c_tab[3]), info.Transparency or 0)
				elseif type(info) == "table" and #info == 3 and type(info[1]) == "number" then
					function_set(Color3.fromRGB(info[1], info[2], info[3]), 0)
				elseif type(info) == "table" and info.active ~= nil then
					function_set(info)
				else
					function_set(info)
				end
			end)
		end
	end

	if library.on_config_loaded then
		pcall(library.on_config_loaded, config)
	end

	library:notification({ text = "Config '" .. name .. "' loaded!" })
end

function library:delete_config(name)
	if not name or name == "" then return end
	local path = library.directory .. "/configs/" .. name .. ".cfg"
	if isfile and isfile(path) and delfile then
		pcall(delfile, path)
		if library:get_autoload_config() == name then
			library:clear_autoload_config()
		end
		library:config_list_update()
		library:notification({ text = "Config '" .. name .. "' deleted!" })
	end
end

function library:get_autoload_config()
	local path = library.directory .. "/autoload.txt"
	if isfile and isfile(path) and readfile then
		local ok, content = pcall(readfile, path)
		if ok and content then
			content = content:gsub("^%s*(.-)%s*$", "%1")
			if content ~= "" and content:lower() ~= "none" then
				return content
			end
		end
	end
	return nil
end

function library:set_autoload_config(name)
	if not name or name == "" then return end
	local dir = library.directory
	if isfolder and not isfolder(dir) then
		pcall(makefolder, dir)
	end
	local path = dir .. "/autoload.txt"
	if writefile then
		pcall(writefile, path, name)
		library:notification({ text = "⚡ Autoload set to: '" .. name .. "'" })
	end
end

function library:clear_autoload_config()
	local path = library.directory .. "/autoload.txt"
	if isfile and isfile(path) and delfile then
		pcall(delfile, path)
	end
	if writefile then
		pcall(writefile, path, "")
	end
	for _, old_path in ipairs({"inactivity/autoload.txt", "NVL/autoload.txt"}) do
		if isfile and isfile(old_path) and delfile then
			pcall(delfile, old_path)
		elseif writefile then
			pcall(writefile, old_path, "")
		end
	end
	library:notification({ text = "Cleared Autoload config" })
end

function library:round(number, float)
	local multiplier = 1 / (float or 1)
	return math.floor(number * multiplier + 0.5) / multiplier
end

function library:apply_theme(instance, theme, property)
	table.insert(themes.utility[theme][property], instance)
end

function library:update_theme(theme, color)
	for _, property in next, themes.utility[theme] do
		for m, object in next, property do
			if object[_] == themes.preset[theme] or object.ClassName == "UIGradient" then
				object[_] = color
			end
		end
	end

	themes.preset[theme] = color
end

library.ui_modes = {
	["Neverlose Classic"] = {
		accent = rgb(0, 150, 255),
		glow = rgb(0, 150, 255),
		inline = rgb(45, 55, 75),
		outline = rgb(24, 28, 38),
	},
	["Skeet / Gamesense"] = {
		accent = rgb(168, 255, 60),
		glow = rgb(168, 255, 60),
		inline = rgb(45, 65, 45),
		outline = rgb(18, 26, 18),
	},
	["Fatality.win"] = {
		accent = rgb(235, 45, 125),
		glow = rgb(235, 45, 125),
		inline = rgb(70, 40, 60),
		outline = rgb(35, 20, 30),
	},
	["Aimware V5"] = {
		accent = rgb(255, 110, 20),
		glow = rgb(255, 110, 20),
		inline = rgb(75, 48, 32),
		outline = rgb(38, 24, 16),
	},
	["Onetap V4"] = {
		accent = rgb(255, 140, 0),
		glow = rgb(255, 140, 0),
		inline = rgb(75, 55, 30),
		outline = rgb(38, 28, 15),
	},
	["Primordial.dev"] = {
		accent = rgb(80, 180, 255),
		glow = rgb(80, 180, 255),
		inline = rgb(40, 60, 80),
		outline = rgb(20, 30, 42),
	},
	["Pandora.gg"] = {
		accent = rgb(30, 220, 200),
		glow = rgb(30, 220, 200),
		inline = rgb(35, 70, 68),
		outline = rgb(18, 36, 35),
	},
	["Nemesis"] = {
		accent = rgb(220, 20, 60),
		glow = rgb(220, 20, 60),
		inline = rgb(68, 28, 36),
		outline = rgb(34, 14, 18),
	},
	["Monolith"] = {
		accent = rgb(140, 70, 255),
		glow = rgb(140, 70, 255),
		inline = rgb(55, 40, 75),
		outline = rgb(28, 20, 38),
	},
	["Evawa / Weave"] = {
		accent = rgb(255, 90, 95),
		glow = rgb(255, 90, 95),
		inline = rgb(75, 45, 48),
		outline = rgb(38, 22, 24),
	},
	["Midnight Purple"] = {
		accent = rgb(155, 89, 255),
		glow = rgb(155, 89, 255),
		inline = rgb(60, 45, 75),
		outline = rgb(30, 24, 38),
	},
	["Blood Moon"] = {
		accent = rgb(255, 65, 85),
		glow = rgb(255, 65, 85),
		inline = rgb(75, 45, 50),
		outline = rgb(38, 24, 26),
	},
	["Emerald Cyber"] = {
		accent = rgb(46, 230, 138),
		glow = rgb(46, 230, 138),
		inline = rgb(40, 65, 55),
		outline = rgb(22, 35, 30),
	},
	["Sunset Mirage"] = {
		accent = rgb(255, 140, 50),
		glow = rgb(255, 140, 50),
		inline = rgb(75, 55, 40),
		outline = rgb(38, 30, 22),
	},
	["Monochrome Frost"] = {
		accent = rgb(235, 245, 255),
		glow = rgb(180, 210, 255),
		inline = rgb(50, 52, 58),
		outline = rgb(28, 29, 33),
	},
	["Acid Toxic"] = {
		accent = rgb(220, 255, 30),
		glow = rgb(220, 255, 30),
		inline = rgb(65, 75, 30),
		outline = rgb(32, 38, 15),
	},
	["Abyss Sapphire"] = {
		accent = rgb(30, 100, 255),
		glow = rgb(30, 100, 255),
		inline = rgb(35, 48, 75),
		outline = rgb(18, 24, 38),
	},
	["Nixware Indigo"] = {
		accent = rgb(95, 75, 240),
		glow = rgb(95, 75, 240),
		inline = rgb(45, 40, 75),
		outline = rgb(24, 20, 40),
	},
	["Legendware Crimson"] = {
		accent = rgb(230, 30, 45),
		glow = rgb(230, 30, 45),
		inline = rgb(70, 25, 30),
		outline = rgb(35, 12, 16),
	},
	["Rifk7 Poison"] = {
		accent = rgb(175, 255, 30),
		glow = rgb(175, 255, 30),
		inline = rgb(55, 75, 28),
		outline = rgb(28, 38, 14),
	},
	["Interverse Amethyst"] = {
		accent = rgb(180, 80, 255),
		glow = rgb(180, 80, 255),
		inline = rgb(60, 42, 78),
		outline = rgb(30, 22, 40),
	},
	["Midnight Synthwave"] = {
		accent = rgb(255, 0, 153),
		glow = rgb(0, 255, 204),
		inline = rgb(65, 25, 55),
		outline = rgb(34, 12, 28),
	},
	["Cyberpunk 2077"] = {
		accent = rgb(255, 34, 0),
		glow = rgb(255, 204, 0),
		inline = rgb(75, 30, 20),
		outline = rgb(40, 15, 10),
	},
	["Matrix Overdrive"] = {
		accent = rgb(0, 255, 65),
		glow = rgb(0, 255, 65),
		inline = rgb(25, 65, 32),
		outline = rgb(12, 34, 16),
	},
	["Vaporwave 1984"] = {
		accent = rgb(255, 106, 213),
		glow = rgb(148, 208, 255),
		inline = rgb(65, 40, 60),
		outline = rgb(35, 20, 32),
	},
	["Sakura Blossom"] = {
		accent = rgb(255, 165, 185),
		glow = rgb(255, 200, 215),
		inline = rgb(70, 50, 56),
		outline = rgb(38, 26, 30),
	},
	["Golden Sovereign"] = {
		accent = rgb(255, 215, 0),
		glow = rgb(255, 215, 0),
		inline = rgb(75, 65, 25),
		outline = rgb(40, 34, 12),
	},
	["Hellfire Diablo"] = {
		accent = rgb(255, 70, 0),
		glow = rgb(255, 150, 0),
		inline = rgb(75, 35, 18),
		outline = rgb(38, 18, 10),
	},
	["Ghost In Shell"] = {
		accent = rgb(210, 235, 255),
		glow = rgb(0, 220, 255),
		inline = rgb(45, 55, 65),
		outline = rgb(24, 28, 35),
	},
	["Eldritch Void"] = {
		accent = rgb(135, 30, 195),
		glow = rgb(135, 30, 195),
		inline = rgb(50, 25, 65),
		outline = rgb(26, 12, 35),
	},
	["Aurora Borealis"] = {
		accent = rgb(0, 255, 180),
		glow = rgb(120, 80, 255),
		inline = rgb(30, 65, 55),
		outline = rgb(15, 35, 30),
	},
	["Neon Genesis"] = {
		accent = rgb(150, 0, 220),
		glow = rgb(0, 255, 100),
		inline = rgb(55, 25, 70),
		outline = rgb(28, 12, 38),
	},
	["Hyperpop Glitch"] = {
		accent = rgb(255, 20, 147),
		glow = rgb(0, 240, 255),
		inline = rgb(70, 25, 55),
		outline = rgb(38, 12, 30),
	},
	["Bismuth Iridescent"] = {
		accent = rgb(255, 105, 225),
		glow = rgb(80, 230, 255),
		inline = rgb(65, 45, 68),
		outline = rgb(35, 24, 36),
	},
	["Obsidian Phantom"] = {
		accent = rgb(255, 35, 35),
		glow = rgb(255, 35, 35),
		inline = rgb(45, 25, 25),
		outline = rgb(24, 12, 12),
	},
	["Bloomcore Gloom"] = {
		accent = rgb(0, 235, 175),
		glow = rgb(0, 235, 175),
		inline = rgb(20, 55, 45),
		outline = rgb(10, 28, 22),
	},
	["Last Summer"] = {
		accent = rgb(215, 235, 75),
		glow = rgb(255, 215, 90),
		inline = rgb(65, 70, 30),
		outline = rgb(32, 35, 15),
	},
	["Just A Memory"] = {
		accent = rgb(110, 130, 255),
		glow = rgb(140, 110, 255),
		inline = rgb(45, 42, 80),
		outline = rgb(22, 20, 42),
	},
	["Hearing Her Voice"] = {
		accent = rgb(165, 195, 245),
		glow = rgb(130, 175, 240),
		inline = rgb(38, 48, 68),
		outline = rgb(18, 24, 35),
	},
	["Why Did You Leave"] = {
		accent = rgb(135, 175, 225),
		glow = rgb(100, 145, 210),
		inline = rgb(28, 42, 65),
		outline = rgb(14, 20, 32),
	},
	["One Last Stop"] = {
		accent = rgb(225, 175, 195),
		glow = rgb(220, 150, 170),
		inline = rgb(48, 42, 50),
		outline = rgb(24, 20, 26),
	},
	["You Were The Only Light I Needed"] = {
		accent = rgb(255, 145, 60),
		glow = rgb(195, 95, 255),
		inline = rgb(60, 32, 75),
		outline = rgb(30, 16, 42),
	},
	["Dying For Someone"] = {
		accent = rgb(255, 87, 34),
		glow = rgb(175, 75, 140),
		inline = rgb(42, 30, 48),
		outline = rgb(22, 14, 26),
	},
	["Dying for someone who moved on."] = {
		accent = rgb(255, 87, 34),
		glow = rgb(175, 75, 140),
		inline = rgb(42, 30, 48),
		outline = rgb(22, 14, 26),
	},
	["Wish We Could Watch Again"] = {
		accent = rgb(240, 65, 105),
		glow = rgb(255, 205, 80),
		inline = rgb(55, 18, 38),
		outline = rgb(28, 8, 18),
	},
	["I wish we could watch them again..."] = {
		accent = rgb(240, 65, 105),
		glow = rgb(255, 205, 80),
		inline = rgb(55, 18, 38),
		outline = rgb(28, 8, 18),
	},
	["Maybe This Sunset"] = {
		accent = rgb(255, 140, 0),
		glow = rgb(255, 215, 60),
		inline = rgb(60, 38, 15),
		outline = rgb(30, 18, 6),
	},
	["maybe this sunset was all we needed..."] = {
		accent = rgb(255, 140, 0),
		glow = rgb(255, 215, 60),
		inline = rgb(60, 38, 15),
		outline = rgb(30, 18, 6),
	},
}

-- Pre-cached colors for maximum FPS and zero garbage collection pressure
local c_neon_pink = rgb(255, 0, 128)
local c_neon_cyan = rgb(0, 240, 255)
local c_blood_red = rgb(255, 20, 50)
local c_dark_red = rgb(90, 0, 15)
local c_matrix_green = rgb(0, 255, 100)
local c_toxic_yellow = rgb(180, 255, 0)
local c_sunset_orange = rgb(255, 120, 40)
local c_sunset_purple = rgb(200, 40, 160)
local c_ice_cyan = rgb(0, 200, 255)
local c_ice_white = rgb(240, 250, 255)
local c_nebula_purple = rgb(160, 50, 255)
local c_nebula_pink = rgb(255, 60, 180)
local c_gold_bright = rgb(255, 215, 0)
local c_gold_amber = rgb(255, 130, 0)
local c_mono_white = rgb(235, 240, 245)
local c_mono_gray = rgb(80, 85, 95)
local c_synth_magenta = rgb(255, 0, 153)
local c_synth_mint = rgb(0, 255, 204)
local c_aurora_emerald = rgb(0, 255, 180)
local c_aurora_indigo = rgb(120, 80, 255)
local c_sakura_pink = rgb(255, 183, 197)
local c_sakura_white = rgb(255, 240, 245)
local c_hell_orange = rgb(255, 80, 0)
local c_hell_yellow = rgb(255, 220, 0)
local c_eldritch_purple = rgb(180, 50, 255)
local c_eldritch_crimson = rgb(120, 10, 80)
local c_ocean_deep = rgb(10, 80, 255)
local c_ocean_aqua = rgb(0, 220, 200)
local c_lime_green = rgb(140, 255, 0)
local c_lime_neon = rgb(0, 255, 120)
local c_pearl_rose = rgb(255, 190, 220)
local c_pearl_ice = rgb(180, 240, 255)
local c_bloom_teal = rgb(0, 245, 185)
local c_gloom_pine = rgb(15, 60, 50)
local c_summer_sun = rgb(255, 225, 95)
local c_summer_leaf = rgb(125, 215, 60)
local c_memory_blue = rgb(90, 125, 255)
local c_memory_violet = rgb(175, 95, 240)
local c_voice_moon = rgb(220, 235, 255)
local c_voice_navy = rgb(70, 110, 180)
local c_leave_navy = rgb(55, 75, 125)
local c_leave_cyan = rgb(150, 195, 235)
local c_stop_ash = rgb(70, 75, 88)
local c_stop_rose = rgb(225, 175, 195)
local c_lamp_warm = rgb(255, 225, 175)
local c_lamp_amber = rgb(215, 185, 140)
local c_signal_red = rgb(245, 70, 85)
local c_signal_dark = rgb(170, 40, 50)
local c_scarf_rose = rgb(235, 185, 205)
local c_scarf_ash = rgb(160, 165, 175)
local c_rail_silver = rgb(190, 195, 205)
local c_rail_charcoal = rgb(80, 85, 100)
local c_cold_lamp = rgb(245, 240, 225)
local c_cold_ice = rgb(165, 205, 245)
local c_whisper_dark = rgb(40, 55, 95)
local c_whisper_blue = rgb(120, 145, 190)
local c_breath_white = rgb(225, 242, 255)
local c_breath_cyan = rgb(135, 185, 235)
local c_shadow_navy = rgb(55, 70, 105)
local c_shadow_indigo = rgb(95, 120, 165)
local c_onlylight_violet = rgb(185, 95, 255)
local c_onlylight_amber = rgb(255, 145, 60)
local c_onlylight_sun = rgb(255, 220, 110)
local c_camcorder_pink = rgb(255, 155, 195)
local c_dusk_indigo = rgb(75, 45, 115)

-- Vibe 1: Dying for someone
local c_smoke_ember = rgb(255, 87, 34)
local c_smoke_ash = rgb(140, 130, 138)
local c_dusk_mauve = rgb(125, 75, 120)
local c_midnight_ash = rgb(35, 25, 40)

-- Vibe 2: Wish we could watch them again
local c_firework_ruby = rgb(240, 65, 105)
local c_firework_gold = rgb(255, 215, 70)
local c_scarf_crimson = rgb(215, 35, 65)
local c_festival_night = rgb(50, 15, 65)

-- Vibe 3: Maybe this sunset was all we needed
local c_honey_gold = rgb(255, 195, 45)
local c_sunset_radiance = rgb(251, 133, 0)
local c_sorbet_peach = rgb(255, 175, 155)
local c_meadow_green = rgb(120, 175, 115)

local function lerp_color(c1, c2, t)
	return Color3.new(
		c1.R + (c2.R - c1.R) * t,
		c1.G + (c2.G - c1.G) * t,
		c1.B + (c2.B - c1.B) * t
	)
end

function library.get_color_mode_color(mode_name, user_color, speed, offset)
	speed = speed or 1
	offset = offset or 0
	local t = tick() * speed + offset

	if mode_name == "Theme Accent" then
		return themes.preset.accent
	elseif mode_name == "Custom Color" then
		return user_color or themes.preset.accent
	elseif mode_name == "RGB Spectrum" then
		return Color3.fromHSV((t * 0.2) % 1, 0.85, 1)
	elseif mode_name == "Cyberpunk Neon" then
		local factor = (math.sin(t * 2.5) + 1) * 0.5
		return lerp_color(c_neon_pink, c_neon_cyan, factor)
	elseif mode_name == "Blood Crimson" then
		local factor = (math.sin(t * 2) + 1) * 0.5
		return lerp_color(c_blood_red, c_dark_red, factor)
	elseif mode_name == "Toxic Matrix" then
		local factor = (math.sin(t * 2.5) + 1) * 0.5
		return lerp_color(c_matrix_green, c_toxic_yellow, factor)
	elseif mode_name == "Sunset Horizon" then
		local factor = (math.sin(t * 2) + 1) * 0.5
		return lerp_color(c_sunset_orange, c_sunset_purple, factor)
	elseif mode_name == "Ice & Frost" then
		local factor = (math.sin(t * 2) + 1) * 0.5
		return lerp_color(c_ice_cyan, c_ice_white, factor)
	elseif mode_name == "Galaxy Nebula" then
		local factor = (math.sin(t * 2) + 1) * 0.5
		return lerp_color(c_nebula_purple, c_nebula_pink, factor)
	elseif mode_name == "Royal Gold" then
		local factor = (math.sin(t * 2) + 1) * 0.5
		return lerp_color(c_gold_bright, c_gold_amber, factor)
	elseif mode_name == "Pastel Dream" then
		return Color3.fromHSV((t * 0.15) % 1, 0.45, 1)
	elseif mode_name == "Monochrome" then
		local factor = (math.sin(t * 2) + 1) * 0.5
		return lerp_color(c_mono_white, c_mono_gray, factor)
	elseif mode_name == "Synthwave 80s" then
		local factor = (math.sin(t * 2.5) + 1) * 0.5
		return lerp_color(c_synth_magenta, c_synth_mint, factor)
	elseif mode_name == "Aurora Lights" then
		local factor = (math.sin(t * 1.8) + 1) * 0.5
		return lerp_color(c_aurora_emerald, c_aurora_indigo, factor)
	elseif mode_name == "Sakura Petals" then
		local factor = (math.sin(t * 1.5) + 1) * 0.5
		return lerp_color(c_sakura_pink, c_sakura_white, factor)
	elseif mode_name == "Hellfire Blaze" then
		local factor = (math.sin(t * 3) + 1) * 0.5
		return lerp_color(c_hell_orange, c_hell_yellow, factor)
	elseif mode_name == "Eldritch Amethyst" then
		local factor = (math.sin(t * 2.2) + 1) * 0.5
		return lerp_color(c_eldritch_purple, c_eldritch_crimson, factor)
	elseif mode_name == "Deep Ocean" then
		local factor = (math.sin(t * 2) + 1) * 0.5
		return lerp_color(c_ocean_deep, c_ocean_aqua, factor)
	elseif mode_name == "Electric Lime" then
		local factor = (math.sin(t * 2.5) + 1) * 0.5
		return lerp_color(c_lime_green, c_lime_neon, factor)
	elseif mode_name == "Iridescent Pearl" then
		local factor = (math.sin(t * 1.6) + 1) * 0.5
		return lerp_color(c_pearl_rose, c_pearl_ice, factor)
	elseif mode_name == "Bloomcore Teal" then
		local factor = (math.sin(t * 1.8) + 1) * 0.5
		return lerp_color(c_bloom_teal, c_gloom_pine, factor)
	elseif mode_name == "Summer Nostalgia" then
		local factor = (math.sin(t * 1.6) + 1) * 0.5
		return lerp_color(c_summer_sun, c_summer_leaf, factor)
	elseif mode_name == "Twilight Memory" then
		local factor = (math.sin(t * 1.7) + 1) * 0.5
		return lerp_color(c_memory_blue, c_memory_violet, factor)
	elseif mode_name == "Moonlit Meadow" then
		local factor = (math.sin(t * 1.5) + 1) * 0.5
		return lerp_color(c_voice_moon, c_voice_navy, factor)
	elseif mode_name == "Tearful Midnight" then
		local factor = (math.sin(t * 1.6) + 1) * 0.5
		return lerp_color(c_leave_navy, c_leave_cyan, factor)
	elseif mode_name == "Last Train Platform" then
		local factor = (math.sin(t * 1.4) + 1) * 0.5
		return lerp_color(c_stop_ash, c_stop_rose, factor)
	elseif mode_name == "Cold Streetlamp" then
		local factor = (math.sin(t * 1.5) + 1) * 0.5
		return lerp_color(c_cold_lamp, c_cold_ice, factor)
	elseif mode_name == "Midnight Indigo" then
		local factor = (math.sin(t * 1.4) + 1) * 0.5
		return lerp_color(c_whisper_dark, c_whisper_blue, factor)
	elseif mode_name == "Winter Breath Ice" then
		local factor = (math.sin(t * 1.8) + 1) * 0.5
		return lerp_color(c_breath_white, c_breath_cyan, factor)
	elseif mode_name == "Distant Shadow" then
		local factor = (math.sin(t * 1.3) + 1) * 0.5
		return lerp_color(c_shadow_navy, c_shadow_indigo, factor)
	elseif mode_name == "Melancholic Scarf Rose" then
		local factor = (math.sin(t * 1.4) + 1) * 0.5
		return lerp_color(c_scarf_rose, c_scarf_ash, factor)
	elseif mode_name == "Station Amber Glow" then
		local factor = (math.sin(t * 1.3) + 1) * 0.5
		return lerp_color(c_lamp_warm, c_lamp_amber, factor)
	elseif mode_name == "Signal Amber Red" then
		local factor = (math.sin(t * 2.2) + 1) * 0.5
		return lerp_color(c_signal_red, c_signal_dark, factor)
	elseif mode_name == "Platform Ash Charcoal" then
		local factor = (math.sin(t * 1.2) + 1) * 0.5
		return lerp_color(c_rail_silver, c_rail_charcoal, factor)
	elseif mode_name == "Only Light Twilight" then
		local factor = (math.sin(t * 1.5) + 1) * 0.5
		return lerp_color(c_onlylight_violet, c_onlylight_amber, factor)
	elseif mode_name == "Golden Amber Sunset" then
		local factor = (math.sin(t * 1.6) + 1) * 0.5
		return lerp_color(c_onlylight_amber, c_onlylight_sun, factor)
	elseif mode_name == "Camcorder Twilight Pink" then
		local factor = (math.sin(t * 1.4) + 1) * 0.5
		return lerp_color(c_camcorder_pink, c_dusk_indigo, factor)
	elseif mode_name == "Dying Cigarette Ember" then
		local factor = (math.sin(t * 1.8) + 1) * 0.5
		return lerp_color(c_smoke_ember, c_smoke_ash, factor)
	elseif mode_name == "Muted Twilight Dusk" then
		local factor = (math.sin(t * 1.4) + 1) * 0.5
		return lerp_color(c_dusk_mauve, c_midnight_ash, factor)
	elseif mode_name == "Fireworks Burst Gold" then
		local factor = (math.sin(t * 2.2) + 1) * 0.5
		return lerp_color(c_firework_gold, c_firework_ruby, factor)
	elseif mode_name == "Wool Scarf Crimson" then
		local factor = (math.sin(t * 1.5) + 1) * 0.5
		return lerp_color(c_scarf_crimson, c_festival_night, factor)
	elseif mode_name == "Honey Sunset Gold" then
		local factor = (math.sin(t * 1.6) + 1) * 0.5
		return lerp_color(c_honey_gold, c_sunset_radiance, factor)
	elseif mode_name == "Meadow Sorbet Peach" then
		local factor = (math.sin(t * 1.4) + 1) * 0.5
		return lerp_color(c_sorbet_peach, c_meadow_green, factor)
	end

	return themes.preset.accent
end

function library:set_ui_mode(mode_name)
	local preset = library.ui_modes[mode_name]
	if not preset then return end
	if preset.accent then library:update_theme("accent", preset.accent) end
	if preset.glow then library:update_theme("glow", preset.glow) end
	if preset.inline then library:update_theme("inline", preset.inline) end
	if preset.outline then library:update_theme("outline", preset.outline) end
	if library.config_flags and library.config_flags["ui_accent_color"] then
		pcall(function()
			library.config_flags["ui_accent_color"](preset.accent)
		end)
	end
	library:notification({ text = "⚡ UI Mode: " .. mode_name, time = 3 })
end

function library:connection(signal, callback)
	local connection = signal:Connect(callback)

	table.insert(library.connections, connection)

	return connection
end

function library:create(instance, options)
	if setthreadidentity then pcall(setthreadidentity, 8) end
	local ins = Instance.new(instance)
	local parent = nil

	for prop, value in next, options do
		if prop == "Parent" then
			parent = value
		else
			ins[prop] = value
		end
	end

	if parent then
		local ok = pcall(function() ins.Parent = parent end)
		if not ok then
			if setthreadidentity then pcall(setthreadidentity, 8) end
			pcall(function() ins.Parent = parent end)
		end
	end

	return ins
end
--

library.gui = library:create("ScreenGui", {
	Enabled = true,
	Parent = coregui,
	Name = "",
	DisplayOrder = 2,
	ZIndexBehavior = 1,
})

-- Centralized input manager (Replaces 70+ individual InputChanged listeners)
library.active_slider = nil
library.active_colorpicker_drag = nil
library.animated_colorpickers = {}

uis.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if library and library.active_slider then
			local slider_cfg = library.active_slider
			local slider = slider_cfg.slider_instance
			if slider then
				local size_x = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
				local value = ((slider_cfg.max - slider_cfg.min) * size_x) + slider_cfg.min
				slider_cfg.set(value)
			end
		end
	end
end)

uis.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if library.active_slider then
			library.active_slider.dragging = false
			library.active_slider = nil
		end
	end
end)

-- library functions
function library:window(properties)
	local cfg = {
		name = properties.Name or properties.name or properties.Title or properties.title or "sp4m.wtf",
		size = properties.Size or properties.size or dim2(0, 500, 0, 650),
	}

	local animated_text = library:animation(cfg.name .. " | private")

	-- watermark
	local __holder = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 20),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		Visible = false,
	})

	local inline1 = library:create("Frame", {
		Parent = __holder,
		Name = "",
		Active = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, ((#animated_text / 2) * 5) + 13, 0, 40),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})
	library:make_smooth_draggable(__holder, inline1)

	local accent_line = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local watermark_line_gradient = library:create("UIGradient", {
		Parent = accent_line,
		Name = "LineGradient",
		Enabled = false,
	})
	cfg.watermark_accent_line = accent_line
	cfg.watermark_line_gradient = watermark_line_gradient

	local depth = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local inline2 = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local main = library:create("Frame", {
		Parent = inline2,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(57, 57, 57),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local tab_inline = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 6, 0, 6),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -12, 1, -12),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local tabs = library:create("Frame", {
		Parent = tab_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local name = library:create("TextLabel", {
		Parent = tabs,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name .. " | private",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(0, 0, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})
	cfg.watermark_label = name

	local TEXT_ANIMATION_GRADIENT = library:create("UIGradient", {
		Parent = name,
		Name = "",
		Enabled = false,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.01, themes.preset.accent),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		}),
	})
	cfg.watermark_gradient = TEXT_ANIMATION_GRADIENT

	local UIPadding = library:create("UIPadding", {
		Parent = tabs,
		Name = "",
		PaddingRight = UDim.new(0, 21),
	})

	local glow = library:create("ImageLabel", {
		Parent = accent_line,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 0, 42),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")
	cfg.watermark_glow = glow
	--

	-- window
	local inline1 = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		Active = true,
		Position = UDim2.new(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		ZIndex = 2,
		Size = cfg.size,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		Visible = false,
	})
	table.insert(library.main_frame, inline1)
	local WINDOW_PATH = inline1
	library:make_resizable(inline1)
	library:make_smooth_draggable(inline1, inline1)

	local inline2 = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local main = library:create("Frame", {
		Parent = inline2,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(57, 57, 57),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local tab_buttons = library:create("Frame", {
		Parent = main,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 4),
		Size = UDim2.new(1, -32, 0, 0),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	cfg["tab_holder"] = tab_buttons

	local list = library:create("UIListLayout", {
		Parent = tab_buttons,
		Name = "",
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local tab_inline = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 15, 0, 33),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -30, 1, -48),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local tabs = library:create("Frame", {
		Parent = tab_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	cfg["tab_instance_holder"] = tabs

	local accent_line = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local title_line_gradient = library:create("UIGradient", {
		Parent = accent_line,
		Name = "LineGradient",
		Enabled = false,
	})
	cfg.title_accent_line = accent_line
	cfg.title_line_gradient = title_line_gradient

	local name = library:create("TextLabel", {
		Parent = inline1,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})
	cfg.title_label = name

	local title_gradient = library:create("UIGradient", {
		Parent = name,
		Name = "",
		Enabled = false,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 170, 170)),
			ColorSequenceKeypoint.new(0.5, themes.preset.accent),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 170, 170)),
		}),
	})
	cfg.title_gradient = title_gradient

	local glow = library:create("ImageLabel", {
		Parent = inline1,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 0, 42),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})
	library:apply_theme(glow, "accent", "ImageColor3")
	cfg.title_glow = glow

	local depth = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local holder = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 20, 0, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	task.spawn(function()
		while true do
			local anim_speed = flags["color_picker_anim_speed"] or 1
			library.sin = math.abs(math.sin(tick() * anim_speed))

			if next(library.animated_colorpickers) ~= nil then
				for _, anim_fn in pairs(library.animated_colorpickers) do
					anim_fn()
				end
			end
			task.wait()
		end
	end)
	--

	-- esp preview
	local esp_preview = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		Visible = false,
		Active = true,
		Position = UDim2.new(
			0,
			inline1.AbsolutePosition.X + inline1.AbsoluteSize.X + 8,
			0,
			inline1.AbsolutePosition.Y + 1
		),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(0, 328, 0, 376),
		BackgroundColor3 = Color3.fromRGB(56, 56, 56),
	})
	library:make_resizable(esp_preview)
	library:make_smooth_draggable(esp_preview, esp_preview)

	local name = library:create("TextLabel", {
		Parent = esp_preview,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "esp preview",
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = name,
		Name = "",
	})

	local main = library:create("Frame", {
		Parent = esp_preview,
		Name = "",
		Position = UDim2.new(0, 4, 0, 4),
		BorderColor3 = Color3.fromRGB(26, 26, 26),
		Size = UDim2.new(1, -8, 1, -8),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	library:create("UIStroke", {
		Parent = main,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local tabs = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 8, 0, 8),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(1, -16, 1, -16),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	library:create("UIStroke", {
		Parent = tabs,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local hitpart = library:create("Frame", {
		Parent = tabs,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 2, 0, 20),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local head = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, -25, 0, 16),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 50, 0, 44),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local torso = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, -42, 0, 64),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 84, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local l_arm = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, -86, 0, 64),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 40, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local r_arm = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, 46, 0, 64),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 40, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local r_leg = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, 2, 0, 158),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 40, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local l_leg = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, -42, 0, 158),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 40, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local hrp = library:create("Frame", {
		Parent = hrp_out,
		Name = "",
		Position = UDim2.new(0, 4, 0, 4),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -8, 1, -8),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local glow_patterns = {}

	for _, v in next, hitpart:GetChildren() do
		local glow = library:create("ImageLabel", {
			Parent = v,
			Name = "",
			Visible = false,
			ImageColor3 = themes.preset.accent,
			ScaleType = Enum.ScaleType.Slice,
			ImageTransparency = 0.8999999761581421,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Image = "http://www.roblox.com/asset/?id=18245826428",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, -20, 0, -20),
			Size = UDim2.new(1, 40, 1, 40),
			ZIndex = 2,
			BorderSizePixel = 0,
			SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
		})

		library:apply_theme(glow, "accent", "ImageColor3")

		table.insert(glow_patterns, glow)
	end

	function cfg.preview_chams(bool)
		for _, glow in next, glow_patterns do
			glow.Visible = bool
		end

		for _, part in next, hitpart:GetChildren() do
			part.BackgroundColor3 = bool and themes.preset.accent or Color3.fromRGB(38, 38, 38)
		end
	end

	local player = library:create("Frame", {
		Parent = tabs,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 43, 0, 28),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -86, 1, -106),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local line_holder = library:create("Frame", {
		Parent = player,
		Name = "",
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local box_outline = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -1, 0, -1),
		ZIndex = 50,
		Size = UDim2.new(1, 2, 1, 2),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local BoxLine2 = library:create("UIStroke", {
		Parent = box_outline,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local box_color = library:create("UIStroke", {
		Parent = line_holder,
		Name = "",
		Color = Color3.fromRGB(255, 255, 255),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local corner_box = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		Visible = false,
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local top_left = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0, 1, 0.30000001192092896, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local top_right = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0, 1, 0.30000001192092896, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local bottom_left = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0.4000000059604645, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local bottom_right = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -1, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0.4000000059604645, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local bottom_left2 = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0, 1, 0.30000001192092896, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local bottom_right2 = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0, 1, 0.30000001192092896, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local top_left2 = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0.4000000059604645, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local top_right2 = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -1, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0.4000000059604645, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	function cfg.preview_corner_boxes(bool)
		corner_box.Visible = bool == "Corner" and true or false
		BoxLine2.Enabled = bool == "Corner" and false or true
		box_outline.Visible = bool == "Corner" and false or true
		box_color.Enabled = bool == "Corner" and false or true
	end

	function cfg.preview_bounding_box(bool)
		BoxLine2.Enabled = bool
		box_outline.Visible = bool
		box_color.Enabled = bool
	end

	local bottom_holder = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -1, 1, 3),
		Size = UDim2.new(1, 2, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = bottom_holder,
		Name = "",
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = bottom_holder,
		Name = "",
		PaddingTop = UDim.new(0, 1),
	})

	local bar_holder = library:create("Frame", {
		Parent = bottom_holder,
		Name = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 4),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local reload_bar = library:create("Frame", {
		Parent = bar_holder,
		Name = "",
		Size = UDim2.new(1, 0, 0, 4),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	function cfg.preview_reload_bar(bool)
		bar_holder.Visible = bool
	end

	local reload_slider = library:create("Frame", {
		Parent = reload_bar,
		Name = "",
		Size = UDim2.new(0.5, -2, 0, 2),
		Position = UDim2.new(0, 1, 0, 1),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(28, 145, 255),
	})

	local gradient = library:create("UIGradient", {
		Parent = reload_slider,
		Name = "",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 238)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 238)),
		}),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = distance,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local weapon = library:create("TextLabel", {
		Parent = bottom_holder,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "double barrel",
		TextStrokeTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.031031031161546707, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 50,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 4),
	})

	function cfg.preview_weapon(bool)
		weapon.Visible = bool
	end

	local UIStroke = library:create("UIStroke", {
		Parent = weapon,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local UIStroke = library:create("UIStroke", {
		Parent = distance,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local image_holder = library:create("Frame", {
		Parent = bottom_holder,
		Name = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	function cfg.preview_icons(bool)
		image_holder.Visible = bool
	end

	local ImageLabel = library:create("ImageLabel", {
		Parent = image_holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Image = "rbxassetid://130516018594923",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(0, 64, 0, 27),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local armor = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		Position = UDim2.new(0, -14, 0, -2),
		Size = UDim2.new(0, 4, 1, 4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	function cfg.preview_armor(bool)
		armor.Visible = bool
	end

	local armor_slider = library:create("Frame", {
		Parent = armor,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0.5, 0, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 13, 255),
	})

	local armor_gradient = library:create("UIGradient", {
		Parent = armor_slider,
		Name = "",
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 242, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 17, 255)),
		}),
		Enabled = false,
	})

	local armor_text = library:create("TextLabel", {
		Parent = armor_slider,
		Name = "",
		ZIndex = 99,
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(0, 13, 255),
		Text = "100",
		Position = UDim2.new(0, -2, 0.75, -2),
		TextStrokeTransparency = 0,
		AnchorPoint = Vector2.new(1, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Active = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(26, 255, 0),
	})

	library:create("UIStroke", {
		Parent = armor_text,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local health = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		Position = UDim2.new(0, -8, 0, -2),
		Size = UDim2.new(0, 4, 1, 4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	function cfg.preview_health(bool)
		health.Visible = bool
	end

	local health_slider = library:create("Frame", {
		Parent = health,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0.5, 0, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 255, 42),
	})

	local health_text = library:create("TextLabel", {
		Parent = health_slider,
		Name = "",
		Visible = false,
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(0, 255, 0),
		Text = "100",
		ZIndex = 99,
		TextStrokeTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, -4, 0.5, -2),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Active = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(26, 255, 0),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = health_text,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local box_inline = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 1, 0, 1),
		ZIndex = 50,
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local BoxLine3 = library:create("UIStroke", {
		Parent = box_inline,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local gradient = library:create("UIGradient", {
		Parent = line_holder,
		Name = "",
		Rotation = -180,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0.5),
		}),
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
		}),
	})

	function cfg.preview_filler(bool)
		line_holder.BackgroundTransparency = bool and 0 or 1
		gradient.Enabled = bool
	end

	local top_holder = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -2, 0, -4),
		Size = UDim2.new(1, 4, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	library:create("UIListLayout", {
		Parent = top_holder,
		Name = "",
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	library:create("UIPadding", {
		Parent = top_holder,
		Name = "",
		PaddingTop = UDim.new(0, 1),
	})

	local player_name = library:create("TextLabel", {
		Parent = top_holder,
		Name = "",
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "hello there",
		FontFace = library.font,
		AnchorPoint = Vector2.new(0, 1),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -2),
		BorderSizePixel = 0,
		ZIndex = 50,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 0),
	})

	function cfg.preview_names(bool)
		player_name.Visible = bool
	end

	local UIStroke = library:create("UIStroke", {
		Parent = player_name,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local accent_line = library:create("Frame", {
		Parent = esp_preview,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local depth = library:create("Frame", {
		Parent = esp_preview,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local glow = library:create("ImageLabel", {
		Parent = esp_preview,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 0, 42),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")
	--

	-- playerlist
	local selected_button
	local selected_player
	local player_buttons = {}

	function library.get_priority(player)
		return player_buttons[player.Name].priority.Text
	end

	local playerlist = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		Active = true,
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, inline1.AbsolutePosition.X - 358 - 8, 0, inline1.AbsolutePosition.Y + 1),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(0, 358, 0, 328),
		BackgroundColor3 = Color3.fromRGB(56, 56, 56),
		Visible = false,
	})
	library:make_resizable(playerlist)
	library:make_smooth_draggable(playerlist, playerlist)

	table.insert(library.main_frame, playerlist)

	local name = library:create("TextLabel", {
		Parent = playerlist,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "playerlist",
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local playerlist_gradient = library:create("UIGradient", {
		Parent = name,
		Name = "",
		Enabled = false,
	})
	cfg.playerlist_label = name
	cfg.playerlist_gradient = playerlist_gradient
	cfg.playerlist_frame = playerlist

	local UIPadding = library:create("UIPadding", {
		Parent = name,
		Name = "",
	})

	local main = library:create("Frame", {
		Parent = playerlist,
		Name = "",
		Position = UDim2.new(0, 4, 0, 4),
		BorderColor3 = Color3.fromRGB(26, 26, 26),
		Size = UDim2.new(1, -8, 1, -8),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	library:create("UIStroke", {
		Parent = main,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local tabs = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 8, 0, 8),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(1, -16, 1, -16),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	library:create("UIStroke", {
		Parent = tabs,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local list = library:create("Frame", {
		Parent = tabs,
		Name = "",
		Position = UDim2.new(0, 14, 0, 14),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -28, 0.75, -28),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local inline = library:create("Frame", {
		Parent = list,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -2, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(57, 57, 57),
	})

	local background = library:create("Frame", {
		Parent = inline,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -2, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local UIGradient = library:create("UIGradient", {
		Parent = background,
		Name = "",
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(167, 167, 167)),
		}),
	})

	local contrast = library:create("Frame", {
		Parent = background,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local __ScrollingFrame = library:create("ScrollingFrame", {
		Parent = contrast,
		Name = "",
		ScrollBarImageColor3 = themes.preset.accent,
		MidImage = "rbxassetid://18406573371",
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		TopImage = "rbxassetid://18406573371",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1.0099999904632568,
		BottomImage = "rbxassetid://18406573371",
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})

	library:apply_theme(__ScrollingFrame, "accent", "ScrollBarImageColor3")

	local UIPadding = library:create("UIPadding", {
		Parent = __ScrollingFrame,
		Name = "",
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = __ScrollingFrame,
		Name = "",
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local info = library:create("Frame", {
		Parent = tabs,
		Name = "",
		Position = UDim2.new(0, 14, 0.75, -5),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -28, 0.30000001192092896, -23),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local inline = library:create("Frame", {
		Parent = info,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -2, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(57, 57, 57),
	})

	local background = library:create("Frame", {
		Parent = inline,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -2, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local UIGradient = library:create("UIGradient", {
		Parent = background,
		Name = "",
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(167, 167, 167)),
		}),
	})

	local contrast = library:create("Frame", {
		Parent = background,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local ScrollingFrame = library:create("ScrollingFrame", {
		Parent = contrast,
		Name = "",
		ScrollBarImageColor3 = Color3.fromRGB(155, 125, 175),
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		BackgroundTransparency = 1.0099999904632568,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = ScrollingFrame,
		Name = "",
		PaddingTop = UDim.new(0, 7),
		PaddingBottom = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 10),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = ScrollingFrame,
		Name = "",
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local display_name_label = library:create("TextLabel", {
		Parent = ScrollingFrame,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(180, 180, 180),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "Display Name: ...",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	library:create("UIStroke", {
		Parent = display_name_label,
		Name = "",
	})

	local name_label = library:create("TextLabel", {
		Parent = ScrollingFrame,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(180, 180, 180),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "Name: ...",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	library:create("UIStroke", {
		Parent = name_label,
		Name = "",
	})

	local priority_label = library:create("TextLabel", {
		Parent = ScrollingFrame,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(180, 180, 180),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "Priority: Friendly",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	library:create("UIStroke", {
		Parent = priority_label,
		Name = "",
	})

	local Frame = library:create("ScrollingFrame", {
		Parent = contrast,
		Name = "",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -5, 0, 4),
		Size = UDim2.new(0, 140, 1, -8),
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = themes.preset.accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local button_inline = library:create("Frame", {
		Parent = Frame,
		Name = "",
		Position = UDim2.new(0, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -6, 0, 14),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local button = library:create("TextButton", {
		Parent = button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "Neutral",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(1, -4, 1, -2),
		TextSize = 11,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	button.MouseButton1Click:Connect(function()
		player_buttons[selected_player.Name].priority.Text = "Neutral"
		player_buttons[selected_player.Name].priority.TextColor3 = rgb(180, 180, 180)
	end)

	local button_inline = library:create("Frame", {
		Parent = Frame,
		Name = "",
		Position = UDim2.new(0, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -6, 0, 14),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local button = library:create("TextButton", {
		Parent = button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "Friendly",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(1, -4, 1, -2),
		TextSize = 11,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	button.MouseButton1Click:Connect(function()
		if not selected_player or not player_buttons[selected_player.Name] then return end
		player_buttons[selected_player.Name].priority.Text = "Friendly"
		player_buttons[selected_player.Name].priority.TextColor3 = rgb(15, 179, 255)
	end)

	local button_inline = library:create("Frame", {
		Parent = Frame,
		Name = "",
		Position = UDim2.new(0, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -6, 0, 14),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local button = library:create("TextButton", {
		Parent = button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "Enemy",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(1, -4, 1, -2),
		TextSize = 11,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	button.MouseButton1Click:Connect(function()
		if not selected_player or not player_buttons[selected_player.Name] then return end
		player_buttons[selected_player.Name].priority.Text = "Enemy"
		player_buttons[selected_player.Name].priority.TextColor3 = rgb(255, 44, 44)
	end)

	-- View Player Button
	local view_button_inline = library:create("Frame", {
		Parent = Frame,
		Name = "",
		Position = UDim2.new(0, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -6, 0, 14),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local view_button = library:create("TextButton", {
		Parent = view_button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "View Player",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(1, -4, 1, -2),
		TextSize = 11,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	view_button.MouseButton1Click:Connect(function()
		if not selected_player then return end
		if library.viewing_player == selected_player then
			library.viewing_player = nil
			if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
				camera.CameraSubject = lp.Character:FindFirstChildOfClass("Humanoid")
			end
			view_button.Text = "View Player"
			view_button.TextColor3 = Color3.fromRGB(170, 170, 170)
		else
			if selected_player.Character and selected_player.Character:FindFirstChildOfClass("Humanoid") then
				library.viewing_player = selected_player
				camera.CameraSubject = selected_player.Character:FindFirstChildOfClass("Humanoid")
				view_button.Text = "Unview"
				view_button.TextColor3 = Color3.fromRGB(0, 255, 150)
			end
		end
	end)

	-- Teleport Button (New Method + Security)
	local tp_button_inline = library:create("Frame", {
		Parent = Frame,
		Name = "",
		Position = UDim2.new(0, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -6, 0, 14),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local tp_button = library:create("TextButton", {
		Parent = tp_button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "Teleport",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(1, -4, 1, -2),
		TextSize = 11,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	tp_button.MouseButton1Click:Connect(function()
		-- Security Checks
		if not selected_player or selected_player == lp then
			library:notification({ text = "Security: Invalid player selected!" })
			return
		end

		local my_char = lp.Character
		local target_char = selected_player.Character
		if not my_char or not target_char then
			library:notification({ text = "Security: Character missing!" })
			return
		end

		local my_hrp = my_char:FindFirstChild("HumanoidRootPart")
		local target_hrp = target_char:FindFirstChild("HumanoidRootPart")
		local target_hum = target_char:FindFirstChildOfClass("Humanoid")

		if not my_hrp or not target_hrp then
			library:notification({ text = "Security: HumanoidRootPart missing!" })
			return
		end

		if target_hum and target_hum.Health <= 0 then
			library:notification({ text = "Security: Target is dead!" })
			return
		end

		-- New Anti-Cheat Safe Teleport Method
		pcall(function()
			-- Step 1: Nullify velocity
			my_hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			my_hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

			-- Step 2: Teleport 3 studs behind target
			local dest_cf = target_hrp.CFrame * CFrame.new(0, 0, 3)
			my_hrp.CFrame = dest_cf
			my_hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

			library:notification({ text = "Safe Teleported to " .. selected_player.Name })
		end)
	end)

	local UIListLayout = library:create("UIListLayout", {
		Parent = Frame,
		Name = "",
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = UDim.new(0, 2),
	})

	local accent_line = library:create("Frame", {
		Parent = playerlist,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local playerlist_line_gradient = library:create("UIGradient", {
		Parent = accent_line,
		Name = "LineGradient",
		Enabled = false,
	})
	cfg.playerlist_accent_line = accent_line
	cfg.playerlist_line_gradient = playerlist_line_gradient

	local depth = library:create("Frame", {
		Parent = playerlist,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local glow = library:create("ImageLabel", {
		Parent = playerlist,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 0, 42),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")
	cfg.playerlist_glow = glow

	local function update_selection(player, button)
		if selected_player == player and player ~= nil then
			selected_player = nil
			selected_button = nil

			for _, p_data in pairs(player_buttons) do
				if p_data and p_data.instance then
					p_data.instance.BackgroundTransparency = 1
				end
			end

			priority_label.Text = "Priority: None"
			name_label.Text = "Name: None"
			display_name_label.Text = "Display: None"
			return
		end

		selected_player = player
		selected_button = button

		for _, p_data in pairs(player_buttons) do
			if p_data and p_data.instance then
				p_data.instance.BackgroundTransparency = 1
			end
		end

		if button then
			button.BackgroundTransparency = 0.85
		end

		if player then
			priority_label.Text = "Priority: " .. library.get_priority(player)
			name_label.Text = "Name: " .. player.Name
			display_name_label.Text = "Display: " .. (player.DisplayName or player.Name)
		else
			priority_label.Text = "Priority: None"
			name_label.Text = "Name: None"
			display_name_label.Text = "Display: None"
		end
	end

	local function create_player(player)
		if setthreadidentity then pcall(setthreadidentity, 8) end
		if not player or not player.Name then return end

		if player_buttons[player.Name] and player_buttons[player.Name].instance then
			pcall(function() player_buttons[player.Name].instance:Destroy() end)
		end

		local TextButton = library:create("TextButton", {
			Parent = __ScrollingFrame,
			Name = player.Name,
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		player_buttons[player.Name] = {}
		player_buttons[player.Name].instance = TextButton

		local name_label_item = library:create("TextLabel", {
			Parent = TextButton,
			Name = "NameLabel",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = player.Name,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		library:create("UIStroke", {
			Parent = name_label_item,
			Name = "",
		})

		local team_label_item = library:create("TextLabel", {
			Parent = TextButton,
			Name = "TeamLabel",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = player.Team and tostring(player.Team) or "None",
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		library:create("UIStroke", {
			Parent = team_label_item,
			Name = "",
		})

		library:create("Frame", {
			Parent = team_label_item,
			Name = "",
			Position = UDim2.new(0, -10, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 1, 0, 12),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(32, 32, 38),
		})

		local prio_label_item = library:create("TextLabel", {
			Parent = TextButton,
			Name = "PriorityLabel",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "Neutral",
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		player_buttons[player.Name].priority = prio_label_item

		library:create("UIStroke", {
			Parent = prio_label_item,
			Name = "",
		})

		library:create("Frame", {
			Parent = prio_label_item,
			Name = "",
			Position = UDim2.new(0, -10, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 1, 0, 12),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(32, 32, 38),
		})

		library:create("UIListLayout", {
			Parent = TextButton,
			Name = "",
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalFlex = Enum.UIFlexAlignment.Fill,
		})

		library:create("UIPadding", {
			Parent = TextButton,
			Name = "",
			PaddingRight = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
		})

		TextButton.MouseButton1Click:Connect(function()
			update_selection(player, TextButton)
		end)
	end

	for _, player in next, players:GetPlayers() do
		task.spawn(function()
			if setthreadidentity then pcall(setthreadidentity, 8) end
			create_player(player)
		end)
	end

	library:connection(players.PlayerAdded, function(player)
		task.spawn(function()
			if setthreadidentity then pcall(setthreadidentity, 8) end
			create_player(player)
		end)
	end)

	library:connection(players.PlayerRemoving, function(player)
		if player and player_buttons[player.Name] then
			if selected_player == player then
				update_selection(nil, nil)
			end
			if player_buttons[player.Name].instance then
				pcall(function() player_buttons[player.Name].instance:Destroy() end)
			end
			player_buttons[player.Name] = nil
		end
	end)
	--

	-- keybind list
	local old_kblist = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0.5, 0),
		ZIndex = 2,
		Active = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(0, 150, 0, 0),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		Visible = false,
	})
	library:make_smooth_draggable(old_kblist, old_kblist)

	local glow = library:create("ImageLabel", {
		Parent = old_kblist,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 1, 40),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	local inline1 = library:create("Frame", {
		Parent = old_kblist,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	local accent_line = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local keybinds_line_gradient = library:create("UIGradient", {
		Parent = accent_line,
		Name = "LineGradient",
		Enabled = false,
	})
	cfg.keybinds_accent_line = accent_line
	cfg.keybinds_line_gradient = keybinds_line_gradient
	cfg.keybinds_glow = glow

	local name = library:create("TextLabel", {
		Parent = inline1,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "keybinds",
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local keybinds_gradient = library:create("UIGradient", {
		Parent = name,
		Name = "",
		Enabled = false,
	})
	cfg.keybinds_label = name
	cfg.keybinds_gradient = keybinds_gradient

	local inline2 = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -4, 0, 28),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local main = library:create("Frame", {
		Parent = inline2,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(57, 57, 57),
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -4, 0, 24),
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local tab_inline = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 6, 0, 6),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -12, 0, 12),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local tabs = library:create("Frame", {
		Parent = tab_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -4, 0, 8),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = tabs,
		Name = "",
		PaddingBottom = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 20),
		PaddingLeft = UDim.new(0, 20),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = tabs,
		Name = "",
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 3),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = tabs,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local depth = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	library.keybind_path = tabs
	--

	function cfg.toggle_list(bool)
		old_kblist.Visible = bool
	end

	function cfg.toggle_playerlist(bool)
		playerlist.Visible = bool
	end

	function cfg.toggle_watermark(bool)
		__holder.Visible = bool
	end

	function cfg.set_menu_visibility(bool, pl)
		WINDOW_PATH.Visible = bool

		if playerlist then
			playerlist.Visible = bool and (library.flags and library.flags["player_list"] == true)
		end
		if old_kblist then
			old_kblist.Visible = (library.flags and library.flags["keybinds_enabled"] == true)
		end
		if __holder then
			__holder.Visible = (library.flags and library.flags["watermark_enabled"] == true)
		end
	end

	cfg.window_frame = WINDOW_PATH
	cfg.watermark_frame = __holder
	cfg.keybinds_frame = old_kblist
	cfg.toggle_keybinds = cfg.toggle_list
	library.active_window = cfg

	return setmetatable(cfg, library)
end

function library:new_keybind(properties)
	local cfg = {
		text = properties.name or properties.text or "aimbot",
		key = properties.key or nil,
		mode = properties.mode or "hold",
	}

	local keybind_text = library:create("TextLabel", {
		Parent = library.keybind_path,
		Name = "",
		FontFace = library.font,
		LineHeight = 1.2000000476837158,
		TextStrokeTransparency = 0.5,
		AnchorPoint = Vector2.new(0.5, 0),
		TextSize = 12,
		Size = UDim2.new(0, 0, 0, 11),
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 8),
		BorderSizePixel = 0,
		Visible = false,
		TextYAlignment = Enum.TextYAlignment.Top,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = keybind_text,
		Name = "",
		PaddingTop = UDim.new(0, 6),
	})

	cfg.active_state = false

	function cfg.set_visible(bool)
		if not (library.flags and library.flags["keybinds_enabled"] == true) then
			keybind_text.Visible = false
			cfg.active_state = false
			return
		end
		if bool then
			keybind_text.Visible = true
			keybind_text.TextTransparency = 1
			keybind_text.TextStrokeTransparency = 1
			keybind_text.Position = UDim2.new(0.5, -10, 0, 8)
			tween_service:Create(keybind_text, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0,
				TextStrokeTransparency = 0.5,
				Position = UDim2.new(0.5, 0, 0, 8)
			}):Play()
		else
			if keybind_text.Visible then
				tween_service:Create(keybind_text, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					TextTransparency = 1,
					TextStrokeTransparency = 1,
					Position = UDim2.new(0.5, 10, 0, 8)
				}):Play()
				task.delay(0.05, function()
					if not cfg.active_state then
						keybind_text.Visible = false
					end
				end)
			end
		end
		cfg.active_state = bool
	end

	function cfg.change_text(text)
		keybind_text.Text = text
	end

	function keyName(key)
		local text = tostring(key) ~= "Enums" and (keys[key] or tostring(key):gsub("Enum.", "")) or nil
		local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))

		return __text or "..."
	end

	-- Shit ass function
	function cfg.update(n_properties)
		cfg.change_text(
			"["
				.. tostring(keyName(n_properties.key))
				.. "] "
				.. tostring(n_properties.text)
				.. " ("
				.. tostring(n_properties.mode)
				.. ")"
		)
	end

	cfg.change_text(
		"[" .. tostring(keyName(cfg.key)) .. "] " .. tostring(cfg.text) .. " (" .. tostring(cfg.mode) .. ")"
	)

	return cfg
end

function library:notification(properties)
	local cfg = {
		time = properties.time or 5,
		text = properties.text or properties.name or "ledger.live is pasted",
	}

	-- 28 offset

	function cfg:refresh_notifications()
		for _, notif in next, library.notifications do
			tween_service
				:Create(
					notif,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{ Position = dim2(0, 20, 0, 72 + (_ * 28)) }
				)
				:Play()
		end
	end

	-- Instances
	local holder = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 72 + (#library.notifications * 28)),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		AnchorPoint = Vector2.new(1, 0),
	})

	local inline1 = library:create("Frame", {
		Parent = holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 0, 0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	local inline2 = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 0, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local main = library:create("Frame", {
		Parent = inline2,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(57, 57, 57),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local tab_inline = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local name = library:create("TextLabel", {
		Parent = tab_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.text,
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(0, 0, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = tab_inline,
		Name = "",
		PaddingRight = UDim.new(0, 14),
	})

	local depth = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 1, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local accent_line = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(0, 2, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local glow = library:create("ImageLabel", {
		Parent = holder,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, 0),
		Size = UDim2.new(0, 42, 1, 40),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")
	--

	task.spawn(function()
		tween_service
			:Create(
				holder,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ AnchorPoint = Vector2.new(0, 0) }
			)
			:Play()

		task.wait(cfg.time)

		tween_service
			:Create(
				holder,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ AnchorPoint = Vector2.new(1, 0) }
			)
			:Play()
		for _, v in next, holder:GetDescendants() do
			if v:IsA("TextLabel") then
				tween_service
					:Create(
						v,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{ TextTransparency = 1 }
					)
					:Play()
			elseif v:IsA("Frame") then
				tween_service
					:Create(
						v,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{ BackgroundTransparency = 1 }
					)
					:Play()
			elseif v:IsA("ImageLabel") then
				tween_service
					:Create(
						v,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{ ImageTransparency = 1 }
					)
					:Play()
			end
		end
	end)

	task.delay(cfg.time + 0.1, function()
		table.remove(library.notifications, table.find(library.notifications, holder))
		cfg:refresh_notifications()
		task.wait(0.5)
		holder:Destroy()
	end)

	table.insert(library.notifications, holder)
end

function library:tab(properties)
	local cfg = {
		name = properties.name or "tab",
		enabled = false,
		sections = {},
	}

	-- Button
	local TAB_BUTTON = library:create("TextButton", {
		Parent = self.tab_holder,
		Name = "",
		FontFace = library.font,
		TextColor3 = themes.preset.unselected_text,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.3330000042915344, -4, 0, 22),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local line = library:create("Frame", {
		Parent = TAB_BUTTON,
		Name = "",
		Position = UDim2.new(0, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = rgb(57, 57, 57),
	})

	library:apply_theme(line, "accent", "BackgroundColor3")

	local glow = library:create("ImageLabel", {
		Parent = line,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 1, 40),
		ZIndex = 2,
		Visible = false,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	local depth = library:create("Frame", {
		Parent = line,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})
	--

	-- Tab Instances
	local TAB = library:create("Frame", {
		Parent = self.tab_instance_holder,
		Name = "",
		Visible = false,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local tab_search_container = library:create("Frame", {
		Parent = TAB,
		Name = "TabSearchContainer",
		Position = UDim2.new(0, 6, 0, 4),
		Size = UDim2.new(1, -12, 0, 22),
		BackgroundColor3 = Color3.fromRGB(18, 18, 22),
		BorderColor3 = Color3.fromRGB(44, 44, 52),
		BorderSizePixel = 1,
	})

	local tab_search_icon = library:create("ImageLabel", {
		Parent = tab_search_container,
		Name = "SearchIcon",
		Position = UDim2.new(0, 6, 0.5, -6),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://10734883986",
		ImageColor3 = Color3.fromRGB(150, 150, 165),
	})

	local tab_search_tb = library:create("TextBox", {
		Parent = tab_search_container,
		Name = "SearchInput",
		Position = UDim2.new(0, 24, 0, 0),
		Size = UDim2.new(1, -48, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = library.font,
		PlaceholderText = "Search in " .. cfg.name .. "...",
		PlaceholderColor3 = Color3.fromRGB(110, 110, 125),
		Text = "",
		TextColor3 = Color3.fromRGB(225, 225, 235),
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	})

	local tab_search_clear = library:create("ImageButton", {
		Parent = tab_search_container,
		Name = "ClearButton",
		Position = UDim2.new(1, -19, 0.5, -6),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://9154608052",
		ImageColor3 = Color3.fromRGB(170, 170, 180),
		ImageTransparency = 0.45,
		Visible = false,
	})

	local tab_caret = library:create("Frame", {
		Parent = tab_search_container,
		Name = "Caret",
		Position = UDim2.new(0, 24, 0.5, -6),
		Size = UDim2.new(0, 1, 0, 12),
		BackgroundColor3 = themes.preset.accent,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	})
	library:apply_theme(tab_caret, "accent", "BackgroundColor3")

	tab_search_clear.MouseEnter:Connect(function()
		tween_service:Create(tab_search_clear, TweenInfo.new(0.15), {
			ImageTransparency = 0.1,
			ImageColor3 = Color3.fromRGB(240, 240, 250)
		}):Play()
	end)
	tab_search_clear.MouseLeave:Connect(function()
		tween_service:Create(tab_search_clear, TweenInfo.new(0.15), {
			ImageTransparency = 0.45,
			ImageColor3 = Color3.fromRGB(170, 170, 180)
		}):Play()
	end)
	tab_search_clear.MouseButton1Click:Connect(function()
		tab_search_tb.Text = ""
	end)

	local tab_word_caret = library:attach_word_caret(tab_search_tb, tab_caret, 24, -6)

	tab_search_tb.Focused:Connect(function()
		tween_service:Create(tab_search_container, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BorderColor3 = themes.preset.accent,
			BackgroundColor3 = Color3.fromRGB(22, 22, 28)
		}):Play()
		tween_service:Create(tab_search_icon, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageColor3 = themes.preset.accent
		}):Play()
	end)

	tab_search_tb.FocusLost:Connect(function()
		tween_service:Create(tab_search_container, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BorderColor3 = Color3.fromRGB(44, 44, 52),
			BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		}):Play()
		tween_service:Create(tab_search_icon, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageColor3 = Color3.fromRGB(150, 150, 165)
		}):Play()
	end)

		function cfg.filter_tab(query)
		local q = string.lower(string.gsub(query or "", "^%s*(.-)%s*$", "%1"))
		local is_empty = (q == "")

		for _, sec in ipairs(cfg.sections) do
			local sec_has_match = false
			if sec.holder then
				for _, el in ipairs(sec.holder:GetChildren()) do
					if el:IsA("GuiObject") and not el:IsA("UIListLayout") and not el:IsA("UIPadding") then
						if is_empty then
							el.Visible = true
							sec_has_match = true
						else
							local match = false
							if (el:IsA("TextLabel") or el:IsA("TextButton")) and el.Text ~= "" then
								if string.find(string.lower(el.Text), q, 1, true) then
									match = true
								end
							end
							if not match then
								for _, desc in ipairs(el:GetDescendants()) do
									if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text ~= "" then
										if string.find(string.lower(desc.Text), q, 1, true) then
											match = true
											break
										end
									end
								end
							end

							el.Visible = match
							if match then
								sec_has_match = true
							end
						end
					end
				end
			end

			if sec.section_frame then
				if is_empty then
					sec.section_frame.Visible = true
				else
					sec.section_frame.Visible = sec_has_match
				end
			end
		end
	end

	tab_search_tb:GetPropertyChangedSignal("Text"):Connect(function()
		local txt = tab_search_tb.Text
		tab_search_clear.Visible = (txt ~= "")
		cfg.filter_tab(txt)
	end)

		local scrolling_columns = library:create("Frame", {
		Parent = TAB,
		Name = "",
		ClipsDescendants = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 0, 30),
		Size = UDim2.new(1, -12, 1, -34),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	cfg["column_holder"] = scrolling_columns

	local UIListLayout = library:create("UIListLayout", {
		Parent = scrolling_columns,
		Name = "",
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local left = library:create("ScrollingFrame", {
		Parent = scrolling_columns,
		Name = "",
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		Size = UDim2.new(0.5, -64, 1, 0),
		ClipsDescendants = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 4, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})

	left:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if library.current_element_open then
			library.current_element_open.set_visible(false)
			library.current_element_open.open = false
			library.current_element_open = nil
		end
	end)

	cfg["left"] = left

	local UIListLayout = library:create("UIListLayout", {
		Parent = left,
		Name = "",
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = left,
		Name = "",
		PaddingBottom = UDim.new(0, 15),
	})

	local right = library:create("ScrollingFrame", {
		Parent = scrolling_columns,
		Name = "",
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		Size = UDim2.new(0.5, -64, 1, 0),
		ClipsDescendants = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, -50, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})

	right:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if library.current_element_open then
			library.current_element_open.set_visible(false)
			library.current_element_open.open = false
			library.current_element_open = nil
		end
	end)

	cfg["right"] = right

	local UIListLayout = library:create("UIListLayout", {
		Parent = right,
		Name = "",
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = right,
		Name = "",
		PaddingBottom = UDim.new(0, 15),
	})
	--

	function cfg.open_tab()
		if library.current_tab and library.current_tab[1] ~= TAB_BUTTON then
			local button = library.current_tab[1]
			button.TextColor3 = themes.preset.unselected_text

			local parent = button:FindFirstChildOfClass("Frame")
			parent.BackgroundColor3 = rgb(57, 57, 57)
			parent:FindFirstChildOfClass("ImageLabel").Visible = false

			library.current_tab[2].Visible = false
		end

		library.current_tab = {
			TAB_BUTTON,
			TAB,
		}

		line.BackgroundColor3 = themes.preset.accent
		glow.Visible = true
		TAB_BUTTON.TextColor3 = themes.preset.text
		
		-- smooth slide-in tab switching animation
		TAB.Position = UDim2.new(0, 0, 0, 6)
		TAB.Visible = true
		tween_service:Create(TAB, TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()

		if library.current_element_open and library.current_element_open ~= cfg then
			library.current_element_open.set_visible(false)
			library.current_element_open.open = false
			library.current_element_open = nil
		end
	end

	TAB_BUTTON.MouseButton1Click:Connect(cfg.open_tab)

	return setmetatable(cfg, library)
end

function library:section(properties)
	local cfg = {
		name = properties.name or properties.Name or "Section",
		side = properties.side or properties.Side or "left",
	}

	-- Instances
	local section_outer = library:create("Frame", {
		Parent = self[cfg.side],
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local section_inline = library:create("Frame", {
		Parent = section_outer,
		Name = "",
		Position = UDim2.new(0, 0, 0, 4),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, 0, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local name = library:create("TextLabel", {
		Parent = section_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 8, 0, 0),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local section = library:create("Frame", {
		Parent = section_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local elements = library:create("Frame", {
		Parent = section,
		Name = "",
		Position = UDim2.new(0, 12, 0, 12),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -24, 0, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = elements,
		Name = "",
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 3),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = section,
		Name = "",
		PaddingBottom = UDim.new(0, 13),
	})
	--

	cfg["holder"] = elements
	cfg["section_frame"] = section_outer
	if self.sections then
		table.insert(self.sections, cfg)
	end

	return setmetatable(cfg, library)
end

function library:hitpart_picker(properties)
	local cfg = {
		name = properties.name or properties.Name or "Hitpart",
		side = properties.side or properties.Side or "left",
		flag = properties.flag or "Hitpart",
		default = properties.default or { "Head" },
		type_char = properties.type or "R6",
		multi = properties.multi or false,
		callback = properties.callback or function() end,
		previous_holder = self,
	}

	flags[cfg.flag] = {}

	local bodyparts = {}
	local bools = {}

	local r15_hitpart_holder = library:create("Frame", {
		Parent = self[cfg.side],
		Name = "",
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 272),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local hitpart_inline = library:create("Frame", {
		Parent = r15_hitpart_holder,
		Name = "",
		Position = UDim2.new(0, 0, 0, 4),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, 0, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local hitpart = library:create("Frame", {
		Parent = hitpart_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	if cfg.type_char == "R15" then
		bodyparts.Head = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -25, 0, 16),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 50, 0, 44),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.UpperTorso = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 84, 0, 76),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftUpperArm = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -86, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 34),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightUpperArm = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 46, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 34),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftUpperLeg = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 158),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 34),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftLowerLeg = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 196),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightFoot = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 2, 0, 242),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 6),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftFoot = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 242),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 6),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightLowerLeg = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 2, 0, 196),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightUpperLeg = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 2, 0, 158),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 34),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftHand = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -86, 0, 148),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 6),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightHand = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 46, 0, 148),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 6),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LowerTorso = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 144),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 84, 0, 10),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightLowerArm = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 46, 0, 102),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftLowerArm = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -86, 0, 102),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		local outline = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -10, 0, 96),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 20, 0, 20),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		})

		bodyparts.HumanoidRootPart = library:create("TextButton", {
			Text = "",
			Parent = outline,
			Name = "",
			Position = UDim2.new(0, 4, 0, 4),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, -8, 1, -8),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})
	else
		bodyparts.Head = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Text = "",
			Position = UDim2.new(0.5, -25, 0, 16),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 50, 0, 44),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.Torso = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Text = "",
			Position = UDim2.new(0.5, -42, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 84, 0, 90),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftArm = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -86, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 90),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightArm = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 46, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 90),
			Text = "",
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightLeg = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 2, 0, 158),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 90),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftLeg = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 158),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 90),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		local hrp_out = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -10, 0, 99),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 20, 0, 20),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		})

		bodyparts.HumanoidRootPart = library:create("TextButton", {
			Parent = hrp_out,
			Name = "",
			Position = UDim2.new(0, 4, 0, 4),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, -8, 1, -8),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})
	end

	local name = library:create("TextLabel", {
		Parent = hitpart_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 8, 0, 0),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	function cfg.set(parts)
		flags[cfg.flag] = {}
		for name, button in pairs(bodyparts) do
			bools[name] = false
			local glow = button:FindFirstChildOfClass("ImageLabel")
			if glow then
				glow.Visible = false
			end
			button.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
		end

		for _, part in pairs(parts) do
			if bodyparts[part] then
				bools[part] = true
				table.insert(flags[cfg.flag], part)
				local glow = bodyparts[part]:FindFirstChildOfClass("ImageLabel")
				if glow then
					glow.Visible = true
				end
				bodyparts[part].BackgroundColor3 = themes.preset.accent
			end
		end

		cfg.callback(flags[cfg.flag])
	end

	for name, button in next, bodyparts do
		bools[name] = false

		library:apply_theme(button, "accent", "BackgroundColor3")

		local glow = library:create("ImageLabel", {
			Parent = button,
			Name = "",
			Visible = false,
			ImageColor3 = themes.preset.accent,
			ScaleType = Enum.ScaleType.Slice,
			ImageTransparency = 0.8999999761581421,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Image = "http://www.roblox.com/asset/?id=18245826428",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, -20, 0, -20),
			Size = UDim2.new(1, 40, 1, 40),
			ZIndex = 2,
			BorderSizePixel = 0,
			SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
		})

		library:apply_theme(glow, "accent", "ImageColor3")

		library:connection(button.MouseButton1Click, function()
			if not cfg.multi then
				cfg.set({ name })
			else
				bools[name] = not bools[name]

				if bools[name] then
					table.insert(flags[cfg.flag], name)
				else
					local index = table.find(flags[cfg.flag], name)
					table.remove(flags[cfg.flag], index)
				end

				glow.Visible = bools[name]
				button.BackgroundColor3 = bools[name] and themes.preset.accent or Color3.fromRGB(38, 38, 38)

				cfg.callback(flags[cfg.flag])
			end
		end)
	end

	if #cfg.default > 1 and not cfg.multi then
		cfg.default = { cfg.default[1] }
	end

	cfg.set(cfg.default)
	config_flags[cfg.flag] = cfg.set
	return setmetatable(cfg, library)
end

function library:toggle(properties)
	local cfg = {
		enabled = properties.enabled or nil,
		name = properties.name or "Toggle",
		flag = properties.flag or tostring(math.random(1, 9999999)),
		callback = properties.callback or function() end,
		default = properties.default or false,
		previous_holder = self,
	}

	-- Instances
	local object = library:create("TextButton", {
		Parent = self.holder,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -26, 0, 12),
		ZIndex = 1,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local right_components = library:create("Frame", {
		Parent = object,
		Name = "",
		Position = UDim2.new(1, 15, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local list = library:create("UIListLayout", {
		Parent = right_components,
		Name = "",
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local icon_inline = library:create("TextButton", {
		Parent = object,
		Name = "",
		Position = UDim2.new(0, -15, 0, 1),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(0, 10, 0, 10),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local icon = library:create("Frame", {
		Parent = icon_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local icon_2 = library:create("Frame", {
		Parent = icon,
		Name = "",
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = themes.preset.accent,
	})
	library:apply_theme(icon_2, "accent", "BackgroundColor3")

	-- white glossy gradient highlight shading
	library:create("UIGradient", {
		Parent = icon_2,
		Name = "",
		Rotation = -45,
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.45),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	local glow = library:create("ImageLabel", {
		Parent = icon_inline,
		Name = "",
		Visible = false,
		ImageColor3 = Color3.fromRGB(255, 255, 255), -- White shadow glow
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -12, 0, -12),
		Size = UDim2.new(1, 24, 1, 24),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	local bottom_components = library:create("Frame", {
		Parent = object,
		Name = "",
		Visible = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Position = UDim2.new(0, 0, 0, 13),
		Size = UDim2.new(1, 26, 0, 0),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local list = library:create("UIListLayout", {
		Parent = bottom_components,
		Name = "",
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	--

	function cfg.set(bool)
		flags[cfg.flag] = bool

		if bool then
			icon_2.Visible = true
			icon_2.Size = UDim2.fromScale(0, 0)
			tween_service:Create(icon_2, TweenInfo.new(0.09, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(1, 1)
			}):Play()

			glow.Visible = true
			glow.ImageTransparency = 1
			tween_service:Create(glow, TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 0.8
			}):Play()
		else
			tween_service:Create(icon_2, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.fromScale(0, 0)
			}):Play()

			tween_service:Create(glow, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				ImageTransparency = 1
			}):Play()

			task.delay(0.08, function()
				if not flags[cfg.flag] then
					icon_2.Visible = false
					glow.Visible = false
				end
			end)
		end

		cfg.callback(bool)
	end

	library:connection(object.MouseButton1Click, function()
		cfg.enabled = not cfg.enabled

		cfg.set(cfg.enabled)
	end)

	library:connection(icon_inline.MouseButton1Click, function()
		cfg.enabled = not cfg.enabled

		cfg.set(cfg.enabled)
	end)

	cfg.set(cfg.default)

	self.previous_holder = left_components
	self.bottom_holder = bottom_components
	self.right_holder = right_components

	cfg.previous_holder = left_components
	cfg.bottom_holder = bottom_components
	cfg.right_holder = right_components
	cfg.element_frame = object

	config_flags[cfg.flag] = cfg.set
	library.config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end

function library:slider(properties)
	local cfg = {
		name = properties.name or nil,
		suffix = properties.suffix or "",
		flag = properties.flag or tostring(2 ^ 789),
		callback = properties.callback or function() end,

		min = properties.min or properties.minimum or 0,
		max = properties.max or properties.maximum or 100,
		intervals = properties.interval or properties.decimal or properties.decimals or properties.changers or 1,
		default = properties.default or 10,
		min_text = properties.min_text or properties.min_string or nil,

		dragging = false,
		value = properties.default or 10,

		previous_holder = self,
	}

	local bottom_components
	if cfg.name then
		object = library:create("TextLabel", {
			Parent = self.holder,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = cfg.name,
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, -26, 0, 12),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		bottom_components = library:create("Frame", {
			Parent = object,
			Name = "",
			Visible = true,
			Position = UDim2.new(0, 0, 0, 13),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, 26, 0, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		local list = library:create("UIListLayout", {
			Parent = bottom_components,
			Name = "",
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	else
		self.bottom_holder.Parent.AutomaticSize = Enum.AutomaticSize.Y
		self.bottom_holder.Parent.TextYAlignment = Enum.TextYAlignment.Top
	end

	local slider_holder = library:create("Frame", {
		Parent = cfg.name and bottom_components or self.bottom_holder,
		Name = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local slider_inline = library:create("TextButton", {
		Parent = slider_holder,
		Name = "",
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 8),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local fill_inline = library:create("Frame", {
		Parent = slider_inline,
		Name = "",
		Size = UDim2.new(0.5, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local fill = library:create("Frame", {
		Parent = fill_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, 0, 1, -4),
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(fill, "accent", "BackgroundColor3")
	library:apply_theme(fill, "accent", "BorderColor3")

	local VALUE_TEXT = library:create("TextBox", {
		Parent = fill_inline,
		Name = "",
		RichText = true,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.5,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 11),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		FontFace = library.font,
		TextSize = 12,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	VALUE_TEXT.Focused:Connect(function()
		VALUE_TEXT.SelectionStart = 1
		VALUE_TEXT.CursorPosition = #VALUE_TEXT.Text + 1
	end)

	VALUE_TEXT.FocusLost:Connect(function(enterPressed)
		local raw = VALUE_TEXT.Text
		local num = tonumber(raw:match("[%d%.%-]+"))
		if num then
			cfg.set(num)
		else
			cfg.set(cfg.value)
		end
	end)

	local glow = library:create("ImageLabel", {
		Parent = fill_inline,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -18, 0, -18),
		Size = UDim2.new(1, 36, 1, 36),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	local add = library:create("TextButton", {
		Parent = slider_inline,
		Name = "",
		TextWrapped = true,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "+",
		TextStrokeTransparency = 0.5,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 5, 0, -1),
		Size = UDim2.new(0, 8, 0, 8),
		FontFace = library.font,
		TextSize = 8,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local reset_btn = library:create("ImageButton", {
		Parent = slider_inline,
		Name = "SliderReset",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 15, 0, -1),
		Size = UDim2.new(0, 8, 0, 8),
		Image = "rbxassetid://10734940376",
		ImageColor3 = Color3.fromRGB(170, 170, 170),
		AutoButtonColor = false,
	})

	reset_btn.MouseEnter:Connect(function()
		reset_btn.ImageColor3 = themes.preset.accent or Color3.fromRGB(255, 255, 255)
	end)

	reset_btn.MouseLeave:Connect(function()
		reset_btn.ImageColor3 = Color3.fromRGB(170, 170, 170)
	end)

	reset_btn.MouseButton1Down:Connect(function()
		cfg.set(cfg.default)
	end)
	reset_btn.MouseButton1Click:Connect(function()
		cfg.set(cfg.default)
	end)

	local sub = library:create("TextButton", {
		Parent = slider_inline,
		Name = "",
		TextWrapped = true,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "-",
		TextStrokeTransparency = 0.5,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -15, 0, -1),
		Size = UDim2.new(0, 8, 0, 8),
		FontFace = library.font,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local slider = library:create("Frame", {
		Parent = slider_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local pad = library:create("UIPadding", {
		Parent = slider_holder,
		Name = "",
		PaddingBottom = UDim.new(0, -17),
	})

	local current_tween = nil
	function cfg.set(value, skip_tween)
		if type(value) ~= "number" then
			return
		end

		cfg.value = math.clamp(library:round(value, cfg.intervals), cfg.min, cfg.max)

		local target_ratio = math.clamp((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1)
		local target_size = dim2(target_ratio, 0, 1, 0)

		if skip_tween then
			if current_tween then current_tween:Cancel() end
			fill_inline.Size = target_size
		else
			if current_tween then current_tween:Cancel() end
			current_tween = tween_service:Create(fill_inline, TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = target_size
			})
			current_tween:Play()
		end

		if cfg.min_text and cfg.value == cfg.min then
			VALUE_TEXT.Text = cfg.min_text
		else
			VALUE_TEXT.Text = tostring(cfg.value) .. cfg.suffix
		end
		flags[cfg.flag] = cfg.value

		cfg.callback(flags[cfg.flag])
	end

	cfg.slider_instance = slider

	slider_inline.MouseButton1Down:Connect(function()
		cfg.dragging = true
		library.active_slider = cfg
		local mouse_pos = uis:GetMouseLocation()
		local size_x = (mouse_pos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
		local value = ((cfg.max - cfg.min) * size_x) + cfg.min
		cfg.set(value)
	end)

	add.MouseButton1Down:Connect(function()
		cfg.value = cfg.value + cfg.intervals
		cfg.set(cfg.value)
	end)

	sub.MouseButton1Down:Connect(function()
		cfg.value = cfg.value - cfg.intervals
		cfg.set(cfg.value)
	end)

	cfg.set(cfg.default, true)
	cfg.element_frame = object or slider_holder

	config_flags[cfg.flag] = cfg.set

	library.config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end

function library:dropdown(properties)
	local cfg = {
		name = properties.name or nil,
		flag = properties.flag or tostring(math.random(1, 9999999)),

		items = properties.items or { "1", "2", "3" },
		callback = properties.callback or function() end,
		multi = properties.multi or false,

		open = false,
		option_instances = {},
		multi_items = {},

		previous_holder = self,
	}
	cfg.default = properties.default or (cfg.multi and { cfg.items[1] }) or cfg.items[1] or nil

	local bottom_components
	local object
	if cfg.name then
		object = library:create("TextLabel", {
			Parent = self.holder,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = cfg.name,
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, -26, 0, 12),
			BorderSizePixel = 0,
			ZIndex = 2,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		bottom_components = library:create("Frame", {
			Parent = object,
			Name = "",
			Visible = true,
			Position = UDim2.new(0, 0, 0, 13),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, 26, 0, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		local list = library:create("UIListLayout", {
			Parent = bottom_components,
			Name = "",
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	else
		self.bottom_holder.Parent.AutomaticSize = Enum.AutomaticSize.Y
		self.bottom_holder.Parent.TextYAlignment = Enum.TextYAlignment.Top
	end

	-- Instances
	local dropdown_inline = library:create("Frame", {
		Parent = cfg.name and bottom_components or self.bottom_holder,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local dropdown = library:create("TextButton", {
		Parent = dropdown_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "option 1, option 3",
		TextStrokeTransparency = 0.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.new(0, 2, 0, 2),
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = dropdown,
		Name = "",
		PaddingLeft = UDim.new(0, 5),
	})

	local icon = library:create("TextLabel", {
		Parent = dropdown,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "+",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(1, -6, 0, -1),
		BorderSizePixel = 0,
		TextSize = 8,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local content_inline = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(0, dropdown_inline.AbsoluteSize.X, 0, 104),
		Position = UDim2.new(
			0,
			dropdown_inline.AbsolutePosition.X,
			0,
			dropdown_inline.AbsolutePosition.Y + dropdown_inline.AbsoluteSize.Y + 2
		),
		BorderSizePixel = 0,
		ZIndex = 2,
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local function update_dropdown_dimensions()
		local visible_count = 0
		for _, opt in ipairs(cfg.option_instances) do
			if opt.Visible then
				visible_count = visible_count + 1
			end
		end
		visible_count = math.clamp(visible_count > 0 and visible_count or 1, 1, 6)
		local target_height = (visible_count * 16) + 28
		content_inline.Size = UDim2.new(0, dropdown_inline.AbsoluteSize.X, 0, target_height)
	end

	dropdown_inline:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		content_inline.Position = UDim2.new(
			0,
			dropdown_inline.AbsolutePosition.X,
			0,
			dropdown_inline.AbsolutePosition.Y + dropdown_inline.AbsoluteSize.Y + 2
		)
	end)

	dropdown_inline:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		update_dropdown_dimensions()
	end)

	local content = library:create("Frame", {
		Parent = content_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local dd_search_frame = library:create("Frame", {
		Parent = content,
		Name = "DDSearchFrame",
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 0, 18),
		BackgroundColor3 = Color3.fromRGB(24, 24, 28),
		BorderColor3 = Color3.fromRGB(48, 48, 56),
		BorderSizePixel = 1,
	})

	local dd_search_icon = library:create("ImageLabel", {
		Parent = dd_search_frame,
		Name = "Icon",
		Position = UDim2.new(0, 4, 0.5, -5.5),
		Size = UDim2.new(0, 11, 0, 11),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://10734883986",
		ImageColor3 = Color3.fromRGB(140, 140, 155),
	})

	local dd_search_tb = library:create("TextBox", {
		Parent = dd_search_frame,
		Name = "Input",
		Position = UDim2.new(0, 18, 0, 0),
		Size = UDim2.new(1, -34, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = library.font,
		PlaceholderText = "Search...",
		PlaceholderColor3 = Color3.fromRGB(100, 100, 115),
		Text = "",
		TextColor3 = Color3.fromRGB(220, 220, 230),
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	})

	local dd_clear_btn = library:create("ImageButton", {
		Parent = dd_search_frame,
		Name = "Clear",
		Position = UDim2.new(1, -15, 0.5, -5.5),
		Size = UDim2.new(0, 11, 0, 11),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://9154608052",
		ImageColor3 = Color3.fromRGB(160, 160, 170),
		ImageTransparency = 0.45,
		Visible = false,
	})

	local dd_caret = library:create("Frame", {
		Parent = dd_search_frame,
		Name = "Caret",
		Position = UDim2.new(0, 18, 0.5, -5),
		Size = UDim2.new(0, 1, 0, 10),
		BackgroundColor3 = themes.preset.accent,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	})
	library:apply_theme(dd_caret, "accent", "BackgroundColor3")

	local dd_word_caret = library:attach_word_caret(dd_search_tb, dd_caret, 18, -5)

	dd_search_tb.Focused:Connect(function()
		tween_service:Create(dd_search_frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BorderColor3 = themes.preset.accent,
			BackgroundColor3 = Color3.fromRGB(28, 28, 36)
		}):Play()
		tween_service:Create(dd_search_icon, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageColor3 = themes.preset.accent
		}):Play()
	end)

	dd_search_tb.FocusLost:Connect(function()
		tween_service:Create(dd_search_frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BorderColor3 = Color3.fromRGB(48, 48, 56),
			BackgroundColor3 = Color3.fromRGB(24, 24, 28)
		}):Play()
		tween_service:Create(dd_search_icon, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageColor3 = Color3.fromRGB(140, 140, 155)
		}):Play()
	end)

		dd_clear_btn.MouseEnter:Connect(function()
		tween_service:Create(dd_clear_btn, TweenInfo.new(0.15), {
			ImageTransparency = 0.1,
			ImageColor3 = Color3.fromRGB(240, 240, 250)
		}):Play()
	end)
	dd_clear_btn.MouseLeave:Connect(function()
		tween_service:Create(dd_clear_btn, TweenInfo.new(0.15), {
			ImageTransparency = 0.45,
			ImageColor3 = Color3.fromRGB(160, 160, 170)
		}):Play()
	end)
	dd_clear_btn.MouseButton1Click:Connect(function()
		dd_search_tb.Text = ""
	end)

	local function filter_dd_options(q)
		local query = string.lower(string.gsub(q or "", "^%s*(.-)%s*$", "%1"))
		for _, opt in ipairs(cfg.option_instances) do
			local name = opt:GetAttribute("OptionName") or opt.Text or ""
			if query == "" or string.find(string.lower(name), query, 1, true) then
				opt.Visible = true
			else
				opt.Visible = false
			end
		end
		update_dropdown_dimensions()
	end

	dd_search_tb:GetPropertyChangedSignal("Text"):Connect(function()
		local txt = dd_search_tb.Text
		dd_clear_btn.Visible = (txt ~= "")
		filter_dd_options(txt)
	end)

		local options = library:create("ScrollingFrame", {
		Parent = content,
		Name = "OptionsList",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 2, 0, 22),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -24),
		BorderSizePixel = 0,
		Active = true,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(60, 65, 80),
		ScrollBarImageTransparency = 0.5,
		MidImage = "rbxassetid://18406573371",
		TopImage = "rbxassetid://18406573371",
		BottomImage = "rbxassetid://18406573371",
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ClipsDescendants = true,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = options,
		Name = "",
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = options,
		Name = "",
		PaddingBottom = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 3),
	})

	function cfg.set_visible(bool)
		content_inline.Visible = bool

		icon.Text = bool and "-" or "+"
		icon.TextSize = bool and 12 or 8

		if cfg.name then
			object.ZIndex = bool and 9999 or 3
		end

		if bool then
			if library.current_element_open and library.current_element_open ~= cfg then
				library.current_element_open.set_visible(false)
				library.current_element_open.open = false
			end

			library.current_element_open = cfg
		else
			dd_search_tb.Text = ""
			filter_dd_options("")
		end
	end

	function cfg.set(value)
		local selected = {}
		local is_table = type(value) == "table"

		for _, opt_btn in ipairs(cfg.option_instances) do
			local opt_name = opt_btn:GetAttribute("OptionName") or ""
			local is_selected = (opt_name == value) or (is_table and table.find(value, opt_name))
			local check_frame = opt_btn:FindFirstChild("CheckFrame")
			local check_mark = check_frame and check_frame:FindFirstChild("CheckMark")
			local left_strip = opt_btn:FindFirstChild("IndicatorStrip")
			local opt_label = opt_btn:FindFirstChild("OptionLabel")

			if is_selected then
				table.insert(selected, opt_name)
				tween_service:Create(opt_btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = themes.preset.accent,
					BackgroundTransparency = 0.82
				}):Play()
				if opt_label then
					tween_service:Create(opt_label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextColor3 = Color3.fromRGB(245, 248, 255)
					}):Play()
				end
				if check_frame then
					local acc = themes.preset.accent
					local lum = (acc.R * 0.299 + acc.G * 0.587 + acc.B * 0.114)
					local mark_color = (lum > 0.55) and Color3.fromRGB(15, 17, 24) or Color3.fromRGB(255, 255, 255)

					tween_service:Create(check_frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundColor3 = themes.preset.accent,
						BorderColor3 = themes.preset.accent
					}):Play()
					if check_mark then
						check_mark.TextColor3 = mark_color
						check_mark.Visible = true
					end
				end
				if left_strip then
					left_strip.Visible = true
				end
			else
				tween_service:Create(opt_btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(35, 38, 48),
					BackgroundTransparency = 1
				}):Play()
				if opt_label then
					tween_service:Create(opt_label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextColor3 = Color3.fromRGB(165, 170, 185)
					}):Play()
				end
				if check_frame then
					tween_service:Create(check_frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(20, 22, 28),
						BorderColor3 = Color3.fromRGB(55, 60, 75)
					}):Play()
					if check_mark then
						check_mark.Visible = false
					end
				end
				if left_strip then
					left_strip.Visible = false
				end
			end
		end

		cfg.multi_items = selected

		if cfg.multi then
			if #selected == 0 then
				dropdown.Text = "none"
				dropdown.TextColor3 = Color3.fromRGB(115, 120, 135)
			elseif #selected <= 2 then
				dropdown.Text = table.concat(selected, ", ")
				dropdown.TextColor3 = Color3.fromRGB(215, 220, 235)
			else
				dropdown.Text = string.format("%s, %s (+%d)", selected[1], selected[2], #selected - 2)
				dropdown.TextColor3 = Color3.fromRGB(240, 245, 255)
			end
			flags[cfg.flag] = selected
		else
			dropdown.Text = selected[1] or ""
			dropdown.TextColor3 = Color3.fromRGB(215, 220, 235)
			flags[cfg.flag] = selected[1] or ""
		end
		cfg.callback(flags[cfg.flag])
	end

	function cfg:refresh_options(refreshed_list)
		for _, v in next, cfg.option_instances do
			v:Destroy()
		end

		cfg.option_instances = {}

		for i, v in ipairs(refreshed_list) do
			local op3 = library:create("TextButton", {
				Parent = options,
				Name = "Option_" .. tostring(i),
				FontFace = library.font,
				TextColor3 = Color3.fromRGB(165, 170, 185),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				Text = "",
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0.5,
				Size = UDim2.new(1, -4, 0, 18),
				Position = UDim2.new(0, 2, 0, 2),
				BorderSizePixel = 0,
				TextSize = 12,
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(35, 38, 48),
			})
			op3:SetAttribute("OptionName", v)

			local row_corner = Instance.new("UICorner")
			row_corner.CornerRadius = UDim.new(0, 3)
			row_corner.Parent = op3

			local opt_label = Instance.new("TextLabel")
			opt_label.Name = "OptionLabel"
			opt_label.FontFace = library.font
			opt_label.Text = v
			opt_label.TextColor3 = Color3.fromRGB(165, 170, 185)
			opt_label.TextSize = 12
			opt_label.TextXAlignment = Enum.TextXAlignment.Left
			opt_label.BackgroundTransparency = 1
			opt_label.BorderSizePixel = 0
			opt_label.Parent = op3

			if cfg.multi then
				local check_frame = Instance.new("Frame")
				check_frame.Name = "CheckFrame"
				check_frame.Size = UDim2.new(0, 12, 0, 12)
				check_frame.Position = UDim2.new(0, 5, 0.5, -6)
				check_frame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
				check_frame.BorderColor3 = Color3.fromRGB(55, 60, 75)
				check_frame.BorderSizePixel = 1
				check_frame.Parent = op3

				local check_corner = Instance.new("UICorner")
				check_corner.CornerRadius = UDim.new(0, 2)
				check_corner.Parent = check_frame

				local check_mark = Instance.new("TextLabel")
				check_mark.Name = "CheckMark"
				check_mark.Size = UDim2.new(1, 0, 1, 0)
				check_mark.Position = UDim2.new(0, 0, 0, -1)
				check_mark.BackgroundTransparency = 1
				check_mark.Text = "✓"
				check_mark.Font = Enum.Font.GothamBold
				check_mark.TextSize = 10
				check_mark.TextColor3 = Color3.fromRGB(15, 17, 24)
				check_mark.Visible = false
				check_mark.Parent = check_frame

				opt_label.Position = UDim2.new(0, 23, 0, 0)
				opt_label.Size = UDim2.new(1, -25, 1, 0)
			else
				local strip = Instance.new("Frame")
				strip.Name = "IndicatorStrip"
				strip.Size = UDim2.new(0, 2, 0, 10)
				strip.Position = UDim2.new(0, 3, 0.5, -5)
				strip.BackgroundColor3 = themes.preset.accent
				strip.BorderSizePixel = 0
				strip.Visible = false
				strip.Parent = op3
				library:apply_theme(strip, "accent", "BackgroundColor3")

				opt_label.Position = UDim2.new(0, 10, 0, 0)
				opt_label.Size = UDim2.new(1, -12, 1, 0)
			end

			table.insert(cfg.option_instances, op3)

			op3.MouseEnter:Connect(function()
				local is_sel = table.find(cfg.multi_items, v) or (not cfg.multi and flags[cfg.flag] == v)
				if not is_sel then
					tween_service:Create(op3, TweenInfo.new(0.12), {
						BackgroundTransparency = 0.65
					}):Play()
					local lbl = op3:FindFirstChild("OptionLabel")
					if lbl then
						tween_service:Create(lbl, TweenInfo.new(0.12), {
							TextColor3 = Color3.fromRGB(225, 230, 245)
						}):Play()
					end
				end
			end)

			op3.MouseLeave:Connect(function()
				local is_sel = table.find(cfg.multi_items, v) or (not cfg.multi and flags[cfg.flag] == v)
				if not is_sel then
					tween_service:Create(op3, TweenInfo.new(0.12), {
						BackgroundTransparency = 1
					}):Play()
					local lbl = op3:FindFirstChild("OptionLabel")
					if lbl then
						tween_service:Create(lbl, TweenInfo.new(0.12), {
							TextColor3 = Color3.fromRGB(165, 170, 185)
						}):Play()
					end
				end
			end)

			op3.MouseButton1Down:Connect(function()
				if cfg.multi then
					local check_frame = op3:FindFirstChild("CheckFrame")
					if check_frame then
						check_frame.Size = UDim2.new(0, 8, 0, 8)
						check_frame.Position = UDim2.new(0, 7, 0.5, -4)
						tween_service:Create(check_frame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Size = UDim2.new(0, 12, 0, 12),
							Position = UDim2.new(0, 5, 0.5, -6)
						}):Play()
					end

					tween_service:Create(op3, TweenInfo.new(0.08), {
						BackgroundTransparency = 0.55
					}):Play()

					local selected_index = table.find(cfg.multi_items, v)
					if selected_index then
						table.remove(cfg.multi_items, selected_index)
					else
						table.insert(cfg.multi_items, v)
					end

					cfg.set(cfg.multi_items)
				else
					cfg.set_visible(false)
					cfg.open = false

					cfg.set(v)
				end
			end)

			local last_option_rc = 0
			local function fire_option_right_click()
				local now = tick()
				if now - last_option_rc < 0.25 then return end
				last_option_rc = now
				if library.on_dropdown_item_right_click then
					library.on_dropdown_item_right_click(cfg, v, op3)
				end
			end
			op3.MouseButton2Click:Connect(fire_option_right_click)
			op3.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton2 then
					fire_option_right_click()
				end
			end)
			for _, desc in ipairs(op3:GetDescendants()) do
				if desc:IsA("GuiObject") then
					desc.InputBegan:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton2 then
							fire_option_right_click()
						end
					end)
				end
			end
			op3.DescendantAdded:Connect(function(desc)
				if desc:IsA("GuiObject") then
					desc.InputBegan:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton2 then
							fire_option_right_click()
						end
					end)
				end
			end)
		end

		dropdown.Text = ""
		update_dropdown_dimensions()
	end


	dropdown.MouseButton1Click:Connect(function()
		cfg.open = not cfg.open

		cfg.set_visible(cfg.open)
	end)

	cfg:refresh_options(cfg.items)

	cfg.set(cfg.default)
	cfg.element_frame = object or dropdown_inline
	cfg.dropdown_btn = dropdown
	cfg.dropdown_inline = dropdown_inline
	cfg.content_inline = content_inline
	cfg.options_frame = options

	library.config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end

function library:colorpicker(properties)
	local cfg = {
		name = properties.name or nil,
		flag = properties.flag or tostring(2 ^ 789),
		color = properties.color or properties.default or Color3.new(1, 1, 1), -- Default to white color if not provided
		alpha = properties.alpha or 1,
		callback = properties.callback or function() end,
		animation = "normal",
		saved_color,
		right_holder = self.right_holder or nil,
		holder = self.holder or nil,
	}

	flags[cfg.flag] = {}

	local dragging_sat = false
	local dragging_hue = false
	local dragging_alpha = false

	local h, s, v = cfg.color:ToHSV()
	local a = cfg.alpha

	-- Button Instances
	local right_components
	if cfg.name then
		local object = library:create("TextLabel", {
			Parent = self.holder,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = cfg.name,
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, -26, 0, 12),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		right_components = library:create("Frame", {
			Parent = object,
			Name = "",
			Position = UDim2.new(1, 15, 0, 1),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		local list = library:create("UIListLayout", {
			Parent = right_components,
			Name = "",
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	end

	local icon_inline = library:create("TextButton", {
		Parent = cfg.name and right_components or self.right_holder,
		Name = "",
		Text = "",
		Size = UDim2.new(0, 16, 0, 10),
		Position = UDim2.new(0, -15, 0, 1),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 3,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(9, 9, 44),
	})

	local icon = library:create("Frame", {
		Parent = icon_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(22, 22, 108),
		ZIndex = 2,
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(41, 41, 204),
	})

	local glow = library:create("ImageLabel", {
		Parent = icon_inline,
		Name = "",
		ImageColor3 = Color3.fromRGB(41, 41, 204),
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 1, 40),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})
	--

	-- =========================================================================
	-- CATALOG COLOR PICKER (HIGH-FIDELITY EVENT-DRIVEN - ZERO FPS IMPACT)
	-- =========================================================================
	local picker_inline = library:create("Frame", {
		Parent = library.gui,
		Name = "NVL_CatalogColorPicker",
		Size = UDim2.new(0, 275, 0, 315),
		Position = dim2(0, icon_inline.AbsolutePosition.X + 1, 0, icon_inline.AbsolutePosition.Y + 17),
		BorderColor3 = Color3.fromRGB(35, 37, 45),
		ZIndex = 9999,
		BorderSizePixel = 0,
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(24, 26, 32),
	})

	local picker_corner = library:create("UICorner", {
		Parent = picker_inline,
		CornerRadius = UDim.new(0, 12),
	})

	local picker_stroke = library:create("UIStroke", {
		Parent = picker_inline,
		Color = Color3.fromRGB(48, 52, 65),
		Thickness = 1,
		Transparency = 0.25,
	})

	-- Top Bar: Title, Confirm button, Close X button
	local topbar = library:create("Frame", {
		Parent = picker_inline,
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 10000,
	})

	local topbar_title = library:create("TextLabel", {
		Parent = topbar,
		Name = "Title",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(245, 248, 255),
		Text = "Color Picker",
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 10001,
	})

	local topbar_btns = library:create("Frame", {
		Parent = topbar,
		Name = "TopbarButtons",
		Size = UDim2.new(0.5, -10, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 10001,
	})

	local topbar_layout = library:create("UIListLayout", {
		Parent = topbar_btns,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	-- Confirm Button (White pill with dark text)
	local confirm_btn = library:create("TextButton", {
		Parent = topbar_btns,
		Name = "ConfirmBtn",
		Text = "Confirm",
		TextColor3 = Color3.fromRGB(20, 22, 28),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = library.font,
		TextSize = 11,
		Size = UDim2.new(0, 56, 0, 20),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = 10002,
	})
	library:create("UICorner", { Parent = confirm_btn, CornerRadius = UDim.new(0, 10) })

	confirm_btn.MouseEnter:Connect(function()
		confirm_btn.BackgroundColor3 = Color3.fromRGB(230, 235, 245)
	end)
	confirm_btn.MouseLeave:Connect(function()
		confirm_btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end)

	-- Close X Button (Native Game Asset ID: 9154608052)
	local close_btn = library:create("ImageButton", {
		Parent = topbar_btns,
		Name = "CloseBtn",
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://9154608052",
		ImageColor3 = Color3.fromRGB(200, 205, 220),
		AutoButtonColor = false,
		ZIndex = 10002,
	})

	close_btn.MouseEnter:Connect(function()
		close_btn.ImageColor3 = Color3.fromRGB(255, 100, 100)
	end)
	close_btn.MouseLeave:Connect(function()
		close_btn.ImageColor3 = Color3.fromRGB(200, 205, 220)
	end)

	-- Mode Icons column (Right side of Wheel)
	local mode_col = library:create("Frame", {
		Parent = picker_inline,
		Name = "ModeColumn",
		Size = UDim2.new(0, 24, 0, 140),
		Position = UDim2.new(1, -34, 0, 36),
		BackgroundTransparency = 1,
		ZIndex = 10001,
	})

	local mode_layout = library:create("UIListLayout", {
		Parent = mode_col,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.SpaceBetween,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local current_picker_mode = "Circle" -- "Circle", "Square", "Triangle"
	local mode_circle_btn = library:create("ImageButton", {
		Parent = mode_col,
		Name = "CircleMode",
		Size = UDim2.new(0, 20, 0, 20),
		BackgroundTransparency = 1,
		Image = "rbxassetid://81707513428574",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 10002,
	})

	local mode_square_btn = library:create("ImageButton", {
		Parent = mode_col,
		Name = "SquareMode",
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://91460273345882",
		ImageColor3 = Color3.fromRGB(130, 135, 150),
		ZIndex = 10002,
	})

	local mode_triangle_btn = library:create("ImageButton", {
		Parent = mode_col,
		Name = "TriangleMode",
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://114667886210601",
		ImageColor3 = Color3.fromRGB(130, 135, 150),
		ZIndex = 10002,
	})

	local mode_palette_btn = library:create("ImageButton", {
		Parent = mode_col,
		Name = "PaletteMode",
		Size = UDim2.new(0, 20, 0, 20),
		BackgroundTransparency = 1,
		Image = "rbxassetid://89303973545283",
		ImageColor3 = Color3.fromRGB(130, 135, 150),
		ZIndex = 10002,
	})

	-- Main interactive Picker Area (Wheel & Square containers)
	local picker_area = library:create("Frame", {
		Parent = picker_inline,
		Name = "PickerArea",
		Size = UDim2.new(0, 145, 0, 145),
		Position = UDim2.new(0, 48, 0, 34),
		BackgroundTransparency = 1,
		ZIndex = 10001,
	})

	-- 1. Circle Mode (Color Wheel ImageLabel: 17109876169)
	local wheel_frame = library:create("ImageLabel", {
		Parent = picker_area,
		Name = "ColorWheel",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://17109876169",
		ZIndex = 10002,
		Visible = true,
	})

	local wheel_cursor = library:create("ImageLabel", {
		Parent = wheel_frame,
		Name = "WheelCursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 14, 0, 14),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://113086710991155",
		ZIndex = 10003,
	})

	-- 2. Square Mode (Photoshop-style Sat/Val gradient)
	local square_frame = library:create("Frame", {
		Parent = picker_area,
		Name = "SquarePicker",
		Size = UDim2.new(1, -6, 1, -6),
		Position = UDim2.new(0, 3, 0, 3),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 10002,
		Visible = false,
	})
	library:create("UICorner", { Parent = square_frame, CornerRadius = UDim.new(0, 6) })

	local sq_white = library:create("Frame", {
		Parent = square_frame,
		Name = "WhiteGrad",
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 10003,
	})
	library:create("UICorner", { Parent = sq_white, CornerRadius = UDim.new(0, 6) })
	library:create("UIGradient", {
		Parent = sq_white,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
	})

	local sq_black = library:create("Frame", {
		Parent = sq_white,
		Name = "BlackGrad",
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 10004,
	})
	library:create("UICorner", { Parent = sq_black, CornerRadius = UDim.new(0, 6) })
	library:create("UIGradient", {
		Parent = sq_black,
		Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) }),
	})

	local sq_cursor = library:create("Frame", {
		Parent = sq_black,
		Name = "SquareCursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 10, 0, 10),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 10005,
	})
	library:create("UICorner", { Parent = sq_cursor, CornerRadius = UDim.new(1, 0) })
	library:create("UIStroke", { Parent = sq_cursor, Color = Color3.fromRGB(0, 0, 0), Thickness = 1.5 })

	local function update_mode_visuals()
		wheel_frame.Visible = (current_picker_mode == "Circle")
		square_frame.Visible = (current_picker_mode == "Square" or current_picker_mode == "Triangle")
		mode_circle_btn.ImageColor3 = (current_picker_mode == "Circle") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 135, 150)
		mode_square_btn.ImageColor3 = (current_picker_mode == "Square") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 135, 150)
		mode_triangle_btn.ImageColor3 = (current_picker_mode == "Triangle") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 135, 150)
	end

	mode_circle_btn.MouseButton1Click:Connect(function() current_picker_mode = "Circle"; update_mode_visuals() end)
	mode_square_btn.MouseButton1Click:Connect(function() current_picker_mode = "Square"; update_mode_visuals() end)
	mode_triangle_btn.MouseButton1Click:Connect(function() current_picker_mode = "Triangle"; update_mode_visuals() end)

	-- Middle Bar: Tabs (HSV / RGB), Hex Input (#ff69b4), Color Preview Swatch
	local middle_bar = library:create("Frame", {
		Parent = picker_inline,
		Name = "MiddleBar",
		Size = UDim2.new(1, -24, 0, 24),
		Position = UDim2.new(0, 12, 0, 186),
		BackgroundTransparency = 1,
		ZIndex = 10001,
	})

	local tab_hsv_btn = library:create("TextButton", {
		Parent = middle_bar,
		Name = "TabHSV",
		Text = "HSV",
		Size = UDim2.new(0, 32, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = library.font,
		TextSize = 11,
		ZIndex = 10002,
	})

	local tab_hsv_line = library:create("Frame", {
		Parent = tab_hsv_btn,
		Name = "Underline",
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 10003,
	})

	local tab_rgb_btn = library:create("TextButton", {
		Parent = middle_bar,
		Name = "TabRGB",
		Text = "RGB",
		Size = UDim2.new(0, 32, 1, 0),
		Position = UDim2.new(0, 36, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(140, 145, 160),
		FontFace = library.font,
		TextSize = 11,
		ZIndex = 10002,
	})

	local tab_rgb_line = library:create("Frame", {
		Parent = tab_rgb_btn,
		Name = "Underline",
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 10003,
	})

	local current_colorspace = "HSV"
	tab_hsv_btn.MouseButton1Click:Connect(function()
		current_colorspace = "HSV"
		tab_hsv_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tab_hsv_line.Visible = true
		tab_rgb_btn.TextColor3 = Color3.fromRGB(140, 145, 160)
		tab_rgb_line.Visible = false
	end)

	tab_rgb_btn.MouseButton1Click:Connect(function()
		current_colorspace = "RGB"
		tab_rgb_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tab_rgb_line.Visible = true
		tab_hsv_btn.TextColor3 = Color3.fromRGB(140, 145, 160)
		tab_hsv_line.Visible = false
	end)

	-- Hex Input Box
	local hex_holder = library:create("Frame", {
		Parent = middle_bar,
		Name = "HexHolder",
		Size = UDim2.new(0, 95, 0, 22),
		Position = UDim2.new(0, 90, 0, 1),
		BackgroundColor3 = Color3.fromRGB(16, 18, 22),
		BorderSizePixel = 0,
		ZIndex = 10002,
	})
	library:create("UICorner", { Parent = hex_holder, CornerRadius = UDim.new(0, 6) })
	library:create("UIStroke", { Parent = hex_holder, Color = Color3.fromRGB(45, 48, 60), Thickness = 1 })

	local hex_input = library:create("TextBox", {
		Parent = hex_holder,
		Name = "HexInput",
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.new(0, 4, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(240, 245, 255),
		FontFace = library.font,
		TextSize = 11,
		ClearTextOnFocus = false,
		Text = "#FFFFFF",
		ZIndex = 10003,
	})

	-- Live Color Preview Box
	local color_preview = library:create("Frame", {
		Parent = middle_bar,
		Name = "ColorPreview",
		Size = UDim2.new(0, 42, 0, 22),
		Position = UDim2.new(1, -42, 0, 1),
		BackgroundColor3 = cfg.color,
		BorderSizePixel = 0,
		ZIndex = 10002,
	})
	library:create("UICorner", { Parent = color_preview, CornerRadius = UDim.new(0, 6) })
	library:create("UIStroke", { Parent = color_preview, Color = Color3.fromRGB(60, 65, 80), Thickness = 1 })

	-- Bottom Sliders Area (Hue, Saturation, Value)
	local sliders_area = library:create("Frame", {
		Parent = picker_inline,
		Name = "SlidersArea",
		Size = UDim2.new(1, -24, 0, 88),
		Position = UDim2.new(0, 12, 0, 218),
		BackgroundTransparency = 1,
		ZIndex = 10001,
	})

	local function make_catalog_slider(name, y_offset)
		local holder = library:create("Frame", {
			Parent = sliders_area,
			Name = name .. "Holder",
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.new(0, 0, 0, y_offset),
			BackgroundTransparency = 1,
			ZIndex = 10002,
		})

		local track_btn = library:create("TextButton", {
			Parent = holder,
			Name = "Track",
			Text = "",
			Size = UDim2.new(1, -44, 0, 12),
			Position = UDim2.new(0, 0, 0.5, -6),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			ZIndex = 10003,
		})
		library:create("UICorner", { Parent = track_btn, CornerRadius = UDim.new(0, 6) })

		local dragger = library:create("Frame", {
			Parent = track_btn,
			Name = "Dragger",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 4, 1, 4),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 10005,
		})
		library:create("UICorner", { Parent = dragger, CornerRadius = UDim.new(0, 3) })
		library:create("UIStroke", { Parent = dragger, Color = Color3.fromRGB(15, 17, 24), Thickness = 1 })

		local val_lbl = library:create("TextLabel", {
			Parent = holder,
			Name = "ValLabel",
			Size = UDim2.new(0, 38, 1, 0),
			Position = UDim2.new(1, -38, 0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(215, 220, 235),
			FontFace = library.font,
			TextSize = 11,
			Text = "100",
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 10003,
		})

		return track_btn, dragger, val_lbl
	end

	local hue_track, hue_dragger, hue_lbl = make_catalog_slider("Hue", 0)
	local sat_track, sat_dragger, sat_lbl = make_catalog_slider("Sat", 28)
	local val_track, val_dragger, val_lbl = make_catalog_slider("Val", 56)

	-- Hue rainbow gradient
	local hue_grad = library:create("UIGradient", {
		Parent = hue_track,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
	})

	-- Saturation gradient (White to current hue/value)
	local sat_grad = library:create("UIGradient", {
		Parent = sat_track,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, v)),
		}),
	})

	-- Value/Brightness gradient (Black to current hue/sat)
	local val_grad = library:create("UIGradient", {
		Parent = val_track,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 1)),
		}),
	})

	-- Enable smooth dragging for modal
	pcall(function()
		if library.make_smooth_draggable then
			library:make_smooth_draggable(picker_inline, topbar)
		end
	end)

	-- Modal Visibility & Position sync
	function cfg.set_visible(bool)
		picker_inline.Visible = bool

		if bool then
			if library.current_element_open and library.current_element_open ~= cfg then
				library.current_element_open.set_visible(false)
				library.current_element_open.open = false
			end
			library.current_element_open = cfg

			local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
			local abs = icon_inline.AbsolutePosition
			local targetX = abs.X + 22
			local targetY = abs.Y - 10
			if targetX + 285 > vp.X then targetX = abs.X - 280 end
			if targetY + 325 > vp.Y then targetY = vp.Y - 330 end
			if targetX < 10 then targetX = 10 end
			if targetY < 10 then targetY = 10 end

			picker_inline.Position = UDim2.new(0, targetX, 0, targetY)
		end
	end

	close_btn.MouseButton1Click:Connect(function()
		cfg.open = false
		cfg.set_visible(false)
	end)

	confirm_btn.MouseButton1Click:Connect(function()
		cfg.open = false
		cfg.set_visible(false)
	end)

	icon_inline.MouseButton1Click:Connect(function()
		cfg.open = not cfg.open
		cfg.set_visible(cfg.open)
	end)

	local dragging_wheel = false
	local dragging_square = false
	local dragging_hue_slider = false
	local dragging_sat_slider = false
	local dragging_val_slider = false

	local function color3_to_hex_str(c3)
		local r = math.clamp(math.floor(c3.R * 255 + 0.5), 0, 255)
		local g = math.clamp(math.floor(c3.G * 255 + 0.5), 0, 255)
		local b = math.clamp(math.floor(c3.B * 255 + 0.5), 0, 255)
		return string.format("#%02x%02x%02x", r, g, b)
	end

	function cfg.set(color, alpha)
		if type(color) == "table" then
			alpha = color.Transparency or color.transparency or alpha
			color = color.Color or color.color or (color[1] and type(color[1]) == "number" and Color3.fromRGB(color[1], color[2], color[3])) or nil
		end
		if typeof(color) == "Color3" then
			h, s, v = color:ToHSV()
		end
		if type(alpha) == "number" then
			a = alpha
		end

		local currentColor = Color3.fromHSV(h, s, v)

		-- Update Color Preview and Hex Input
		color_preview.BackgroundColor3 = currentColor
		if not hex_input:IsFocused() then
			hex_input.Text = color3_to_hex_str(currentColor)
		end

		-- Update Slider dragger positions & labels
		hue_dragger.Position = UDim2.new(math.clamp(h, 0, 1), 0, 0.5, 0)
		hue_lbl.Text = tostring(math.floor(h * 360 + 0.5))

		sat_dragger.Position = UDim2.new(math.clamp(s, 0, 1), 0, 0.5, 0)
		sat_lbl.Text = tostring(math.floor(s * 100 + 0.5))

		val_dragger.Position = UDim2.new(math.clamp(v, 0, 1), 0, 0.5, 0)
		val_lbl.Text = tostring(math.floor(v * 100 + 0.5))

		-- Update Gradient track color destinations
		sat_grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, v)),
		})
		val_grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 1)),
		})

		-- Update Wheel Cursor position (Polar to Cartesian)
		local angle = (h * 2 * math.pi) - math.pi
		local radius = 62 * math.clamp(s, 0, 1)
		local cx = 72 + math.cos(angle) * radius
		local cy = 72 + math.sin(angle) * radius
		wheel_cursor.Position = UDim2.new(0, cx, 0, cy)

		-- Update Square cursor & background
		square_frame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		sq_cursor.Position = UDim2.new(math.clamp(s, 0, 1), 0, 1 - math.clamp(v, 0, 1), 0)

		-- Update Icon next to toggle
		icon_inline.BackgroundColor3 = Color3.fromRGB(currentColor.R * 60, currentColor.G * 60, currentColor.B * 60)
		icon.BorderColor3 = Color3.fromRGB(
			math.floor((currentColor.R * 255) + 0.5) / 2,
			math.floor((currentColor.G * 255) + 0.5) / 2,
			math.floor((currentColor.B * 255) + 0.5) / 2
		)
		icon.BackgroundColor3 = currentColor
		glow.ImageColor3 = currentColor

		cfg.color = currentColor
		cfg.alpha = a

		flags[cfg.flag] = setmetatable({
			Color = currentColor,
			color = currentColor,
			Transparency = a,
			transparency = a,
		}, {
			__index = currentColor,
			__tostring = function() return tostring(currentColor) end,
		})
		cfg.saved_color = currentColor

		cfg.callback(currentColor, a)
	end

	-- Hex Input Listener
	hex_input.FocusLost:Connect(function()
		local raw = hex_input.Text:gsub("^#", "")
		if #raw == 6 and raw:match("^%x+$") then
			local ok, col = pcall(function() return Color3.fromHex(raw) end)
			if ok and col then
				cfg.set(col, a)
				return
			end
		end
		hex_input.Text = color3_to_hex_str(cfg.color)
	end)

	-- Event-driven Interactive Mouse Handlers (Zero FPS Impact)
	local function process_wheel_input()
		local m = uis:GetMouseLocation()
		local abs = wheel_frame.AbsolutePosition
		local center = Vector2.new(abs.X + 72, abs.Y + 72 + gui_offset)
		local dx = m.X - center.X
		local dy = (m.Y - gui_offset) - (abs.Y + 72)
		local dist = math.sqrt(dx * dx + dy * dy)
		local angle = math.atan2(dy, dx)
		local new_h = (angle + math.pi) / (2 * math.pi)
		local new_s = math.clamp(dist / 62, 0, 1)
		h = new_h
		s = new_s
		cfg.set(Color3.fromHSV(h, s, v), a)
	end

	local function process_square_input()
		local m = uis:GetMouseLocation()
		local abs = square_frame.AbsolutePosition
		local sx = square_frame.AbsoluteSize.X
		local sy = square_frame.AbsoluteSize.Y
		s = math.clamp((m.X - abs.X) / sx, 0, 1)
		v = 1 - math.clamp((m.Y - gui_offset - abs.Y) / sy, 0, 1)
		cfg.set(Color3.fromHSV(h, s, v), a)
	end

	local function process_slider_input(track, sliderType)
		local m = uis:GetMouseLocation()
		local abs = track.AbsolutePosition.X
		local width = track.AbsoluteSize.X
		local ratio = math.clamp((m.X - abs) / width, 0, 1)
		if sliderType == "hue" then
			h = ratio
		elseif sliderType == "sat" then
			s = ratio
		elseif sliderType == "val" then
			v = ratio
		end
		cfg.set(Color3.fromHSV(h, s, v), a)
	end

	wheel_frame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 and current_picker_mode == "Circle" then
			dragging_wheel = true
			process_wheel_input()
		end
	end)

	square_frame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 and (current_picker_mode == "Square" or current_picker_mode == "Triangle") then
			dragging_square = true
			process_square_input()
		end
	end)

	hue_track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging_hue_slider = true
			process_slider_input(hue_track, "hue")
		end
	end)

	sat_track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging_sat_slider = true
			process_slider_input(sat_track, "sat")
		end
	end)

	val_track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging_val_slider = true
			process_slider_input(val_track, "val")
		end
	end)

	uis.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging_wheel = false
			dragging_square = false
			dragging_hue_slider = false
			dragging_sat_slider = false
			dragging_val_slider = false
		end
	end)

	uis.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement then
			if dragging_wheel then
				process_wheel_input()
			elseif dragging_square then
				process_square_input()
			elseif dragging_hue_slider then
				process_slider_input(hue_track, "hue")
			elseif dragging_sat_slider then
				process_slider_input(sat_track, "sat")
			elseif dragging_val_slider then
				process_slider_input(val_track, "val")
			end
		end
	end)

	cfg.saved_color = hsv(h, s, v)
	local selected = normal
	flags[cfg.flag]["animation"] = "normal"

	local function update_anim()
		if selected ~= "normal" then
			cfg.set(
				hsv(
					selected == "rainbow" and library.sin or h,
					selected == "rainbow" and 1 or s,
					selected == "fade" and library.sin or v
				),
				selected == "fade_alpha" and library.sin
			)
		end
	end

	rainbow.MouseButton1Down:Connect(function()
		selected.BackgroundTransparency = 1
		selected = "rainbow"
		rainbow.BackgroundTransparency = 0

		flags[cfg.flag]["animation"] = "rainbow"
		cfg.saved_color = hsv(s, s, v)
		library.animated_colorpickers[cfg] = update_anim
	end)

	fade_alpha.MouseButton1Down:Connect(function()
		selected.BackgroundTransparency = 1
		selected = "fade_alpha"
		fade_alpha.BackgroundTransparency = 0

		flags[cfg.flag]["animation"] = "fade_alpha"
		cfg.saved_color = hsv(s, s, v)
		library.animated_colorpickers[cfg] = update_anim
	end)

	fade.MouseButton1Down:Connect(function()
		selected.BackgroundTransparency = 1
		selected = "fade"
		fade.BackgroundTransparency = 0

		flags[cfg.flag]["animation"] = "fade"
		cfg.saved_color = hsv(s, s, v)
		library.animated_colorpickers[cfg] = update_anim
	end)

	normal.MouseButton1Down:Connect(function()
		selected.BackgroundTransparency = 1
		selected = "normal"
		normal.BackgroundTransparency = 0

		flags[cfg.flag]["animation"] = "normal"
		library.animated_colorpickers[cfg] = nil
		cfg.set(cfg.saved_color)
	end)

	cfg.set(cfg.color, cfg.alpha)

	self.previous_holder = parent

	library.config_flags[cfg.flag] = cfg.set

	cfg.previous_holder = self.previous_holder
	cfg.bottom_holder = self.bottom_holder
	cfg.right_holder = self.right_holder

	return setmetatable(cfg, library)
end

function library:keybind(properties)
	local toggled = false
	local parent_name = self.name or nil
	local cfg = {
		flag = properties.flag or tostring(2 ^ math.random(1, 30) * 3),
		keybind_name = properties.keybind_name or parent_name or nil,
		open = false,
		binding = nil,
		name = properties.name or nil,
		key = properties.default or properties.key or nil,
		mode = properties.mode or "toggle",
		active = properties.active or false,
		display = properties.displayName or properties.display or properties.name or parent_name or nil,
		hold_instances = {},
	}

	local original_callback = properties.callback or function() end
	cfg.callback = function(val)
		if self.set then
			self.set(val)
		end
		original_callback(val)
	end

	flags[cfg.flag] = {}

	local key = library:new_keybind({
		text = cfg.display,
		key = cfg.key,
		mode = cfg.mode,
	})

	-- Instances
	local right_components
	local object
	if cfg.name then
		object = library:create("TextLabel", {
			Parent = self.holder,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = cfg.name,
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, -26, 0, 12),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		right_components = library:create("Frame", {
			Parent = object,
			Name = "",
			Position = UDim2.new(1, 15, 0, 1),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		local list = library:create("UIListLayout", {
			Parent = right_components,
			Name = "",
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	end

	local keybind = library:create("TextButton", {
		Parent = cfg.name and right_components or self.right_holder,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "ERROR",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(0, 16, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	-- Settings Cog Icon (Phổ biến: rbxassetid://6031280882)
	local settings_btn = library:create("ImageButton", {
		Parent = cfg.name and right_components or self.right_holder,
		Name = "KeybindSettingsIcon",
		Size = UDim2.new(0, 11, 0, 11),
		Position = UDim2.new(0, 0, 0, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://6031280882",
		ImageColor3 = Color3.fromRGB(150, 150, 150),
		AutoButtonColor = false,
	})

	settings_btn.MouseEnter:Connect(function()
		settings_btn.ImageColor3 = themes.preset.accent or Color3.fromRGB(220, 220, 220)
	end)

	settings_btn.MouseLeave:Connect(function()
		settings_btn.ImageColor3 = Color3.fromRGB(150, 150, 150)
	end)

	local content_inline = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(0, 58, 0, 0),
		Position = dim2(0, keybind.AbsolutePosition.X, 0, keybind.AbsolutePosition.Y - 5),
		BorderSizePixel = 0,
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local function update_keybind_popup_pos()
		local ref = settings_btn or keybind
		if ref then
			pcall(function()
				content_inline.Position = UDim2.new(0, ref.AbsolutePosition.X - 45, 0, ref.AbsolutePosition.Y + 14)
			end)
		end
	end

	keybind:GetPropertyChangedSignal("AbsolutePosition"):Connect(update_keybind_popup_pos)
	settings_btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(update_keybind_popup_pos)

	local content = library:create("Frame", {
		Parent = content_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local options = library:create("Frame", {
		Parent = content,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = options,
		Name = "",
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local hold = library:create("TextButton", {
		Parent = options,
		Name = "HoldOption",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "Hold",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 13),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = hold,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	local press = library:create("TextButton", {
		Parent = options,
		Name = "ToggleOption",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "Toggle",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 13),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = press,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	local always = library:create("TextButton", {
		Parent = options,
		Name = "AlwaysOption",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "Always",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 13),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = always,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = options,
		Name = "",
		PaddingBottom = UDim.new(0, 4),
	})
	--

	local function update_mode_visuals()
		hold.BackgroundTransparency = (cfg.mode == "hold") and 0 or 1
		press.BackgroundTransparency = (cfg.mode == "toggle") and 0 or 1
		always.BackgroundTransparency = (cfg.mode == "always") and 0 or 1
		hold.TextColor3 = (cfg.mode == "hold") and (themes.preset.accent or Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(170, 170, 170)
		press.TextColor3 = (cfg.mode == "toggle") and (themes.preset.accent or Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(170, 170, 170)
		always.TextColor3 = (cfg.mode == "always") and (themes.preset.accent or Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(170, 170, 170)
	end

	function cfg.set_visible(bool)
		content_inline.Visible = bool

		if bool then
			update_keybind_popup_pos()
			update_mode_visuals()
			if library.current_element_open and library.current_element_open ~= cfg then
				library.current_element_open.set_visible(false)
				library.current_element_open.open = false
			end

			library.current_element_open = cfg
		end
	end

	function cfg.set_mode(mode)
		cfg.mode = mode

		if mode == "always" then
			cfg.set(true)
		elseif mode == "hold" then
			cfg.set(false)
		end

		flags[cfg.flag] = {
			mode = cfg.mode,
			key = cfg.key,
			active = cfg.active,
		}

		flags[cfg.flag]["mode"] = mode
		update_mode_visuals()
	end

	function cfg.set(input)
		if type(input) == "boolean" then
			local __cached = input

			if cfg.mode == "always" then
				__cached = true
			end

			cfg.active = __cached
			toggled = __cached
			flags[cfg.flag]["active"] = __cached
			cfg.callback(__cached)

			flags[cfg.flag] = {
				mode = cfg.mode,
				key = cfg.key,
				active = cfg.active,
			}
		elseif tostring(input):find("Enum") then
			input = input.Name == "Escape" and "..." or input

			cfg.key = input or "..."

			local _text = keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")
			local _text2 = (tostring(_text):gsub("KeyCode.", ""):gsub("UserInputType.", "")) or "..."
			cfg.key_name = _text2

			flags[cfg.flag]["mode"] = cfg.mode
			flags[cfg.flag]["key"] = cfg.key

			keybind.Text = "[" .. string.lower(_text2) .. "]"

			cfg.callback(cfg.active or false)

			flags[cfg.flag] = {
				mode = cfg.mode,
				key = cfg.key,
				active = cfg.active,
			}
		elseif table.find({ "toggle", "hold", "always" }, input) then
			cfg.set_mode(input)

			if input == "always" then
				cfg.active = true
			end

			cfg.callback(cfg.active or false)

			flags[cfg.flag] = {
				mode = cfg.mode,
				key = cfg.key,
				active = cfg.active,
			}
		elseif type(input) == "table" then
			input.key = type(input.key) == "string" and input.key ~= "..." and library:convert_enum(input.key)
				or input.key

			input.key = input.key == Enum.KeyCode.Escape and "..." or input.key
			cfg.key = input.key or "..."

			cfg.mode = input.mode or "toggle"

			if input.active then
				cfg.active = input.active
				toggled = input.active
			end

			flags[cfg.flag] = {
				mode = cfg.mode,
				key = cfg.key,
				active = cfg.active,
			}

			local text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
			local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))

			keybind.Text = "[" .. string.lower(__text) .. "]" or "..."
			cfg.key_name = __text
		end

		if cfg.keybind_name and cfg.display ~= "menu" and cfg.name ~= "Menu Key" then
			key.change_text(keybind.Text .. " " .. cfg.keybind_name .. " (" .. flags[cfg.flag].mode .. ")")
			key.set_visible(cfg.active)
		end
	end

	hold.MouseButton1Click:Connect(function()
		cfg.set_mode("hold")
		cfg.set_visible(false)
		cfg.open = false

		key.update({
			text = cfg.display,
			key = cfg.key,
			mode = cfg.mode,
		})
	end)

	press.MouseButton1Click:Connect(function()
		cfg.set_mode("toggle")
		cfg.set_visible(false)
		cfg.open = false

		key.update({
			text = cfg.display,
			key = cfg.key,
			mode = cfg.mode,
		})
	end)

	always.MouseButton1Click:Connect(function()
		cfg.set_mode("always")
		cfg.set_visible(false)
		cfg.open = false

		key.update({
			text = cfg.display,
			key = cfg.key,
			mode = cfg.mode,
		})
	end)

	settings_btn.MouseButton1Click:Connect(function()
		cfg.open = not cfg.open
		cfg.set_visible(cfg.open)
	end)

	keybind.MouseButton2Click:Connect(function()
		cfg.open = not cfg.open
		cfg.set_visible(cfg.open)
	end)

	keybind.MouseButton1Down:Connect(function()
		task.wait()
		keybind.Text = "..."

		if library.current_active_keybind_conn then
			pcall(function() library.current_active_keybind_conn:Disconnect() end)
			library.current_active_keybind_conn = nil
		end
		if library.current_active_keybind_reset then
			pcall(library.current_active_keybind_reset)
			library.current_active_keybind_reset = nil
		end

		library.current_active_keybind_reset = function()
			local _cur_text = keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")
			local _cur_text2 = (tostring(_cur_text):gsub("KeyCode.", ""):gsub("UserInputType.", "")) or "..."
			keybind.Text = "[" .. string.lower(_cur_text2) .. "]"
		end

		local conn
		conn = uis.InputBegan:Connect(function(input, game_event)
			if getgenv()._nvl_suppress_keybind then return end

			local selected_key = nil
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
					selected_key = "..."
				else
					selected_key = input.KeyCode
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3
			then
				selected_key = input.UserInputType
			end

			if selected_key then
				if conn then
					conn:Disconnect()
					conn = nil
				end
				library.current_active_keybind_conn = nil
				library.current_active_keybind_reset = nil

				if selected_key == "..." then
					cfg.key = nil
					flags[cfg.flag]["key"] = nil
					keybind.Text = "[...]"
				else
					cfg.set(selected_key)
				end

				key.update({
					text = cfg.display,
					key = cfg.key,
					mode = cfg.mode,
				})
			end
		end)

		library.current_active_keybind_conn = conn
		cfg.binding = conn
	end)

	library:connection(uis.InputBegan, function(input, game_event)
		if not game_event and not getgenv()._nvl_suppress_keybind then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == cfg.key then
					if cfg.mode == "toggle" then
						toggled = not toggled
						cfg.set(toggled)
					elseif cfg.mode == "hold" then
						cfg.set(true)
					end
				end
			else
				if input.UserInputType == cfg.key then
					if cfg.mode == "toggle" then
						toggled = not toggled
						cfg.set(toggled)
					elseif cfg.mode == "hold" then
						cfg.set(true)
					end
				end
			end
		end
	end)

	library:connection(uis.InputEnded, function(input, game_event)
		if game_event or getgenv()._nvl_suppress_keybind then
			return
		end

		local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType

		if selected_key == cfg.key then
			if cfg.mode == "hold" then
				cfg.set(false)
			end
		end
	end)

	cfg.set({ mode = cfg.mode, active = cfg.active, key = cfg.key })
	key.update({
		text = cfg.display,
		key = cfg.key,
		mode = cfg.mode,
	})

	library.config_flags[cfg.flag] = cfg.set

	cfg.previous_holder = self.previous_holder
	cfg.bottom_holder = self.bottom_holder
	cfg.right_holder = self.right_holder
	cfg.element_frame = object or keybind

	return setmetatable(cfg, library)
end

function library:button(properties)
	local cfg = {
		callback = properties.callback or function() end,
		name = properties.text or properties.name or "Button",
	}

	local button_inline = library:create("Frame", {
		Parent = self.holder,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local button = library:create("TextButton", {
		Parent = button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	button.MouseButton1Click:Connect(function()
		cfg.callback()
	end)

	cfg.element_frame = button_inline

	return setmetatable(cfg, library)
end

function library:textbox(properties)
	local cfg = {
		placeholder = properties.placeholder
			or properties.placeholdertext
			or properties.holder
			or properties.holdertext
			or "type here...",
		default = properties.default,
		clear_on_focus = properties.clearonfocus or false,
		flag = properties.flag or "...",
		callback = properties.callback or function() end,
	}

	local textbox_inline = library:create("Frame", {
		Parent = self.holder,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local textbox = library:create("TextBox", {
		Parent = textbox_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		ClearTextOnFocus = cfg.clear_on_focus,
		PlaceholderColor3 = Color3.fromRGB(90, 90, 90),
		CursorPosition = -1,
		PlaceholderText = cfg.placeholder,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local tb_caret = library:create("Frame", {
		Parent = textbox_inline,
		Name = "Caret",
		Position = UDim2.new(0, 4, 0.5, -6),
		Size = UDim2.new(0, 1.5, 0, 12),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	})
	library:attach_word_caret(textbox, tb_caret, 4, -6)

	textbox:GetPropertyChangedSignal("Text"):Connect(function()
		if setthreadidentity then pcall(setthreadidentity, 8) end
		local txt = ""
		local ok = pcall(function() txt = textbox.Text end)
		if ok then
			flags[cfg.flag] = txt
			cfg.callback(txt)
		end
	end)

	function cfg.set(text)
		flags[cfg.flag] = text
		textbox.Text = text
		cfg.callback(text)
	end

	if cfg.default then
		cfg.set(cfg.default)
	end

	cfg.element_frame = textbox_inline
	cfg.textbox = textbox
	cfg.textbox_inline = textbox_inline

	library.config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end

function library:panel(properties)
	if library.__panel == true then
		return
	end

	library.__panel = true

	local cfg = {
		name = properties.name or "Are you sure?",
		options = properties.options or { "Confirm", "Discard" },
		callback = properties.callback or function() end,
	}

	local panel_main_frame = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BackgroundTransparency = 0.4000000059604645,
		Size = UDim2.new(1, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 3,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local holder = library:create("Frame", {
		Parent = panel_main_frame,
		Name = "",
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 4,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	local inline1 = library:create("Frame", {
		Parent = holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(56, 56, 56),
	})

	local main = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 4, 0, 4),
		BorderColor3 = Color3.fromRGB(26, 26, 26),
		Size = UDim2.new(1, -8, 1, -8),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = main,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local tabs = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 8, 0, 8),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(1, -16, 1, -16),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = tabs,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = tabs,
		Name = "",
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 22),
		PaddingRight = UDim.new(0, 20),
		PaddingLeft = UDim.new(0, 20),
	})

	local aimbot = library:create("TextLabel", {
		Parent = tabs,
		Name = "",
		FontFace = library.font,
		LineHeight = 1.2000000476837158,
		TextStrokeTransparency = 0.5,
		AnchorPoint = Vector2.new(0.5, 0),
		TextSize = 12,
		Size = UDim2.new(0, 0, 0, 11),
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 8),
		BorderSizePixel = 0,
		TextYAlignment = Enum.TextYAlignment.Top,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = aimbot,
		Name = "",
		PaddingTop = UDim.new(0, 6),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = tabs,
		Name = "",
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 4),
	})

	local Frame = library:create("Frame", {
		Parent = tabs,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = Frame,
		Name = "",
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 3),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = Frame,
		Name = "",
	})

	-- local textbox_inline = library:create("Frame", {
	--     Parent = Frame,
	--     Name = "",
	--     Position = UDim2.new(0, -15, 0, 2),
	--     BorderColor3 = Color3.fromRGB(19, 19, 19),
	--     Size = UDim2.new(0, 130, 0, 16),
	--     BorderSizePixel = 0,
	--     BackgroundColor3 = Color3.fromRGB(8, 8, 8)
	-- })

	-- local textbox = library:create("TextBox", {
	--     Parent = textbox_inline,
	--     Name = "",
	--     FontFace = library.font,
	--     TextColor3 = Color3.fromRGB(170, 170, 170),
	--     BorderColor3 = Color3.fromRGB(56, 56, 56),
	--     Text = "",
	--     TextStrokeTransparency = 0.5,
	--     Size = UDim2.new(1, -4, 1, -4),
	--     PlaceholderColor3 = Color3.fromRGB(90, 90, 90),
	--     Position = UDim2.new(0, 2, 0, 2),
	--     PlaceholderText = "name",
	--     TextSize = 12,
	--     BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	-- })

	for _, v in next, cfg.options do
		local button_inline = library:create("Frame", {
			Parent = Frame,
			Name = "",
			Position = UDim2.new(0, 0, 0, 4),
			BorderColor3 = Color3.fromRGB(19, 19, 19),
			Size = UDim2.new(0, 130, 0, 16),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(8, 8, 8),
		})

		local button = library:create("TextButton", {
			Parent = button_inline,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			Text = v,
			TextStrokeTransparency = 0.5,
			Position = UDim2.new(0, 2, 0, 2),
			Size = UDim2.new(1, -4, 1, -4),
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		button.MouseButton1Click:Connect(function()
			cfg.callback(v)
			panel_main_frame:Destroy()
			library.__panel = false
		end)
	end
end
--
--

return library
