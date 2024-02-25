`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2024 12:23:25 PM
// Design Name: 
// Module Name: counter
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


module counter(
    input clk,
    input rst,
    input en,
    input [6:0] max_value, // assign max val 0-127, exclusive
    input load,
    input [6:0] load_value,
    output [6:0] out,
    output overflow
    );
    
    reg [6:0] internal_counter = 7'b0000000;
    reg internal_ovf = 1'b0;
    
    always @ (posedge clk, posedge rst, posedge load) begin: clk_cycle
        if (rst) begin
            internal_counter = 7'b0000000;
            internal_ovf = 1'b0;
        end else if (load) begin
            internal_counter = (load_value < max_value ? load_value : max_value - 1);
        end else if (en) begin
            
            // overflow detection
            internal_ovf = (internal_counter == 7'b1111111) | (internal_counter == max_value - 1);
            
            // increment counter
            internal_counter = internal_counter + 1;
            
            // if counter exceeds max value, reset it
            if (max_value > 0 && internal_counter >= max_value) internal_counter = 0;
        end
    end
    
    assign out = internal_counter;
    assign overflow = internal_ovf;
    
endmodule
