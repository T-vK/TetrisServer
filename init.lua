print('Upgrading baudrate from 115200 to 460800')
uart.setup(0, 460800, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
print('Successfully upgraded to 460800 baudrate!')

require('libs/LedMatrix/Matrix')
require('libs/LedMatrix/LedMatrix')
require('libs/Tetris/TetrisShape')
require('libs/Tetris/Tetris')
--require('libs/')

local LEFT_BUTTON = 1   -- GPIO 5
local RIGHT_BUTTON = 2  -- GPIO 4
local ROTATE_BUTTON = 6 -- GPIO 12
local DOWN_BUTTON = 7   -- GPIO 13

gpio.mode(LEFT_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(RIGHT_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(DOWN_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(ROTATE_BUTTON, gpio.INT, gpio.PULLUP)

ws2812.init()

function main()
    print("Main is executing...")
    local ledMatrix = newLedMatrix(13, 13, true, true, false, true, true)
    ledMatrix.ledBuffer:fill(0,0,0)
    ledMatrix:show()

    local tetris = newTetris(ledMatrix,60) -- Run tetris with 60FPS
    tetris:start()

    -- Enable GPIO interrupts and internal pullup resistors on our button inputs
    -- Connect out buttons to the appropriate tetris actions
    local lastAction = 0
    local minTimeBetweenActions = 100000 -- This is to prevent buttons from accidental spamming. In microseconds (100000us=0.1s)

    gpio.trig(LEFT_BUTTON, "down", function(level, when)
        if when-lastAction < minTimeBetweenActions then
            return
        end
        print("left") 
        tetris:action("left")
        lastAction = when
    end)
    gpio.trig(RIGHT_BUTTON, "down", function(level, when)
        if when-lastAction < minTimeBetweenActions then
            return
        end
        print("right")
        tetris:action("right")
        lastAction = when
    end)
    gpio.trig(DOWN_BUTTON, "down", function(level, when)
        print("down")
        tetris:action("down")
        lastAction = when
    end)
    gpio.trig(ROTATE_BUTTON, "down", function(level, when)
        if when-lastAction < minTimeBetweenActions then
            return
        end
        print("rotateRight")
        tetris:action("rotateRight")
        lastAction = when
    end)
end
tmr.alarm(0,2500,0,main)
print("About to start main.")
