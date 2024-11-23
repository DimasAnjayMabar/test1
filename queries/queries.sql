-- Table for items (barang)
CREATE TABLE barang (
    id_barang INT AUTO_INCREMENT PRIMARY KEY,
    nama_barang VARCHAR(255) NOT NULL,
    harga_beli INT NOT NULL,
    harga_jual INT NOT NULL,
    tanggal_masuk DATE DEFAULT CURRENT_DATE,
    stok INT NOT NULL,
    barcode CHAR(36) DEFAULT UUID(),
    hutang BOOLEAN NOT NULL
);

-- Table for customers
CREATE TABLE customer (
    id_customer INT AUTO_INCREMENT PRIMARY KEY,
    nama_customer VARCHAR(255) NOT NULL,
    no_telp_customer VARCHAR(20),
    email_customer VARCHAR(255)
);

-- Table for distributors
CREATE TABLE distributor (
    id_distributor INT AUTO_INCREMENT PRIMARY KEY,
    nama_distributor VARCHAR(255) NOT NULL,
    not_telp_distributor VARCHAR(20),
    email_distributor VARCHAR(255),
    link_ecommerce TEXT
);

-- Table for transaction details
CREATE TABLE detail_transaksi (
    id_detail_transaksi INT AUTO_INCREMENT PRIMARY KEY,
    id_transaksi INT NOT NULL,
    id_barang INT NOT NULL,
    quantity INT NOT NULL,
    subtotal INT NOT NULL
);

-- Table for transactions
CREATE TABLE transaksi (
    id_transaksi INT AUTO_INCREMENT PRIMARY KEY,
    nama_customer VARCHAR(255),
    tanggal_transaksi DATE DEFAULT CURRENT_DATE,
    total_harga INT NOT NULL
);

-- Connect barang to distributor
ALTER TABLE barang
ADD COLUMN id_distributor INT,
ADD CONSTRAINT fk_distributor
FOREIGN KEY (id_distributor) REFERENCES distributor(id_distributor);

-- Connect detail_transaksi to barang
ALTER TABLE detail_transaksi
ADD COLUMN id_barang INT,
ADD CONSTRAINT fk_barang
FOREIGN KEY (id_barang) REFERENCES barang(id_barang);

-- Connect transaksi to detail_transaksi
ALTER TABLE transaksi
ADD COLUMN id_detail_transaksi INT,
ADD CONSTRAINT fk_detail_transaksi
FOREIGN KEY (id_detail_transaksi) REFERENCES detail_transaksi(id_detail_transaksi);

-- Connect transaksi to customer
ALTER TABLE transaksi
ADD COLUMN id_customer INT,
ADD CONSTRAINT fk_customer
FOREIGN KEY (id_customer) REFERENCES customer(id_customer);

INSERT INTO barang (nama_barang, harga_beli, harga_jual, stok, hutang, distributor_id) VALUES
('Barang A', 10000, 15000, 50, FALSE, 1),
('Barang B', 20000, 25000, 30, TRUE, 2),
('Barang C', 15000, 20000, 20, FALSE, 3),
('Barang D', 25000, 30000, 10, TRUE, 4),
('Barang E', 30000, 35000, 5, FALSE, 5),
('Barang F', 12000, 17000, 40, TRUE, 1),
('Barang G', 18000, 23000, 25, FALSE, 2),
('Barang H', 22000, 27000, 15, TRUE, 3),
('Barang I', 13000, 18000, 35, FALSE, 4),
('Barang J', 16000, 21000, 45, TRUE, 5),
('Barang K', 14000, 19000, 60, FALSE, 1),
('Barang L', 17000, 22000, 55, TRUE, 2),
('Barang M', 19000, 24000, 80, FALSE, 3),
('Barang N', 21000, 26000, 65, TRUE, 4),
('Barang O', 23000, 28000, 75, FALSE, 5),
('Barang P', 24000, 29000, 85, TRUE, 1),
('Barang Q', 26000, 31000, 90, FALSE, 2),
('Barang R', 27000, 32000, 95, TRUE, 3),
('Barang S', 28000, 33000, 100, FALSE, 4),
('Barang T', 29000, 34000, 105, TRUE, 5);

-- insert distributor
CREATE TABLE distributor (
    id_distributor INT AUTO_INCREMENT PRIMARY KEY,
    nama_distributor VARCHAR(255) NOT NULL,
    not_telp_distributor VARCHAR(20),
    email_distributor VARCHAR(255),
    link_ecommerce TEXT
);

-- insert detail transaksi
INSERT INTO detail_transaksi (id_transaksi, id_barang, quantity, subtotal) VALUES
(1, 1, 2, 20000),  -- 2 units of Barang A (id_barang = 1)
(1, 2, 1, 25000),  -- 1 unit of Barang B (id_barang = 2)
(1, 3, 3, 60000),  -- 3 units of Barang C (id_barang = 3)
(1, 4, 1, 30000),  -- 1 unit of Barang D (id_barang = 4)
(1, 5, 5, 175000); -- 5 units of Barang E (id_barang = 5)


-- Insert Transaction 1
INSERT INTO transaksi (nama_customer, total_harga) VALUES
('Customer 1', 20000 + 25000 + 60000);

-- Insert Transaction 2
INSERT INTO transaksi (nama_customer, total_harga) VALUES
('Customer 2', 30000 + 175000);

-- Table for customers
INSERT INTO customer (nama_customer, no_telp_customer, email_customer) VALUES
('John Doe', '1234567890', 'johndoe@example.com'),
('Jane Smith', '0987654321', 'janesmith@example.com');
