/* 
Author Name : NAHARJUN
Created On 	: <Created Date (12/03/2014)  >
Section  	: TAC Invoice Help
Purpose  	: TAC Invoice Help
Remarks  	: <Remarks if any>                        
Reviewed By	: <Reviewed By (Leave it blank)>
*/            
/*******************************************************************************************************
*				AMENDMENT BLOCK
********************************************************************************************************
'Name			Date			Signature			Description of Changes
********************************************************************************************************	
*******************************************************************************************************
*/

CREATE PROCEDURE [dbo].[Sp_WarsoftTACInvoice_Help]
(
@Action NVARCHAR(100),
@Id		BIGINT,
@UserId BIGINT,
@FromDate	NVARCHAR(100),
@ToDate		NVARCHAR(100),
@PId		BIGINT,
@Str        Nvarchar(100),
@Id1        BIGINT 
)
 AS
 BEGIN
 IF @Action='PAGELOAD'
 BEGIN
	CREATE TABLE #TEMP (Id BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),BookingCode BIGINT,BillNo BIGINT,CreatedDate NVARCHAR(100),InvoiceNo NVARCHAR(100),
	Property NVARCHAR(100),Amount DECIMAL(27,2),Tax DECIMAL(27,2),TotalAmount DECIMAL(27,2),Guests NVARCHAR(3000),
	Client NVARCHAR(100),ChkInDate NVARCHAR(100),ChkOutDate NVARCHAR(100),NOOfDays INT,	PerdayRate DECIMAL(27,2),Location NVARCHAR(1000),SBCess DECIMAL(27,2),
	KKCess DECIMAL(27,2))
	
	SELECT PropertyName as Property,Id as ZId from WRBHBProperty WHERE IsActive=1 and IsDeleted=0
	ORDER BY PropertyName

	INSERT INTO #TEMP(BookingCode,BillNo,CreatedDate,InvoiceNo,Property,Amount,Tax,TotalAmount,Guests,Client,ChkInDate,
	ChkOutDate,NOOfDays,PerdayRate,Location,SBCess,KKCess)
	
	SELECT B.BookingCode,C.CheckOutNo as BillId,Convert(NVARCHAR(100),C.CreatedDate,103) AS CreatedDate,
	CT.TACInvoiceNo InvoiceNo,P.PropertyName Property,CT.MarkUpAmount as Amount,
	isnull(CT.TotalBusinessSupportST,0) as Tax,Round(CT.TACAmount,0) TotalAmount,
	C.GuestName AS Guest,C.ClientName AS Client,
	CONVERT(NVARCHAR,CT.CheckInDate,103) as ChkInDt,CONVERT(NVARCHAR,CT.CheckOutDate,103) AS ChkOutDt,
	ct.NoOfDays,ct.Rate,ci.CityName as Location,CT.ChkOutTariffCess,CT.KKCess
	FROM WRBHBChechkOutHdr C 
	JOIN WRBHBBooking B ON C.BookingId=B.Id and B.IsActive=1 and B.IsDeleted=0
	JOIN WRBHBExternalChechkOutTAC CT ON CT.ChkOutHdrId = C.Id and ct.IsActive=1 and ct.IsDeleted=0
	JOIN WRBHBProperty P ON P.Id=CT.PropertyId and c.PropertyId=p.Id and p.IsActive=1 and p.IsDeleted=0
	 Left outer join WRBHBCity Ci on P.CityId=ci.Id and Ci.IsActive=1 and Ci.IsDeleted=0
	WHERE C.IsActive=1 and c.IsDeleted=0 AND   p.Category NOT IN('Managed G H','Internal Property') 
	ORDER BY TACInvoiceNo ASC
	
	SELECT ISNULL(Id,0) AS Id,ISNULL(BookingCode,0) AS BookingCode,ISNULL(BillNo,0) AS BillNo,ISNULL(CreatedDate,'')  AS CreatedDate, 
	ISNULL(InvoiceNo,'') AS InvoiceNo,ISNULL(Property,'') AS Property,ISNULL(Amount,0) AS Amount,ISNULL(Tax,0) AS Tax,Round(ISNULL(TotalAmount,0),0) AS TotalAmount,
	ISNULL(Guests,'') AS Guests,ISNULL(Client,'') AS Client,ISNULL(CONVERT(NVARCHAR,ChkInDate,103),'') AS ChkInDate,
	ISNULL(CONVERT(NVARCHAR,ChkOutDate,103),'') AS ChkOutDate ,
	ISNULL(NOOfDays,0) AS TotalDays,ISNULL(PerdayRate,0) AS Perday, ISNULL(Location,'') AS Location,ISNULL(SBCess,0) AS SBCess,ISNULL(KKCess,0) AS KKCess
	FROM #TEMP	
 END
 
 
 IF @Action='DataLoad'
 BEGIN												--drop table #TEMP
	CREATE TABLE #TEMPs (Id BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),BookingCode BIGINT,BillNo BIGINT,CreatedDate NVARCHAR(100),
	InvoiceNo NVARCHAR(100),Property NVARCHAR(100),PropertyId BIGINT,Amount DECIMAL(27,2),Tax DECIMAL(27,2),
	TotalAmount DECIMAL(27,2),Guests NVARCHAR(3000),Client NVARCHAR(100),ChkInDate NVARCHAR(100),
	ChkOutDate NVARCHAR(100),NOOfDays int,PerdayRate decimal(27,2),Location NVARCHAR(1000),SBCess DECIMAL(27,2),KKCess DECIMAL(27,2),Cess  DECIMAL(27,2),HECess  DECIMAL(27,2))
	
	CREATE TABLE #TEMPNew (Id BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),BookingCode BIGINT,BillNo BIGINT,CreatedDate NVARCHAR(100),
	InvoiceNo NVARCHAR(100),Property NVARCHAR(100),PropertyId bigint,Amount DECIMAL(27,2),Tax DECIMAL(27,2),
	TotalAmount DECIMAL(27,2),Guests NVARCHAR(3000),Client NVARCHAR(100),ChkInDate NVARCHAR(100),
	ChkOutDate NVARCHAR(100),NOOfDays INT,PerdayRate DECIMAL(27,2),Location NVARCHAR(1000),SBCess DECIMAL(27,2),KKCess DECIMAL(27,2),Cess  DECIMAL(27,2),HECess  DECIMAL(27,2))
	
	
		INSERT INTO #TEMPs(BookingCode,BillNo,CreatedDate,InvoiceNo,Property,PropertyId,Amount,Tax,TotalAmount,Guests,
		Client,ChkInDate,ChkOutDate,NOOfDays,PerdayRate,Location,SBCess,KKCess,Cess,HECess)
	
		SELECT B.BookingCode,C.CheckOutNo as BillId, convert(date,C.CreatedDate,103) ,
		CT.TACInvoiceNo InvoiceNo,P.PropertyName Property,C.PropertyId,CT.MarkUpAmount as Amount,
		isnull(CT.TotalBusinessSupportST,0) as Tax,CT.TACAmount TotalAmount,C.GuestName AS Guest,C.ClientName AS Client,
		CT.CheckInDate as ChkInDt,CT.CheckOutDate AS ChkOutDt,ct.NoOfDays,ct.Rate,Ci.CityName ,CT.ChkOutTariffCess,ISNULL(CT.KKCess,0),0,CT.ChkOutTariffHECess
		FROM WRBHBChechkOutHdr C 
		JOIN WRBHBBooking B ON C.BookingId=B.Id and B.IsActive=1 and B.IsDeleted=0
		JOIN WRBHBExternalChechkOutTAC CT ON CT.ChkOutHdrId = C.Id and ct.IsActive=1 and ct.IsDeleted=0
	    JOIN WRBHBProperty P ON P.Id=CT.PropertyId and c.PropertyId=p.Id and p.IsActive=1 and p.IsDeleted=0
	    Left outer join WRBHBCity Ci on P.CityId=ci.Id and Ci.IsActive=1 and Ci.IsDeleted=0
	    WHERE C.IsActive=1 and c.IsDeleted=0 AND p.Category NOT IN('Managed G H','Internal Property')
		AND CONVERT(date,C.CreatedDate,103) >='2015-11-15'

		INSERT INTO #TEMPs(BookingCode,BillNo,CreatedDate,InvoiceNo,Property,PropertyId,Amount,Tax,TotalAmount,Guests,
		Client,ChkInDate,ChkOutDate,NOOfDays,PerdayRate,Location,SBCess,KKCess,Cess,HECess)
	
		SELECT B.BookingCode,C.CheckOutNo as BillId, convert(date,C.CreatedDate,103) ,
		CT.TACInvoiceNo InvoiceNo,P.PropertyName Property,C.PropertyId,CT.MarkUpAmount as Amount,
		isnull(CT.TotalBusinessSupportST,0) as Tax,CT.TACAmount TotalAmount,C.GuestName AS Guest,C.ClientName AS Client,
		CT.CheckInDate as ChkInDt,CT.CheckOutDate AS ChkOutDt,ct.NoOfDays,ct.Rate,Ci.CityName,0,0,CT.ChkOutTariffCess,CT.ChkOutTariffHECess
		FROM WRBHBChechkOutHdr C 
		JOIN WRBHBBooking B ON C.BookingId=B.Id and B.IsActive=1 and B.IsDeleted=0
		JOIN WRBHBExternalChechkOutTAC CT ON CT.ChkOutHdrId = C.Id and ct.IsActive=1 and ct.IsDeleted=0
	    JOIN WRBHBProperty P ON P.Id=CT.PropertyId and c.PropertyId=p.Id and p.IsActive=1 and p.IsDeleted=0
	    Left outer join WRBHBCity Ci on P.CityId=ci.Id and Ci.IsActive=1 and Ci.IsDeleted=0
	    WHERE C.IsActive=1 and c.IsDeleted=0 AND p.Category NOT IN('Managed G H','Internal Property')
		AND CONVERT(date,C.CreatedDate,103) <='2015-11-14'

