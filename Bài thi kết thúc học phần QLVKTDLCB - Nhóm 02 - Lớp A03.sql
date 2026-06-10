USE master;
IF DB_ID('QuanLyKinhDoanh') IS NOT NULL
BEGIN
    ALTER DATABASE QuanLyKinhDoanh SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyKinhDoanh;
END;
GO
-- 1. TẠO CƠ SỞ DỮ LIỆU QuanLyKinhDoanh
CREATE DATABASE QuanLyKinhDoanh;
GO
USE QuanLyKinhDoanh;
GO
-- 2. TẠO CÁC BẢNG
--      BẢNG NHACC
CREATE TABLE NHACC (
    MaNCC VARCHAR(20) NOT NULL,
    TenNCC NVARCHAR(100) NOT NULL,
    Sdt VARCHAR(11) NOT NULL,
    DiaChi NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_NHACC PRIMARY KEY (MaNCC)
);
--      BẢNG NHANVIEN
CREATE TABLE NHANVIEN (
    MaNV VARCHAR(20) NOT NULL,
    HoTenNV NVARCHAR(100) NOT NULL,
    Sdt VARCHAR(11) NOT NULL,
    CONSTRAINT PK_NHANVIEN PRIMARY KEY (MaNV)
);
--      BẢNG SANPHAM
CREATE TABLE SANPHAM (
    MaSP VARCHAR(20) NOT NULL,
    TenSP NVARCHAR(100) NOT NULL,
    QuyCach NVARCHAR(100) NULL,
    DonVi NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_SANPHAM PRIMARY KEY (MaSP)
);
--      BẢNG KHACHHANG
CREATE TABLE KHACHHANG (
    MaKH VARCHAR(20) NOT NULL,
    HoTenKH NVARCHAR(100) NOT NULL,
    Sdt VARCHAR(11) NOT NULL,
    DiaChi NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_KHACHHANG PRIMARY KEY (MaKH)
);
--     BẢNG PNHAP
CREATE TABLE PNHAP (
    SoPN VARCHAR(20) NOT NULL,
    MaNCC VARCHAR(20) NOT NULL,
    MaNV VARCHAR(20) NOT NULL,
    NgayNhap DATE NOT NULL,
    CONSTRAINT PK_PNHAP PRIMARY KEY (SoPN),
    CONSTRAINT FK_PNHAP_NHACC FOREIGN KEY (MaNCC) REFERENCES NHACC(MaNCC),
    CONSTRAINT FK_PNHAP_NHANVIEN FOREIGN KEY (MaNV)  REFERENCES NHANVIEN(MaNV)
);
--      BẢNG CTPNHAP
CREATE TABLE CTPNHAP (
    SoPN VARCHAR(20) NOT NULL,
    MaSP VARCHAR(20) NOT NULL,
    SoLuong INT NOT NULL,
    DonGia DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_CTPNHAP PRIMARY KEY (SoPN, MaSP),
    CONSTRAINT FK_CTPNHAP_PNHAP FOREIGN KEY (SoPN) REFERENCES PNHAP(SoPN),
    CONSTRAINT FK_CTPNHAP_SP FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);
--      BẢNG PMUA
CREATE TABLE PMUA (
    SoPM VARCHAR(20) NOT NULL,
    MaKH VARCHAR(20) NOT NULL,
    MaNV VARCHAR(20) NOT NULL,
    NgayMua DATE NOT NULL,
    CONSTRAINT PK_PMUA PRIMARY KEY (SoPM),
    CONSTRAINT FK_PMUA_KHACHHANG FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH),
    CONSTRAINT FK_PMUA_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);
--      BẢNG CTPMUA
CREATE TABLE CTPMUA (
    SoPM VARCHAR(20) NOT NULL,
    MaSP VARCHAR(20) NOT NULL,
    SoLuong INT NOT NULL,
    DonGia DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_CTPMUA PRIMARY KEY (SoPM, MaSP),
    CONSTRAINT FK_CTPMUA_PMUA FOREIGN KEY (SoPM) REFERENCES PMUA(SoPM),
    CONSTRAINT FK_CTPMUA_SP FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);
