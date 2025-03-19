import pyodbc
import random
from datetime import datetime, timedelta
import re

def remove_accents(input_str):
    accents_map = str.maketrans(
        "àáảãạâầấẩẫậăằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ",
        "aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd"
    )
    return input_str.translate(accents_map).lower()

try:
    conn = pyodbc.connect(
        'DRIVER={ODBC Driver 17 for SQL Server};'
        'SERVER=TYANZUQ-2811\\SQLEXPRESS;'
        'DATABASE=QLHTBVXP;'
        'UID=sa;'
        'PWD=123456',
        autocommit=True
    )
    print("Kết nối thành công!")
except pyodbc.Error as e:
    print("Lỗi kết nối:", e)
    exit()

cur = conn.cursor()

ten_phim = [
    "Avengers: Endgame", "Titanic", "The Dark Knight", "Inception", "The Lion King",
    "Spider-Man: No Way Home", "Jurassic Park", "The Godfather", "Star Wars: Episode IV",
    "Frozen", "Parasite", "Interstellar", "The Matrix", "Forrest Gump", "Harry Potter",
    "Avatar", "Black Panther", "Joker", "Pulp Fiction", "The Shawshank Redemption",
    "Mad Max: Fury Road", "The Avengers", "Gladiator", "The Departed", "Toy Story",
    "The Empire Strikes Back", "Back to the Future", "The Silence of the Lambs", 
    "Finding Nemo", "The Incredibles", "Shrek", "Die Hard", "Terminator 2", 
    "Lord of the Rings", "The Hobbit", "Pirates of the Caribbean", "Deadpool", 
    "Wonder Woman", "Skyfall", "The Wolf of Wall Street", "La La Land", "Coco",
    "Inside Out", "Up", "WALL-E", "The Grand Budapest Hotel", "Memento", 
    "Fight Club", "Se7en", "No Country for Old Men"
]

the_loai_phim = [
    "Hành động", "Kinh dị", "Tình cảm", "Hài", "Khoa học viễn tưởng",
    "Phiêu lưu", "Hoạt hình", "Tội phạm", "Drama", "Giả tưởng",
    "Chiến tranh", "Lịch sử", "Thể thao", "Âm nhạc", "Bí ẩn"
]

ten_phong_chieu = [
    "Phòng 1", "Phòng 2", "Phòng 3", "Phòng 4", "Phòng 5", "Phòng 6", "Phòng 7",
    "Phòng VIP 1", "Phòng VIP 2", "Phòng VIP 3", "Phòng 3D 1", "Phòng 3D 2",
    "Phòng 4DX 1", "Phòng 4DX 2", "Phòng IMAX"
]

ho = ["Nguyễn", "Trần", "Lê", "Phạm", "Vũ", "Đặng", "Hoàng", "Hồ", "Ngô", "Dương"]
ten_dem = ["Quốc", "Anh", "Thế", "Đức", "Minh", "Văn", "Huy", "Khánh", "Trường", "Bảo"]
ten = ["Hải", "Tùng", "Thành", "Long", "Minh", "Quang", "Duy", "Khôi", "Hưng", "Vũ"]

ma_khuyen_mai = ["KM10", "KM20", "KM30", "KM50", "KMTET", "KMVIP", "KMWEEKEND", 
                 "KMNEW", "KMFRI", "KMSUN", "KMSTUDENT", "KMGROUP"]
loai_ve = ["Thường", "VIP", "Couple", "Student", "3D", "4DX"]

def random_name():
    return random.choice(ho) + " " + random.choice(ten_dem) + " " + random.choice(ten)

def generate_email(name):
    name_no_accents = remove_accents(name)
    email_base = re.sub(r'\s+', '', name_no_accents)
    email = f"{email_base}{random.randint(1, 999)}@gmail.com"
    return email

def random_date(start_date, end_date):
    delta = end_date - start_date
    random_days = random.randint(0, delta.days)
    return start_date + timedelta(days=random_days)

def random_time():
    hour = random.randint(8, 22)
    minute = random.choice([0, 15, 30, 45])
    return f"{hour:02}:{minute:02}:00"