--NON IS GIVEN	
	IF @PId=0 AND @FromDate='' AND @ToDate='' 
	BEGIN
		INSERT INTO #TEMPNew(BookingCode,BillNo,CreatedDate,InvoiceNo,Property,PropertyId,Amount,Tax,TotalAmount,Guests,
		Client,ChkInDate,ChkOutDate,NOOfDays,PerdayRate,Location,SBCess,KKCess,Cess,HECess)
		SELECT BookingCode,BillNo,CreatedDate,InvoiceNo,Property,PropertyId,Amount,Tax,TotalAmount,Guests,Client,ChkInDate,
		ChkOutDate,NOOfDays TotalDays ,PerdayRate Perday ,Location,SBCess,KKCess ,Cess,HECess
		FROM #TEMPs
	END
--ONLY PROPERTY IS GIVEN		
	IF @PId!=0 AND @FromDate='' AND @ToDate='' 
	BEGIN
		INSERT INTO #TEMPNew(BookingCode,BillNo,CreatedDate,InvoiceNo,Property,PropertyId,Amount,Tax,TotalAmount,Guests,
		Client,ChkInDate,ChkOutDate,NOOfDays,PerdayRate,Location,SBCess,KKCess,Cess,HECess)
		SELECT  BookingCode,BillNo,CreatedDate,InvoiceNo,Property,PropertyId,Amount,Tax,TotalAmount,Guests,Client,ChkInDate,
		ChkOutDate,NOOfDays TotalDays ,PerdayRate Perday ,Location ,SBCess,KKCess,Cess,HECess
		FROM #TEMPs WHERE PropertyId=@PId
	END

