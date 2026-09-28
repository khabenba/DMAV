module FIFO_FINAL #(parameter DEPTH = 32, parameter WIDTH = 8)
	(DATA_IN,READ,WRITE,CLEAR_N,RESET_N,CLOCK,DATA_OUT,F_FULL_N,F_EMPTY_N,USE_DW);

	localparam AW = $clog2(DEPTH-1);            // Bits de direccion de la RAM (5 para 32)

	input logic [WIDTH-1:0]DATA_IN;
	input logic READ,WRITE,CLEAR_N,RESET_N,CLOCK;
	output logic F_FULL_N,F_EMPTY_N;
	output logic [$clog2(DEPTH):0] USE_DW;            // 6 bits: tiene que llegar a 32
	output logic [WIDTH-1:0]DATA_OUT;

	enum logic [1:0] {vacio, otros, lleno} state;
	
	logic enableR,enableW,enableDW,UpDownDW;	     //Enable de los contadores
	logic [WIDTH-1:0] data_RAM;                  //Salida de la RAM
	logic [AW-1:0]cableR,cableW;	
	logic bypass;                                 //Flag caso especial W && R en vacio
	logic [WIDTH-1:0] dato_bypass;                //Dato guardado en el caso especial
	
always_ff @(posedge CLOCK or negedge RESET_N)
			if(!RESET_N)                          //Reset Asíncrono
				state <= vacio;
			else
				if(!CLEAR_N)                       //Clear Síncrono
					state <= vacio;
				else			
// Definimos los estados siguientes en función de las entradas y salida (USE_DW)			
	case (state)
	
		vacio: if(WRITE && !READ)
					begin
						state<=otros;
					end
				 else 
					begin
						state<=vacio;
					end
					
	   otros: if(WRITE && !READ)
				begin
					if(USE_DW == DEPTH-1)
						state<=lleno;
					else
						state<=otros;
				end
			 else if(!WRITE && READ)
				begin
					if(USE_DW == 1)
						state<=vacio;
					else
						state<=otros;
				end
			 else
						state<=otros;
								
		lleno: if(!WRITE && READ)
						state<=otros;
					else
						state<=lleno;
						
					default: state<=vacio;				
	
	endcase	
// Defnimos el valor de las salidas
always_comb begin
	enableR=1'b0;		    //Inicializamos las señales para que no 
	enableW=1'b0;     	 //salgan en alta impedancia en tb
	enableDW=1'b0;    
	UpDownDW=1'b1;
	F_EMPTY_N=1;
	F_FULL_N=1;
	
	case(state)
		
	vacio: 
		 begin
			F_EMPTY_N=0;
			F_FULL_N=1;
			case({WRITE, READ})
				2'b10:
							begin
								enableR=1'b0;		//  --
								enableW=1'b1;     //countw<=countw+1
								enableDW=1'b1;    //countDW<=countDW+1
								UpDownDW=1'b1;    // a = a + 1
							end

			default:
							begin	
								enableR=1'b0;		//  --
								enableW=1'b0;     //  --   (el caso 11 lo hace el bypass)
								enableDW=1'b0;    //  --
								UpDownDW=1'bx;    //  --
							end
			endcase
		end

		
	otros: 
		begin
			F_EMPTY_N=1;
			F_FULL_N=1;		
				case({WRITE, READ}) 
					2'b11:
							begin
								enableR=1'b1;		//countr<=countr+1
								enableW=1'b1; 		//countw<=countw+1
								enableDW=1'b0;    //  -- 
								UpDownDW=1'b1;    //  --;
							end
					2'b10:
							begin
								enableR=1'b0;		//  --
								enableW=1'b1; 		//countw<=countw+1
								enableDW=1'b1;    //countDW<=countDW+1
								UpDownDW=1'b1;    // a = a + 1
							end
					2'b01:
							begin
								enableR=1'b1;		//countr<=countr+1
								enableW=1'b0; 		//  --
								enableDW=1'b1;    //countDW<=countDW-1
								UpDownDW=1'b0;    // a = a - 1
							end
			default:
							begin
								enableR=1'b0;		//  --
								enableW=1'b0; 		//  --
								enableDW=1'b0;    //  --
								UpDownDW=1'bx;    //  --
							end
			endcase
		end
	
	lleno: 
	begin
			F_EMPTY_N=1;
			F_FULL_N=0;	
				case({WRITE, READ})
						2'b11:
								begin
									enableR=1'b1;		//countr<=countr+1
									enableW=1'b1; 		//countw<=countw+1
									enableDW=1'b0;    //  --
									UpDownDW=1'bx;    //  --
								end
						2'b01:
								begin 
									enableR=1'b1;		//countr<=countr+1
									enableW=1'b0; 		//  --
									enableDW=1'b1;    //countDW<=countDW-1
									UpDownDW=1'b0;    //a = a - 1
								end
					
			default:
								begin
									enableR=1'b0;		//  --
									enableW=1'b0; 		//  --
									enableDW=1'b0;    //  --
									UpDownDW=1'bx;    //  --;
								end
				endcase
		end
		
			default: 
						begin
									enableR=1'b0;		//  --
									enableW=1'b0; 		//  --     // Default general
									enableDW=1'b0;    //  --
									UpDownDW=1'bx;    //  --
						end
	endcase 
