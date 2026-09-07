`timescale 1ns/1ps

module soma_ponto_flutuante_tb;

localparam LARGURA_EXPOENTE = 4;
localparam LARGURA_MANTISSA = 11;

reg modo_subtracao;
reg sinal_a;
reg [LARGURA_EXPOENTE-1:0] expoente_a;
reg [LARGURA_MANTISSA-1:0] mantissa_a;
reg sinal_b;
reg [LARGURA_EXPOENTE-1:0] expoente_b;
reg [LARGURA_MANTISSA-1:0] mantissa_b;
wire sinal_resultado;
wire [LARGURA_EXPOENTE-1:0] expoente_resultado;
wire [LARGURA_MANTISSA-1:0] mantissa_resultado;

soma_ponto_flutuante #(.LARGURA_EXPOENTE(LARGURA_EXPOENTE), .LARGURA_MANTISSA(LARGURA_MANTISSA)) u_soma_float (
    .modo_subtracao(modo_subtracao),
    .sinal_a(sinal_a), .expoente_a(expoente_a), .mantissa_a(mantissa_a),
    .sinal_b(sinal_b), .expoente_b(expoente_b), .mantissa_b(mantissa_b),
    .sinal_resultado(sinal_resultado),
    .expoente_resultado(expoente_resultado),
    .mantissa_resultado(mantissa_resultado)
);

integer valor_a, valor_b, valor_resultado, valor_esperado;

task executar_caso;
    input [799:0] nome_caso;
    input integer esperado;
    begin
        #10;
        valor_a = (sinal_a ? -1 : 1) * mantissa_a * (2 ** expoente_a);
        valor_b = (sinal_b ? -1 : 1) * mantissa_b * (2 ** expoente_b);
        valor_resultado = (sinal_resultado ? -1 : 1) * mantissa_resultado * (2 ** expoente_resultado);
        $display("CASO: %0s | A=%0d B=%0d modo_subtracao=%0d -> resultado=%0d (esperado sem quantizacao=%0d)",
                    nome_caso, valor_a, valor_b, modo_subtracao, valor_resultado, esperado);
    end
endtask

initial begin
    $display("=== Iniciando testes da soma_ponto_flutuante ===");

    modo_subtracao = 1'b0;
    sinal_a = 1'b0; mantissa_a = 11'd100; expoente_a = 4'd2;
    sinal_b = 1'b0; mantissa_b = 11'd50; expoente_b = 4'd1;
    executar_caso("soma tipica, mesmo sinal (400 + 100)", 500);

    modo_subtracao = 1'b0;
    sinal_a = 1'b0; mantissa_a = 11'd2000; expoente_a = 4'd0;
    sinal_b = 1'b0; mantissa_b = 11'd2000; expoente_b = 4'd0;
    executar_caso("soma com estouro de mantissa, exige normalizacao (2000 + 2000)", 4000);

    modo_subtracao = 1'b1;
    sinal_a = 1'b0; mantissa_a = 11'd500; expoente_a = 4'd3;
    sinal_b = 1'b0; mantissa_b = 11'd500; expoente_b = 4'd3;
    executar_caso("subtracao de dois numeros iguais, resultado zero (4000 - 4000)", 0);

    modo_subtracao = 1'b1;
    sinal_a = 1'b0; mantissa_a = 11'd300; expoente_a = 4'd2;
    sinal_b = 1'b0; mantissa_b = 11'd100; expoente_b = 4'd1;
    executar_caso("subtracao tipica (1200 - 200)", 1000);

    modo_subtracao = 1'b0;
    sinal_a = 1'b0; mantissa_a = 11'd800; expoente_a = 4'd1;
    sinal_b = 1'b1; mantissa_b = 11'd300; expoente_b = 4'd0;
    executar_caso("soma de sinais opostos (1600 + (-300))", 1300);

    modo_subtracao = 1'b0;
    sinal_a = 1'b0; mantissa_a = 11'd7; expoente_a = 4'd3;
    sinal_b = 1'b0; mantissa_b = 11'd5; expoente_b = 4'd0;
    executar_caso("caso de borda: parcela pequena absorvida pelo alinhamento (56 + 5)", 61);

    $display("=== Testes concluidos ===");
    $finish;
end

endmodule