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
    age INTEGER NOT NULL,
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
INSERT INTO users (name, email, password_hash, age, status) VALUES
    ('山田太郎', 'yamada@example.com', 'hashedpassword123', 25, 1),
    ('佐藤花子', 'sato@example.com', 'hashedpassword456', 20, 1),
    ('鈴木一郎', 'suzuki@example.com', 'hashedpassword789', 29, 2);

-- 商品の追加
INSERT INTO products (name, price, stock_quantity, category_id) VALUES
    ('商品A', 1000, 10, 1),
    ('商品B', 2000, 20, 1),
    ('商品C', 3000, 30, 2),
    ('商品D', 1500, 0, 2),
    ('商品E', 2500, 15, 3);

-- 正規化されたordersテーブル
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 正規化されていないordersテーブル
CREATE TABLE orders_not_normalized (
   id SERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   price INTEGER NOT NULL,
   quantity INTEGER NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- サンプルデータの挿入（正規化されたorders）
INSERT INTO orders (product_id, quantity) VALUES
  (1, 2),  -- 商品A を2個注文
  (2, 5),  -- 商品B を5個注文
  (3, 3),  -- 商品C を3個注文
  (1, 1),  -- 商品A をもう1個注文
  (4, 2);  -- 商品D を2個注文

-- サンプルデータの挿入（正規化されていないorders）
INSERT INTO orders_not_normalized (name, price, quantity) VALUES
  ('ノートパソコン', 80000, 2),
  ('マウス', 3000, 5),
  ('キーボード', 5000, 3),
  ('モニター', 25000, 2),
  ('USBケーブル', 500, 10);

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

-- トリガーの追加（正規化されたorders）
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- トリガーの追加（正規化されていないorders）
CREATE TRIGGER update_orders_not_normalized_updated_at
    BEFORE UPDATE ON orders_not_normalized
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