end	

   //BLOQUE SECUENCIAL PARA EL CASO ESPECIAL (vacio con W && R: DATA_OUT<=DATA_IN)
	
always_ff @(posedge CLOCK or negedge RESET_N)
		if(!RESET_N)
			begin
				bypass<=1'b0;
				dato_bypass<='0;
			end
		else
			if(!CLEAR_N)
				bypass<=1'b0;
			else if(state==vacio && WRITE && READ)
				begin
					bypass<=1'b1;           // Si W&&R en vacio no pasamos por la RAM
					dato_bypass<=DATA_IN;
				end
			else if(enableR)
				bypass<=1'b0;           // En la siguiente lectura volvemos a la RAM

   //BLOQUE COMBINACIONAL DE LA SALIDA
	
always_comb
		if(bypass)
			DATA_OUT=dato_bypass;    // Dato del caso especial
		else 
			DATA_OUT=data_RAM;       // Resto de casos
				
				
	//RAM INSTANCIADA
	
ram_dp #(.mem_depth(DEPTH), .size(WIDTH)) RAM
(
	.data(DATA_IN) ,	      // Input Dato
	.wren(enableW) ,	   	// Escribe solo cuando lo manda el ASM	
	.clock1(CLOCK) ,	      // Reloj escritura
	.clock2(CLOCK) ,	      // Reloj lectura (el mismo)
	.rden(enableR) ,	      // Lee solo cuando lo manda el ASM
	.DPO(data_RAM), 	      // Salida de la Ram
	.wraddress(cableW),     // Salida de ContadorW Dirección de escritura
	.rdaddress(cableR)      // Salida de ContadorR Dirección de lectura
);

counter #(.N(AW)) CONTADOR_R(
   .CLK(CLOCK), 
	.RST_N(RESET_N), 
	.CLR_N(CLEAR_N),
	.ENABLE(enableR),             //+1 pos lectura
	.UP_DOWN(1'b1),
	.COUNT(cableR)                //Posición de Lectura
);	

counter #(.N(AW)) CONTADOR_W(
   .CLK(CLOCK), 
	.RST_N(RESET_N), 
	.CLR_N(CLEAR_N),
	.ENABLE(enableW),             //+1 pos escritura 
	.UP_DOWN(1'b1),
	.COUNT(cableW)				      //Posición de Escritura
);

counter #(.N($clog2(DEPTH)+1)) CONTADOR_DW(
   .CLK(CLOCK), 
	.RST_N(RESET_N), 
	.CLR_N(CLEAR_N),
	.ENABLE(enableDW),            //+1 pos ocupada 
	.UP_DOWN(UpDownDW),   
	.COUNT(USE_DW)                //N de espacios ocupados (6 bits)
);

	
endmodule