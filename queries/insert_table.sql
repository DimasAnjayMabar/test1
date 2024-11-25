--insert table barang
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
    quantity INT NOT NULL,
    subtotal INT NOT NULL
);

-- Table for transactions
CREATE TABLE transaksi (
    id_transaksi INT AUTO_INCREMENT PRIMARY KEY,
    tanggal_transaksi DATE DEFAULT CURRENT_DATE,
    total_harga INT
);