--      BẢNG PGIAO
CREATE TABLE PGIAO (
    SoPG VARCHAR(20) NOT NULL,
    SoPM VARCHAR(20) NOT NULL,
    MaNV VARCHAR(20) NOT NULL,
    MaKH VARCHAR(20) NOT NULL,
    NgayGiao DATE NOT NULL,
    CONSTRAINT PK_PGIAO PRIMARY KEY (SoPG),
    CONSTRAINT FK_PGIAO_PMUA FOREIGN KEY (SoPM) REFERENCES PMUA(SoPM),
    CONSTRAINT FK_PGIAO_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV),
    CONSTRAINT FK_PGIAO_KHACHHANG FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH)
);
--      BẢNG CTPGIAO
CREATE TABLE CTPGIAO (
    SoPG VARCHAR(20) NOT NULL,
    SoPM VARCHAR(20) NOT NULL,
    MaSP VARCHAR(20) NOT NULL,
    SoLuong INT NOT NULL,
    CONSTRAINT PK_CTPGIAO PRIMARY KEY (SoPG, SoPM),
    CONSTRAINT FK_CTPGIAO_PGIAO FOREIGN KEY (SoPG) REFERENCES PGIAO(SoPG),
    CONSTRAINT FK_CTPGIAO_PMUA FOREIGN KEY (SoPM) REFERENCES PMUA(SoPM),
    CONSTRAINT FK_CTPGIAO_SANPHAM FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);
--3. Định nghĩa các ràng buộc: Sdt, SoLuong, DonGia
ALTER TABLE NHACC
ADD CONSTRAINT CK_Sdt_NHACC CHECK (Sdt LIKE '0%');

ALTER TABLE NHANVIEN
ADD CONSTRAINT CK_Sdt_NHANVIEN CHECK (Sdt LIKE '0%');

ALTER TABLE KHACHHANG
ADD CONSTRAINT CK_Sdt_KHACHHANG CHECK (Sdt LIKE '0%');

ALTER TABLE CTPNHAP
ADD CONSTRAINT CK_SoLuong_CTPNHAP CHECK (SoLuong > 0),
    CONSTRAINT CK_DonGia_CTPNHAP CHECK (DonGia > 0);

ALTER TABLE CTPMUA
ADD CONSTRAINT CK_SoLuong_CTPMUA CHECK (SoLuong > 0),
    CONSTRAINT CK_DonGia_CTPMUA CHECK (DonGia > 0);

ALTER TABLE CTPGIAO
ADD CONSTRAINT CK_SoLuong_CTPGIAO CHECK (SoLuong > 0);

/*--4. Sửa đổi bảng
--      Thêm cột Email vào bảng KHACHHANG
ALTER TABLE KHACHHANG
ADD Email VARCHAR(255) NOT NULL;
--      Thay đổi kích thước cột DiaChi trong bảng NHACC
ALTER TABLE NHACC
ALTER COLUMN DiaChi NVARCHAR(255);

--5. Xóa ràng buộc, xóa bảng
--      Xóa ràng buộc thuộc tính DonGia trong bảng CTPMUA
ALTER TABLE CTPMUA
DROP CONSTRAINT CK_DonGia_CTPMUA;
--      Xóa bảng CTPGIAO
DROP TABLE CTPGIAO;*/

--6. Nhập dữ liệu cho các bảng
INSERT INTO NHACC (MaNCC, TenNCC, Sdt, DiaChi) VALUES
('NCC01', N'Công ty TNHH Quốc tế Tam Liên', '0901111111', N'Hải Dương'),
('NCC02', N'Công ty Vật tư An Bình', '0902222222', N'Hà Nội'),
('NCC03', N'Công ty Thiết bị Hà Minh', '0368521657', N'Hà Nội');

INSERT INTO NHANVIEN (MaNV, HoTenNV, Sdt) VALUES
('NV01', N'Nguyễn Văn An', '0911111111'),
('NV02', N'Trần Thị Bình', '0912222222'),
('NV03', N'Nguyễn Như Quỳnh', '0969357864');

INSERT INTO SANPHAM (MaSP, TenSP, QuyCach, DonVi) VALUES
('SP01', N'Thẻ màu', N'86x305 mm', N'Thẻ'),
('SP02', N'Keo dán', Null, N'Thùng'),
('SP03', N'Giấy Duplex', N'100*120 cm', N'Tờ'),
('SP04', N'Giấy in nhiệt', N'80*100 cm', N'Tờ');

