`timescale 1ns / 1ps

module ascii_decoder (
    input clk,
    input reset,
    input [7:0] ascii_in,
    output reg [7:0] ascii_out
);
    always @(ascii_in) begin
        case (ascii_in)
            8'h72:   ascii_out = 8'b1000_0000;
            8'h73:   ascii_out = 8'b0100_0000;
            8'h63:   ascii_out = 8'b0010_0000;
            8'h6D:   ascii_out = 8'b0001_0000;
            8'h55:   ascii_out = 8'b0000_1000;
            8'h44:   ascii_out = 8'b0000_0100;
            8'h4C:   ascii_out = 8'b0000_0010;
            8'h52:   ascii_out = 8'b0000_0001;
            default: ascii_out = 8'b0000_0000;
        endcase
    end
endmodule
