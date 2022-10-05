USE master
GO

CREATE DATABASE ShoesManagement
GO

USE ShoesManagement
GO

--Phân tích table
Create Table tblSupplier
(
	SupId INT IDENTITY(1,1) PRIMARY KEY,
	SupName nvarchar (100) NOT NULL,
	SupAddress nvarchar (500)NOT NULL,
	PhoneNumber NVARCHAR (50) NOT NULL,
	Email nvarchar (100) NOT NULL,
	Status int NOT NULL
)
Go

Create Table tblAccount
(
	UsId INT IDENTITY(1,1) PRIMARY KEY,
	UserName nvarchar (100),
	Password nvarchar (max) not null,
	TypeAccount int not null,--1 admin // 0 staff
	DisplayName nvarchar(100),
	Email nvarchar(100),
	Status int NOT NULL
)
Go

Create Table tblImportCoupon
(
	ImcId INT IDENTITY(1,1) PRIMARY KEY,
	CheckDateImport Date,
	SupId int NOT NULL,
	UsId int NOT NULL,
	TypeImc int NOT NULL,
	Status int NOT NULL,

	Foreign Key (SupId) References dbo.tblSupplier(SupId),
	Foreign Key (UsId) References dbo.tblAccount(UsId)
)
Go

CREATE TABLE tblCategory
(
	CateId INT IDENTITY(1,1) PRIMARY KEY,
	NameCate nvarchar(200),
	Status int NOT NULL
)
GO

CREATE TABLE tblProduct
(
	ProdId INT IDENTITY(1,1) PRIMARY KEY,
	NameSP NVARCHAR(100) NOT NULL,
	Price FLOAT NOT NULL,
	Image IMAGE NOT NULL,
	CateId INT NOT NULL,
	SupId INT NOT NULL,
	Quantity int null,
	Status int NOT NULL,

	Foreign Key (CateId) References dbo.tblCategory(CateId),
	Foreign Key (SupId) References dbo.tblSupplier(SupId)
)
GO

Create Table tblImportCouponInfo
(
	ImcIdInFo INT IDENTITY(1,1) PRIMARY KEY,
	ImcId INT NOT NULL,
	Quantity INT NOT NULL,
	ProdId INT NOT NULL,
	Status int NOT NULL,

	Foreign Key (ProdId) References dbo.tblProduct(ProdId),
	Foreign Key (ImcId) References dbo.tblImportCoupon(ImcId)
)
Go

Create Table tblCustomer
(
	CusId INT IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	Address NVARCHAR(50) NOT NULL,
	PhoneNumber NVARCHAR(50) NOT NULL,
	Status int NOT NULL
)
GO

CREATE TABLE tblBill
(
	BillId INT IDENTITY(1,1) PRIMARY KEY,
	UsId INT NOT NULL,
	CusId INT NOT NULL,
	DateOfPayment DATETIME DEFAULT SYSDATETIME(),
	TotalPrice FLOAT NOT NULL,
	Status int NOT NULL,

	FOREIGN KEY (UsId) REFERENCES dbo.tblAccount(UsId),
	FOREIGN KEY (CusId) REFERENCES dbo.tblCustomer(CusId)
)
GO

CREATE TABLE tblBillInfo
(
	BillifId INT IDENTITY(1,1) PRIMARY KEY,
	BillId INT NOT NULL,
	ProdId INT NOT NULL,
	Quantity INT NOT NULL,
	Price FLOAT NOT NULL,
	Status int NOT NULL,

	FOREIGN KEY (ProdId) REFERENCES dbo.tblProduct(ProdId),
	FOREIGN KEY (BillId) REFERENCES dbo.tblBill(BillId)
)
GO
--End Phân tích table


----- Insert default Data -----
--Insert default accounts
--1 ở đầu là phân quyền (1 admin/0 staff), 1 ở sau là hoạt động hay không (1 là có/0 là không)
INSERT INTO dbo.tblAccount VALUES
(N'admin', N'admin',1, N'Trần Thông',N'quangthong211101@gmail.com',1),
(N'nv123', N'123',0, N'Thông NV',N'thongzuka2000@gmail.com',1)
GO