INSERT INTO KHACHHANG (MaKH, HoTenKH, Sdt, DiaChi) VALUES
('KH01', N'Lê Minh Long', '0981111111', N'Hải Phòng'),
('KH02', N'Công ty TNHH Công nghệ Đại Cát', '0982222222', N'Hải Phòng'),
('KH03', N'Công ty Thiết bị Trường An', '0368369564', N'Nghệ An');

INSERT INTO PNHAP (SoPN, MaNCC, MaNV, NgayNhap) VALUES
('PN01', 'NCC01', 'NV02', '2024-11-01'),
('PN02', 'NCC02', 'NV01', '2024-11-01'),
('PN03', 'NCC01', 'NV03', '2025-10-26');

INSERT INTO CTPNHAP (SoPN, MaSP, SoLuong, DonGia) VALUES
('PN01', 'SP01', 100, 150000),
('PN01', 'SP02', 50, 200000),
('PN02', 'SP02', 80, 200000),
('PN03', 'SP03', 25, 160000);

INSERT INTO PMUA (SoPM, MaKH, MaNV, NgayMua) VALUES
('PM01', 'KH01', 'NV01', '2025-11-04'),
('PM02', 'KH02', 'NV02', '2025-11-04'),
('PM03', 'KH03', 'NV02', '2025-12-05');

INSERT INTO CTPMUA (SoPM, MaSP, SoLuong, DonGia) VALUES
('PM01', 'SP01', 5, 180000),
('PM01', 'SP02', 3, 220000),
('PM02', 'SP02', 4, 225000),
('PM03', 'SP01', 15, 165000);

INSERT INTO PGIAO (SoPG, SoPM, MaNV, MaKH, NgayGiao) VALUES
('PG01', 'PM01', 'NV01', 'KH01', '2025-11-24'),
('PG02', 'PM02', 'NV02', 'KH02', '2025-11-24'),
('PG03', 'PM01', 'NV01', 'KH01', '2025-12-01');

INSERT INTO CTPGIAO (SoPG, SoPM, MaSP, SoLuong) VALUES
('PG01', 'PM01','SP01', 5),
('PG02', 'PM01','SP02', 3),
('PG03', 'PM02','SP02', 4);

--7. Đặt 3 yêu cầu đơn giản
--      Hiện thị thông tin các nhà cung cấp
SELECT * FROM NHACC;

--      Hiện thị tên và số điện thoại các khách hàng ở Hải Phòng
SELECT HoTenKH, Sdt FROM KHACHHANG
WHERE DiaChi = N'Hải Phòng';

--      Hiện thị mã khách hàng, tên khách hàng với khách hàng là công ty
SELECT MaKH, HoTenKH FROM KHACHHANG
WHERE HoTenKH LIKE N'%Công ty%';

--8. Đặt 3 yêu cầu phức tạp
--      Hiện thị danh sách phiếu nhập và tổng tiền của từng phiếu
SELECT pn.SoPN, pn.NgayNhap,
        SUM(ctpn.SoLuong * ctpn.DonGia) AS TongTien
FROM PNHAP pn
JOIN CTPNHAP ctpn ON pn.SoPN = ctpn.SoPN
GROUP BY pn.SoPN, pn.NgayNhap;

--      Hiện thị thông tin khách hàng mua nhiều sản phẩm nhất
SELECT TOP 1 kh.MaKH, kh.HoTenKH,
    SUM(ctpm.SoLuong) AS TongLuongMua
FROM KHACHHANG kh
JOIN PMUA pm ON pm.MaKH = kh.MaKH
JOIN CTPMUA ctpm ON ctpm.SoPM = pm.SoPM
GROUP BY kh.MaKH, kh.HoTenKH
ORDER BY TongLuongMua DESC;

--      Hiện thị sản phẩm được mua nhiều nhất
SELECT TOP 1 sp.MaSP, sp.TenSP,
    SUM(ctpm.SoLuong) AS LuongMuaNhieuNhat
FROM SANPHAM sp
JOIN CTPMUA ctpm ON ctpm.MaSP = sp.MaSP
GROUP BY sp.MaSP, sp.TenSP
ORDER BY LuongMuaNhieuNhat DESC;

--9. Đặt 6 yêu cầu thống kê đơn giản
--      Thống kê doanh thu theo ngày
SELECT pm.NgayMua,
    SUM(ctpm.SoLuong * ctpm.DonGia) AS DoanhThuNgay
