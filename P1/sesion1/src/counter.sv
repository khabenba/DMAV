module counter #(parameter N = 5)
(
  input  logic         CLK, RST_N, CLR_N, ENABLE, UP_DOWN,
  output logic [N-1:0] COUNT
);
  always_ff @(posedge CLK or negedge RST_N)
    if (!RST_N)       COUNT <= '0;
    else if (!CLR_N)  COUNT <= '0;
    else if (ENABLE)  COUNT <= UP_DOWN ? COUNT + 1'b1 : COUNT - 1'b1;
endmodule