// Clase que hace que la FIFO se vaya LLENANDO.
// "is a": un RCSG_subir ES UN RCSG_base con una constraint mas.
class RCSG_subir #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
) extends utilidades_pkg::RCSG_base #(WIDTH, DEPTH);   // heredamos pasando los mismos parametros

// Constraint nueva: mientras la FIFO no este llena, solo escribimos
  // constraint c_subir {
  //   if (llenado < DEPTH) {           // si todavia cabe algo...
  //     wr_rd == SOLO_ESCRITURA;       // ...obligamos a escribir
  //   }
  // }

  constraint c_subir {  //Codigo modificado para aumentar la cobertura (similar en bajar)
    if (llenado < DEPTH) {
      wr_rd dist { SOLO_ESCRITURA  := 3,     // 3 de cada 4 veces: escribir
                  LEER_Y_ESCRIBIR := 1 };   // 1 de cada 4: leer y escribir (no cambia el llenado)
    }
  }

// Constructor: primero construimos la clase base
  function new();
    super.new();                     // llama al new() de RCSG_base (clear = 1)
  endfunction

endclass