FROM PMUA pm
JOIN CTPMUA ctpm ON ctpm.SoPM = pm.SoPM
GROUP BY pm.NgayMua;

--      Thống kê doanh thu theo tháng
SELECT 
    YEAR(pm.NgayMua) AS Nam,
    MONTH(pm.NgayMua) AS Thang,
    SUM(ctpm.SoLuong * ctpm.DonGia) AS DoanhThuThang
FROM PMUA pm
JOIN CTPMUA ctpm ON pm.SoPM = ctpm.SoPM
GROUP BY YEAR(pm.NgayMua), MONTH(pm.NgayMua)
ORDER BY Nam, Thang;

--      Thống kê doanh thu theo khách hàng
SELECT kh.MaKH, kh.HoTenKH,
    SUM(ctpm.SoLuong * ctpm.DonGia) AS DoanhThuKH
FROM KHACHHANG kh
JOIN PMUA pm ON pm.MaKH = kh.MaKH
JOIN CTPMUA ctpm ON ctpm.SoPM = pm.SoPM
GROUP BY kh.MaKH, kh.HoTenKH;

--      Thống kê tổng số lượng hàng nhập theo sản phẩm
SELECT sp.MaSP, sp.TenSP,
    SUM(ctpn.SoLuong) AS TongLuongNhap
FROM SANPHAM sp
JOIN CTPNHAP ctpn ON ctpn.MaSP = sp.MaSP
GROUP BY sp.MaSP, sp.TenSP;

--      Thống kê tổng số lượng hàng đã giao theo sản phẩm
SELECT sp.MaSP, sp.TenSP,
    SUM(ctpg.SoLuong) AS TongLuongGiao
FROM SANPHAM sp
JOIN CTPGIAO ctpg ON ctpg.MaSP = sp.MaSP
GROUP BY sp.MaSP, sp.TenSP;

--      Hiện thị nhân viên bán được nhiều sản phẩm nhất
SELECT TOP 1 nv.MaNV, nv.HoTenNV,
    SUM(ctpm.SoLuong) AS TongLuongBan
FROM NHANVIEN nv
JOIN PMUA pm ON pm.MaNV = nv.MaNV
JOIN CTPMUA ctpm ON ctpm.SoPM = pm.SoPM
GROUP BY nv.MaNV, nv.HoTenNV
ORDER BY TongLuongBan DESC;

--      Sắp xếp giảm dần tổng số nghiệp vụ mà các nhân viên tham gia
SELECT nv.MaNV, nv.HoTenNV,
(SELECT COUNT(*) FROM PNHAP WHERE MaNV=nv.MaNV)
+ (SELECT COUNT(*) FROM PMUA WHERE MaNV=nv.MaNV)
+ (SELECT COUNT(*) FROM PGIAO WHERE MaNV=nv.MaNV) AS TongNghiepVu
FROM NHANVIEN nv
ORDER BY TongNghiepVu DESC;

--10. Đặt 6 yêu cầu thống kê nâng cao
--      Hiện thị những sản phẩm chưa có trong kho
SELECT sp.MaSP, sp.TenSP
FROM SANPHAM sp
WHERE sp.MaSP NOT IN (SELECT MaSP FROM CTPNHAP);

--      Hiện thị những sản phẩm đã nhập mà chưa bán
SELECT DISTINCT MaSP, TenSP
FROM SANPHAM
WHERE MaSP IN (SELECT MaSP FROM CTPNHAP)
AND MaSP NOT IN (SELECT MaSP FROM CTPMUA);

--      Hiện thị những nhà cung cấp có tổng tiền nhập lớn hơn 20 000 000
SELECT ncc.MaNCC, ncc.TenNCC,
    SUM(ctpn.SoLuong * ctpn.DonGia) AS TongTienNhap
FROM NHACC ncc
JOIN PNHAP pn ON pn.MaNCC = ncc.MaNCC
JOIN CTPNHAP ctpn ON ctpn.SoPN = pn.SoPN
GROUP BY ncc.MaNCC, ncc.TenNCC
HAVING SUM(ctpn.SoLuong * ctpn.DonGia) > 20000000;

