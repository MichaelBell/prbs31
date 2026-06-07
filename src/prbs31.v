`default_nettype    none

module prbs31 (
    input wire          clk,
    input wire          rst_n,
    input wire          en,
    output reg  [31:0]  q
);

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) q <= '1;
        else if (en) begin
            q[0] <= q[30] ^ q[27];
            q[31:1] <= q[30:0];
        end
    end

endmodule
