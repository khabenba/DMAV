// Clase que hace que la FIFO se vaya VACIANDO.
// "is a": un RCSG_bajar ES UN RCSG_base con una constraint mas.
class RCSG_bajar #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
) extends utilidades_pkg::RCSG_base #(WIDTH, DEPTH);   // heredamos pasando los mismos parametros
//) extends RCSG_base #(WIDTH, DEPTH);   // heredamos pasando los mismos parametros

// Constraint nueva: mientras la FIFO no este vacia, solo leemos
  constraint c_bajar {
  if (llenado > 0) {
    wr_rd dist { SOLO_LECTURA    := 3,     // 3 de cada 4 veces: leer
                 LEER_Y_ESCRIBIR := 1 };   // 1 de cada 4: leer y escribir (no cambia el llenado)
  }
}

// Constructor: primero construimos la clase base
  function new();
    super.new();                     // llama al new() de RCSG_base (clear = 1)
  endfunction

endclass
