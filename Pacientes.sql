use cc;	
    
    -- TABELAS -- 
                
-- Criação da Tabela Pacientes
CREATE TABLE Pacientes (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especie VARCHAR(50),
    idade INT CHECK (idade > 0)
);

-- Criação da Tabela Veterinários
CREATE TABLE Veterinarios (
    id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(50)
);

-- Criação da Tabela Consultas
CREATE TABLE Consultas (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT,
    id_veterinario INT,
    data_consulta DATE NOT NULL,
    custo DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente),
    FOREIGN KEY (id_veterinario) REFERENCES Veterinarios(id_veterinario)
);


				-- PROCEDURES --

-- Procedure 1: agendar_consulta
DELIMITER //
CREATE PROCEDURE agendar_consulta (
    IN p_id_paciente INT,
    IN p_id_veterinario INT,
    IN p_data_consulta DATE,
    IN p_custo DECIMAL(10, 2)
)
BEGIN
    INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo)
    VALUES (p_id_paciente, p_id_veterinario, p_data_consulta, p_custo);
END //
DELIMITER ;

-- Procedure 2: atualizar_paciente
DELIMITER //
CREATE PROCEDURE atualizar_paciente (
    IN p_id_paciente INT,
    IN p_novo_nome VARCHAR(100),
    IN p_nova_especie VARCHAR(50),
    IN p_nova_idade INT
)
BEGIN
    UPDATE Pacientes
    SET nome = p_novo_nome,
        especie = p_nova_especie,
        idade = p_nova_idade
    WHERE id_paciente = p_id_paciente;
END //
DELIMITER ;

-- Procedure 3: remover_consulta
DELIMITER //
CREATE PROCEDURE remover_consulta (
    IN p_id_consulta INT
)
BEGIN
    DELETE FROM Consultas
    WHERE id_consulta = p_id_consulta;
END //
DELIMITER ;


				-- FUNCTIONS --
                

-- Function: total_gasto_paciente
DELIMITER //
CREATE FUNCTION total_gasto_paciente (
    p_id_paciente INT
) RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE v_total DECIMAL(10, 2);
    
    SELECT IFNULL(SUM(custo), 0) INTO v_total
    FROM Consultas
    WHERE id_paciente = p_id_paciente;
    
    RETURN v_total;
END //
DELIMITER ;


				-- TRIGGERS --

-- Trigger 1: verificar_idade_paciente
DELIMITER //
CREATE TRIGGER verificar_idade_paciente
BEFORE INSERT ON Pacientes
FOR EACH ROW
BEGIN
    IF NEW.idade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A idade do paciente deve ser um número positivo.';
    END IF;
END //
DELIMITER ;

-- Trigger 2: atualizar_custo_consulta
DELIMITER //
CREATE TRIGGER atualizar_custo_consulta
AFTER UPDATE ON Consultas
FOR EACH ROW
BEGIN
    IF OLD.custo <> NEW.custo THEN
        INSERT INTO Log_Consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (OLD.id_consulta, OLD.custo, NEW.custo);
    END IF;
END //
DELIMITER ;

-- Criação da tabela Log_Consultas
CREATE TABLE Log_Consultas (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT,
    custo_antigo DECIMAL(10, 2),
    custo_novo DECIMAL(10, 2)
);