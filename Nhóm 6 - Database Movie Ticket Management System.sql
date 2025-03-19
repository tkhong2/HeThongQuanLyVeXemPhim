CREATE DATABASE QLHTBVXP;

USE QLHTBVXP;

CREATE TABLE MovieGenre (
    MovieGenreID INT IDENTITY(1,1) PRIMARY KEY,
    NameGenre NVARCHAR(50)
);

CREATE TABLE Movie (
    MovieID INT IDENTITY(1,1) PRIMARY KEY,
    NameMovie NVARCHAR(100),
    Director NVARCHAR(100),
    MovieGenreID INT,
    FOREIGN KEY (MovieGenreID) REFERENCES MovieGenre(MovieGenreID)
);

CREATE TABLE ScreenRoom (
    ScreenRoomID INT IDENTITY(1,1) PRIMARY KEY,
    NameRoom NVARCHAR(50),
    TotalSeat INT
);

CREATE TABLE Seats (
    SeatID INT IDENTITY(1,1) PRIMARY KEY,
    ScreenRoomID INT,
    SeatNumber NVARCHAR(10),
    Status NVARCHAR(10) DEFAULT N'Trống', 
    FOREIGN KEY (ScreenRoomID) REFERENCES ScreenRoom(ScreenRoomID),
    CONSTRAINT CHK_SeatStatus CHECK (Status IN (N'Trống', N'Đã đặt', N'Đã bán')) 
);

CREATE TABLE ShowTime (
    ShowTimeID INT IDENTITY(1,1) PRIMARY KEY,
    BeginTime DATETIME,
    EndTime DATETIME,
    CapacityUtilization DECIMAL(5, 2)
);

CREATE TABLE Promotions (
    PromotionID INT IDENTITY(1,1) PRIMARY KEY,
    PromotionCode NVARCHAR(20),
    DiscountPercentage DECIMAL(5, 2),
    StartDate DATE,
    EndDate DATE,
    ApplicableTicketType NVARCHAR(50)
);

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Address NVARCHAR(255),
    DateOfBirth DATE,
    PhoneNumber NVARCHAR(20),
    Salary DECIMAL(10, 2)
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Address NVARCHAR(255),
    DateOfBirth DATE,
    PhoneNumber NVARCHAR(20),
    Email NVARCHAR(100)
);

CREATE TABLE Tickets (
    TicketID INT IDENTITY(1,1) PRIMARY KEY,
    Price DECIMAL(10, 2),
    EmployeeID INT,
    CustomerID INT,
    SeatID INT,
    MovieID INT,
    RoomID INT,
    ShowTimeID INT,
    TicketType NVARCHAR(50),
    TicketSaleDate DATE,
    PromotionID INT,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (SeatID) REFERENCES Seats(SeatID),
    FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
    FOREIGN KEY (RoomID) REFERENCES ScreenRoom(ScreenRoomID),
    FOREIGN KEY (ShowTimeID) REFERENCES ShowTime(ShowTimeID),
    FOREIGN KEY (PromotionID) REFERENCES Promotions(PromotionID)
);

CREATE TABLE Counter (
    CounterID INT IDENTITY(1,1) PRIMARY KEY,
    TicketID INT,
    EmployeeID INT,
    NameCounter NVARCHAR(50),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID)
);

CREATE TABLE Invoices (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
    TicketID INT,
    CustomerID INT,
    Amount DECIMAL(10, 2),
    PaymentMethod NVARCHAR(20),
    InvoiceDate DATETIME,
    FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT CHK_PaymentMethod CHECK (PaymentMethod IN (N'Tiền mặt', N'Thẻ', N'Ví điện tử'))
);

SELECT * FROM ShowTime

DROP TABLE IF EXISTS Counter;
DROP TABLE IF EXISTS Invoices;
DROP TABLE IF EXISTS Tickets;
DROP TABLE IF EXISTS Seats;
DROP TABLE IF EXISTS ShowTime;
DROP TABLE IF EXISTS ScreenRoom;
DROP TABLE IF EXISTS Promotions;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Movie;
DROP TABLE IF EXISTS MovieGenre;

--VIEW
-- View 1: MovieWithGenre
-- Mục đích: Liệt kê tất cả phim cùng với thể loại tương ứng, giúp người dùng dễ dàng tìm kiếm phim theo thể loại.
CREATE VIEW MovieWithGenre AS
SELECT m.NameMovie, mg.NameGenre
FROM Movie m
JOIN MovieGenre mg ON m.MovieGenreID = mg.MovieGenreID;
SELECT * FROM MovieWithGenre;

