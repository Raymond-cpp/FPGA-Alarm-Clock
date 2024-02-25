`timescale 1ns / 1ps

// adapted from https://www.realdigital.org/doc/6dae6583570fd816d1d675b93578203d

module binary_bcd_converter(
    input [7:0] bin,
    output reg [11:0] bcd
);
    integer i;
        
    always @(bin) begin
        bcd=0;
        for (i=0;i<8;i=i+1) begin					//Iterate once for each bit in input number
            if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;		//If any BCD digit is >= 5, add three
            if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
            if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
            bcd = {bcd[10:0], bin[7-i]};				//Shift one bit, and shift in proper bit from input 
        end
    end

endmodule
