import pandas as pd
from sqlalchemy import create_engine
import urllib


params = urllib.parse.quote_plus(
    r'DRIVER={ODBC Driver 17 for SQL Server};SERVER=LAPTOP-E1984K43\SQLEXPRESS;DATABASE=NEO_Monitoring_DB;Trusted_Connection=yes;')
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")


csv_path = 'Data/neo.csv'
try:
    print("A ler o ficheiro CSV...")

    colunas_csv = ['spkid', 'name', 'full_name', 'diameter']

    df = pd.read_csv(csv_path, sep=';', low_memory=False, usecols=colunas_csv)

    df = df.replace('<null>', None)


    df['full_name'] = df['full_name'].fillna(df['name']).fillna(df['spkid'].astype(str))


    df['name'] = df['name'].fillna('Unnamed')

    print(f"A iniciar a importação de {len(df)} linhas...")


    df.to_sql('Asteroid', con=engine, if_exists='append', index=False, chunksize=500)

    print("Sucesso! Os dados foram finalmente importados.")

except Exception as e:
    print(f"Ocorreu um erro: {e}")
