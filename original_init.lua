print('Upgrading baudrate from 115200 to 460800 ...')
uart.setup(0, 460800, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
print('\r\nSuccessfully upgraded baudrate to 460800!')

--require('libs/LedMatrix/Matrix')
--require('libs/LedMatrix/LedMatrix')
--require('libs/Tetris/TetrisShape')
--require('libs/Tetris/Tetris')
require('libs/HttpServer/HttpServer')
require('credentials')

local LEFT_BUTTON = 8   -- GPIO 15
local RIGHT_BUTTON = 5  -- GPIO 14
local ROTATE_BUTTON = 6 -- GPIO 12
local DOWN_BUTTON = 7   -- GPIO 13
local START_BUTTON = 2  -- GPIO 4

print(HOME_WIFI_SSID)

function main()
    print("Main is executing...")
       
    local wifiConfig = {}
    
    wifiConfig.mode = wifi.STATIONAP --wifi.STATIONAP --wifi.STATION --wifi.SOFTAP
    
    if (wifiConfig.mode == wifi.SOFTAP) or (wifiConfig.mode == wifi.STATIONAP) then
        wifiConfig.accessPointConfig = {}
        wifiConfig.accessPointConfig.ssid = AP_WIFI_SSID -- SSID of the AP you want to create
        wifiConfig.accessPointConfig.pwd =  AP_WIFI_PASS -- WiFi password - at least 8 characters
       
        wifiConfig.accessPointIpConfig = {}
        wifiConfig.accessPointIpConfig.ip = "192.168.111.1"
        wifiConfig.accessPointIpConfig.netmask = "255.255.255.0"
        wifiConfig.accessPointIpConfig.gateway = "192.168.111.1"
    end
    
    if (wifiConfig.mode == wifi.STATION) or (wifiConfig.mode == wifi.STATIONAP) then
        wifiConfig.stationConfig = {}
        wifiConfig.stationConfig.ssid = HOME_WIFI_SSID -- Name of the WiFi network you want to join
        wifiConfig.stationConfig.pwd =  HOME_WIFI_PASS -- Password for the WiFi network

    end
   
    wifi.setmode(wifiConfig.mode)
    --print('set (mode='..wifi.getmode()..')')

    if (wifiConfig.mode == wifi.SOFTAP) or (wifiConfig.mode == wifi.STATIONAP) then
        print('AP MAC: ',wifi.ap.getmac())
        wifi.ap.config(wifiConfig.accessPointConfig)
        wifi.ap.setip(wifiConfig.accessPointIpConfig)
    end

    if (wifiConfig.mode == wifi.STATION) or (wifiConfig.mode == wifi.STATIONAP) then
        print('Client MAC: ',wifi.sta.getmac())
        wifi.sta.config(wifiConfig.stationConfig.ssid, wifiConfig.stationConfig.pwd, 1)
    end

    
    wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("STATION_WRONG_PASSWORD") end)
    wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("STATION_NO_AP_FOUND") end)
    wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("STATION_CONNECT_FAIL") end)
    wifi.sta.eventMonReg(wifi.STA_GOTIP, function() 
        print("CONNECTED!")
        print("IP: " .. wifi.sta.getip())
    end)
    wifi.sta.eventMonStart()
    
    gpio.mode(LEFT_BUTTON, gpio.INT, gpio.PULLUP)
    gpio.mode(RIGHT_BUTTON, gpio.INT, gpio.PULLUP)
    gpio.mode(DOWN_BUTTON, gpio.INT, gpio.PULLUP)
    gpio.mode(ROTATE_BUTTON, gpio.INT, gpio.PULLUP)
    gpio.mode(START_BUTTON, gpio.INT, gpio.PULLUP)
    
    --[[
    ws2812.init()
    
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
    ]]
    local app = express.new()
    app:listen(80)
    
    -- create a new middleware that prints the url of every request
    app:use(function(req,res,next) 
        print(req.url)
        next()
    end)
    
    -- Create a new route that just returns an html site that says "HELLO WORLD!"
    app:get('/helloworld',function(req,res)
        res:send('<html><head></head><body>HELLO WORLD!</body></html>')
    end)
    
    app:use(express.static('/http'))
end

local started = false
gpio.trig(START_BUTTON, "up", function(level, when)
    if not started then
        main()
        started = true
    else
        return
    end
end)
--tmr.alarm(0,2500,0,main) 

print("Press the GPIO4 button to start the game!")

