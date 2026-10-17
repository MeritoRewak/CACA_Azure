-- 1. Tworzenie tabeli 'pizza'
CREATE TABLE IF NOT EXISTS pizza (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200) NOT NULL,
    price FLOAT NOT NULL
);

-- 2. Dodanie jednego elementu (Margarita)
INSERT INTO pizza (name, description, price)
VALUES ('Margherita', 'Sos pomidorowy, ser mozzarella, świeża bazylia', 25.0);

-- 3. Sprawdzenie zawartości tabeli
SELECT * FROM pizza;