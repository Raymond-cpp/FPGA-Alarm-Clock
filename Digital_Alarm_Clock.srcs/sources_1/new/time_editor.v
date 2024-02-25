`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2024 12:08:51 AM
// Design Name: 
// Module Name: time_editor
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


module time_editor(
    input clk,
    input en,
    input [3:0] current_hour,
    input [7:0] current_minute_bcd,
    input [3:0] bcd_in,
    input [2:0] selected_digit,
    
    output load_hour,
    output load_minute,
    output [6:0] load_value
);

    reg [7:0] current_bcd_value = 8'b00000000;
    reg [6:0] load_register = 7'b0000000;
    reg [3:0] prev_bcd = 4'b0000;
    wire bcd_changed;

    assign bcd_changed = ~(prev_bcd == bcd_in);
    assign load_hour = (selected_digit == 2'b01) & en & bcd_changed;
    assign load_minute = (selected_digit > 2'b01) & en & bcd_changed;
    
    always @ (posedge clk) begin
        if (bcd_changed & en) begin
            if (load_hour) begin // hour selected
                current_bcd_value = bcd_in >= 4'd12 ? 0 : bcd_in;
            end else if (load_minute) begin // minute selected
                current_bcd_value = ( selected_digit[0] ? // if true, 1's place
                    { current_minute_bcd[7:4], ( (bcd_in > 4'b1001) ? 4'b1001 : bcd_in) } :
                    { ( (bcd_in > 4'b0101) ? 4'b0101 : bcd_in), current_minute_bcd[3:0] }
                );
            end
            
            // this line converts BCD to binary
            if (load_hour | load_minute) load_register = (current_bcd_value[7:4]*4'd10) + current_bcd_value[3:0];
            
        end
        prev_bcd = bcd_in;
    end

    assign load_value = load_register;
    
endmodule