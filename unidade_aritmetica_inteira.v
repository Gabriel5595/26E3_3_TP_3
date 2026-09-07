module unidade_aritmetica_inteira #(
    parameter LARGURA = 8
)(
    input wire com_sinal,
    input wire [1:0] operacao,
    input wire [LARGURA-1:0] operando_a,
    input wire [LARGURA-1:0] operando_b,
    output reg [2*LARGURA-1:0] resultado,
    output reg estouro
);

localparam OPERACAO_SOMA = 2'b00;
localparam OPERACAO_SUBTRACAO = 2'b01;
localparam OPERACAO_MULTIPLICACAO = 2'b10;
localparam OPERACAO_DIVISAO = 2'b11;

reg [LARGURA:0] operando_a_estendido;
reg [LARGURA:0] operando_b_estendido;
reg [LARGURA:0] operando_b_ajustado;
reg [LARGURA:0] soma_estendida;
reg estouro_soma_subtracao;

reg signed [LARGURA-1:0] operando_a_com_sinal;
reg signed [LARGURA-1:0] operando_b_com_sinal;
reg [2*LARGURA-1:0] produto_sem_sinal;
reg signed [2*LARGURA-1:0] produto_com_sinal;

reg divisor_zero;
reg [LARGURA-1:0] quociente_sem_sinal;
reg signed [LARGURA-1:0] quociente_com_sinal;

always @(*) begin
    operando_a_com_sinal = operando_a;
    operando_b_com_sinal = operando_b;

    if (com_sinal) begin
        operando_a_estendido = {operando_a[LARGURA-1], operando_a};
        operando_b_estendido = {operando_b[LARGURA-1], operando_b};
    end else begin
        operando_a_estendido = {1'b0, operando_a};
        operando_b_estendido = {1'b0, operando_b};
    end

    if (operacao == OPERACAO_SUBTRACAO)
        operando_b_ajustado = (~operando_b_estendido) + 1'b1;
    else
        operando_b_ajustado = operando_b_estendido;

    soma_estendida = operando_a_estendido + operando_b_ajustado;

    if (com_sinal)
        estouro_soma_subtracao = (soma_estendida[LARGURA] != soma_estendida[LARGURA-1]);
    else
        estouro_soma_subtracao = soma_estendida[LARGURA];

    produto_sem_sinal = operando_a * operando_b;
    produto_com_sinal = operando_a_com_sinal * operando_b_com_sinal;

    divisor_zero = (operando_b == {LARGURA{1'b0}});
    if (divisor_zero) begin
        quociente_sem_sinal = {LARGURA{1'b0}};
        quociente_com_sinal = {LARGURA{1'b0}};
    end else begin
        quociente_sem_sinal = operando_a / operando_b;
        quociente_com_sinal = operando_a_com_sinal / operando_b_com_sinal;
    end

    resultado = {(2*LARGURA){1'b0}};
    estouro = 1'b0;
    case (operacao)
        OPERACAO_SOMA, OPERACAO_SUBTRACAO: begin
            if (com_sinal)
                resultado = {{LARGURA{soma_estendida[LARGURA-1]}}, soma_estendida[LARGURA-1:0]};
            else
                resultado = {{LARGURA{1'b0}}, soma_estendida[LARGURA-1:0]};
            estouro = estouro_soma_subtracao;
        end
        OPERACAO_MULTIPLICACAO: begin
            if (com_sinal)
                resultado = produto_com_sinal;
            else
                resultado = produto_sem_sinal;
            estouro = 1'b0;
        end
        OPERACAO_DIVISAO: begin
            if (com_sinal)
                resultado = {{LARGURA{quociente_com_sinal[LARGURA-1]}}, quociente_com_sinal};
            else
                resultado = {{LARGURA{1'b0}}, quociente_sem_sinal};
            estouro = divisor_zero;
        end
        default: begin
            resultado = {(2*LARGURA){1'b0}};
            estouro = 1'b0;
        end
    endcase
end

endmodule