-- View 2: RoomWithSeats
-- Mục đích: Hiển thị thông tin cơ bản về phòng chiếu (tên phòng và tổng số ghế), hỗ trợ quản lý cơ sở vật chất.
CREATE VIEW RoomWithSeats AS
SELECT NameRoom, TotalSeat
FROM ScreenRoom;

SELECT * FROM RoomWithSeats

-- View 3: SeatStatus
-- Mục đích: Cung cấp trạng thái của từng ghế trong từng phòng (trống, đã đặt, đã bán), hỗ trợ bán vé và kiểm tra chỗ ngồi.
CREATE VIEW SeatStatus AS
SELECT s.SeatNumber, sr.NameRoom, s.Status
FROM Seats s
JOIN ScreenRoom sr ON s.ScreenRoomID = sr.ScreenRoomID;

SELECT * FROM SeatStatus
-- View 4: ShowTimesWithMovieAndRoom
-- Mục đích: Liệt kê lịch chiếu với thông tin phim và phòng chiếu, dùng để hiển thị lịch chiếu cho khách hàng hoặc lập kế hoạch.
CREATE VIEW ShowTimesWithMovieAndRoom AS
SELECT DISTINCT st.BeginTime, st.EndTime, m.NameMovie, sr.NameRoom
FROM ShowTime st
JOIN Tickets t ON st.ShowTimeID = t.ShowTimeID
JOIN Movie m ON t.MovieID = m.MovieID
JOIN ScreenRoom sr ON t.RoomID = sr.ScreenRoomID;

SELECT * FROM ShowTimesWithMovieAndRoom

-- View 5: ActivePromotions
-- Mục đích: Liệt kê các chương trình khuyến mãi đang hoạt động dựa trên ngày hiện tại, hỗ trợ quản lý và áp dụng khuyến mãi.
CREATE VIEW ActivePromotions AS
SELECT *
FROM Promotions
WHERE GETDATE() BETWEEN StartDate AND EndDate;

SELECT * FROM ActivePromotions

-- View 8: TicketDetails
-- Mục đích: Hiển thị thông tin chi tiết của từng vé đã bán (khách hàng, phim, suất chiếu, ghế), hỗ trợ kiểm tra và dịch vụ khách hàng.
CREATE VIEW TicketDetails AS
SELECT t.TicketID, c.FullName as CustomerName, m.NameMovie, st.BeginTime as ShowTime, s.SeatNumber
FROM Tickets t
JOIN Customers c ON t.CustomerID = c.CustomerID
JOIN Movie m ON t.MovieID = m.MovieID
JOIN ShowTime st ON t.ShowTimeID = t.ShowTimeID
JOIN Seats s ON t.SeatID = s.SeatID;

SELECT * FROM TicketDetails

-- View 9: RevenuePerMovie (Nâng cao)
-- Mục đích: Tính tổng doanh thu từ vé bán cho từng phim, hỗ trợ phân tích tài chính và đánh giá hiệu quả phim.
CREATE VIEW RevenuePerMovie AS
SELECT m.NameMovie, SUM(t.Price) as TotalRevenue
FROM Movie m
JOIN Tickets t ON m.MovieID = t.MovieID
GROUP BY m.NameMovie;

SELECT * FROM RevenuePerMovie

-- View 10: TicketsPerShowTime (Nâng cao)
-- Mục đích: Đếm số lượng vé bán cho mỗi suất chiếu, bao gồm cả suất không có vé (số 0), giúp đánh giá hiệu suất suất chiếu.
CREATE VIEW TicketsPerShowTime AS
SELECT st.ShowTimeID, COUNT(t.TicketID) as TicketCount
FROM ShowTime st
LEFT JOIN Tickets t ON st.ShowTimeID = t.ShowTimeID
GROUP BY st.ShowTimeID;

SELECT * FROM TicketsPerShowTime