-- Trigger: Kiểm tra dữ liệu trước khi nhập vào bảng CTPMUA
GO
CREATE TRIGGER Trg_Check_CTPMUA
ON CTPMUA
FOR INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra số lượng
    IF EXISTS (SELECT 1 FROM inserted WHERE SoLuong <= 0)
    BEGIN
        RAISERROR ('SoLuong phải > 0', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    -- Kiểm tra đơn giá
    IF EXISTS (SELECT 1 FROM inserted WHERE DonGia <= 0)
    BEGIN
        RAISERROR ('DonGia phải > 0', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

--      Trigger ngăn giao hàng vượt quá số lượng đã mua
GO
CREATE TRIGGER Trg_CTPGIAO_CheckSL
ON CTPGIAO
FOR INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i
        JOIN CTPMUA ctpm ON ctpm.SoPM = i.SoPM AND ctpm.MaSP = i.MaSP
        WHERE i.SoLuong > ctpm.SoLuong)
    BEGIN
        RAISERROR('So luong giao khong the vuot so luong mua', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO
/*
--      Trigger tự động cập nhật tồn kho khi nhập hàng
GO
ALTER TABLE SANPHAM
ADD TonKho INT DEFAULT 0;
GO
CREATE TRIGGER Trg_CTPNHAP_TonKho
ON CTPNHAP
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON; -- Tắt thông báo (X rows affected)
    -- Kiểm tra số lượng > 0
    IF EXISTS (SELECT * FROM inserted WHERE SoLuong <= 0)
    BEGIN
        RAISERROR('So luong phai lon hon 0', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    -- Cập nhật tồn kho
    UPDATE sp
    SET sp.TonKho = sp.TonKho + i.SoLuong
    FROM SANPHAM sp
    JOIN inserted i ON sp.MaSP = i.MaSP;
END;
GO
*/
--11. Viết và thực thi 2 hàm/thủ tục tạo thông báo bất kỳ
--      Hàm tính tồn kho của sản phẩm
GO
CREATE FUNCTION TonKho (@MaSP VARCHAR(20))
RETURNS TABLE
AS
RETURN
(
    SELECT sp.MaSP, sp.TenSP,
           ISNULL(Nhap.TongNhap, 0) - ISNULL(Giao.TongGiao, 0) AS TonKho
    FROM SANPHAM sp
    LEFT JOIN (SELECT MaSP, SUM(SoLuong) AS TongNhap
        FROM CTPNHAP GROUP BY MaSP) AS Nhap ON Nhap.MaSP = sp.MaSP
    LEFT JOIN (SELECT MaSP, SUM(SoLuong) AS TongGiao
        FROM CTPGIAO GROUP BY MaSP) AS Giao ON Giao.MaSP = sp.MaSP
    WHERE sp.MaSP = @MaSP
);
GO

SELECT * FROM dbo.TonKho('SP01'); --Nhập mã sản phẩm để xem số lượng tồn kho
SELECT * FROM dbo.TonKho('SP02');

--      Thủ tục thông báo hàng tồn kho dưới mức tối thiểu
GO
CREATE PROCEDURE ThongBao_TonKhoThap
    @MaSP VARCHAR(20),
    @TonKhoToiThieu INT
AS
BEGIN
    DECLARE @Nhap INT;
    DECLARE @Giao INT;
    DECLARE @TonKho INT;
    SELECT @Nhap = ISNULL(SUM(SoLuong), 0) --Tổng nhập
    FROM CTPNHAP
    WHERE MaSP = @MaSP;
    SELECT @Giao = ISNULL(SUM(SoLuong), 0) --Tổng giao
    FROM CTPGIAO
    WHERE MaSP = @MaSP;
    SET @TonKho = @Nhap - @Giao; --Tồn kho
    -- Kiểm tra sản phẩm có tồn tại hay không
    IF NOT EXISTS (SELECT 1 FROM SANPHAM WHERE MaSP = @MaSP)
    BEGIN
        PRINT N'Mã sản phẩm không tồn tại!';
        RETURN;
    END;
    IF @TonKho < @TonKhoToiThieu
        PRINT N'Tồn kho của sản phẩm ' + @MaSP + N' đang thấp hơn mức tối thiểu! (Tồn: '
        + CAST(@TonKho AS VARCHAR(10)) +  N', Mức tối thiểu: ' + CAST(@TonKhoToiThieu AS VARCHAR(10)) + N')';
    ELSE
        PRINT N'Tồn kho sản phẩm ' + @MaSP + N' vẫn đảm bảo. (Tồn hiện tại: ' + CAST(@TonKho AS VARCHAR(10)) + N')';
END;
GO

EXEC ThongBao_TonKhoThap 'SP01',100;
EXEC ThongBao_TonKhoThap 'SP02', 50;

--12. Sao lưu và phục hồi dữ liệu
--      Sao lưu
BACKUP DATABASE QuanLyKinhDoanh
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\QuanLyKinhDoanh_Full.bak'
WITH INIT, FORMAT;

--     Phục hồi
ALTER DATABASE QuanLyKinhDoanh
SET SINGLE_USER WITH ROLLBACK IMMEDIATE; --Đảm bảo không có kết nối khác đang sử dụng
RESTORE DATABASE QuanLyKinhDoanh
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\QuanLyKinhDoanh_Full.bak'
WITH REPLACE;
ALTER DATABASE QuanLyKinhDoanh SET MULTI_USER; --Đưa về trạng thái ban đầu


SELECT 
    KH.HoTenKH,
    SP.MaSP,
    SP.TenSP,
    CT.SoLuong,
    CT.DonGia,
    (CT.SoLuong * CT.DonGia) AS ThanhTien,
    PM.NgayMua
FROM PMUA PM
JOIN CTPMUA CT ON PM.SoPM = CT.SoPM
JOIN SANPHAM SP ON CT.MaSP = SP.MaSP
JOIN KHACHHANG KH ON PM.MaKH = KH.MaKH
WHERE PM.NgayMua = '2025-12-12';


SELECT TOP 1 
       sp.MaSP,
       sp.TenSP,
       SUM(ct.SoLuong) AS TongSoLuongBan
FROM PMUA pm
JOIN CTPMUA ct ON pm.SoPM = ct.SoPM
JOIN SANPHAM sp ON ct.MaSP = sp.MaSP
WHERE MONTH(pm.NgayMua) = 12
GROUP BY sp.MaSP, sp.TenSP
ORDER BY TongSoLuongBan DESC;


SELECT TOP 1 
       sp.MaSP,
       sp.TenSP,
       SUM(ct.SoLuong) AS TongSoLuongBan
FROM HoaDon hd
JOIN ChiTietHoaDon ct ON hd.MaHoaDon = ct.MaHoaDon
JOIN SanPham sp ON ct.MaSP = sp.MaSP
WHERE MONTH(hd.NgayLap) = 12
GROUP BY sp.MaSP, sp.TenSP
ORDER BY TongSoLuongBan DESC;


SELECT DISTINCT
    n.MaNCC,
    n.TenNCC,
    s.MaSP,
    s.TenSP
FROM NHACC n
JOIN PNHAP p ON p.MaNCC = n.MaNCC
JOIN CTPNHAP c ON c.SoPN = p.SoPN
JOIN SANPHAM s ON s.MaSP = c.MaSP
ORDER BY n.TenNCC, s.TenSP;
SELECT
    n.MaNCC,
    n.TenNCC,
    s.MaSP,
    s.TenSP,
    SUM(c.SoLuong) AS TongSoLuongNhap_Thang12
FROM NHACC n
JOIN PNHAP p ON p.MaNCC = n.MaNCC
JOIN CTPNHAP c ON c.SoPN = p.SoPN
JOIN SANPHAM s ON s.MaSP = c.MaSP
WHERE MONTH(p.NgayNhap) = 12 AND YEAR(p.NgayNhap) = 2025
GROUP BY n.MaNCC, n.TenNCC, s.MaSP, s.TenSP
ORDER BY n.TenNCC, TongSoLuongNhap_Thang12 DESC;


SELECT ncc.MaNCC, ncc.TenNCC
FROM NHACC ncc
WHERE ncc.MaNCC NOT IN 
    (SELECT pn.MaNCC
     FROM PNHAP pn
     WHERE MONTH(pn.NgayNhap) = 12
     AND YEAR(pn.NgayNhap) = 2025);


SELECT
    sp.TenSP,
    ctpm.SoLuong,
    pm.NgayMua
FROM NHANVIEN nv
JOIN PMUA pm ON nv.MaNV = pm.MaNV
JOIN CTPMUA ctpm ON pm.SoPM = ctpm.SoPM
JOIN SANPHAM sp ON ctpm.MaSP = sp.MaSP
WHERE nv.MaNV = 'NV02' 
    AND MONTH(pm.NgayMua) = 12
ORDER BY pm.NgayMua;