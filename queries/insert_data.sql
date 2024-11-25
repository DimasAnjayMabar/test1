-- distributor
INSERT INTO distributor (nama_distributor, not_telp_distributor, email_distributor, link_ecommerce) 
VALUES 
('Agung Supplier', '081234567890', 'agung@example.com', 'https://agungsupplier.com'),
('Tirta Plastik', '082345678901', NULL, NULL),
('Mega Grosir', NULL, NULL, 'https://megagrosir.com'),
('Jaya Makmur', '083456789012', 'jayamakmur@example.com', NULL),
('Kencana Sejahtera', NULL, NULL, NULL);

-- barang
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

-- customer
INSERT INTO customer (nama_customer, no_telp_customer, email_customer)
VALUES
('Agus Santoso', '08123456789', 'agus@example.com'),
('Budi Hartono', '08198765432', NULL), -- No email
('Citra Dewi', NULL, 'citra@example.com'), -- No phone number
('Dedi Suharto', NULL, NULL), -- Neither phone nor email
('Eka Prasetya', '08234567890', 'eka@example.com');

-- transaksi
INSERT INTO transaksi (id_customer)
VALUES
(1), -- Transaction for customer with id 1 (Agus Santoso)
(3); -- Transaction for customer with id 3 (Citra Dewi)

-- detail transaksi
