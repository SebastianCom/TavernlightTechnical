-- jumppopup.lua

--this hooks up this script as a module for the module manager
JumpPopup = {}

--The popup window for the jump game
local jumpWindow

--this is to stop the scheduled events on unload. Otherwise after destroying the window and button the MoveButton will try to access them throwing an error
local Loaded = false

--called when the module comes online - either game start if it has already been loaded or when it is loaded thorugh the manager
function online()
    jumpButton:show()
    Loaded = true;
end

--called when the package is unload or when the game ends. it hides the window and toggles off the button getting them ready to be destroyed
function offline()
    jumpWindow:hide()
    jumpButton:setOn(false)
end

--this function is called by jumppopup.otmod on load. In other words when the modual is loaded through the manager this is called
function init()

    --suscribes our Online function  to Games onGameStart and subscribe our Offline function to Games onGameEnd function
    connect(g_game, { onGameStart = online,
                      onGameEnd   = offline })
  
    --this creates our pop up window where the jump game is going to be played.
    jumpWindow = g_ui.displayUI('jumpwindow', modules.game_interface.getRightPanel())
    jumpWindow:hide()
  
    --this creates our button at the top left to open the game. I made the image the same as the spelllist but it says Jump Button if you hover of it 
    jumpButton = modules.client_topmenu.addRightGameToggleButton('jumpButton', tr('Jump Button'), '/images/topbuttons/spelllist', toggle)
    jumpButton:setOn(false)
  
    if g_game.isOnline() then
      online()
    end

    --This function is what repositions the button widget when you click. We call it once here to pick a randomized starting postion
    onButtonClick()

    --This is what starts making the button widget move. As far as i could tell there is no update method so to call our move button function we scheudule it as an event
    g_dispatcher.scheduleEvent(MoveButton, 0)

   
end

--handles the movement of the button widget. Moveing right to left at a speed of 10
function MoveButton()

    --because we schedule our events before hand there is a chance that after unloaded the module this function will be called but the references will be nill
    -- i use this bool to remedy that issue. When the module is unloaded this function will return and not schedule another interation
    if Loaded == false then
        return
    end


    -- here we grab the button widget reference from the jumpwindow.otui file
    local buttonWidget = jumpWindow:getChildById('jumpinnerbutton')

    --grab the x position of the button widget
    local Xpos = buttonWidget:getX()

    --subtract from the xposition to move the widget from right to left 
    local NewPos = Xpos - 10

    --last we need to factor in the widows xpositon so that we know where the edge of the window is 
    local windowXpos = jumpWindow:getX();

    --if the button widget hits the left side of the window OnClick will be called to move the button to a random Y postion of the right of the window
    -- in other words this wraps the button around the screen
    if NewPos < windowXpos + 2 then
       onButtonClick()
    else
        buttonWidget:setX(NewPos)
    end

   
    --last we schedule the next interation of the this function to move the button again. A delay is used this time to reduce the function being called faster and faster
    --each iteration
    g_dispatcher.scheduleEvent(MoveButton, 100)
    
end 



--this is a simple function that toggles the window and button to open the window. If is button is on then you close the window and turn it off, if the button is off
--turn it on and show the window. Because we have just opened the window we should also raise it and put it in focus so it appears above other open windows
function toggle()
    if jumpButton:isOn() then
       jumpButton:setOn(false)
       jumpWindow:hide()
    else
      jumpButton:setOn(true)
      jumpWindow:show()
      jumpWindow:raise()
      jumpWindow:focus()
    end
end


--this is the function that is called when you hit the button widget it is called from the jumpwindow.otui file
function onButtonClick()

    --grab the reference to the buttonWidget
    local buttonWidget = jumpWindow:getChildById('jumpinnerbutton')

    --grab the dimesnsions of the window and the buttons
    local windowWidth = jumpWindow:getWidth()
    local windowHeight = jumpWindow:getHeight()
    local buttonWidth = buttonWidget:getWidth()
    local buttonHeight = buttonWidget:getHeight()
    
    --get the windows position - its important to also factor in where the window is on the screen as this will change the bounds of the window 
    local windowXpos = jumpWindow:getX();
    local windowYpos = jumpWindow:getY();
    
    -- Set a fixed position on the x axis to return the button widget to the right side of the window
    local SetX = windowXpos + windowWidth - buttonWidth - 5

    -- Set a random level for the Y axis of the button widget. The minuim should be the top of the play area where as the maxium should be the bottom of the play area
    local randomY = math.random(windowYpos + 25, windowYpos + windowHeight - buttonHeight - 2)
    
    --last we pass through our new X and Y position to the button widget
    buttonWidget:setX(SetX)
    buttonWidget:setY(randomY)

end


--this function is linked to the jumppopup.otmod file and is called when @onUnload is called by the module manager 
function terminate()
    disconnect(g_game, { onGameStart = online,
                         onGameEnd   = offline })
  
    Loaded = false
    jumpWindow:destroy()
    jumpWindow = nil
    jumpButton:destroy()
    jumpButton = nil

  
  end












