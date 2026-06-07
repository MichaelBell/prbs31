`default_nettype    none

module prbs31 (
    input wire          clk,
    input wire          rst_n,
    output reg  [31:0]  q
);

    wire [31:0] f;

    // This unrolls 32 iterations of the poly x^31 + x^28 + 1
    assign f[31]  = q[27] ^ q[30];
    assign f[30]  = q[26] ^ q[29];
    assign f[29]  = q[25] ^ q[28];
    assign f[28]  = q[24] ^ q[27];
    assign f[27]  = q[23] ^ q[26];
    assign f[26]  = q[22] ^ q[25];
    assign f[25]  = q[21] ^ q[24];
    assign f[24]  = q[20] ^ q[23];
    assign f[23]  = q[19] ^ q[22];
    assign f[22]  = q[18] ^ q[21];
    assign f[21] = q[17] ^ q[20];
    assign f[20] = q[16] ^ q[19];
    assign f[19] = q[15] ^ q[18];
    assign f[18] = q[14] ^ q[17];
    assign f[17] = q[13] ^ q[16];
    assign f[16] = q[12] ^ q[15];
    assign f[15] = q[11] ^ q[14];
    assign f[14] = q[10] ^ q[13];
    assign f[13] = q[9]  ^ q[12];
    assign f[12] = q[8]  ^ q[11];
    assign f[11] = q[7]  ^ q[10];
    assign f[10] = q[6]  ^ q[9];
    assign f[9] = q[5]  ^ q[8];
    assign f[8] = q[4]  ^ q[7];
    assign f[7] = q[3]  ^ q[6];
    assign f[6] = q[2]  ^ q[5];
    assign f[5] = q[1]  ^ q[4];
    assign f[4] = q[0]  ^ q[3];

    // The final 4 bits "wrap around". They need the q bits that were 
    // generated during this clock cycle.
    assign f[3] = f[31] ^ q[2];
    assign f[2] = f[30] ^ q[1];
    assign f[1] = f[29] ^ q[0];
    assign f[0] = f[28] ^ f[31];

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) q <= '1;
        else begin
            q <= f;
        end
    end

endmodule