-- View 11: RecentCustomers (
-- Mục đích: Liệt kê thông tin khách hàng đã mua vé trong vòng 1 tháng gần nhất, hỗ trợ quản lý khách hàng thân thiết và khuyến mãi.
CREATE VIEW RecentCustomers AS
SELECT c.*
FROM Customers c
JOIN Tickets t ON c.CustomerID = t.CustomerID
WHERE t.TicketSaleDate >= DATEADD(MONTH, -1, GETDATE());

SELECT * FROM RecentCustomers
-- View 12: ShowTimeDetails (Nâng cao)
-- Mục đích: Cung cấp chi tiết về mỗi suất chiếu (phim, phòng, tổng số ghế, số vé đã bán), hỗ trợ phân tích hiệu suất và lập kế hoạch.
CREATE VIEW ShowTimeDetails AS
SELECT st.ShowTimeID, m.NameMovie, sr.NameRoom, sr.TotalSeat, COUNT(t.TicketID) as TicketsSold
FROM ShowTime st
JOIN Tickets t ON st.ShowTimeID = t.ShowTimeID
JOIN Movie m ON t.MovieID = m.MovieID
JOIN ScreenRoom sr ON t.RoomID = sr.ScreenRoomID
GROUP BY st.ShowTimeID, m.NameMovie, sr.NameRoom, sr.TotalSeat;

SELECT * FROM ShowTimeDetails

--Procedure 
-- 1. Thêm khách hàng mới và kiểm tra email hợp lệ
CREATE PROCEDURE sp_AddCustomer
    @FullName NVARCHAR(100),
    @Address NVARCHAR(255),
    @DateOfBirth DATE,
    @PhoneNumber NVARCHAR(20),
    @Email NVARCHAR(100)
AS
BEGIN
    IF @Email NOT LIKE '%_@__%.__%' -- Kiểm tra định dạng email cơ bản
    BEGIN
        RAISERROR ('Email không hợp lệ!', 16, 1);
        RETURN;
    END
    INSERT INTO Customers (FullName, Address, DateOfBirth, PhoneNumber, Email)
    VALUES (@FullName, @Address, @DateOfBirth, @PhoneNumber, @Email);
    PRINT 'Thêm khách hàng thành công!';
END;

EXEC sp_AddCustomer 
    @FullName = N'Nguyễn Quốc Phong', 
    @Address = N'Số 99 Đường Nguyễn Trãi', 
    @DateOfBirth = '1995-08-20', 
    @PhoneNumber = '0941234567', 
    @Email = 'nguyenquocphong@gmail.com';

-- 2. Cập nhật trạng thái ghế sau khi đặt vé
CREATE PROCEDURE sp_UpdateSeatStatus
    @SeatID INT,
    @Status VARCHAR(10)
AS
BEGIN
    UPDATE Seats
    SET Status = @Status
    WHERE SeatID = @SeatID;
    IF @@ROWCOUNT = 0
        RAISERROR ('Không tìm thấy ghế với SeatID đã cho!', 16, 1);
    ELSE
        PRINT N'Cập nhật trạng thái ghế thành công!';
END;

EXEC sp_UpdateSeatStatus 
    @SeatID = 1, 
    @Status = 'Đã đặt';

-- 3. Tính tổng doanh thu theo ngày
CREATE PROCEDURE sp_GetRevenueByDate
    @SaleDate DATE
AS
BEGIN
    SELECT SUM(Amount) AS TotalRevenue
    FROM Invoices
    WHERE CAST(InvoiceDate AS DATE) = @SaleDate;
END;

EXEC sp_GetRevenueByDate 
@SaleDate = '2025-03-15';

-- 5. Áp dụng khuyến mãi cho vé dựa trên loại vé
CREATE PROCEDURE sp_ApplyPromotion
    @TicketID INT,
    @PromotionCode NVARCHAR(20)
AS
BEGIN
    DECLARE @PromotionID INT, @Discount DECIMAL(5, 2), @TicketType NVARCHAR(50), @Price DECIMAL(10, 2);
    SELECT @PromotionID = PromotionID, @Discount = DiscountPercentage, @TicketType = ApplicableTicketType
    FROM Promotions
    WHERE PromotionCode = @PromotionCode
    AND GETDATE() BETWEEN StartDate AND EndDate;

    IF @PromotionID IS NULL
    BEGIN
        RAISERROR ('Mã khuyến mãi không hợp lệ hoặc đã hết hạn!', 16, 1);
        RETURN;
    END
    SELECT @Price = Price, @TicketType = TicketType
    FROM Tickets
    WHERE TicketID = @TicketID;
    IF @TicketType != @TicketType
    BEGIN
        RAISERROR ('Loại vé không áp dụng được khuyến mãi này!', 16, 1);
        RETURN;
    END
    UPDATE Tickets
    SET Price = @Price * (1 - @Discount / 100),
        PromotionID = @PromotionID
    WHERE TicketID = @TicketID;
    PRINT 'Áp dụng khuyến mãi thành công!';
END;

EXEC sp_ApplyPromotion 
    @TicketID = 1, 
    @PromotionCode = 'KM10';

-- 7. Tìm ghế trống trong một phòng chiếu cho suất chiếu cụ thể
CREATE PROCEDURE sp_GetAvailableSeats
    @ShowTimeID INT,
    @RoomID INT
AS
BEGIN
    SELECT s.SeatID, s.SeatNumber
    FROM Seats s
    WHERE s.ScreenRoomID = @RoomID
    AND s.Status = 'Trống'
    AND s.SeatID NOT IN (
        SELECT t.SeatID
        FROM Tickets t
        WHERE t.ShowTimeID = @ShowTimeID
        AND t.RoomID = @RoomID
    );
END;

EXEC sp_GetAvailableSeats 
    @ShowTimeID = 1, 
    @RoomID = 1;

-- 8. Thống kê phim có doanh thu cao nhất trong tháng
CREATE PROCEDURE sp_GetTopRevenueMovieByMonth
    @Month INT,
    @Year INT
AS
BEGIN
    SELECT TOP 1 
        m.NameMovie, 
        SUM(i.Amount) AS TotalRevenue
    FROM Movie m
    JOIN Tickets t ON m.MovieID = t.MovieID
    JOIN Invoices i ON t.TicketID = i.TicketID
    WHERE MONTH(i.InvoiceDate) = @Month
    AND YEAR(i.InvoiceDate) = @Year
    GROUP BY m.NameMovie
    ORDER BY TotalRevenue DESC;
END;
GO

EXEC sp_GetTopRevenueMovieByMonth 
    @Month = 3, 
    @Year = 2025;

-- 9. Cập nhật tỷ lệ sử dụng suất chiếu
CREATE PROCEDURE sp_UpdateCapacityUtilization
    @ShowTimeID INT
AS
BEGIN
    DECLARE @RoomID INT, @TotalSeats INT, @SoldSeats INT, @Capacity DECIMAL(5, 2);
    SELECT @RoomID = RoomID
    FROM Tickets
    WHERE ShowTimeID = @ShowTimeID
    GROUP BY RoomID;
    SELECT @TotalSeats = TotalSeat
    FROM ScreenRoom
    WHERE ScreenRoomID = @RoomID;
    SELECT @SoldSeats = COUNT(*)
    FROM Tickets
    WHERE ShowTimeID = @ShowTimeID
    AND RoomID = @RoomID;
    SET @Capacity = (@SoldSeats * 100.0) / @TotalSeats;
    UPDATE ShowTime
    SET CapacityUtilization = @Capacity
    WHERE ShowTimeID = @ShowTimeID;
    PRINT 'Cập nhật tỷ lệ sử dụng suất chiếu thành công!';
END;

EXEC sp_UpdateCapacityUtilization 
    @ShowTimeID = 1;

-- 10. Tạo hóa đơn tự động khi bán vé
CREATE PROCEDURE sp_CreateInvoice
    @TicketID INT,
    @CustomerID INT,
    @PaymentMethod NVARCHAR(20)
AS
BEGIN
    DECLARE @Amount DECIMAL(10, 2);
    SELECT @Amount = Price
    FROM Tickets
    WHERE TicketID = @TicketID;
    INSERT INTO Invoices (TicketID, CustomerID, Amount, PaymentMethod, InvoiceDate)
    VALUES (@TicketID, @CustomerID, @Amount, @PaymentMethod, GETDATE());
    PRINT 'Tạo hóa đơn thành công!';
END;

EXEC sp_CreateInvoice 
    @TicketID = 3, 
    @CustomerID = 3, 
    @PaymentMethod = N'Thẻ';

-- 11. Tìm khách hàng mua nhiều vé nhất trong khoảng thời gian
CREATE PROCEDURE sp_GetTopCustomerByTicketCount
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT TOP 1 
        c.CustomerID, 
        c.FullName, 
        COUNT(t.TicketID) AS TotalTickets
    FROM Customers c
    JOIN Tickets t ON c.CustomerID = t.CustomerID
    WHERE t.TicketSaleDate BETWEEN @StartDate AND @EndDate
    GROUP BY c.CustomerID, c.FullName
    ORDER BY TotalTickets DESC;
END;

EXEC sp_GetTopCustomerByTicketCount 
    @StartDate = '2025-03-01', 
    @EndDate = '2025-03-31';


-- 12. Tự động gia hạn khuyến mãi nếu chưa hết hạn và đạt điều kiện 
CREATE PROCEDURE sp_ExtendPromotion
    @PromotionID INT,
    @ExtensionDays INT,
    @MinTicketSold INT
AS
BEGIN
    DECLARE @TicketCount INT;
    SELECT @TicketCount = COUNT(*)
    FROM Tickets
    WHERE PromotionID = @PromotionID;
    IF @TicketCount >= @MinTicketSold
    BEGIN
        UPDATE Promotions
        SET EndDate = DATEADD(DAY, @ExtensionDays, EndDate)
        WHERE PromotionID = @PromotionID
        AND EndDate >= GETDATE();
        PRINT 'Gia hạn khuyến mãi thành công!';
    END
    ELSE
    BEGIN
        RAISERROR ('Không đủ số vé để gia hạn khuyến mãi!', 16, 1);
    END
END;

EXEC sp_ExtendPromotion 
    @PromotionID = 1, 
    @ExtensionDays = 15, 
    @MinTicketSold = 2;

--Trigger

-- 1. Trigger: Tự động cập nhật trạng thái ghế thành 'Đã đặt' khi thêm vé mới
CREATE TRIGGER tr_AfterInsertTicket
ON Tickets
AFTER INSERT
AS
BEGIN
    UPDATE Seats
    SET Status = 'Đã đặt'
    WHERE SeatID IN (SELECT SeatID FROM inserted);
    PRINT 'Trigger tr_AfterInsertTicket đã cập nhật trạng thái ghế thành Đã đặt!';
END;

INSERT INTO Tickets (Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, TicketType, TicketSaleDate, PromotionID)
VALUES (120000.00, 1, 1, 2, 1, 1, 1, N'Thường', '2025-03-14', NULL);
-- Kiểm tra: SELECT * FROM Seats WHERE SeatID = 2; (Trạng thái sẽ là 'Đã đặt')

-- 2. Trigger: Ngăn chặn xóa khách hàng nếu đã mua vé
CREATE TRIGGER tr_PreventDeleteCustomer
ON Customers
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted d JOIN Tickets t ON d.CustomerID = t.CustomerID)
    BEGIN
        RAISERROR ('Không thể xóa khách hàng đã mua vé!', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM Customers WHERE CustomerID IN (SELECT CustomerID FROM deleted);
        PRINT 'Xóa khách hàng thành công!';
    END
END;

DELETE FROM Customers WHERE CustomerID = 1;
-- Kiểm tra: Vì CustomerID = 1 đã có vé (từ dữ liệu mẫu), sẽ ra lỗi; thử với CustomerID mới (nếu có): DELETE FROM Customers WHERE CustomerID = 501;

-- 4. Trigger: Ghi log khi cập nhật giá vé
CREATE TRIGGER tr_LogTicketUpdate
ON Tickets
AFTER UPDATE
AS
BEGIN
    INSERT INTO TicketUpdateLog (TicketID, OldPrice, NewPrice, UpdateDate)
    SELECT i.TicketID, d.Price, i.Price, GETDATE()
    FROM inserted i
    JOIN deleted d ON i.TicketID = d.TicketID
    WHERE i.Price != d.Price;
    PRINT 'Trigger tr_LogTicketUpdate đã ghi log cập nhật giá vé!';
END;
GO

CREATE TABLE TicketUpdateLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TicketID INT,
    OldPrice DECIMAL(10, 2),
    NewPrice DECIMAL(10, 2),
    UpdateDate DATETIME
);
GO

