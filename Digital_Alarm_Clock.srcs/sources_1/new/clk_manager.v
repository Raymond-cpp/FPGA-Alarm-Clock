`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Raymond Wong
// 
// Create Date: 10/22/2023 03:31:55 PM
// Design Name: Clock manager (modified for use by digital clock)
// Module Name: clk_manager
// Project Name: Nexys A7 Digital Alarm Clock
// Target Devices: Nexys A7
// Tool Versions: Xilinx Vivado 2018.1
// Description: This clock manager intakes a 100 MHz clock and outputs a 100 Hz clock
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// this clock manager has a fixed output freq of 100 Hz 
module clk_manager (
    input clk_in,
    output clk_out,
    output ssd_clk
);

    reg toggle_clk = 0;
    reg [19:0] clk_counter = 20'b00000000000000000000;
    reg [19:0] max_value  =  20'd500000;
    
    always @ (posedge clk_in) begin
        if (clk_counter >= max_value) begin
            toggle_clk = ~toggle_clk;
            clk_counter = 0;
        end else
            clk_counter = clk_counter + 1;
    end
    
    assign clk_out = toggle_clk;
    assign ssd_clk = clk_counter[13];

endmodule
