-- カテゴリーテーブルの作成
CREATE TABLE categories (
                            id SERIAL PRIMARY KEY,
                            name VARCHAR(100) NOT NULL
);

-- ユーザーテーブルの作成
CREATE TABLE users (
                       id SERIAL PRIMARY KEY,
                       name VARCHAR(100) NOT NULL,
                       email VARCHAR(255) UNIQUE NOT NULL,
                       password_hash VARCHAR(60) NOT NULL,
                       status INTEGER DEFAULT 1,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 商品テーブルの作成
CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(200) NOT NULL,
                          price INTEGER NOT NULL,
                          stock_quantity INTEGER NOT NULL DEFAULT 0,
                          category_id INTEGER,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- サンプルデータの追加
-- カテゴリーの追加
INSERT INTO categories (name) VALUES
                                  ('電化製品'),
                                  ('食品'),
                                  ('書籍');

-- ユーザーの追加
INSERT INTO users (name, email, password_hash, status) VALUES
                                                           ('山田太郎', 'yamada@example.com', 'hashedpassword123', 1),
                                                           ('佐藤花子', 'sato@example.com', 'hashedpassword456', 1),
                                                           ('鈴木一郎', 'suzuki@example.com', 'hashedpassword789', 2);

-- 商品の追加
INSERT INTO products (name, price, stock_quantity, category_id) VALUES
                                                                    ('商品A', 1000, 10, 1),
                                                                    ('商品B', 2000, 20, 1),
                                                                    ('商品C', 3000, 30, 2),
                                                                    ('商品D', 1500, 0, 2),
                                                                    ('商品E', 2500, 15, 3);

-- テーブルの更新時に updated_at を自動更新する関数とトリガーの作成
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();