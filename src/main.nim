import device/[core_cm4, device]
import startup
import volatile

#compileStartup 
#I dont have a startup.c, startup object file will be passed in compile flags

const 
  StartingSystemCoreClock = 16000000
  HALTickFreq1khz = 1

var 
  tickFreq = HALTickFreq1khz
  sysClockFreq = StartingSystemCoreClock
  uwTickPrio: uint32 = 1 shl NVIC_PRIO_BITS

proc HAL_NVIC_SetPriority(irqn: IRQn, preemptPriority, subPriority: uint32) =
  let priorityGroup = NVIC_GetPriorityGrouping()
  NVIC_SetPriority(irqn, NVIC_EncodePriority(priorityGroup, preemptPriority, subPriority))

proc HAL_initTick(tickPriority: uint32): uint32 =
  discard SysTick_Config(sysClockFreq/(1000/tickFreq))
  HAL_NVIC_SetPriority(irqSysTick, tickPriority, 0)

proc HAL_MspInit() =
  RCC.APB2ENR.modifyIt:
    it.SYSCFGEN = true

  RCC.APB1ENR.modifyIt:
    it.PWREN = true

  NVIC_SetPriorityGrouping(0x03)

# init HAL
proc initHAL() =
  FLASH.ACR.modifyIt:
    it.ICEN = true
    it.DCEN = true
    it.PRFTEN = true

  NVIC_SetPriorityGrouping(0x03) # prio grouping 4
  HAL_initTick(0)
  #HAL_MspInit() # dont know if this is needed or ran yet


var msticks {.volatile.}: uint64

proc HAL_IncTick() {.exportc.} =
  msticks.inc

proc SysTick_Handler() {.exportc.} = 
  HAL_IncTick()

proc HAL_RCC_GetSysClockFreq(): uint32
  case RCC.CFGR.read().SWS:
    of 0b00: # HSI
      result = 16000000 # HSI
      break
    of 0b01: # HSE
      result = 25000000 # HSE
      break
    of 0b10: # PLL
      let pllvco: uint32
      let pllm = RCC.PLLCFGR.read().PLLM
      if RCC.PLLCFGR.read().PLLSRC != false:
        pllvco = uint32 (25000000 * RCC.PLLCFGR.read().PLLN) / PLLM
      else:
        pllvco = uint32 (16000000 * RCC.PLLCFGR.read().PLLN) / PLLM
      let pllp = RCC.PLLCFGR.read().PLLP
      result = pllvco/pllp
    else: result = 16000000

proc HAL_RCC_MCOConfig(rcc_mcox, rcc_mcosrc, rcc_mcodiv) =
  



# init clock
proc initClock() =
  RCC.DCKCFGR.modifyIt: # HAL_RCC_OscConfig()
    it.SAI1BSRC = 0b10
    it.SAI1ASRC = 0b10

  RCC.APB1ENR.modifyIt:
    it.PWREN = true

  PWR.CR.modifyIt:
    it.VOS = 0b11

  RCC.CR.modifyIt:
    it.HSEON = true

    let start = msticks
    while msticks - start < 100: discard

  RCC.CR.modifyIt:
    it.HSION = false 

    let start = msticks
    while msticks - start < 2: discard

  RCC.CR.modifyIt:
    PLLON = false

    let start = msticks
    while msticks - start < 2: discard

  RCC.PLLCFGR.modifyIt:
    it.PLLSRC = true
    it.PLLM = 25
    it.PLLN = 336
    it.PLLP = 0
    it.PLLQ = 7

  RCC.CR.modifyIt:
    PLLON = true

    let start = msticks
    while msticks - start < 2: discard

  if FLASH.ACR.read().LATENCY < 0x05: # HAL_RCC_ClockConfig()
    FLASH.ACR.modifyIt:
      it.LATENCY = 0x05

  RCC.CFGR.modifyIt:
    it.PPRE1 = 0b111
    it.PPRE2 = 0b111
    it.HPRE = 0b0

  RCC.CFGR.modifyIt:
    it.SW = 0b10

    let start = msticks
    while RCC.CFGR.read().SWS != 0b10
      if msticks - start < 5000: break

  if FLASH.ACR.read().LATENCY > 0x05:
    FLASH.ACR.modifyIt:
      it.LATENCY = 0x05
    
  RCC.CFGR.modifyIt:
    PPRE1 = 0b101
    PPRE2 = 0b100

  sysClockFreq = HAL_RCC_GetSysClockFreq()
  HAL_initTick(uwTickPrio)




# init gpio

while true:
  discard
  # blink
