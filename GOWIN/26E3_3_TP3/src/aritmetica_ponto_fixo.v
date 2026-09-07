module aritmetica_ponto_fixo #(
    parameter BITS_INTEIROS = 3,
    parameter BITS_FRACIONARIOS = 5
)(
    input wire [1:0] operacao,
    input wire signed [BITS_INTEIROS+BITS_FRACIONARIOS-1:0] operando_a,
    input wire signed [BITS_INTEIROS+BITS_FRACIONARIOS-1:0] operando_b,
    output reg signed [BITS_INTEIROS+BITS_FRACIONARIOS-1:0] resultado,
    output reg saturou
);

localparam LARGURA_TOTAL = BITS_INTEIROS + BITS_FRACIONARIOS;
localparam OPERACAO_SOMA = 2'b00;
localparam OPERACAO_SUBTRACAO = 2'b01;
localparam OPERACAO_MULTIPLICACAO = 2'b10;

localparam signed [LARGURA_TOTAL-1:0] VALOR_MAXIMO = {1'b0, {(LARGURA_TOTAL-1){1'b1}}};
localparam signed [LARGURA_TOTAL-1:0] VALOR_MINIMO = {1'b1, {(LARGURA_TOTAL-1){1'b0}}};

reg [LARGURA_TOTAL:0] operando_a_estendido;
reg [LARGURA_TOTAL:0] operando_b_estendido;
reg [LARGURA_TOTAL:0] operando_b_ajustado;
reg [LARGURA_TOTAL:0] soma_estendida;
reg estouro_soma_subtracao;

reg signed [2*LARGURA_TOTAL-1:0] produto_bruto;
reg signed [2*LARGURA_TOTAL-1:0] produto_deslocado;
reg estouro_multiplicacao;

always @(*) begin
    operando_a_estendido = {operando_a[LARGURA_TOTAL-1], operando_a};
    operando_b_estendido = {operando_b[LARGURA_TOTAL-1], operando_b};

    if (operacao == OPERACAO_SUBTRACAO)
        operando_b_ajustado = (~operando_b_estendido) + 1'b1;
    else
        operando_b_ajustado = operando_b_estendido;

    soma_estendida = operando_a_estendido + operando_b_ajustado;
    estouro_soma_subtracao = (soma_estendida[LARGURA_TOTAL] != soma_estendida[LARGURA_TOTAL-1]);

    produto_bruto = operando_a * operando_b;
    produto_deslocado = produto_bruto >>> BITS_FRACIONARIOS;
    estouro_multiplicacao = (produto_deslocado[2*LARGURA_TOTAL-1 -: (LARGURA_TOTAL+1)] !=
                                {(LARGURA_TOTAL+1){produto_deslocado[LARGURA_TOTAL-1]}});

    resultado = {LARGURA_TOTAL{1'b0}};
    saturou = 1'b0;
    case (operacao)
        OPERACAO_SOMA, OPERACAO_SUBTRACAO: begin
            if (estouro_soma_subtracao) begin
                resultado = soma_estendida[LARGURA_TOTAL] ? VALOR_MINIMO : VALOR_MAXIMO;
                saturou = 1'b1;
            end else begin
                resultado = soma_estendida[LARGURA_TOTAL-1:0];
                saturou = 1'b0;
            end
        end
        OPERACAO_MULTIPLICACAO: begin
            if (estouro_multiplicacao) begin
                resultado = produto_bruto[2*LARGURA_TOTAL-1] ? VALOR_MINIMO : VALOR_MAXIMO;
                saturou = 1'b1;
            end else begin
                resultado = produto_deslocado[LARGURA_TOTAL-1:0];
                saturou = 1'b0;
            end
        end
        default: begin
            resultado = {LARGURA_TOTAL{1'b0}};
            saturou = 1'b0;
        end
    endcase
end

endmodule