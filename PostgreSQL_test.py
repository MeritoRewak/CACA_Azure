import os
from sqlalchemy import create_engine, text

# Connection string do bazy w Azure PostgreSQL
DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql+psycopg2://wsbmerito:Student1!@wsbpizza-pgdb2.postgres.database.azure.com:5432/postgres?sslmode=require"
)

def test_azure_db():
    print("Próba połączenia z bazą danych w Azure...")
    try:
        engine = create_engine(DATABASE_URL)
        with engine.connect() as connection:
            print("Połączono pomyślnie! Wykonuję zapytanie SELECT...")
            
            # Pobieranie danych z tabeli pizza
            result = connection.execute(text("SELECT id, name, price FROM pizza;"))
            
            print("\n--- WYNIKI Z BAZY AZURE ---")
            for row in result:
                print(f"ID: {row[0]} | Nazwa: {row[1]} | Cena: {row[2]} PLN")
                
    except Exception as e:
        print(f"\nBłąd podczas łączenia lub wykonywania zapytania: {e}")

if __name__ == "__main__":
    test_azure_db()