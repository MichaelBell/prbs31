`default_nettype    none

module prbs31 (
    input wire          clk,
    input wire          rst_n,
    input wire          en,
    output reg  [30:0]  q
);

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) q <= '1;
        else if (en) begin
            q[0] <= q[30] ^ q[27];
            q[30:1] <= q[29:0];
        end
    end

endmodule