UPDATE Tickets SET Price = 130000.00 WHERE TicketID = 2;
-- Kiểm tra: SELECT * FROM TicketUpdateLog WHERE TicketID = 2; (Sẽ có bản ghi với OldPrice và NewPrice)

-- 5. Trigger: Ngăn chặn đặt vé nếu suất chiếu đã đầy 
CREATE TRIGGER tr_PreventOverCapacity
ON Tickets
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN ShowTime s ON i.ShowTimeID = s.ShowTimeID
        JOIN ScreenRoom sr ON i.RoomID = sr.ScreenRoomID
        JOIN (SELECT ShowTimeID, COUNT(*) as SeatCount FROM Tickets GROUP BY ShowTimeID) t
            ON i.ShowTimeID = t.ShowTimeID
        WHERE t.SeatCount >= sr.TotalSeat
    )
    BEGIN
        RAISERROR ('Suất chiếu đã đầy, không thể đặt thêm vé!', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        INSERT INTO Tickets (Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, TicketType, TicketSaleDate, PromotionID)
        SELECT Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, TicketType, TicketSaleDate, PromotionID
        FROM inserted;
        PRINT 'Trigger tr_PreventOverCapacity đã cho phép đặt vé!';
    END
END;

INSERT INTO Tickets (Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, TicketType, TicketSaleDate, PromotionID)
VALUES (120000.00, 1, 2, 3, 1, 1, 1, N'Thường', '2025-03-14', NULL);
-- Kiểm tra: Nếu phòng đã đầy (TotalSeat = số vé), sẽ ra lỗi; nếu chưa đầy, vé sẽ được thêm: SELECT * FROM Tickets WHERE ShowTimeID = 1;

-- 6. Trigger: Tự động cập nhật hóa đơn khi giá vé thay đổi
CREATE TRIGGER tr_UpdateInvoiceOnTicketPriceChange
ON Tickets
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Price)
    BEGIN
        UPDATE i
        SET i.Amount = t.Price
        FROM Invoices i
        JOIN inserted t ON i.TicketID = t.TicketID;
        PRINT 'Trigger tr_UpdateInvoiceOnTicketPriceChange đã cập nhật hóa đơn!';
    END