def create_tables():
    cur.execute("""
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MovieGenre')
        CREATE TABLE MovieGenre (
            MovieGenreID INT IDENTITY(1,1) PRIMARY KEY,
            NameGenre NVARCHAR(50)
        );
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Movie')
        CREATE TABLE Movie (
            MovieID INT IDENTITY(1,1) PRIMARY KEY,
            NameMovie NVARCHAR(100),
            Director NVARCHAR(100),
            MovieGenreID INT,
            FOREIGN KEY (MovieGenreID) REFERENCES MovieGenre(MovieGenreID)
        );
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ScreenRoom')
        CREATE TABLE ScreenRoom (
            ScreenRoomID INT IDENTITY(1,1) PRIMARY KEY,
            NameRoom NVARCHAR(50),
            TotalSeat INT
        );
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Seats')
        CREATE TABLE Seats (
        SeatID INT IDENTITY(1,1) PRIMARY KEY,
        ScreenRoomID INT,
        SeatNumber NVARCHAR(10),
        Status NVARCHAR(10) DEFAULT N'Trống', 
        FOREIGN KEY (ScreenRoomID) REFERENCES ScreenRoom(ScreenRoomID),
        CONSTRAINT CHK_SeatStatus CHECK (Status IN (N'Trống', N'Đã đặt', N'Đã bán'))
        );
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ShowTime')
        CREATE TABLE ShowTime (
            ShowTimeID INT IDENTITY(1,1) PRIMARY KEY,
            BeginTime DATETIME,
            EndTime DATETIME,
            CapacityUtilization DECIMAL(5, 2)
        );
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Promotions')
        CREATE TABLE Promotions (
            PromotionID INT IDENTITY(1,1) PRIMARY KEY,
            PromotionCode NVARCHAR(20),
            DiscountPercentage DECIMAL(5, 2),
            StartDate DATE,
            EndDate DATE,
            ApplicableTicketType NVARCHAR(50)
        );
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employees')
        CREATE TABLE Employees (
            EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
            FullName NVARCHAR(100),
            Address NVARCHAR(255),
            DateOfBirth DATE,
            PhoneNumber NVARCHAR(20),
            Salary DECIMAL(10, 2)
        );
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customers')
        CREATE TABLE Customers (
            CustomerID INT IDENTITY(1,1) PRIMARY KEY,
            FullName NVARCHAR(100),
            Address NVARCHAR(255),
            DateOfBirth DATE,
            PhoneNumber NVARCHAR(20),
            Email NVARCHAR(100)
        );
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Tickets')
        CREATE TABLE Tickets (
            TicketID INT IDENTITY(1,1) PRIMARY KEY,
            Price DECIMAL(10, 2),
            EmployeeID INT ,
            CustomerID INT ,
            SeatID INT ,
            MovieID INT ,
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
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Counter')
        CREATE TABLE Counter (
            CounterID INT IDENTITY(1,1) PRIMARY KEY,
            TicketID INT,
            EmployeeID INT,
            NameCounter NVARCHAR(50),
            FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
            FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID)
        );
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Invoices')
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
    """)
    conn.commit()

# Chèn dữ liệu vào bảng MovieGenre
def insert_movie_genre():
    for genre in the_loai_phim:
        sql = f'''
            INSERT INTO MovieGenre (NameGenre)
            VALUES (N'{genre}')
        '''
        cur.execute(sql)
    conn.commit()

# Chèn dữ liệu vào bảng Movie
def insert_movie():
    for i, movie in enumerate(ten_phim):
        genre_id = random.randint(1, len(the_loai_phim))
        director = random_name()
        sql = f'''
            INSERT INTO Movie (NameMovie, Director, MovieGenreID)
            VALUES (N'{movie}', N'{director}', {genre_id})
        '''
        cur.execute(sql)
    conn.commit()

# Chèn dữ liệu vào bảng ScreenRoom
def insert_screen_room():
    for i, room in enumerate(ten_phong_chieu):
        total_seat = random.randint(50, 150)
        sql = f'''
            INSERT INTO ScreenRoom (NameRoom, TotalSeat)
            VALUES (N'{room}', {total_seat})
        '''
        cur.execute(sql)
    conn.commit()

