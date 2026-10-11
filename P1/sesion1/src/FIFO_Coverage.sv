class FIFO_Coverage #(
  parameter int WIDTH = 8,
  parameter int DEPTH = 32
);

  FIFO_Transaction #(WIDTH, DEPTH) transaction;

  mailbox #(FIFO_Transaction #(WIDTH, DEPTH)) mbx;

  covergroup fifo_cover with function sample(FIFO_Transaction #(WIDTH,DEPTH) tr);
    grado_llenado:coverpoint tr.use_dw
    {bins intermedio[] = {[1:31]};
    bins corner_case_vacio ={0};
    bins corner_case_lleno ={32};
    }
//escribid vuestro código aquí
 
  endgroup;
endclass
