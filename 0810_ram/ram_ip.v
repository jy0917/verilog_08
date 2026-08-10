`timescale 1ns / 1ps


module ram_ip (
    input clk,
    input [9:0] addr,
    input [7:0] wdata,
    input wr,
    //조합출력시 사용
    // output [7:0] rdata
    //순차출력시 사용
    output reg [7:0] rdata
);

    // (*ram_style = "block" *) reg [7:0] ram[0:1023];
    reg [7:0] ram[0:1023];

    always @(posedge clk) begin
        if (wr) ram[addr] <= wdata;
        //SL output 순차출력
        else rdata <= ram[addr];
    end

    //CL output 조합출력
    // assign rdata = (!wr) ? ram[addr] : 8'hz;
    // assign rdata = ram[addr];

endmodule
