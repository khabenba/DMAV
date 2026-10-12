// =====================================================================
// FIFO_Scoreboard: comprueba automaticamente que la FIFO funciona bien
//   - mbx_in : llegan las ENTRADAS de cada ciclo significativo
//              -> el predictor calcula las salidas ESPERADAS
//   - mbx_out: llegan las SALIDAS OBTENIDAS de la FIFO (un ciclo despues)
//              -> el comparador las compara con las esperadas
// =====================================================================
class FIFO_Scoreboard #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 32
);

  // ------------------------------------------------------------------
  // 2. Handles de transaccion (NO se construyen: apuntaran a lo que
  //    llegue por los mailbox)
  // ------------------------------------------------------------------
  FIFO_Transaction #(WIDTH,DEPTH) tr_expected;   // valores esperados (predictor)
  FIFO_Transaction #(WIDTH,DEPTH) tr_obtained;   // valores obtenidos (FIFO real)

  // ------------------------------------------------------------------
  // 3. Mailboxes que solo aceptan transacciones FIFO_Transaction
  // ------------------------------------------------------------------
  mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx_in;    // entradas  (desde el monitor)
  mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx_out;   // salidas   (desde el monitor)

  // Mailbox interno: el predictor deja aqui cada transaccion esperada y el
  // comparador la recoge. Asi cada salida obtenida se compara con SU
  // esperada, aunque el predictor ya este calculando la del ciclo siguiente.
  mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx_expected;

  // ------------------------------------------------------------------
  // 4. Cola que hace de FIFO ideal (modelo de referencia)
  // ------------------------------------------------------------------
  logic [WIDTH-1:0] FIFO_ideal [$];

  // Contadores para el resumen final
  int n_comparaciones = 0;
  int n_errores       = 0;

  // ------------------------------------------------------------------
  // 5. Constructor: recibe los dos mailbox y los asocia
  // ------------------------------------------------------------------
  function new(mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx_in,
               mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx_out);
    this.mbx_in  = mbx_in;     // this.mbx_in = el de la clase ; mbx_in = el argumento
    this.mbx_out = mbx_out;
    mbx_expected = new();      // el mailbox interno lo construimos aqui
  endfunction

  // ------------------------------------------------------------------
  // 6. PREDICTOR: con las entradas calcula las salidas esperadas
  //    (es la descripcion de la FIFO no sintetizable)
  // ------------------------------------------------------------------
  task predictor_resultados();
    forever begin
      mbx_in.get(tr_expected);            // espera (bloqueado) unas entradas

      if (!tr_expected.rst_s)             // clear sincrono: se vacia la FIFO
      begin
        FIFO_ideal.delete();
        tr_expected.data_out = '0;
      end
      else
      begin
        case ({tr_expected.read_enable, tr_expected.write_enable})
          2'b01: if (FIFO_ideal.size() < DEPTH)                     // solo escritura
                   FIFO_ideal.push_front(tr_expected.data_in);
          2'b10: tr_expected.data_out = FIFO_ideal.pop_back();      // solo lectura
          2'b11: begin                                              // las dos
                   FIFO_ideal.push_front(tr_expected.data_in);
                   tr_expected.data_out = FIFO_ideal.pop_back();
                 end
        endcase
      end

      // Salidas esperadas despues de la operacion
      tr_expected.use_dw = FIFO_ideal.size();
      tr_expected.full   = !(FIFO_ideal.size() == DEPTH);   // activo en bajo
      tr_expected.empty  = !(FIFO_ideal.size() == 0);       // activo en bajo

      mbx_expected.put(tr_expected);      // se la dejamos al comparador
    end
  endtask

  // ------------------------------------------------------------------
  // 7. COMPARADOR: salidas obtenidas frente a esperadas (4 aserciones)
  // ------------------------------------------------------------------
  task comparar_resultados();
    FIFO_Transaction #(WIDTH,DEPTH) esperada;   // la esperada que toca comparar

    forever begin
      mbx_out.get(tr_obtained);           // espera (bloqueado) unas salidas obtenidas
      mbx_expected.get(esperada);         // y coge la esperada correspondiente
      n_comparaciones++;

      assert (tr_obtained.data_out == esperada.data_out)
        else begin n_errores++; $error("data_out: obtenido %h, esperado %h", tr_obtained.data_out, esperada.data_out); end

      assert (tr_obtained.empty == esperada.empty)
        else begin n_errores++; $error("empty: obtenido %b, esperado %b", tr_obtained.empty, esperada.empty); end

      assert (tr_obtained.full == esperada.full)
        else begin n_errores++; $error("full: obtenido %b, esperado %b", tr_obtained.full, esperada.full); end

      assert (tr_obtained.use_dw == esperada.use_dw)
        else begin n_errores++; $error("use_dw: obtenido %0d, esperado %0d", tr_obtained.use_dw, esperada.use_dw); end
    end
  endtask

endclass