--Insert default Category
INSERT INTO dbo.tblCategory VALUES
(N'Giày Nike',1),
(N'Dép Vento',1)
GO

--Insert default Supplier
INSERT INTO dbo.tblSupplier VALUES
(N'Giày VIT', N'Hà Nội' , N'0966621342',N'xuonggiayvit@gmail.com',1),
(N'Giày Huy Hoàng', N'Hồ Chí Minh' , N'0903697273',N'lhuytien@yahoo.com',1),
(N'Giày Dép Hatilo', N'Hồ Chí Minh' , N'0966865121',N'giaydepsaoviet@gmail.com',1)
GO

--Insert default accounts
INSERT INTO dbo.tblCustomer VALUES
(N'Trần Thông', N'Đà Nẵng' , N'0147852369',1),
(N'Nguyễn Huy Hoàng', N'Thanh Hóa' , N'0123456789',1),
(N'Bùi Xuân Vũ', N'Gia Lai' , N'0987654321',1)
GO
----- End Insert default Data -----



----- CREATE PROCEDDURE -----
--> Category--
Select * from tblCategory
Go

CREATE PROC USP_ListOfCategory
AS
BEGIN
	SELECT CateId, NameCate FROM tblCategory Where Status = 1
END
GO

CREATE PROC USP_DelCate
@idCate int
AS
Begin
	Update dbo.tblCategory Set Status = 0 Where CateId = @idCate
End
GO

CREATE PROC USP_SearchCate
@name NVARCHAR(200)
AS 
BEGIN
	SELECT CateId,NameCate FROM dbo.tblCategory WHERE NameCate LIKE '%' + @name + '%' and Status = 1
END
GO
--> End Category--



--> Product--
Select * from tblProduct
Go

CREATE PROC USP_ListOfProduct
AS
BEGIN
	SELECT ProdId,NameSP,Price,Image,CateId,SupId,Quantity FROM tblProduct Where Status = 1
END
GO

CREATE PROC USP_InsertProduct
@name NVARCHAR(100), @price FLOAT, @image IMAGE, @cateId int, @SupId int,@quantity int,@status int
AS 
BEGIN
	INSERT INTO dbo.tblProduct VALUES(@name, @price , @image, @cateId,@SupId,@quantity,@status)
END
GO

CREATE PROC USP_UpdateProduct
@name NVARCHAR(100), @price FLOAT, @image IMAGE, @cateId int, @SupId int,@idP int
AS 
BEGIN
	Update dbo.tblProduct set NameSP = @name , Price = @price , Image = @image , CateId = @cateId , SupId = @SupId Where ProdId = @idP
END
GO

CREATE PROC USP_DelProduct
@idP int
AS 
BEGIN
	Update dbo.tblProduct Set Status = 0 Where ProdId = @idP
END
GO

CREATE PROC USP_SearchProducts
@name NVARCHAR(200)
AS 
BEGIN
	SELECT ProdId,NameSP,Price,Image,CateId,SupId,Quantity FROM dbo.tblProduct WHERE NameSP LIKE '%' + @name + '%' and Status = 1
END
GO

CREATE PROC USP_GetIdSP
@name NVARCHAR(200)
AS 
BEGIN
	SELECT * FROM dbo.tblProduct WHERE NameSP LIKE N''+@name+''
END
GO
--> End Product--



--> Account--
Select * from dbo.tblAccount
Go

CREATE PROC USP_AccountLogin
@usname nvarchar(100),@Pass nvarchar(100)
AS 
BEGIN
	Select * from dbo.tblAccount Where UserName=@usname And Password = @Pass
END
GO

CREATE PROC USP_GetListUser
AS 
BEGIN
	Select UsId,UserName,Password,TypeAccount,DisplayName,Email from dbo.tblAccount Where Status = 1
END
GO

Create PROC USP_InsertUser
@name NVARCHAR(100), @pass NVARCHAR(100), @Type int, @displayN NVARCHAR(100),@email NVARCHAR(100),@status int
AS 
BEGIN
	INSERT INTO dbo.tblAccount VALUES(@name, @pass , @Type, @displayN, @email, @status)
