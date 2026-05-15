# DC Motor Control FSM (FPGA Verilog)

This project implements a **Finite State Machine (FSM)** on an MAX 10 FPGA (Terasic DE10-Lite board) to control the speed of a DC motor using **Pulse Width Modulation (PWM)** and a **Frequency Divider (FD)** module.  
Motor speed is adjusted via pushbuttons, increasing or decreasing the duty cycle in 15% increments (0–90%).  
The current speed setting is displayed on a **7-segment display**.

### Project Details
- 7 distinct speed states using **Moore one-hot encoding**
- **PWM generation** for motor speed control
- **Frequency divider** for timing base
- **Button input** for speed control (increase/decrease)
- **7-segment display** showing the current speed state
- Synthesizable in **Intel Quartus Prime**
- Testbenches included for functional simulation
- Simulated in **Modelsim**



