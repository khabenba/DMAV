// TEST: primer test aleatorio.
// "has a": el test TIENE un environment.
class FIFO_Testaleatorio1 #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);

  FIFO_Enviroment #(WIDTH, DEPTH) env;

  function new(virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).driver vif);
    env = new(vif);            // le pasamos el interfaz hacia abajo
  endfunction

// Caso de test: como los tasks del testbench original, pero con metodos de clases
  task prueba_aleatoria();
    $display("*** TEST ALEATORIO 1: inicio");
    env.driver.reset_asincrono();
    $display("*** Reset realizado");
    // 1. Llenar la FIFO del todo y quedarse un rato en el limite de llena
    env.driver.subir(DEPTH + 20);
    $display("*** LLenado acabado");
    // 2. Vaciarla del todo y quedarse un rato en el limite de vacia
    env.driver.bajar(DEPTH + 20);
    $display("*** Vaciado acabado");
    // 3. Tramos aleatorios de subida y bajada de longitud aleatoria
    repeat (20) begin
      if ($urandom_range(0, 1))
        env.driver.subir($urandom_range(1, DEPTH));
      else
        env.driver.bajar($urandom_range(1, DEPTH));
    end

    $display("*** TEST ALEATORIO 1: fin");
  endtask

endclass
