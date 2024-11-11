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
    id_customer INT,
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



