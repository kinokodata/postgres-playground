-- ベーステーブルの作成（他のテーブルから参照されるテーブル）
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- ユーザーテーブルの作成
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(60) NOT NULL,
    age INTEGER NOT NULL,
    phone VARCHAR(20),
    department_id INTEGER REFERENCES departments(id),
    status INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 商品関連テーブル
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    price INTEGER NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    category_id INTEGER REFERENCES categories(id) NULL, -- NULLを許容する
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stock (
    product_id INTEGER PRIMARY KEY REFERENCES products(id),
    quantity INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 注文関連テーブル
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    amount INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders_not_normalized (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,  -- customer_idを追加
    name VARCHAR(100) NOT NULL,
    price INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_details (
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE shipments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- updated_at自動更新用の関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ language 'plpgsql';

-- 全テーブルのトリガー作成
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_not_normalized_updated_at
    BEFORE UPDATE ON orders_not_normalized
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_stock_updated_at
    BEFORE UPDATE ON stock
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shipments_updated_at
    BEFORE UPDATE ON shipments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_details_updated_at
    BEFORE UPDATE ON order_details
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- サンプルデータの挿入
-- 基本マスタデータ
INSERT INTO categories (name) VALUES
    ('電化製品'),
    ('食品'),
    ('書籍'),
    ('アウトドア用品'), -- 商品が紐づかないカテゴリ
    ('スポーツ用品');   -- 商品が紐づかないカテゴリ

INSERT INTO departments (department_name) VALUES
    ('営業部'),
    ('開発部'),
    ('人事部');

-- ユーザーデータ
INSERT INTO users (name, email, password_hash, age, phone, department_id, status) VALUES
    ('山田太郎', 'yamada@example.com', 'hashedpassword123', 25, '090-1234-5678', 1, 1),
    ('佐藤花子', 'sato@example.com', 'hashedpassword456', 20, NULL, 2, 1),
    ('鈴木一郎', 'suzuki@example.com', 'hashedpassword789', 29, '080-8765-4321', 3, 2);

-- 商品データ
INSERT INTO products (name, price, stock_quantity, category_id) VALUES
    ('商品A', 1000, 10, 1),
    ('商品B', 2000, 20, 1),
    ('商品C', 3000, 30, 2),
    ('商品D', 1500, 0, 2),
    ('商品E', 2500, 15, 3),
    ('カテゴリなし商品1', 500, 5, NULL),    -- カテゴリがNULL
    ('カテゴリなし商品2', 800, 8, NULL),    -- カテゴリがNULL
    ('カテゴリなし商品3', 1200, 12, NULL);  -- カテゴリがNULL

-- 在庫データ
INSERT INTO stock (product_id, quantity) VALUES
    (1, 100),
    (2, 50),
    (3, 0),
    (4, 75),
    (5, 25);

-- 注文データ
INSERT INTO orders (product_id, quantity, user_id, amount) VALUES
    (1, 2, 1, 4000),
    (2, 5, 2, 9000),
    (3, 3, 3, 1000),
    (1, 1, 1, 4000),
    (4, 2, 2, 500);

-- orders_not_normalized にテストデータを追加
-- 進行中の注文を追加（pending/processing）
INSERT INTO orders_not_normalized (customer_id, name, price, quantity, category_id, status, created_at) VALUES
    (1, 'スマートウォッチ', 45000, 1, 1, 'pending', '2024-03-15 10:00:00'),
    (1, 'ワイヤレスイヤホン', 35000, 1, 1, 'processing', '2024-03-15 11:00:00'),
    (1, 'タブレット', 85000, 1, 1, 'pending', '2024-03-15 12:00:00'),
    (2, 'ボールペンセット', 2500, 2, 3, 'processing', '2024-03-15 13:00:00'),
    (2, '付箋セット', 1200, 5, 3, 'pending', '2024-03-15 14:00:00'),
    (2, 'カレンダー', 800, 3, 3, 'processing', '2024-03-15 15:00:00'),
    (3, 'メモリーカード', 12000, 1, 1, 'pending', '2024-03-15 16:00:00'),
    (3, 'カメラケース', 8000, 1, 1, 'processing', '2024-03-15 17:00:00'),
    (3, 'バッテリー', 15000, 2, 1, 'pending', '2024-03-15 18:00:00');


-- customer_id = 1 のユーザー（平均購入額が1万円以上で10件以上の注文）
INSERT INTO orders_not_normalized (customer_id, name, price, quantity, category_id, status, created_at) VALUES
    (1, 'ハイエンドPC', 150000, 1, 1, 'completed', '2024-01-01 10:00:00'),
    (1, '4Kモニター', 80000, 1, 1, 'completed', '2024-01-02 11:00:00'),
    (1, 'ゲーミングチェア', 50000, 1, 1, 'completed', '2024-01-03 12:00:00'),
    (1, 'グラフィックボード', 120000, 1, 1, 'completed', '2024-01-04 13:00:00'),
    (1, 'メカニカルキーボード', 30000, 1, 1, 'completed', '2024-01-05 14:00:00'),
    (1, 'ゲーミングマウス', 20000, 1, 1, 'completed', '2024-01-06 15:00:00'),
    (1, 'ヘッドセット', 25000, 1, 1, 'completed', '2024-01-07 16:00:00'),
    (1, 'SSD 2TB', 40000, 1, 1, 'completed', '2024-01-08 17:00:00'),
    (1, 'RAM 32GB', 35000, 1, 1, 'completed', '2024-01-09 18:00:00'),
    (1, 'CPUクーラー', 15000, 1, 1, 'completed', '2024-01-10 19:00:00'),
    (1, 'PCケース', 18000, 1, 1, 'completed', '2024-01-11 20:00:00');

-- customer_id = 2 のユーザー（10件以上だが平均購入額が1万円未満）
INSERT INTO orders_not_normalized (customer_id, name, price, quantity, category_id, status, created_at) VALUES
    (2, '文具セット', 1500, 2, 3, 'completed', '2024-02-01 10:00:00'),
    (2, 'ノート', 500, 5, 3, 'completed', '2024-02-02 11:00:00'),
    (2, 'ペン', 200, 10, 3, 'completed', '2024-02-03 12:00:00'),
    (2, '消しゴム', 100, 5, 3, 'completed', '2024-02-04 13:00:00'),
    (2, 'メモ帳', 300, 3, 3, 'completed', '2024-02-05 14:00:00'),
    (2, 'ファイル', 400, 4, 3, 'completed', '2024-02-06 15:00:00'),
    (2, 'はさみ', 800, 1, 3, 'completed', '2024-02-07 16:00:00'),
    (2, 'のり', 250, 2, 3, 'completed', '2024-02-08 17:00:00'),
    (2, '定規', 350, 1, 3, 'completed', '2024-02-09 18:00:00'),
    (2, 'マーカー', 600, 3, 3, 'completed', '2024-02-10 19:00:00');

-- customer_id = 3 のユーザー（平均購入額は1万円以上だが10件未満）
INSERT INTO orders_not_normalized (customer_id, name, price, quantity, category_id, status, created_at) VALUES
    (3, 'デジタルカメラ', 80000, 1, 1, 'completed', '2024-03-01 10:00:00'),
    (3, 'レンズ', 120000, 1, 1, 'completed', '2024-03-02 11:00:00'),
    (3, '三脚', 30000, 1, 1, 'completed', '2024-03-03 12:00:00'),
    (3, 'カメラバッグ', 15000, 1, 1, 'completed', '2024-03-04 13:00:00'),
    (3, 'フィルター', 20000, 1, 1, 'completed', '2024-03-05 14:00:00');

INSERT INTO order_details (order_id, product_id, quantity, price) VALUES
    (1, 1, 2, 1000),
    (1, 2, 1, 2000),
    (2, 3, 3, 3000),
    (3, 1, 1, 1000),
    (4, 2, 2, 2000);