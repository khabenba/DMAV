module ram_dp #(parameter mem_depth=32, parameter size=8)
(
input [size-1:0] data,
input wren,clock1,clock2,rden,
input [$clog2(mem_depth-1)-1:0] wraddress,
input [$clog2(mem_depth-1)-1:0] rdaddress,
output logic [size-1:0] DPO
);
logic [size-1:0] mem [mem_depth-1 :0];
always_ff @(posedge clock1)
  if (wren==1'b1)
        mem[wraddress]<=data;
always_ff @(posedge clock2)
  if (rden==1'b1)
        DPO<=mem[rdaddress];
endmodule