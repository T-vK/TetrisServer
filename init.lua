print('Upgrading baudrate from 115200 to 460800 ...')
uart.setup(0, 460800, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
print('Successfully upgraded baudrate to 460800!')
test = 132
local START_BUTTON = 2  -- GPIO 4
gpio.mode(START_BUTTON, gpio.INT, gpio.PULLUP)

local started = false
gpio.trig(START_BUTTON, "up", function(level, when)
    if not started then
        print('start!')
        require('libs/HttpServer/example')
        started = true
    end
end)
print('READY')

