# FPGA-Alarm-Clock
A Verilog-based digital alarm clock implemented on the Nexys A7 FPGA board.


## Input/Outputs
The following inputs are used to edit the current time, set an alarm
- Set of 4 switches (later referred to as "BCD switches")
- Left button
- Right button
- Select/Edit button
- Snooze button

The following outputs of the Nexys A7 are used to express the clock's current state and time:
- All 8 digits of the on-board 7-segment displays (Time in HH:MM SS.MS format)
- The 4 left-most LEDs ("alarm status" LEDs)
- The 4 right-most LEDs ("alarm match" LEDs)
- Red RGB LED #1 ("Edit Mode" LED)
- Red RGB LED #2 ("AM/PM" LED)

## Modules

### Topfile (top.v)
// TODO

### Counter (counter.v)
// TODO

### Alarm (alarm.v)
// TODO

### Time Editor (time_editor.v)
// TODO

### Other modules
- Clock manager (clk_manager.v)
- Binary -> BCD Converter (binary_bcd.v)
- Seven-Segment Display Driver (ssd_driver.v)
- Button Debouncer (debouncer.v)

## References
The resources linked below were used when creating this project.
- Input debouncer - [Electrical Engineering Stack Exchange](https://electronics.stackexchange.com/questions/505911/debounce-circuit-design-in-verilog)
- Binary to BCD converter - [RealDigital](https://www.realdigital.org/doc/6dae6583570fd816d1d675b93578203d)
- Nexys A7 100T Constraints - [Digilient on GitHub](https://github.com/Digilent/Nexys-A7-100T-Keyboard/blob/master/src/constraints/Nexys-A7-100T-Master.xdc)
