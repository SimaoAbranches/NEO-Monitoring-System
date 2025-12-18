import pyodbc


def get_connection():
    """Conecta à base de dados usando autenticação Windows."""
    conn_str = (
        "Driver={SQL Server};"
        "Server=LOCALHOST;"  
        "Database=NEO_Monitoring_DB;"
        "Trusted_Connection=yes;"
    )
    return pyodbc.connect(conn_str)



def get_active_alerts():
    """Executa a lógica de alertas e devolve os alertas ativos."""
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("{CALL sp_GenerateAutomaticAlerts}")
    conn.commit()

    cursor.execute("SELECT asteroid_spkid, priority_level, alert_message FROM Alert_Logs WHERE is_active = 1")
    alerts = cursor.fetchall()
    conn.close()
    return alerts


def create_asteroid(spkid, name, diameter, full_name):
    """Insere um novo asteroide na base de dados."""
    conn = get_connection()
    cursor = conn.cursor()
    query = "INSERT INTO Asteroid (spkid, name, diameter, full_name) VALUES (?, ?, ?, ?)"
    try:
        cursor.execute(query, (spkid, name, diameter, full_name))
        conn.commit()
        print("Asteroide inserido com sucesso!")
    except Exception as e:
        print(f"Erro ao inserir: {e}")
    finally:
        conn.close()


def update_asteroid_diameter(spkid, new_diameter):
    """Atualiza o diâmetro de um asteroide existente."""
    conn = get_connection()
    cursor = conn.cursor()
    query = "UPDATE Asteroid SET diameter = ? WHERE spkid = ?"
    cursor.execute(query, (new_diameter, spkid))
    conn.commit()
    conn.close()
    print("Dados atualizados!")


def delete_asteroid(spkid):
    """Remove um asteroide (se não tiver dependências)."""
    conn = get_connection()
    cursor = conn.cursor()
    try:
        query = "DELETE FROM Asteroid WHERE spkid = ?"
        cursor.execute(query, (spkid,))
        conn.commit()
        print("Registo apagado.")
    except Exception as e:
        print(f"Erro ao apagar: O asteroide tem dependências (FK).")
    finally:
        conn.close()