END;

UPDATE Tickets SET Price = 140000.00 WHERE TicketID = 3;
-- Kiểm tra: SELECT * FROM Invoices WHERE TicketID = 3; (Amount sẽ được cập nhật thành 140000)

-- 7. Trigger: Ngăn chặn đặt vé trùng ghế trong cùng suất chiếu
CREATE TRIGGER tr_CheckCapacityAndDuplicateSeat
ON Tickets
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN ShowTime s ON i.ShowTimeID = s.ShowTimeID
        JOIN ScreenRoom sr ON i.RoomID = sr.ScreenRoomID
        JOIN (SELECT ShowTimeID, COUNT(*) as SeatCount FROM Tickets GROUP BY ShowTimeID) t
            ON i.ShowTimeID = t.ShowTimeID
        WHERE t.SeatCount >= sr.TotalSeat
    )
    BEGIN
        RAISERROR ('Suất chiếu đã đầy, không thể đặt thêm vé!', 16, 1);
        ROLLBACK;
        RETURN;
    END
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Tickets t ON i.SeatID = t.SeatID AND i.ShowTimeID = t.ShowTimeID AND i.RoomID = t.RoomID
    )
    BEGIN
        RAISERROR ('Ghế đã được đặt trong suất chiếu này!', 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO Tickets (Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, TicketType, TicketSaleDate, PromotionID)
    SELECT Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, TicketType, TicketSaleDate, PromotionID
    FROM inserted;
    PRINT 'Trigger tr_CheckCapacityAndDuplicateSeat đã cho phép đặt vé!';
END;

DROP TRIGGER IF EXISTS tr_CheckCapacityAndDuplicateSeat;
INSERT INTO Tickets (Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, TicketType, TicketSaleDate, PromotionID)
VALUES (120000.00, 1, 2, 2, 1, 1, 1, N'Thường', '2025-03-14', NULL);
-- Kiểm tra: Nếu ghế 2 đã được dùng, sẽ ra lỗi; nếu chưa, vé sẽ được thêm: SELECT * FROM Tickets WHERE SeatID = 2;

-- 8. Trigger: Tự động gửi thông báo khi thêm khuyến mãi mới (nâng cao)
CREATE TRIGGER tr_NotifyNewPromotion
ON Promotions
AFTER INSERT
AS
BEGIN
    DECLARE @PromotionCode NVARCHAR(20), @Discount DECIMAL(5, 2);
    SELECT @PromotionCode = PromotionCode, @Discount = DiscountPercentage FROM inserted;
    PRINT 'Khuyến mãi mới: Mã ' + @PromotionCode + ' với giảm giá ' + CAST(@Discount AS NVARCHAR(5)) + '% đã được thêm!';
END;

INSERT INTO Promotions (PromotionCode, DiscountPercentage, StartDate, EndDate, ApplicableTicketType)
VALUES (N'KMNEW2025', 15.00, '2025-03-15', '2025-04-15', N'Thường');
-- Kiểm tra: Quan sát thông báo in ra (PromotionCode và DiscountPercentage)

-- 9. Trigger: Tự động cập nhật lương nhân viên khi bán vé thành công
CREATE TRIGGER tr_UpdateEmployeeSalary
ON Tickets
AFTER INSERT
AS
BEGIN
    UPDATE Employees
    SET Salary = Salary + 5000 -- Tăng 5000 cho mỗi vé bán
    WHERE EmployeeID IN (SELECT EmployeeID FROM inserted);
    PRINT 'Trigger tr_UpdateEmployeeSalary đã cập nhật lương nhân viên!';
END;

INSERT INTO Tickets (Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, TicketType, TicketSaleDate, PromotionID)
VALUES (120000.00, 1, 3, 4, 1, 1, 1, N'Thường', '2025-03-14', NULL);
-- Kiểm tra: SELECT * FROM Employees WHERE EmployeeID = 1; (Salary sẽ tăng thêm 5000)

-- 10. Trigger: Ngăn chặn cập nhật sai ngày bán vé (nâng cao)
CREATE TRIGGER tr_PreventInvalidTicketSaleDate
ON Tickets
INSTEAD OF UPDATE
AS
BEGIN
    IF UPDATE(TicketSaleDate)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM inserted i
            WHERE i.TicketSaleDate > GETDATE()
        )
        BEGIN
            RAISERROR ('Ngày bán vé không thể là tương lai!', 16, 1);
            ROLLBACK;
        END
        ELSE
        BEGIN
            UPDATE Tickets
            SET TicketSaleDate = i.TicketSaleDate
            FROM Tickets t
            JOIN inserted i ON t.TicketID = i.TicketID;
            PRINT 'Trigger tr_PreventInvalidTicketSaleDate đã cập nhật ngày bán vé!';
        END
    END
