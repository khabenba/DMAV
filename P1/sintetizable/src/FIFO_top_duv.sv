module FIFO_top_duv #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
) (fifo_if.duv bus) ; 
 
//instanciación de vuestra DUV a verificar
FIFO_FINAL #(
    .DEPTH(DEPTH),
    .WIDTH(WIDTH)
) fifo_duv (
    .CLOCK(bus.clk),
    .RESET_N(bus.rst_a),
    .CLEAR_N(bus.rst_s),
    .DATA_IN(bus.data_in),
    .READ(bus.rd_en),
    .WRITE(bus.wr_en),
    .DATA_OUT(bus.data_out),
    .USE_DW(bus.use_dw),
    .F_EMPTY_N(bus.vacio),
    .F_FULL_N(bus.lleno)
);
 
endmodule