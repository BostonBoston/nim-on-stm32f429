# some avant garde bindings of stm32f4xx_hal_gpio.h provided by STM32CubeIDE
import ../device/stm32f429

type 
  GPIO* {.pure.} = enum
    a
    b
    c
    d
    e
    f
    g
    h
    i
    j
    k

  GPIOPin* = enum 
    gp0 = 0
    gp1 = 1
    gp2 = 2
    gp3 = 3
    gp4 = 4
    gp5 = 5
    gp6 = 6
    gp7 = 7
    gp8 = 8
    gp9 = 9
    gp10 = 10
    gp11 = 11
    gp12 = 12
    gp13 = 13
    gp14 = 14
    gp15 = 15
    gpAll = 0xFFFF

  GPIOMode* = enum
    gmInput = 0b00
    gmOutput = 0b01
    gmAlternateFunc = 0b10
    gmAnalog = 0b11

  GPIOOutputType* = enum
    gotPushPull = 0b0
    gotOpenDrain = 0b1

  GPIOSpeed* = enum
    gsLow = 0b00
    gsMedium = 0b01
    gsHigh = 0b10
    gsVeryHigh = 0b11


const gpioIndex: array[GPIO, GPIOK_Type] = [GPIOA, GPIOB, GPIOC, GPIOD, GPIOE, GPIOF, GPIOG, GPIOH GPIOI, GPIOJ, GPIOK]

func setGPIOxPinyMode(port: GPIO, pin: GPIOPin, mode: GPIOMode) =
  gpioIndex[port].MODER.modifyIt:
    it.clearMask(2*pin .. 2*pin+1)
    it.setMask((mode.uint32 shl 2*pin).masked(2*pin .. 2*pin+1))

func setGPIOxPinyOutputType(port: GPIO, pin: GPIOPin, otype: GPIOOutputType) =
  gpioIndex[port].OTYPER.modifyIt:
    it |= uint32 (mode shl (pin))

func setGPIOxPinySpeed(port: GPIO, pin: GPIOPin, speed: GPIOSpeed) = 
  gpioIndex[port].OSPEEDR.modifyIt:
    it |= uint32 (mode shl (2*pin))
  


