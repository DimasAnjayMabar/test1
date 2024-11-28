CREATE TABLE barang (
    id_barang serial PRIMARY KEY,
    nama_barang VARCHAR(255) NOT NULL,
    harga_beli INT NOT NULL,
    harga_jual INT NOT NULL,
    tanggal_masuk DATE DEFAULT CURRENT_DATE,
    stok INT NOT NULL,
    barcode CHAR(36) DEFAULT uuid_generate_v4(),
    hutang BOOLEAN NOT NULL
);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE customer (
    id_customer serial PRIMARY KEY,
    nama_customer VARCHAR(255) NOT NULL,
    no_telp_customer VARCHAR(20),
    email_customer VARCHAR(255)
);

CREATE TABLE distributor (
    id_distributor serial PRIMARY KEY,
    nama_distributor VARCHAR(255) NOT NULL,
    not_telp_distributor VARCHAR(20),
    email_distributor VARCHAR(255),
    link_ecommerce TEXT
);

-- Table for transaction details
CREATE TABLE detail_transaksi (
    id_detail_transaksi serial PRIMARY KEY,
    quantity INT NOT NULL,
    subtotal INT NOT NULL
);

CREATE TABLE transaksi (
    id_transaksi serial PRIMARY KEY,
    tanggal_transaksi DATE DEFAULT CURRENT_DATE,
    total_harga INT NOT NULL
);

alter table transaksi
add column piutang boolean

ALTER TABLE barang
ADD COLUMN id_distributor INT,
ADD CONSTRAINT fk_distributor
FOREIGN KEY (id_distributor) REFERENCES distributor(id_distributor);

-- Connect detail_transaksi to barang
ALTER TABLE detail_transaksi
ADD COLUMN id_barang INT,
ADD CONSTRAINT fk_barang
FOREIGN KEY (id_barang) REFERENCES barang(id_barang);

ALTER TABLE detail_transaksi
ADD COLUMN id_transaksi INT,
ADD CONSTRAINT fk_id_transaksi
FOREIGN KEY (id_transaksi) REFERENCES transaksi(id_transaksi);

alter table transaksi
drop column nama_customer;

ALTER TABLE transaksi
ADD COLUMN id_customer INT,
ADD CONSTRAINT fk_customer
FOREIGN KEY (id_customer) REFERENCES customer(id_customer);

INSERT INTO distributor (nama_distributor, not_telp_distributor, email_distributor, link_ecommerce) 
VALUES 
('Agung Supplier', '081234567890', 'agung@example.com', 'https://agungsupplier.com'),
('Tirta Plastik', '082345678901', NULL, NULL),
('Mega Grosir', NULL, NULL, 'https://megagrosir.com'),
('Jaya Makmur', '083456789012', 'jayamakmur@example.com', NULL),
('Kencana Sejahtera', NULL, NULL, NULL);

INSERT INTO barang (nama_barang, harga_beli, harga_jual, stok, hutang, id_distributor)
VALUES 
-- Distributor 1
('Plastik Kresek Kecil', 500, 1000, 200, FALSE, 1),
('Plastik Kresek Besar', 1500, 2500, 100, FALSE, 1),
('Cup Plastik 250ml', 300, 600, 500, FALSE, 1),
('Sedotan Jumbo', 200, 400, 300, FALSE, 1),
('Kantong Plastik Ziplock', 1000, 1500, 50, TRUE, 1),

-- Distributor 2
('Plastik Mika A4', 2500, 4000, 80, FALSE, 2),
('Plastik Sampah Hitam', 1000, 1800, 300, TRUE, 2),
('Gelas Plastik 500ml', 400, 800, 400, FALSE, 2),
('Lid Plastik Transparan', 300, 500, 200, FALSE, 2),
('Plastik PP 1kg', 2000, 3500, 100, TRUE, 2),

-- Distributor 3
('Baskom Plastik Besar', 5000, 7500, 30, TRUE, 3),
('Tempat Makan Plastik', 2500, 4000, 70, FALSE, 3),
('Rak Plastik Susun', 15000, 20000, 20, TRUE, 3),
('Botol Plastik 1L', 1000, 2000, 120, FALSE, 3),
('Tutup Botol Plastik', 200, 500, 500, FALSE, 3),

-- Distributor 4
('Plastik Roll Serbaguna', 3000, 5000, 50, TRUE, 4),
('Plastik Laminating', 2000, 3500, 60, FALSE, 4),
('Box Plastik Transparan', 10000, 15000, 40, TRUE, 4),
('Tali Plastik', 500, 800, 250, FALSE, 4),
('Plastik Bubble Wrap', 1500, 2500, 100, FALSE, 4),

-- Distributor 5
('Sendok Plastik', 100, 300, 1000, FALSE, 5),
('Garpu Plastik', 100, 300, 1000, FALSE, 5),
('Pisau Plastik', 150, 400, 800, TRUE, 5),
('Tray Plastik Hitam', 500, 1000, 200, FALSE, 5),
('Kemasan Plastik Vacuum', 2500, 4000, 30, TRUE, 5),

-- Mixed Distributors
('Plastik Wrapping', 1000, 1500, 100, TRUE, 1),
('Plastik HDPE', 500, 800, 300, FALSE, 2),
('Plastik OPP', 1000, 2000, 150, FALSE, 3),
('Plastik Kresek Medium', 750, 1200, 400, FALSE, 4),
('Tutup Plastik untuk Gelas', 250, 500, 600, FALSE, 5);

INSERT INTO customer (nama_customer, no_telp_customer, email_customer)
VALUES
('Agus Santoso', '08123456789', 'agus@example.com'),
('Budi Hartono', '08198765432', NULL), -- No email
('Citra Dewi', NULL, 'citra@example.com'), -- No phone number
('Dedi Suharto', NULL, NULL), -- Neither phone nor email
('Eka Prasetya', '08234567890', 'eka@example.com');

-- Insert into transaksi and capture the generated id_transaksi dynamically
-- Step 1: Insert into transaksi and get the id_transaksi
WITH new_transaksi AS (
    INSERT INTO transaksi (id_customer)
    VALUES (1)  -- Replace with actual customer ID and date
    RETURNING id_transaksi
)
-- Step 2: Insert into detail_transaksi using the dynamic id_transaksi
INSERT INTO detail_transaksi (id_transaksi, id_barang, quantity, subtotal)
SELECT nt.id_transaksi, 1, 2, 20000 FROM new_transaksi nt
UNION ALL
SELECT nt.id_transaksi, 2, 1, 15000 FROM new_transaksi nt
UNION ALL
SELECT nt.id_transaksi, 3, 5, 50000 FROM new_transaksi nt;

-- Step 3: Update total_harga in transaksi
UPDATE transaksi t
SET total_harga = (
    SELECT SUM(subtotal)
    FROM detail_transaksi
    WHERE id_transaksi = t.id_transaksi
)
WHERE t.id_transaksi = 9;  -- Replace with actual id_transaksi

update transaksi
set piutang = true
where id_transaksi = 3

alter table transaksi
add column piutang boolean;

update transaksi
set piutang = true
where id_transaksi = 9

SELECT * 
            FROM transaksi
            JOIN customer ON transaksi.id_customer = customer.id_customer

SELECT * 
        FROM barang
        JOIN distributor ON barang.id_distributor = distributor.id_distributor
        where hutang = true