--FROM DATE AND TO DATE ARE GIVEN		
	IF @PId=0 AND @FromDate!='' AND @ToDate!='' 
	BEGIN
		INSERT INTO #TEMPNew(BookingCode,BillNo,CreatedDate,InvoiceNo,Property,PropertyId,Amount,Tax,TotalAmount,Guests,
		Client,ChkInDate,ChkOutDate,NOOfDays,PerdayRate,Location,SBCess,KKCess,Cess,HECess)
		SELECT BookingCode,BillNo,Convert(NVARCHAR(100),CAST(CreatedDate as DATE),103)  AS CreatedDate, 
		InvoiceNo,Property,PropertyId,Amount,Tax,TotalAmount,Guests,Client,CONVERT(NVARCHAR,ChkInDate,103) 
		AS ChkInDate,CONVERT(NVARCHAR,ChkOutDate,103) AS ChkOutDate ,
		NOOfDays TotalDays,PerdayRate Perday,Location ,SBCess,KKCess,Cess,HECess
		FROM #TEMPs 
		WHERE  CreatedDate  BETWEEN Convert(date,@FromDate,103) AND Convert(date,@ToDate,103); 
	END
--PROPERTY,FROM DATE AND TO DATE ARE GIVEN		
	IF @PId!=0 AND @FromDate!='' AND @ToDate!='' 
	BEGIN
		INSERT INTO #TEMPNew(BookingCode,BillNo,CreatedDate,InvoiceNo,Property,PropertyId,Amount,Tax,TotalAmount,Guests,
		Client,ChkInDate,ChkOutDate,NOOfDays,PerdayRate,Location,SBCess,KKCess,Cess,HECess)
		SELECT BookingCode,BillNo,Convert(NVARCHAR(100),CAST(CreatedDate as DATE),103),InvoiceNo,Property,PropertyId,Amount,
		Tax,TotalAmount,Guests,Client,ChkInDate,
		ChkOutDate ,NOOfDays TotalDays,PerdayRate Perday,Location,SBCess,KKCess,Cess,HECess
		FROM #TEMPs 
		where  PropertyId=@PId and
		CreatedDate BETWEEN CONVERT(DATE,@FromDate,103)AND CONVERT(DATE,@ToDate,103);
	END
	    SELECT ISNULL(Id,0) AS Id,ISNULL(BookingCode,0) AS BookingCode,ISNULL(BillNo,0) AS BillNo,ISNULL(CreatedDate,'')  AS CreatedDate, 
		ISNULL(InvoiceNo,'') AS InvoiceNo,ISNULL(Property,'') AS Property,ISNULL(Amount,0) AS Amount,ISNULL(Tax,0) AS Tax,ISNULL(SBCess,0) AS SBCess,ISNULL(KKCess,0) KKCess,
		Round(ISNULL(TotalAmount,0),0) AS TotalAmount,
		ISNULL(Guests,'') AS Guests,ISNULL(Client,'') AS Client,ISNULL(CONVERT(NVARCHAR,ChkInDate,103),'') AS ChkInDate,
		ISNULL(CONVERT(NVARCHAR,ChkOutDate,103),'') AS ChkOutDate ,
		ISNULL(NOOfDays,0) AS TotalDays,ISNULL(PerdayRate,0) AS Perday, ISNULL(Location,'') AS Location,ISNULL(Cess,0) AS Cess,ISNULL(HECess,0) AS HECess
		FROM #TEMPNew 
	
	End
 
END