END
GO

Create PROC USP_UpdateUser
@name NVARCHAR(100), @pass NVARCHAR(100), @Type int, @displayN NVARCHAR(100),@email NVARCHAR(100),@idU int
AS 
BEGIN
	Update dbo.tblAccount set UserName = @name, Password = @pass , TypeAccount = @Type , DisplayName = @displayN , Email = @email where UsId = @idU 
END
GO

Create PROC USP_DelUser
@idU int
AS 
BEGIN
	Update dbo.tblAccount Set Status = 0 Where UsId = @idU
END
GO

CREATE PROC USP_SearchAcc
@name NVARCHAR(200)
AS 
BEGIN
	SELECT UsId,UserName,Password,TypeAccount,DisplayName,Email FROM dbo.tblAccount WHERE Email LIKE '%' + @name + '%' and Status = 1
END
GO
--> End Account--



--> Supplier--
Select * from tblSupplier
Go

CREATE PROC USP_GetListSupplier
AS
BEGIN
	SELECT SupId,SupName,SupAddress,PhoneNumber,Email FROM tblSupplier Where Status = 1
END
GO

CREATE PROC USP_InsertSupplier
@name NVARCHAR(100), @diachi NVARCHAR(100),@sdt NVARCHAR(50),@email NVARCHAR(100),@status int
AS 
BEGIN
	INSERT INTO dbo.tblSupplier VALUES(@name, @diachi, @sdt, @email, @status)
END
GO

CREATE PROC USP_UpdateSupplier
@name NVARCHAR(100), @diachi NVARCHAR(100),@sdt NVARCHAR(50),@email NVARCHAR(100) ,@id int
AS 
BEGIN
	Update dbo.tblSupplier set SupName = @name , SupAddress = @diachi , PhoneNumber = @sdt ,	Email = @email Where SupId = @id
END
GO

CREATE PROC USP_DelSupplier
@id int
AS 
BEGIN
	Update dbo.tblSupplier Set Status = 0 Where SupId = @id
END
GO

CREATE PROC USP_SearcSupplier
@name NVARCHAR(200)
AS 
BEGIN
	SELECT SupId,SupName,SupAddress,PhoneNumber,Email FROM dbo.tblSupplier WHERE PhoneNumber LIKE '%' + @name + '%' and Status = 1
END
GO
--> End Supplier--



--> Customers--
Select * from tblCustomer
Go

CREATE PROC USP_GetListCus
AS
BEGIN
	SELECT CusId,Name,Address,PhoneNumber FROM tblCustomer Where Status = 1
END
GO

CREATE PROC USP_InsertCustomers
@name NVARCHAR(100), @diachi NVARCHAR(50),@sdt NVARCHAR(50),@status int
AS 
BEGIN
	INSERT INTO dbo.tblCustomer VALUES(@name, @diachi, @sdt, @status)
END
GO

CREATE PROC USP_UpdateCustomers
@name NVARCHAR(100), @diachi NVARCHAR(50),@sdt NVARCHAR(50),@idCus int
AS 
BEGIN
	Update dbo.tblCustomer set Name = @name , Address = @diachi , PhoneNumber = @sdt Where CusId = @idCus
END
GO

CREATE PROC USP_DelCustomers
@idCus int
AS 
BEGIN
	Update dbo.tblCustomer Set Status = 0 Where CusId = @idCus
END
GO

CREATE PROC USP_SearcCustomers
@name NVARCHAR(200)
AS 
BEGIN
	SELECT CusId,Name,Address,PhoneNumber FROM dbo.tblCustomer WHERE PhoneNumber LIKE '%' + @name + '%' and Status = 1
END
GO
--> End Customers--



--> tblImportCoupon--
Select * from tblImportCoupon
Go
--Trạng thái 0 là đã thanh toán 1 là chưa thanh toán
CREATE PROC USP_GetImportCoupon
AS
BEGIN
	SELECT ImcId,CheckDateImport,SupId,UsId,TypeImc FROM tblImportCoupon Where Status = 1
