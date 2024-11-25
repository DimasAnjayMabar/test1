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

-- Step 3: Update total_harga in transaksi using the id_transaksi from the same query
WITH total AS (
    SELECT nt.id_transaksi, SUM(dt.subtotal) AS grand_total
    FROM new_transaksi nt
    JOIN detail_transaksi dt ON nt.id_transaksi = dt.id_transaksi
    GROUP BY nt.id_transaksi
)
UPDATE transaksi t
SET total_harga = total.grand_total
FROM total
WHERE t.id_transaksi = total.id_transaksi;

-- Step 3: Update total_harga in transaksi
UPDATE transaksi t
SET total_harga = (
    SELECT SUM(subtotal)
    FROM detail_transaksi
    WHERE id_transaksi = t.id_transaksi
)
WHERE t.id_transaksi = 9;  -- Replace with actual id_transaksi