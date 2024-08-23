# some avant garde bindings of stm32f4xx_hal_gpio.h provided by STM32CubeIDE
import ../device/stm32f429
import std/[macros, strutils, genasts]

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
  
  GPIOPuPd* = enum 
    pullNone = 0b00
    pullUp = 0b01
    pullDown = 0b10

  GPIOAltFunc* = enum 
    af0
    af1
    af2
    af3
    af4
    af5
    af6
    af7
    af8
    af9
    af10
    af11
    af12
    af13
    af14
    af15

const 
  afSystem* = GPIOAltFunc.af1
  afTIM1to2* = GPIOAltFunc.af1 # consider splitting names in to duplicate references to an alt func at the risk of confusion, i.e afTIM1* = GPIOAltLow.af1 and afTIM12* = GPIOAltLow.af1
  afTIM3to5* = GPIOAltFunc.af2
  afTIM8to11* = GPIOAltFunc.af3
  afI2C1to3* = GPIOAltFunc.af4
  afSPI1to6* = GPIOAltFunc.af5
  afSPI2to3SAI1* = GPIOAltFunc.af6
  afUSART1to3* = GPIOAltFunc.af7
  afUSART4to8* = GPIOAltFunc.af8
  afCAN1to2LTDCTIM12to14* = GPIOAltFunc.af9
  afOTG_FSHS* = GPIOAltFunc.af10
  afETH* = GPIOAltFunc.af11
  afFMCSDIOOTG_HS* = GPIOAltFunc.af12
  afDCMI* = GPIOAltFunc.af13
  afLTDC* = GPIOAltFunc.af14
  afEVENTOUT* = GPIOAltFunc.af15



# macros kind of feel like cheating but I can't think of a nicer way other than using the SVD bindings directly (no fun)

macro setGPIOxPinyMode*(port: static[GPIO], pin: static[GPIOPin], mode: GPIOMode): untyped =
  let setterCall = ident "MODER" & $pin.ord
  let reg = ident "GPIO" & ($port).toUpperAscii()
  quote do:
    `reg`.MODER.modifyIt:
      it.`setterCall` = mode

  # nnkStmtList.newTree(
  # nnkCall.newTree(
  #   nnkDotExpr.newTree(       
  #     nnkDotExpr.newTree(     
  #       newIdentNode("GPIO" & ($port).toUpperAscii()),
  #       newIdentNode("MODER")),
  #     newIdentNode("modifyIt")),
  #   nnkStmtList.newTree(      
  #     nnkAsgn.newTree(
  #       nnkDotExpr.newTree(
  #         newIdentNode("it"),
  #         newIdentNode("MODER" & $pin.ord)),
  #       newLit(mode)))))

macro setGPIOxPinyOutputType*(port: static[GPIO], pin: static[GPIOPin], otype: GPIOOutputType): untyped =
  nnkStmtList.newTree(
  nnkCall.newTree(
    nnkDotExpr.newTree(       
      nnkDotExpr.newTree(     
        newIdentNode("GPIO" & ($port).toUpperAscii()),
        newIdentNode("OTYPER")),
      newIdentNode("modifyIt")),
    nnkStmtList.newTree(      
      nnkAsgn.newTree(
        nnkDotExpr.newTree(
          newIdentNode("it"),
          newIdentNode("OT" & $pin.ord)),
        newLit(otype)))))

macro setGPIOxPinySpeed*(port: static[GPIO], pin: static[GPIOPin], speed: GPIOSpeed): untyped = 
  nnkStmtList.newTree(
  nnkCall.newTree(
    nnkDotExpr.newTree(       
      nnkDotExpr.newTree(     
        newIdentNode("GPIO" & ($port).toUpperAscii()),
        newIdentNode("OSPEEDR")),
      newIdentNode("modifyIt")),
    nnkStmtList.newTree(      
      nnkAsgn.newTree(
        nnkDotExpr.newTree(
          newIdentNode("it"),
          newIdentNode("OSPEEDR" & $pin.ord)),
        newLit(speed)))))

macro setGPIOxPinyPullDir*(port: static[GPIO], pin: static[GPIOPin], pull: GPIOPuPd): untyped = 
  nnkStmtList.newTree(
  nnkCall.newTree(
    nnkDotExpr.newTree(       
      nnkDotExpr.newTree(     
        newIdentNode("GPIO" & ($port).toUpperAscii()),
        newIdentNode("PUPDR")),
      newIdentNode("modifyIt")),
    nnkStmtList.newTree(      
      nnkAsgn.newTree(
        nnkDotExpr.newTree(
          newIdentNode("it"),
          newIdentNode("PUPDR" & $pin.ord)),
        newLit(pull)))))

macro setGPIOxPinyPullDir*(port: static[GPIO], pin: static[GPIOPin], data: bool): untyped = 
  nnkStmtList.newTree(
  nnkCall.newTree(
    nnkDotExpr.newTree(       
      nnkDotExpr.newTree(     
        newIdentNode("GPIO" & ($port).toUpperAscii()),
        newIdentNode("ODR")),
      newIdentNode("modifyIt")),
    nnkStmtList.newTree(      
      nnkAsgn.newTree(
        nnkDotExpr.newTree(
          newIdentNode("it"),
          newIdentNode("ODR" & $pin.ord)),
        newLit(data)))))

macro setGPIOxPinyAFR*(port: static[GPIO], pin: static[GPIOPin], af: GPIOAltFunc): untyped = 
  nnkStmtList.newTree(
  nnkCall.newTree(
    nnkDotExpr.newTree(       
      nnkDotExpr.newTree(     
        newIdentNode("GPIO" & ($port).toUpperAscii()),
        newIdentNode("AFR" & (if pin > gp7: 'H' else: 'L'))),
      newIdentNode("modifyIt")),
    nnkStmtList.newTree(      
      nnkAsgn.newTree(
        nnkDotExpr.newTree(
          newIdentNode("it"),
          newIdentNode("AFR" & (if pin > gp7: 'H' else: 'L') & $pin.ord)),
        newLit(af)))))

# TODO: alot, BSRR, LCKR
