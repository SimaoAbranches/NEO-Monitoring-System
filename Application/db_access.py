import pyodbc

def get_connection():

    conn_str = (
        "Driver={SQL Server};"
        r"Server=LAPTOP-E1984K43\SQLEXPRESS;"
        "Database=NEO_Monitoring_DB;"
        "Trusted_Connection=yes;"
    )
    return pyodbc.connect(conn_str)


def get_active_alerts():

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("{CALL sp_GenerateAutomaticAlerts}")
    conn.commit()

    cursor.execute("SELECT asteroid_spkid, priority_level, alert_message FROM Alert_Logs WHERE is_active = 1")
    alerts = cursor.fetchall()
    conn.close()
    return alerts


def create_asteroid(spkid, name, diameter, full_name):

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

    conn = get_connection()
    cursor = conn.cursor()
    query = "UPDATE Asteroid SET diameter = ? WHERE spkid = ?"
    cursor.execute(query, (new_diameter, spkid))
    conn.commit()
    conn.close()
    print("Dados atualizados!")


def delete_asteroid(spkid):

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

def search_asteroids(term):

    conn = get_connection()
    cursor = conn.cursor()
    query = "SELECT spkid, full_name, diameter FROM Asteroid WHERE full_name LIKE ? OR spkid LIKE ?"
    cursor.execute(query, (f'%{term}%', f'%{term}%'))
    results = cursor.fetchall()
    conn.close()
    return results

def search_by_name(name_term):

    conn = get_connection()
    cursor = conn.cursor()
    query = "SELECT spkid, full_name, diameter FROM Asteroid WHERE full_name LIKE ?"
    cursor.execute(query, (f'%{name_term}%',))
    results = cursor.fetchall()
    conn.close()
    return results

def search_by_id(spkid_term):

    conn = get_connection()
    cursor = conn.cursor()
    query = "SELECT spkid, full_name, diameter FROM Asteroid WHERE spkid LIKE ?"
    cursor.execute(query, (f'%{spkid_term}%',))
    results = cursor.fetchall()
    conn.close()
    return results

def search_by_full_name(name_term):

    conn = get_connection()
    cursor = conn.cursor()
    query = "SELECT spkid, full_name, diameter FROM Asteroid WHERE full_name LIKE ?"
    cursor.execute(query, (f'%{name_term}%',))
    results = cursor.fetchall()
    conn.close()
    return results

def get_stats_data():

    conn = get_connection()
    cursor = conn.cursor()

    query = "SELECT priority_level, COUNT(*) FROM Alert_Logs GROUP BY priority_level"
    try:
        cursor.execute(query)
        data = cursor.fetchall()
        return data
    except Exception as e:
        print(f"Erro na Query SQL: {e}")
        return []
    finally:
        conn.close()
def get_total_asteroids_count():

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM Asteroid")
    total = cursor.fetchone()[0]
    conn.close()
    return total

def get_alert_counts_fixed():

    conn = get_connection()
    cursor = conn.cursor()

    query = """
        SELECT levels.lvl, COUNT(a.priority_level) 
        FROM (SELECT 1 AS lvl UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) AS levels
        LEFT JOIN Alert_Logs a ON (
            CASE 
                WHEN a.priority_level = 'Baixa' THEN 1
                WHEN a.priority_level = 'Media' THEN 2
                WHEN a.priority_level = 'Alta' THEN 3
                WHEN a.priority_level = 'Critico' THEN 4
                ELSE NULL 
            END
        ) = levels.lvl
        GROUP BY levels.lvl
    """
    cursor.execute(query)
    data = cursor.fetchall()
    conn.close()
    return data
