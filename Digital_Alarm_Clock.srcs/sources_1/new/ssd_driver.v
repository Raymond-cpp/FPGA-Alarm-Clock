module ssd_driver(
        input ssd_clk,
        input [31:0] ssd_driver_port_inp,
        input [7:0] ssd_driver_port_en,
        input [7:0] ssd_driver_port_idp,
        
        output [15:0] ssd_driver_port_led,
        output [6:0] ssd_driver_port_cc,
        output ssd_driver_port_odp,
        output [7:0] ssd_driver_port_an
    );
    
    reg [2:0] internal_toggle = 3'b000;
    reg [7:0] internal_anode = 8'b11111111;
    reg [3:0] internal_bcd = 4'b0000;
    reg internal_dp = 1'b0;
    
    assign ssd_driver_port_odp = internal_dp;
    assign ssd_driver_port_led = ssd_driver_port_inp[15:0];

    reg[6:0] ssd_driver_tmp_cc;
    integer lsb = 0;
    integer msb = 0;
    
    always @ (posedge ssd_clk) begin:SEG_ENC
    
        internal_dp = ~ssd_driver_port_idp[internal_toggle-1];
         
         case (internal_toggle)
                 3'b000: begin
                    internal_anode <= 8'b01111111;
                    internal_bcd <= ssd_driver_port_inp[3:0];
                 end
                 3'b001: begin
                    internal_anode <= 8'b11111110;
                    internal_bcd <= ssd_driver_port_inp[7:4];
                 end
                 3'b010: begin
                    internal_anode <= 8'b11111101;
                    internal_bcd <= ssd_driver_port_inp[11:8];
                 end
                 3'b011: begin
                    internal_anode <= 8'b11111011;
                    internal_bcd <= ssd_driver_port_inp[15:12];
                 end
                 3'b100: begin
                    internal_anode <= 8'b11110111;
                    internal_bcd <= ssd_driver_port_inp[19:16];
                 end
                 3'b101: begin
                    internal_anode <= 8'b11101111;
                    internal_bcd <= ssd_driver_port_inp[23:20];
                 end
                 3'b110: begin
                    internal_anode <= 8'b11011111;
                    internal_bcd <= ssd_driver_port_inp[27:24];
                 end
                 3'b111: begin
                    internal_anode <= 8'b10111111;
                    internal_bcd <= ssd_driver_port_inp[31:28];
                 end
         endcase

         case (internal_bcd)      
             4'h0: ssd_driver_tmp_cc = 7'b0000001;
             4'h1: ssd_driver_tmp_cc = 7'b1001111;
             4'h2: ssd_driver_tmp_cc = 7'b0010010;
             4'h3: ssd_driver_tmp_cc = 7'b0000110;
             4'h4: ssd_driver_tmp_cc = 7'b1001100;
             4'h5: ssd_driver_tmp_cc = 7'b0100100;
             4'h6: ssd_driver_tmp_cc = 7'b0100000;
             4'h7: ssd_driver_tmp_cc = 7'b0001111;
             4'h8: ssd_driver_tmp_cc = 7'b0000000;
             4'h9: ssd_driver_tmp_cc = 7'b0001100;
             4'hA: ssd_driver_tmp_cc = 7'b0001000;
             4'hB: ssd_driver_tmp_cc = 7'b1100000;
             4'hC: ssd_driver_tmp_cc = 7'b0110001;
             4'hD: ssd_driver_tmp_cc = 7'b1000010;
             4'hE: ssd_driver_tmp_cc = 7'b0110000;
             4'hF: ssd_driver_tmp_cc = 7'b0111000;
             default: ssd_driver_tmp_cc = 7'hZZ;
          endcase       
         internal_toggle = internal_toggle + 1;
     end

     assign ssd_driver_port_an = internal_anode | ~ssd_driver_port_en;
     assign ssd_driver_port_cc = ssd_driver_tmp_cc;
    
endmodule
