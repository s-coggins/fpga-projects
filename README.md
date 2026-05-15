## About

This repository holds the files for my previous and current FPGA related projects. 

## Project Environment Specs:  
**EDA Tool**: Altera/Intel Quartus Prime Lite  
**Languages**: SystemVerilog (with bits Verilog & Schematic Capture at times)  
**FPGA**: Altera/Intel Max 10 Family (Device: 10M50DAF484C7G on Terasic DE10-Lite board)  
  **CLOCK**: 50 MHz  
  **DEV BOARD**: 10 Switches, 2 pushbuttons, several 7-segment displays, etc.   
**Simulation Tool**: ModelSim (Standalone and in Quartus)  

# Project 1: DC Motor Control FSM

### Goal:   
To control the speed of a DC motor using pushbuttons to increase/decrease the speed in 15% increments (0-90%) and display its current speed via the 7-segment displays.   
  
### Method:  
This project implemented a **Finite State Machine (FSM)** on an FPGA to control the speed of a DC motor using **Pulse Width Modulation (PWM)** and **Frequency Divider (FD)** modules.   
  
 -Frequency Division was used to obtain two clocks, a 1 Hz clock to update the FSM every 1s, and a 100 kHz clock for the PWM   
 -A total of 7 states were used to cover speeds 0-90%, with s0 = 0% and s6 = 90% speed  
 -Moore FSM was used to ensure stable motor speed and digit transitions (Mealy speed wasn't necessary)  
 -PWM Duty Cycle was determined by state and mirrored speed % 
 -FSM behavior simulated in testbenches to test correct transitions
 -FSM Reset (can be) tied to switch, active LOW (Switch must be UP for FSM to function)


Note: I have also completed the same project in schematic capture using one-hot encoding of its Moore state diagram, but files were not included in the github (not very relevant). 

# Project 2: Mini Modules

### Goal:   
To create/combine common FPGA modules that don't necessitate projects on their own.   
  
### Method:      
 -MUX/DEMUX
 -LFSR
 -Count Toggler
 -Mini Project to use LFSR or Count Toggle with DEMUX to blink and select certain LEDs

# Project 3: UART

### Goal:   
To create UART TX-RX communication channel.   
  
### Method:  
This project implemented a **Finite State Machine (FSM)** to parse UART traffic, and support half and full duplex modes via o_txActive.   
  
 -TX and RX make use of IDLE, START, DATA, STOP, and RESET states to parse UART traffic



# Project 4: Simple Processor

### Goal:   
To create a multistage pipelined processor.   
  
### Method:  
In progress...

