require "winapi"

Input = {
	mousetab = {},
	mousetab_prev = {},
	joypad = {},
	noteForm = nil,
}

function Input.update()
	Input.mousetab = input.getmouse()
	if Input.mousetab["Left"] and not Input.mousetab_prev["Left"] then
		local xmouse = Input.mousetab["X"]
		local ymouse = Input.mousetab["Y"] + GraphicConstants.UP_GAP
		Input.check(xmouse, ymouse)
	end
	Input.mousetab_prev = Input.mousetab

	local joypadButtons = joypad.get()
	-- "Settings.controls.CYCLE_VIEW" pressed
	if joypadButtons[Settings.controls.CYCLE_VIEW] == true and Input.joypad[Settings.controls.CYCLE_VIEW] ~= joypadButtons[Settings.controls.CYCLE_VIEW] then
		if Tracker.Data.inBattle == 1 then
			Tracker.Data.selectedPlayer = (Tracker.Data.selectedPlayer % 2) + 1
			if Tracker.Data.selectedPlayer == 1 then
				Tracker.Data.selectedSlot = 1
				Tracker.Data.targetPlayer = 2
				Tracker.Data.targetSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
			elseif Tracker.Data.selectedPlayer == 2 then
				local enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
				Tracker.Data.selectedSlot = enemySlotOne
				Tracker.Data.targetPlayer = 1
				Tracker.Data.targetSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotOne) + 1
				CopyMon()
			end
		else
			CopyMon()
		end

		Tracker.redraw = true
	end

	-- "Settings.controls.CYCLE_STAT" pressed, display box over next stat
	if joypadButtons[Settings.controls.CYCLE_STAT] == true and Input.joypad[Settings.controls.CYCLE_STAT] ~= joypadButtons[Settings.controls.CYCLE_STAT] then
		Tracker.controller.statIndex = (Tracker.controller.statIndex % 6) + 1
		Tracker.controller.framesSinceInput = 0
		Tracker.redraw = true
	else
		if Tracker.controller.framesSinceInput == Tracker.controller.boxVisibleFrames - 1 then
			Tracker.redraw = true
		end
		if Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames then
			Tracker.controller.framesSinceInput = Tracker.controller.framesSinceInput + 1
		end
	end

	-- "Settings.controls.NEXT_SEED"
	local allPressed = true
	for button in string.gmatch(Settings.controls.NEXT_SEED, '([^,]+)') do
		if joypadButtons[button] ~= true then
			allPressed = false
		end
	end
	if allPressed == true then
		Main.LoadNextSeed = true
	end

	-- "Settings.controls.CYCLE_PREDICTION" pressed, cycle stat prediction for selected stat
	if joypadButtons[Settings.controls.CYCLEl_PREDICTION] == true and Input.joypad[Settings.controls.CYCLE_PREDICTION] ~= joypadButtons[Settings.controls.CYCLE_PREDICTION] then
		if Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames then
			if Tracker.controller.statIndex == 1 then
				Program.StatButtonState.hp = ((Program.StatButtonState.hp + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.hp]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.hp]
				Tracker.controller.framesSinceInput = 0
			elseif Tracker.controller.statIndex == 2 then
				Program.StatButtonState.att = ((Program.StatButtonState.att + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.att]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.att]
				Tracker.controller.framesSinceInput = 0
			elseif Tracker.controller.statIndex == 3 then
				Program.StatButtonState.def = ((Program.StatButtonState.def + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.def]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.def]
				Tracker.controller.framesSinceInput = 0
			elseif Tracker.controller.statIndex == 4 then
				Program.StatButtonState.spa = ((Program.StatButtonState.spa + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.spa]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.spa]
				Tracker.controller.framesSinceInput = 0
			elseif Tracker.controller.statIndex == 5 then
				Program.StatButtonState.spd = ((Program.StatButtonState.spd + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.spd]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.spd]
				Tracker.controller.framesSinceInput = 0
			elseif Tracker.controller.statIndex == 6 then
				Program.StatButtonState.spe = ((Program.StatButtonState.spe + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.spe]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.spe]
				Tracker.controller.framesSinceInput = 0
			end
			Tracker.TrackStatPrediction(Tracker.Data.selectedPokemon.pokemonID, Program.StatButtonState)
			Tracker.redraw = true
		end
	end

	Input.joypad = joypadButtons
end

