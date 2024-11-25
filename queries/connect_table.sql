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
ALTER TABLE detail_transaksi
ADD COLUMN id_transaksi INT,
ADD CONSTRAINT fk_id_transaksi
FOREIGN KEY (id_transaksi) REFERENCES transaksi(id_transaksi);

-- Connect transaksi to customer
ALTER TABLE transaksi
ADD COLUMN id_customer INT,
ADD CONSTRAINT fk_customer
FOREIGN KEY (id_customer) REFERENCES customer(id_customer);