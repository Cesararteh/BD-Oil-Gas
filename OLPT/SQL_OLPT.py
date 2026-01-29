import pandas as pd
import numpy as np
from sqlalchemy import create_engine

from sqlalchemy import create_engine

def crear_engine_sqlserver():
    server = "CESARARTEH"
    database = "SCADA_OLTP"
    driver = "ODBC Driver 17 for SQL Server"

    connection_string = (
        f"mssql+pyodbc://@{server}/{database}"
        f"?driver={driver.replace(' ', '+')}"
        "&trusted_connection=yes"
        "&TrustServerCertificate=yes"
    )

    engine = create_engine(connection_string)
    return engine

engine = crear_engine_sqlserver()

m = ''' SELECT s.id_segmento, m.tag
        FROM Segmentos_planta s
        INNER JOIN Instrumento_tag m
        ON s.id_segmento = m.id_segmento
        '''
df = pd.read_sql(m, engine)
print(df)
