import device
import std/strformat

const headerStr = fmt"""
#define __CM4_REV                  {CM4_REV:#06x}U
#define __NVIC_PRIO_BITS           {NVIC_PRIO_BITS}
#define __Vendor_SysTickConfig     {Vendor_SysTickConfig.int}
#define __VTOR_PRESENT             {VTOR_PRESENT.int}
#define __MPU_PRESENT              {MPU_PRESENT.int}
#define __FPU_PRESENT              {FPU_PRESENT.int}

typedef enum {{
  Reset_IRQn             =  -15, // Reset Vector, invoked on Power up and warm reset
  NonMaskableInt_IRQn    =  -14, // Non maskable Interrupt, cannot be stopped or preempted
  HardFault_IRQn         =  -13, // Hard Fault, all classes of Fault
  SVCall_IRQn            =   -5, // System Service Call via SVC instruction
  PendSV_IRQn            =   -2, // Pendable request for system service
  SysTick_IRQn           =   -1  // System Tick Timer
}} IRQn_Type;

#include "core_cm4.h"
"""

## IRQn_Type potentially needs an update?


# Nim bindings for core_cm0plus.h HAL functions
# NVIC bindings

proc NVIC_SetPriorityGrouping_impl(priorityGroup: uint32)
  {.importc: "__NVIC_SetPriorityGrouping", header: headerStr.}

proc NVIC_SetPriorityGrouping*(priorityGroup: 0..7) =
  NVIC_SetPriorityGrouping_impl(priorityGroup.uint32)

proc NVIC_GetPriorityGrouping*(): uint32
  {.importc: "__NVIC_GetPriorityGrouping", header: headerStr.}

proc NVIC_EnableIRQ*(irqn: IRQn)
  {.importc: "__NVIC_EnableIRQ", header: headerStr.}

proc NVIC_GetEnableIRQ*(irqn: IRQn): uint32
  {.importc: "__NVIC_GetEnableIRQ", header: headerStr.}

proc NVIC_DisableIRQ*(irqn: IRQn)
  {.importc: "__NVIC_DisableIRQ", header: headerStr.}

proc NVIC_GetPendingIRQ*(irqn: IRQn): uint32
  {.importc: "__NVIC_GetPendingIRQ", header: headerStr.}

proc NVIC_SetPendingIRQ*(irqn: IRQn)
  {.importc: "__NVIC_SetPendingIRQ", header: headerStr.}

proc NVIC_ClearPendingIRQ*(irqn: IRQn)
  {.importc: "__NVIC_ClearPendingIRQ", header: headerStr.}

proc NVIC_GetActive*(irqn: IRQn): uint32
  {.importc: "__NVIC_GetActive", header: headerStr.} 

proc NVIC_SetPriority*(irqn: IRQn)
  {.importc: "__NVIC_SetPriority", header: headerStr.}

proc NVIC_GetPriority*(irqn: IRQn): uint32
  {.importc: "__NVIC_GetPriority", header: headerStr.}  

proc NVIC_EncodePriority_impl(priorityGroup, preemptPriority, subPriority: uint32): uint32
  {.importc: "NVIC_EncodePriority", header: headerStr.}

proc NVIC_EnodePriority*(priorityGroup: 0..7, preemptPriority, subPriority: uint32): uint32 =
  NVIC_EncodePriority_impl(priorityGroup.uint32, preemptPriority, subPriority)

proc NVIC_DecodePriority_impl(priority, priorityGroup: uint32, pPremptPriority, pSubPriority: ptr uint32)
  {.importc: "NVIC_DecodePriority", header: headerStr.}

func NVIC_DecodePriority*(priority, priorityGroup: uint32): tuple[preemptPriority, subPriority: uint32] =
  ## Friendly wrapper around NVIC_DecodePriority that returns a tuple
  ## instead of taking pointers as arguments.
  NVIC_DecodePriority_impl(priority, priorityGroup, result.preemptPriority.addr, result.subPriority.addr)

proc NVIC_SetVector*(irqn: IRQn, vector: uint32)
  {.importc: "__NVIC_SetVector", header: headerStr.}

proc NVIC_GetVector*(irqn: IRQn): uint32
  {.importc: "__NVIC_GetVector", header: headerStr.}

proc NVIC_SystemReset*()
  {.importc: "__NVIC_SystemReset", header: headerStr.}
  

# MPU Functions

when MPU_PRESENT: # im just riffing here
  const mpuHeader = "mpu_armv7.h"

  type
    ARM_MPU_Region* {.importc: "ARM_MPU_Region_t", header: mpuHeader, bycopy.} = object
      rbar* {.importc: "RBAR".}: uint32
      rasr* {.importc: "RASR".}: uint32

  proc ARM_MPU_Enable*(mpuControl: uint32) 
    {.importc:"$1", header: mpuHeader.}

  proc ARM_MPU_Disable*()
    {.importc:"$1", header: mpuHeader.} 

  proc ARM_MPU_ClrRegion*(region: uint32)
    {.importc:"$1", header: mpuHeader.}

  proc ARM_MPU_SetRegion*(rbar, rasr: uint32) # potentially make an impl that takes ARM_MPU_Region
    {.importc:"$1", header: mpuHeader.}

  proc ARM_MPU_SetRegionEx*(region, rbar, rasr: uint32) # potentially make an impl that takes ARM_MPU_Region
    {.importc:"$1", header: mpuHeader.}

  proc ARM_MPU_OrderedMemcpy*(dst, src: ptr uint32, len: uint32)
    {.importc:"$1", header: mpuHeader.}

  proc ARM_MPU_Load_impl(table: ptr UncheckedArray[ARM_MPU_Region], count: uint32)
    {.importc:"ARM_MPU_Load", header: mpuHeader.}

  proc ARM_MPU_Load*(table: openArray[ARM_MPU_Region]) =
    ARM_MPU_Load_impl(cast[ptr UncheckedArray[ARM_MPU_Region]](addr table[0]), table.len.uint32)


# FPU Functions

proc SCB_GetFPUType*(): uint32
  {.importc:"$1", header: headerStr.}


# SysTick Functions

when not Vendor_SysTickConfig:
  proc SysTick_Config_impl(ticks: uint32): uint32
    # Note: returns 1 when failed, 0 when succeeded
    {.importc: "SysTick_Config", header: headerStr.}

  proc SysTick_Config*(ticks: 0..0x1000000): bool =
    not SysTick_Config_impl(uint32(ticks)).bool
