`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Richie Raymond Wong
// 
// Create Date: 01/11/2024 12:11:20 PM
// Design Name: Digital Alarm Clock
// Module Name: top
// Project Name: Digital Alarm Clock
// Target Devices: Nexys A7
// Tool Versions: Xilinx Vivado 2018.1
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input sys_clk, // 100 MHz system clock
    input sys_rst,
    input sys_en,
    input left_btn,
    input right_btn,
    input sel_btn,
    input snooze_btn,
    input [3:0] bcd_switches, // used for BCD input or enabling alarms
    
    output [3:0] alarm_active,
    
    output [6:0] ssd_cc,
    output ssd_dp,
    output [7:0] ssd_an,
    output am_pm_led,
    output [3:0] switch_leds,
    output edit_led
);
    
    reg edit_mode = 1'b0; // HIGH when editing time or alarm
    reg [3:0] edit_alarm = 4'b0000;
    reg [1:0] selected_digit = 2'b00; // 0 = deselected
    reg [7:0] ssd_digit_select = 8'b11111111;
    reg sec_rst;
    
    wire ms_clk;
    wire ssd_clk;
    reg hour_clk;
    wire flashing_alm_clk;
    
    wire [6:0] time_ms;
    wire overflow_ms;
    wire [6:0] time_sec;
    wire overflow_sec;
    wire [6:0] time_min;
    wire overflow_min;
    reg prev_min_overflow;
    wire [6:0] time_hour;
    wire overflow_hour;
    reg prev_hour_overflow = 1'b0;
    reg am_pm = 1'b0; // 0 for pm, 1 for am
    
    wire [11:0] bcd_ms, bcd_sec, bcd_min;
    wire load_hour, load_minute;
    wire [6:0] editor_load_value;
    
    wire [3:0] alarm_match;
    wire blink = time_ms < 50;
    
    assign flashing_alm_clk = (time_ms < 25) || (time_ms < 75 && time_ms > 50);
    
    wire sel_triggered, left_triggered, right_triggered, snooze_triggered;
            
    // setup clock manager
    clk_manager manager(
        .clk_in(sys_clk),
        .clk_out(ms_clk),
        .ssd_clk(ssd_clk)
    );
    
    always @ (posedge sys_clk) begin
        if (sys_rst) begin
            edit_mode = 1'b0;
            sec_rst = 1'b0;
            am_pm = 1'b0;
        end else if (sel_triggered) begin
            sec_rst = (edit_mode && edit_alarm == 4'h0); // sec_rst refresh
            if (edit_mode || bcd_switches < 3 || bcd_switches == 4 || bcd_switches == 8) begin
                if (edit_mode) begin
                    edit_mode = 1'b0;
                    selected_digit = 2'b00;
                    edit_alarm = 4'b0000;
                end else begin
                    edit_mode = 1'b1;
                    selected_digit = 2'b01;
                    edit_alarm = bcd_switches;
                end
            end
        end else begin
            sec_rst = 1'b0;
        end
        if (edit_mode) begin
            if (right_triggered) selected_digit = selected_digit + 1;
            else if (left_triggered) selected_digit = selected_digit - 1;
            if (snooze_triggered & (edit_alarm == 4'h0)) am_pm = ~am_pm;
            if (selected_digit == 2'b00) selected_digit = 2'b01;
            case (selected_digit)
                2'b01: ssd_digit_select = {blink, blink, 6'b111111}; // hour
                2'b10: ssd_digit_select = {2'b11, blink, 5'b11111}; // minute 10's
                2'b11: ssd_digit_select = {3'b111, blink, 4'b1111}; // minute 1's
            endcase
        end else begin
            ssd_digit_select = {8{1'b1}};
        end
        
        if (overflow_min & ~prev_min_overflow & ~(edit_mode & edit_alarm == 4'b0000)) begin
            hour_clk = 1'b1;
        end else begin
            hour_clk = 1'b0;
        end
        
        // posedge overflow_hour
        if (overflow_hour & ~prev_hour_overflow) begin
            am_pm = ~am_pm; // toggle AM/PM
        end
        
        prev_hour_overflow = overflow_hour;
        prev_min_overflow = overflow_min;
        
    end
    
    // input debouncers
    debouncer debounce_sel(
        .clk(sys_clk),
        .in(sel_btn),
        .rise(sel_triggered),
        .out(), .edj(), .fall() // silences warnings
    );
    debouncer debounce_left(
        .clk(sys_clk),
        .in(left_btn),
        .rise(left_triggered),
        .out(), .edj(), .fall() // silences warnings
    );
    debouncer debounce_right(
        .clk(sys_clk),
        .in(right_btn),
        .rise(right_triggered),
        .out(), .edj(), .fall() // silences warnings
    );
    debouncer debounce_snooze(
        .clk(sys_clk),
        .in(snooze_btn),
        .rise(snooze_triggered),
        .out(), .edj(), .fall() // silences warnings
    );
    
    // setup time editor for loading a time
    time_editor editor(
        .clk(ms_clk),
        .en(edit_mode & (edit_alarm == 4'b0000)),
        .current_hour(time_hour),
        .current_minute_bcd(bcd_min),
        .bcd_in(bcd_switches),
        .selected_digit(selected_digit),
        .load_hour(load_hour),
        .load_minute(load_minute),
        .load_value(editor_load_value)
    );
    
    // setup time unit counters
    counter millis( // technically a 10 ms counter, but "clk_ms" is shorter
        .clk(ms_clk),
        .rst(sys_rst | sec_rst),
        .en(sys_en),
        .max_value(7'd100),
        .load(1'b0),
        .load_value(), // silences warning
        .out(time_ms),
        .overflow(overflow_ms)
    );
    
    counter secs(
        .clk(overflow_ms),
        .rst(sys_rst | sec_rst),
        .en(sys_en),
        .max_value(7'd60),
        .load(1'b0),
        .load_value(), // silences warning
        .out(time_sec),
        .overflow(overflow_sec)
    );
    
    counter mins(
        .clk(overflow_sec),
        .rst(sys_rst),
        .en(sys_en & ~(edit_mode & (edit_alarm == 4'b0000))), // don't count up while in edit mode
        .max_value(7'd60),
        .load(load_minute),
        .load_value(editor_load_value),
        .out(time_min),
        .overflow(overflow_min)
    );
    
    counter hours(
        .clk(hour_clk),
        .rst(sys_rst),
        .en(sys_en & ~(edit_mode & (edit_alarm == 4'b0000))), // don't count up while in edit mode
        .max_value(7'd12),
        .load(load_hour),
        .load_value(editor_load_value),
        .out(time_hour),
        .overflow(overflow_hour)
    );
    
    wire [3:0] alm_hour [0:3];
    wire [5:0] alm_min [0:3];
    wire [7:0] alm_hour_bcd [0:3];
    wire [7:0] alm_min_bcd [0:3];
    
    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin
            wire [3:0] alm_hour_pre_bcd;
            wire [3:0] iBus = 4'b0001 << i;
            wire editor_active = edit_mode & (edit_alarm == iBus);
            
            binary_bcd_converter bcd_alm_min (
                .bin({2'b00, alm_min[i]}),
                .bcd({4'b0000, alm_min_bcd[i]}) // this feels illegal
            );
            
            binary_bcd_converter bcd_alm_hour (
                .bin(alm_hour[i]),
                .bcd(alm_hour_pre_bcd)
            );
            
            assign alm_hour_bcd[i] = (alm_hour_pre_bcd == 4'h0) ? 8'b00010010 : alm_hour_pre_bcd;
            
            alarm alm(
                // in
                .sys_clk(ms_clk),
                .current_hour(time_hour[4:0]),
                .current_minute(time_min),
                .current_am_pm(am_pm),
                .toggle_am_pm(snooze_triggered),
                .load(editor_active),
                .en(bcd_switches[i] && time_sec < 1),
                .rst(sys_rst),
                .rst_match_flag(snooze_btn),
                .selected_digit(selected_digit),
                .bcd_switches(bcd_switches),
                
                // out
                .alarm_hour(alm_hour[i]),
                .alarm_minute(alm_min[i]),
                .match_flag(alarm_match[i])
            );
            assign alarm_active[i] = alarm_match[i] & flashing_alm_clk;
            
        end
    endgenerate
    
    // for converting binary values into bcd for display
    binary_bcd_converter bcd_ms_conv(
        .bin(time_ms),
        .bcd(bcd_ms)
    );
    binary_bcd_converter bcd_sec_conv(
        .bin(time_sec),
        .bcd(bcd_sec)
    );
    binary_bcd_converter bcd_min_conv(
        .bin(time_min),
        .bcd(bcd_min)
    );
    wire [7:0] bcd_hour_ssd;
    binary_bcd_converter bcd_hour_ssd_conv(
        .bin((time_hour == 7'b0000000 | time_hour > 4'b1100) ? 4'b1100 : time_hour),
        .bcd(bcd_hour_ssd)
    );
    
    // for on-board SSD display
    ssd_driver ssd(
        .ssd_clk(ssd_clk),
        .ssd_driver_port_inp( {
            // hours
                edit_alarm == 4'b0000 ? bcd_hour_ssd[7:0] :
                edit_alarm == 4'b0001 ? alm_hour_bcd[0] :
                edit_alarm == 4'b0010 ? alm_hour_bcd[1] :
                edit_alarm == 4'b0100 ? alm_hour_bcd[2] :
                edit_alarm == 4'b1000 ? alm_hour_bcd[3] :
                8'h00,
            // minutes
                edit_alarm == 4'b0000 ? bcd_min[7:0] :
                edit_alarm == 4'b0001 ? alm_min_bcd[0] :
                edit_alarm == 4'b0010 ? alm_min_bcd[1] :
                edit_alarm == 4'b0100 ? alm_min_bcd[2] :
                edit_alarm == 4'b1000 ? alm_min_bcd[3] :
                8'h00,
            // seconds
            bcd_sec[7:0],
            // milliseconds
            bcd_ms[7:0]
        } ),
        .ssd_driver_port_en(ssd_digit_select),
        .ssd_driver_port_idp(8'b00000100),
        
        .ssd_driver_port_led(),
        .ssd_driver_port_cc(ssd_cc),
        .ssd_driver_port_odp(ssd_dp),
        .ssd_driver_port_an(ssd_an)
    );
    
    assign switch_leds = edit_alarm > 0 ? edit_alarm & {4{blink}} : bcd_switches;
    assign edit_led = edit_mode & blink;
    assign am_pm_led = am_pm;
    
endmodule