END;

UPDATE Tickets SET TicketSaleDate = '2025-04-01' WHERE TicketID = 3;
-- Kiểm tra: Sẽ ra lỗi vì ngày 01/04/2025 > 13/03/2025; thử với ngày hợp lệ: UPDATE Tickets SET TicketSaleDate = '2025-03-12' WHERE TicketID = 3;

-- 11. Trigger: Tự động tạo hóa đơn khi thêm vé (nâng cao)
CREATE TRIGGER tr_AutoCreateInvoice
ON Tickets
AFTER INSERT
AS
BEGIN
    INSERT INTO Invoices (TicketID, CustomerID, Amount, PaymentMethod, InvoiceDate)
    SELECT i.TicketID, i.CustomerID, i.Price, N'Tiền mặt', GETDATE()
    FROM inserted i;
    PRINT 'Trigger tr_AutoCreateInvoice đã tạo hóa đơn tự động!';
END;

INSERT INTO Tickets (Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, TicketType, TicketSaleDate, PromotionID)
VALUES (130000.00, 2, 3, 5, 2, 2, 2, N'VIP', '2025-03-14', NULL);
-- Kiểm tra: SELECT * FROM Invoices WHERE TicketID = (SELECT MAX(TicketID) FROM Tickets); (Sẽ có hóa đơn mới)