END
GO

CREATE PROC USP_InsertImportCoupon
@date Date, @supid int, @usid int, @type int , @status int
AS 
BEGIN
	INSERT INTO dbo.tblImportCoupon VALUES(@date,@supid,@usid,@type,@status)
END
GO

CREATE PROC USP_UpdateImportCoupon
@date Date, @supid int, @usid int,@id int
AS 
BEGIN
	Update dbo.tblImportCoupon set CheckDateImport = @date , SupId = @supid , UsId = @usid Where ImcId = @id
END
GO

CREATE PROC USP_DelImportCoupon
@id int
AS 
BEGIN
	Update dbo.tblImportCoupon Set Status = 0 Where ImcId = @id
END
GO

--Chưa thực thi
--Create PROC SearchImportCoupon
--@date Date
--AS 
--BEGIN
--	SELECT ImcId,CheckDateImport,SupId,UsId FROM dbo.tblImportCoupon WHERE CheckDateImport <= @date or CheckDateImport = @date
--END
--GO
--Chưa thực thi
--> End tblImportCoupon--



--> tblImportCouponInfo--
Select * from tblImportCouponInfo
Go

CREATE PROC USP_InsertImportCouponInfo
@imcid int,@quantity int,@prodid int,@status int
AS
BEGIN
	INSERT INTO dbo.tblImportCouponInfo VALUES(@imcid,@quantity,@prodid,@status)
	Update dbo.tblProduct set Quantity = Quantity + @quantity Where ProdId = @prodid
	Update dbo.tblImportCoupon set TypeImc = 0 Where ImcId = @imcid
END
GO

--> End tblImportCouponInfo--
----- END CREATE PROCEDDURE -----



----- CREATE PROCEDDURE PHỤC HỒI DỮ LIỆU -----

--> Account --
CREATE PROC USP_PhucHoiTaiKhoan
@name nvarchar(200)
AS
BEGIN
	Update dbo.tblAccount Set Status = 1 Where Email = @name
END
GO
--> End Account --


--> Customer --
CREATE PROC USP_PhucHoiKhachHang
@phone nvarchar(200)
AS
BEGIN
	Update dbo.tblCustomer Set Status = 1 Where PhoneNumber = @phone
END
GO
--> End Customer --
----- END CREATE PROCEDDURE -----



----- CREATE PROCEDDURE LOAD LÊN COMBO BOX BÁN HÀNG -----
CREATE PROC ListProductNameQuantity
AS 
BEGIN
	SELECT NameSP + ' | ' + CONVERT(NVARCHAR(50), Quantity) FROM dbo.tblProduct Where Status = 1
END
GO

CREATE PROC ListCustomerIdName
AS 
BEGIN
	SELECT CONVERT(NVARCHAR(50), CusId) + ' | ' + Name + ' | ' + PhoneNumber FROM dbo.tblCustomer Where Status = 1
END
GO

CREATE PROC GetEmployeeIdName
@idus int
AS 
BEGIN
	SELECT CONVERT(NVARCHAR(50), UsId) + ' | ' + DisplayName + ' | ' + UserName FROM dbo.tblAccount WHERE UsId = @idus and Status = 1
END
GO

CREATE PROC GetUnitPrice
@name NVARCHAR(200)
AS 
BEGIN
	SELECT Price FROM dbo.tblProduct WHERE NameSP = @name and Status = 1
END
GO


CREATE PROC ListBillInfo
AS 
BEGIN
	SELECT p.ProdId, p.NameSP, b.Quantity, b.Price FROM dbo.tblBillInfo b, dbo.tblProduct p WHERE p.ProdId = b.ProdId and p.Status = 1
END
GO
----- END CREATE PROCEDDURE -----



--Select * from tblAccount
--Select * from tblBill
--Select * from tblBillInfo
--Select * from tblCategory
--Select * from tblCustomer
--Select * from tblImportCoupon
--Select * from tblImportCouponInfo
--Select * from tblProduct
--Select * from tblSupplier