function CopyMon()
	local pName = PokemonData[Tracker.Data.selectedPokemon.pokemonID + 1].name
	local pHealth = Tracker.Data.selectedPokemon.maxHP
	local pAttack = Tracker.Data.selectedPokemon.atk
	local pDefense = Tracker.Data.selectedPokemon.def
	local pSAttack = Tracker.Data.selectedPokemon.spa
	local pSDefense = Tracker.Data.selectedPokemon.spd
	local pSpeed = Tracker.Data.selectedPokemon.spe
	local pLevel = Tracker.Data.selectedPokemon.level
	local pMove1 = MoveData[Tracker.Data.selectedPokemon.move1 + 1].name
	local pMove2 = MoveData[Tracker.Data.selectedPokemon.move2 + 1].name
	local pMove3 = MoveData[Tracker.Data.selectedPokemon.move3 + 1].name
	local pMove4 = MoveData[Tracker.Data.selectedPokemon.move4 + 1].name
	local pAbility = MiscData.ability[Tracker.Data.selectedPokemon["ability"] + 1]
	winapi.set_clipboard(pName .. "," .. pHealth .. "," .. pAttack .. "," .. pDefense .. "," .. pSAttack .. "," .. pSDefense .. "," .. pSpeed .. "," .. pLevel .. "," .. pMove1 .. "," .. pMove2 .. "," .. pMove3 .. "," .. pMove4 .. "," .. pAbility)
end

function Input.check(xmouse, ymouse)
	-- Tracker input regions
	if Program.state == State.TRACKER then
		---@diagnostic disable-next-line: deprecated
		for i = 1, table.getn(Buttons), 1 do
			if Buttons[i].visible() then
				if Buttons[i].type == ButtonType.singleButton then
					if Input.isInRange(xmouse, ymouse, Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4]) then
						Buttons[i].onclick()
						Tracker.redraw = true
					end
				end
			end
		end

		-- settings gear
		if Input.isInRange(xmouse, ymouse, GraphicConstants.SCREEN_WIDTH + 101 - 8, 7, 7, 7) then
			Options.redraw = true
			Program.state = State.SETTINGS
		end

		--note box
		if Input.isInRange(xmouse, ymouse, GraphicConstants.SCREEN_WIDTH + 6, 141, GraphicConstants.RIGHT_GAP - 12, 12) and Input.noteForm == nil then
			Input.noteForm = forms.newform(290, 60, "Note (70 char. max)", function() Input.noteForm = nil end)
			local textBox = forms.textbox(Input.noteForm, Tracker.GetNote(), 200, 20)
			forms.button(Input.noteForm, "Set", function()
				Tracker.SetNote(forms.gettext(textBox))
				Tracker.redraw = true
				forms.destroy(Input.noteForm)
				Input.noteForm = nil
			end, 200, 0)
		end

		-- Settings menu mouse input regions
	elseif Program.state == State.SETTINGS then
		-- Options buttons toggles
		for _, value in pairs(Options.optionsButtons) do
			if Input.isInRange(xmouse, ymouse, value.box[1], value.box[2], GraphicConstants.RIGHT_GAP - (value.box[3] * 2), value.box[4]) then
				value.optionState = value.onClick()
				Options.redraw = true
			end
		end

		-- Roms folder setting
		if Input.isInRange(xmouse, ymouse, Options.romsFolderOption.box[1], Options.romsFolderOption.box[2], GraphicConstants.RIGHT_GAP - (Options.romsFolderOption.box[3] * 2), Options.romsFolderOption.box[4]) then
			-- Use the standard file open dialog to get the roms folder
			local file = forms.openfile(nil, Settings.config.ROMS_FOLDER)
			-- Since the user had to pick a file, strip out the file name to just get the folder.
			Settings.config.ROMS_FOLDER = string.sub(file, 0, string.match(file, "^.*()\\") - 1)
			Options.redraw = true
			Options.updated = true
		end

		-- Settings close button
		if Input.isInRange(xmouse, ymouse, Options.closeButton.box[1], Options.closeButton.box[2], Options.closeButton.box[3], Options.closeButton.box[4]) then
			-- Save the Settings.ini file if any changes were made
			if Options.updated then
				Options.updated = false
				INI.save("Settings.ini", Settings)
			end
			Tracker.redraw = true
			Program.state = State.TRACKER
		end
	end
end

--[[
	Checks if a mouse click is within a range and returning true.

	xmouse, ymouse: number -> coordinates of the mouse
	x, y: number -> starting coordinate of the region being tested for clicks
	xregion, yregion -> size of the region being tested from the starting coordinates
]]
function Input.isInRange(xmouse, ymouse, x, y, xregion, yregion)
	if xmouse >= x and xmouse <= x + xregion then
		if ymouse >= y and ymouse <= y + yregion then
			return true
		end
	end
	return false
end
