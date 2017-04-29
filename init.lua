print('Upgrading baudrate from 115200 to 460800 ...')
uart.setup(0, 460800, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
print('Successfully upgraded baudrate to 460800!')

require('libs/LedMatrix/Matrix')
require('libs/LedMatrix/LedMatrix')
require('libs/Tetris/TetrisShape')
require('libs/Tetris/Tetris')
require('credentials')

local LEFT_BUTTON = 8   -- GPIO 15
local RIGHT_BUTTON = 5  -- GPIO 14
local ROTATE_BUTTON = 6 -- GPIO 12
local DOWN_BUTTON = 7   -- GPIO 13
local START_BUTTON = 2  -- GPIO 4


local wifiConfig = {}

-- Possible modes:   wifi.STATION       : station: join a WiFi network
--                   wifi.SOFTAP        : access point: create a WiFi network
--                   wifi.wifi.STATIONAP: both station and access point
wifiConfig.mode = wifi.STATION

if (wifiConfig.mode == wifi.SOFTAP) or (wifiConfig.mode == wifi.STATIONAP) then
   wifiConfig.accessPointConfig = {}
   wifiConfig.accessPointConfig.ssid = "ESP-"..node.chipid()   -- Name of the SSID you want to create
   wifiConfig.accessPointConfig.pwd = "ESP-"..node.chipid()    -- WiFi password - at least 8 characters

   wifiConfig.accessPointIpConfig = {}
   wifiConfig.accessPointIpConfig.ip = "192.168.111.1"
   wifiConfig.accessPointIpConfig.netmask = "255.255.255.0"
   wifiConfig.accessPointIpConfig.gateway = "192.168.111.1"
end

if (wifiConfig.mode == wifi.STATION) or (wifiConfig.mode == wifi.STATIONAP) then
   wifiConfig.stationConfig = {}
   wifiConfig.stationConfig.ssid = "Internet"        -- Name of the WiFi network you want to join
   wifiConfig.stationConfig.pwd =  ""                -- Password for the WiFi network
end

gpio.mode(LEFT_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(RIGHT_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(DOWN_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(ROTATE_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(START_BUTTON, gpio.INT, gpio.PULLUP)

ws2812.init()

function main()
    print("Main is executing...")
    local ledMatrix = newLedMatrix(13, 13, true, true, false, true, true)
    ledMatrix.ledBuffer:fill(0,0,0)
    ledMatrix:show()

    local tetris = newTetris(ledMatrix,60) -- Run tetris with 60FPS

    local started = false
    gpio.trig(START_BUTTON, "up", function(level, when)
        if not started then
            tetris:start()
            started = true
        else
            tetris:reset()
            started = false
        end
    end)
    
    print("Press the GPIO4 button to start the game!")
    
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
--tmr.alarm(0,2500,0,main) 
main()