# Chèn dữ liệu vào bảng Seats
def insert_seats():
    cur.execute("SELECT ScreenRoomID, TotalSeat FROM ScreenRoom")
    rooms = cur.fetchall()
    seat_id = 1
    for room in rooms:
        room_id, total_seat = room
        for seat_num in range(1, total_seat + 1):
            seat_number = f"{chr(65 + (seat_num - 1) // 10)}{(seat_num - 1) % 10 + 1}"
            sql = f'''
                INSERT INTO Seats (ScreenRoomID, SeatNumber, Status)
                VALUES ({room_id}, N'{seat_number}', 'Trống')
            '''
            cur.execute(sql)
            seat_id += 1
    conn.commit()

# Chèn dữ liệu vào bảng ShowTime
def insert_show_time():
    start_date = datetime(2025, 3, 1)
    end_date = datetime(2025, 12, 31)
    for i in range(150):
        show_date = random_date(start_date, end_date)
        begin_time = random_time()
        end_time = (datetime.strptime(begin_time, "%H:%M:%S") + timedelta(hours=2)).strftime("%H:%M:%S")
        capacity = 0
        sql = f'''
            INSERT INTO ShowTime (BeginTime, EndTime, CapacityUtilization)
            VALUES ('{show_date.strftime('%Y-%m-%d')} {begin_time}', 
                    '{show_date.strftime('%Y-%m-%d')} {end_time}', {capacity})
        '''
        cur.execute(sql)
    conn.commit()

# Chèn dữ liệu vào bảng Promotions
def insert_promotions():
    start_date = datetime(2025, 1, 1)
    end_date = datetime(2025, 12, 31)
    for i, code in enumerate(ma_khuyen_mai):
        discount = random.randint(10, 50)
        promo_start = random_date(start_date, end_date)
        promo_end = promo_start + timedelta(days=random.randint(7, 30))
        ticket_type = random.choice(loai_ve)
        sql = f'''
            INSERT INTO Promotions (PromotionCode, DiscountPercentage, StartDate, EndDate, ApplicableTicketType)
            VALUES (N'{code}', {discount}, '{promo_start.strftime('%Y-%m-%d')}', 
                    '{promo_end.strftime('%Y-%m-%d')}', N'{ticket_type}')
        '''
        cur.execute(sql)
    conn.commit()

# Chèn dữ liệu vào bảng Employees
def insert_employees():
    for i in range(50):
        name = random_name()
        address = f"Số {random.randint(1, 100)} Đường {random.choice(ten)}"
        dob = random_date(datetime(1980, 1, 1), datetime(2000, 12, 31)).strftime("%Y-%m-%d")
        phone = f"09{random.randint(10000000, 99999999)}"
        salary = random.randint(5000000, 20000000)
        sql = f'''
            INSERT INTO Employees (FullName, Address, DateOfBirth, PhoneNumber, Salary)
            VALUES (N'{name}', N'{address}', '{dob}', N'{phone}', {salary})
        '''
        cur.execute(sql)
    conn.commit()

def insert_customers():
    for i in range(500):
        name = random_name()
        address = f"Số {random.randint(1, 100)} Đường {random.choice(ten)}"
        dob = random_date(datetime(1980, 1, 1), datetime(2005, 12, 31)).strftime("%Y-%m-%d")
        phone = f"09{random.randint(10000000, 99999999)}"
        email = generate_email(name)
        sql = f'''
            INSERT INTO Customers (FullName, Address, DateOfBirth, PhoneNumber, Email)
            VALUES (N'{name}', N'{address}', '{dob}', N'{phone}', N'{email}')
        '''
        cur.execute(sql)
    conn.commit()