-- 12. Trigger: Cảnh báo khi tỷ lệ sử dụng suất chiếu vượt 80% (nâng cao)
CREATE TRIGGER tr_WarnHighCapacityUtilization
ON ShowTime
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE i.CapacityUtilization > 80.0
    )
    BEGIN
        PRINT 'CẢNH BÁO: Tỷ lệ sử dụng suất chiếu vượt 80%!';
    END
END;
GO

UPDATE ShowTime SET CapacityUtilization = 85.00 WHERE ShowTimeID = 1;
-- Kiểm tra: Quan sát thông báo in ra (CẢNH BÁO: Tỷ lệ sử dụng suất chiếu vượt 80%!)

--Phân quyền và bảo vệ
USE master;
GO

-- 1. Tạo Login cho các tài khoản
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ManagerLogin')
    CREATE LOGIN ManagerLogin WITH PASSWORD = 'Manager@123455', DEFAULT_DATABASE = QLHTBVXP, CHECK_POLICY = ON;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'EmployeeLogin')
    CREATE LOGIN EmployeeLogin WITH PASSWORD = 'Employee@123455', DEFAULT_DATABASE = QLHTBVXP, CHECK_POLICY = ON;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CustomerLogin')
    CREATE LOGIN CustomerLogin WITH PASSWORD = 'Customer@123455', DEFAULT_DATABASE = QLHTBVXP, CHECK_POLICY = ON;

-- 2. Tạo User và ánh xạ với Login
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ManagerUser')
    CREATE USER ManagerUser FOR LOGIN ManagerLogin;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'EmployeeUser')
    CREATE USER EmployeeUser FOR LOGIN EmployeeLogin;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CustomerUser')
    CREATE USER CustomerUser FOR LOGIN CustomerLogin;

-- 3. Tạo Role (Vai trò)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ManagerRole')
    CREATE ROLE ManagerRole;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'EmployeeRole')
    CREATE ROLE EmployeeRole;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CustomerRole')
    CREATE ROLE CustomerRole;

-- 4. Gán User vào Role
ALTER ROLE ManagerRole ADD MEMBER ManagerUser;
ALTER ROLE EmployeeRole ADD MEMBER EmployeeUser;
ALTER ROLE CustomerRole ADD MEMBER CustomerUser;

