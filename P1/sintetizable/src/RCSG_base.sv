class RCSG_base #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
) ;
//Propiedades
// 1.1 para datos
  rand logic [WIDTH-1:0] data;

// 1.2 para lectura y escritura: wr_rd = {escritura, lectura}
//     2'b00 nada | 2'b01 solo lectura | 2'b10 solo escritura | 2'b11 las dos
  rand logic [1:0] wr_rd;

// Nombres para las combinaciones de wr_rd (para que se lean mejor los constraints)
  localparam logic [1:0] NADA           = 2'b00;
  localparam logic [1:0] SOLO_LECTURA   = 2'b01;
  localparam logic [1:0] SOLO_ESCRITURA = 2'b10;
  localparam logic [1:0] LEER_Y_ESCRIBIR = 2'b11;

// 2  constraint para datos (no excluye ningun valor)
  localparam logic [WIDTH-1:0] DATO_MAX = '1;   // todos los bits a 1 (255 si WIDTH=8)

  constraint c_datos {
    data >= 0;           // valor minimo
    data <= DATO_MAX;    // valor maximo
  }

// 3 propiedad para clear (rst_s -> CLEAR_N, activo en bajo)
  logic clear;

// 4 variable estática de grado de llenado (0..DEPTH -> $clog2(DEPTH)+1 bits)
  static logic [$clog2(DEPTH):0] llenado = '0;

// 5.1 constraint que controle que no hay lecturas solo cuando la FIFO esta vacia
  constraint c_no_leer_vacia {
    if (llenado == 0) {              // si la FIFO esta vacia...
      wr_rd != SOLO_LECTURA;         // ...no puede salir "solo lectura"
    }
  }

// 5.2 constraint que controle que no hay escrituras solo cuando la FIFO está llena
  constraint c_no_escribir_llena {
    if (llenado == DEPTH) {          // si la FIFO esta llena...
      wr_rd != SOLO_ESCRITURA;       // ...no puede salir "solo escritura"
    }
  }

//metodos
//1 constructor
  function new();
    clear = 1'b1;              // clear inactivo (activo en bajo)
  endfunction

//2 funcion calculo del grado de llenado
  function void calcula_llenado();
    if (!clear)
      llenado = '0;            // si hay clear la FIFO se vacia
    else
      case (wr_rd)
        SOLO_ESCRITURA: llenado = llenado + 1'b1;   // entra una palabra
        SOLO_LECTURA:   llenado = llenado - 1'b1;   // sale una palabra
        default: ;                         // 00 y 11 no cambian el llenado
      endcase
  endfunction

//3 funcion reset del grado de llenado
  static function void reset_llenado();
    llenado = '0;
  endfunction

//4 funcion post_randomize
  function void post_randomize();
    calcula_llenado();
  endfunction

endclass