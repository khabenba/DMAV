// TEST: primer test aleatorio, ahora con monitor y cobertura funcional.
// "has a": el test TIENE un environment.
class FIFO_Testaleatorio1 #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);

  FIFO_Enviroment #(WIDTH, DEPTH) env;

  // Dos argumentos: el interfaz con modport driver y el interfaz con modport monitor
  function new(virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).driver  fifo_vif_driver,
               virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).monitor fifo_vif_monitor);
    env = new(fifo_vif_driver, fifo_vif_monitor);   // se los pasamos hacia abajo
  endfunction

// Caso de test: como los tasks del testbench original, pero con metodos de clases
  task prueba_aleatoria();
    $display("*** TEST ALEATORIO 1: inicio");
    env.driver.reset_asincrono();

    // OBSERVABILIDAD: lanzamos los bucles infinitos en paralelo.
    // join_none: los deja corriendo y seguimos con las lineas de abajo sin esperar
    fork
      // Cobertura
      env.monitor.monitorizar();              // captura señales y las manda a la cobertura
      env.monitor.cov.cobertura();            // recoge del mailbox y muestrea el covergroup
      // Scoreboard
      env.monitor.monitorizar_scoreboard();   // manda entradas y salidas al scoreboard
      env.monitor.sb.predictor_resultados();  // calcula las salidas esperadas
      env.monitor.sb.comparar_resultados();   // compara obtenidas con esperadas
    join_none

    // 1. Llenar la FIFO del todo y quedarse un rato en el limite de llena
    env.driver.subir(DEPTH + 20);
    // 2. Vaciarla del todo y quedarse un rato en el limite de vacia
    env.driver.bajar(DEPTH + 20);

    // 3. Tramos aleatorios de subida y bajada de longitud aleatoria
    repeat (20) begin
      if ($urandom_range(0, 1))
        env.driver.subir($urandom_range(1, DEPTH));
      else
        env.driver.bajar($urandom_range(1, DEPTH));
    end

    // Un par de ciclos mas para que el scoreboard compare las ultimas operaciones
    env.driver.reposo();
    env.driver.reposo();

    $display("*** TEST ALEATORIO 1: fin");

    // Resultado del scoreboard
    $display("Scoreboard: %0d comparaciones, %0d errores",
             env.monitor.sb.n_comparaciones, env.monitor.sb.n_errores);

    // Resultado de la cobertura funcional (paso 6)
    $display("Cobertura del covergroup  = %0.2f%%", env.monitor.cov.fifo_cover.get_coverage());
    $display("Cobertura funcional total = %0.2f%%", $get_coverage());
  endtask

endclass
