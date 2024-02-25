`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/12/2024 05:48:48 PM
// Design Name: 
// Module Name: alarm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alarm(
    input sys_clk,
    input [4:0] current_hour,
    input [5:0] current_minute,
    input current_am_pm,
    input toggle_am_pm,
    
    input en,
    input rst,
    input rst_match_flag,
    
    // trial: directly taking in board inputs
    input [1:0] selected_digit,
    input [3:0] bcd_switches,
    
    input load,
//    input [6:0] load_hour,
//    input [6:0] load_minute,
    
    output [4:0] alarm_hour,
    output [5:0] alarm_minute,
    output match_flag
);
    reg internal_am_pm = 1'b0;
    reg internal_match_flag = 1'b0;
    reg [4:0] internal_hour = 5'b00000;
    reg [5:0] internal_minute = 6'b000000;

    wire hour_match = (internal_hour == current_hour);
    wire minute_match = (internal_minute == current_minute);
    
    reg [7:0] current_bcd_value = 8'b00000000;
    reg [6:0] load_register = 7'b0000000;
    
    reg [3:0] prev_bcd = 4'b0000;
    wire bcd_changed = (prev_bcd != bcd_switches);
    
    // used for converting bcd -> bin for minute input
    wire [11:0] bcd_minute; // internal_minute expressed in BCD
    binary_bcd_converter bcd_minute_converter(
        .bin(internal_minute),
        .bcd(bcd_minute)
    );
    
    wire [5:0] modified_minute = 
        selected_digit == 2'b10 ? 
            (bcd_switches > 4'd5 ? 4'd5 : bcd_switches)*4'd10 + bcd_minute[3:0] :
            bcd_minute[7:4]*4'd10 + (bcd_switches > 4'd9 ? 4'd9 : bcd_switches) ;
    
    always @ (posedge sys_clk) begin
        if (rst) begin
            internal_match_flag = 1'b0;
            internal_hour = 5'b00000;
            internal_minute = 6'b000000;
        end else if (rst_match_flag & internal_match_flag) begin
            internal_match_flag = 1'b0;
        end else if (load & bcd_changed) begin
            if (selected_digit == 2'b01) 
                internal_hour = (bcd_switches >= 4'd12) ? 0 : bcd_switches;
            else if (selected_digit > 2'b01)
                internal_minute = modified_minute;
//            internal_hour = load_hour[4:0];
//            internal_minute = load_minute[5:0];
        end else if (en & hour_match & minute_match /*& (internal_am_pm == current_am_pm)*/) begin // TODO re-enable eventually
            internal_match_flag = 1'b1;
        end
        
        if (toggle_am_pm) internal_am_pm = ~internal_am_pm;
        
        prev_bcd = bcd_switches;
    end
    
    assign match_flag = internal_match_flag;
    assign alarm_hour = internal_hour;
    assign alarm_minute = internal_minute;

endmodule