-- 5. Tạo bảng log để bảo vệ (ghi lại hành động)
CREATE TABLE AuditLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(128),
    ActionType NVARCHAR(50),
    TableName NVARCHAR(128),
    RecordID INT,
    ActionDate DATETIME DEFAULT GETDATE()
);

-- 6. Tạo trigger để ghi log khi chèn vé
CREATE TRIGGER tr_LogTicketInsert
ON Tickets
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLog (UserName, ActionType, TableName, RecordID)
    SELECT SUSER_SNAME(), 'INSERT', 'Tickets', i.TicketID
    FROM inserted i;
END;

-- 7. Phân quyền cho từng vai trò

-- 7.1 Quyền cho Tài khoản Quản lý (ManagerRole)
ALTER ROLE db_owner ADD MEMBER ManagerUser;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::dbo TO ManagerRole;
GRANT CONTROL ON DATABASE::QLHTBVXP TO ManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON AuditLog TO ManagerRole;
GO

-- 7.2 Quyền cho Tài khoản Nhân viên (EmployeeRole)
GRANT SELECT, INSERT, UPDATE ON Tickets TO EmployeeRole;
GRANT SELECT, UPDATE ON Seats TO EmployeeRole;
GRANT SELECT, INSERT ON Invoices TO EmployeeRole;
GRANT EXECUTE ON sp_UpdateSeatStatus TO EmployeeRole;
GRANT EXECUTE ON sp_CreateInvoice TO EmployeeRole;
DENY SELECT ON Employees TO EmployeeRole;
DENY SELECT ON Promotions TO EmployeeRole;

-- 7.3 Quyền cho Tài khoản Khách hàng (CustomerRole)
GRANT SELECT ON Tickets TO CustomerRole;
GRANT SELECT ON ShowTime TO CustomerRole;
GRANT EXECUTE ON sp_GetShowTimesByMovieAndDate TO CustomerRole;
DENY INSERT, UPDATE, DELETE ON Tickets TO CustomerRole;
DENY INSERT, UPDATE, DELETE ON ShowTime TO CustomerRole;

-- Tạo view với tham số CustomerID (cần stored procedure để truyền CustomerID)
CREATE OR ALTER PROCEDURE sp_GetCustomerTickets
    @CustomerID INT
AS
BEGIN
    SELECT t.*
    FROM Tickets t
    WHERE t.CustomerID = @CustomerID;
END;

GRANT EXECUTE ON sp_GetCustomerTickets TO CustomerRole;


-- 8. Test phân quyền

-- 8.1 Test quyền của Tài khoản Quản lý (ManagerLogin/ManagerUser)
SELECT * FROM Tickets; -- Thành công
UPDATE Tickets SET Price = 150000 WHERE TicketID = 1; -- Thành công
EXEC sp_UpdateSeatStatus @SeatID = 1, @Status = 'Đã bán'; -- Thành công
DROP TABLE Tickets; -- Thành công
SELECT * FROM AuditLog; -- Thành công (xem log)

-- 8.2 Test quyền của Tài khoản Nhân viên (EmployeeLogin/EmployeeUser)

SELECT * FROM Tickets; -- Thành công
UPDATE Seats SET Status = 'Đã đặt' WHERE SeatID = 1; -- Thành công
EXEC sp_UpdateSeatStatus @SeatID = 1, @Status = 'Đã đặt'; -- Thành công
SELECT * FROM Employees; -- Bị từ chối
INSERT INTO Promotions VALUES ('NEWPROMO', 10, '2025-03-01', '2025-03-31', 'Thường'); -- Bị từ chối
INSERT INTO Tickets VALUES (120000, 1, 1, 1, 1, 1, 1, 'Thường', '2025-03-14', NULL); -- Thành công
SELECT * FROM AuditLog; -- Bị từ chối (chỉ Quản lý xem log)

-- 8.3 Test quyền của Tài khoản Khách hàng (CustomerLogin/CustomerUser)
EXEC sp_GetCustomerTickets @CustomerID = 1; -- Thành công (chỉ thấy vé của CustomerID = 1)
EXEC sp_GetShowTimesByMovieAndDate @MovieID = 1, @ShowDate = '2025-03-14'; -- Thành công
UPDATE Tickets SET Price = 150000 WHERE TicketID = 1; -- Bị từ chối
DELETE FROM Tickets WHERE TicketID = 1; -- Bị từ chối
SELECT * FROM Employees; -- Bị từ chối
GO