# Chèn dữ liệu vào bảng Tickets và Invoices
def insert_tickets_and_invoices():
    cur.execute("SELECT SeatID, ScreenRoomID FROM Seats WHERE Status = 'Trống'")
    seats = cur.fetchall()
    cur.execute("SELECT ShowTimeID FROM ShowTime")
    showtimes = cur.fetchall()
    cur.execute("SELECT MovieID FROM Movie")
    movies = cur.fetchall()
    cur.execute("SELECT CustomerID FROM Customers")
    customers = cur.fetchall()
    cur.execute("SELECT EmployeeID FROM Employees")
    employees = cur.fetchall()
    cur.execute("SELECT PromotionID FROM Promotions")
    promotions = cur.fetchall()

    customer_tickets = {cust[0]: 0 for cust in customers} 
    max_tickets_per_customer = 5

    for i in range(1000):
        if not seats or all(customer_tickets[cust_id] >= max_tickets_per_customer for cust_id in customer_tickets):
            break
        seat = random.choice(seats)
        seats.remove(seat)
        showtime = random.choice(showtimes)
        movie = random.choice(movies)
        customer = random.choice([c for c in customers if customer_tickets[c[0]] < max_tickets_per_customer])
        customer_tickets[customer[0]] += 1
        employee = random.choice(employees)
        promotion = random.choice(promotions) if random.random() > 0.5 else None
        ticket_type = random.choice(loai_ve)
        price = random.randint(50000, 200000)
        if promotion:
            cur.execute(f"SELECT DiscountPercentage FROM Promotions WHERE PromotionID = {promotion[0]}")
            discount = cur.fetchone()[0]
            price = price * (1 - discount / 100)
        sale_date = random_date(datetime(2025, 3, 1), datetime(2025, 12, 31)).strftime("%Y-%m-%d")

        sql_ticket = f'''
            INSERT INTO Tickets (Price, EmployeeID, CustomerID, SeatID, MovieID, RoomID, ShowTimeID, 
                                TicketType, TicketSaleDate, PromotionID)
            VALUES ({price}, {employee[0]}, {customer[0]}, {seat[0]}, {movie[0]}, {seat[1]}, 
                    {showtime[0]}, N'{ticket_type}', '{sale_date}', {promotion[0] if promotion else 'NULL'})
        '''
        cur.execute(sql_ticket)

        cur.execute(f"UPDATE Seats SET Status = 'Đã bán' WHERE SeatID = {seat[0]}")
        cur.execute(f"SELECT COUNT(*) FROM Tickets WHERE ShowTimeID = {showtime[0]}")
        ticket_count = cur.fetchone()[0]
        cur.execute(f"SELECT TotalSeat FROM ScreenRoom WHERE ScreenRoomID = {seat[1]}")
        total_seat = cur.fetchone()[0]
        capacity = (ticket_count / total_seat) * 100 if total_seat > 0 else 0
        cur.execute(f"UPDATE ShowTime SET CapacityUtilization = {capacity} WHERE ShowTimeID = {showtime[0]}")
        payment_method = random.choice(['Tiền mặt', 'Thẻ', 'Ví điện tử'])
        sql_invoice = f'''
            INSERT INTO Invoices (TicketID, CustomerID, Amount, PaymentMethod, InvoiceDate)
            VALUES ({i + 1}, {customer[0]}, {price}, N'{payment_method}', '{sale_date}')
        '''
        cur.execute(sql_invoice)

        if random.random() > 0.5:
            sql_counter = f'''
                INSERT INTO Counter (TicketID, EmployeeID, NameCounter)
                VALUES ({i + 1}, {employee[0]}, N'Quầy {random.randint(1, 5)}')
            '''
            cur.execute(sql_counter)
    conn.commit()

# Hàm chính
def main():
    create_tables()
    insert_movie_genre()      # 15 bản ghi
    insert_movie()            # 50 bản ghi
    insert_screen_room()      # 15 bản ghi
    insert_seats()            # ~1000-2000 bản ghi
    insert_show_time()        # 150 bản ghi
    insert_promotions()       # 12 bản ghi
    insert_employees()        # 50 bản ghi
    insert_customers()        # 500 bản ghi
    insert_tickets_and_invoices()  # 1000 bản ghi

    cur.close()
    conn.close()

if __name__ == "__main__":
    main()

