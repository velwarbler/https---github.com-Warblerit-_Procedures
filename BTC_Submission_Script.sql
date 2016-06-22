/****** Object:  Table [dbo].[WRBHBBTCSubmission_Header]    Script Date: 5/19/2016 3:28:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WRBHBBTCSubmission_Header](
	[ClientId] [bigint] NOT NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[RowId] [uniqueidentifier] NOT NULL,
	[ConsolidateNo] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

Alter table WRBHBBTCSubmission add [HeaderId] [bigint] NULL

GO

CREATE PROCEDURE [dbo].[Sp_BTCSubmission_Header_Insert]
(
@CId		BIGINT,
@CBy   BIGINT,
@Type nvarchar(20)
)
AS
BEGIN
DECLARE @Identity int
INSERT INTO WRBHBBTCSubmission_Header(ClientId,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,
			IsActive,IsDeleted,RowId,ConsolidateNo)
VALUES (@CId,@CBy,GETDATE(),@CBy,GETDATE(),1,0,NEWID(),@Type)--,@HId
 SET  @Identity=@@IDENTITY
 SELECT Id,RowId FROM WRBHBBTCSubmission_Header WHERE Id=@Identity;
 
END
Go


ALTER PROCEDURE [dbo].[SP_BTCSubmission_Save](
@HdrId              BIGINT=NULL,
@ClientId			BIGINT,
@Acknowledged		NVARCHAR(100)=NULL,
@Comments           NVARCHAR(100)=NULL, 
@Filename			NVARCHAR(100)=NULL, 
@Physical			NVARCHAR(100)=NULL,
@Expected			NVARCHAR(100)=NULL,	
@SubmittedOn		NVARCHAR(100)=NULL,
@CollectionStatus	NVARCHAR(100)=NULL,
@DepositDetilsId	BIGINT,
@ChkOutHdrId        BIGINT, 
@InvoiceNo			NVARCHAR(100)=NULL, 
@InvoiceType		NVARCHAR(100)=NULL,
@InvoiceDate		NVARCHAR(100)=NULL,	
@CreatedBy			BIGINT
)
AS
BEGIN  
	INSERT INTO WRBHBBTCSubmission(ClientId,SubmittedOnDate,ExpectedDate,PhysicalInvoice,Acknowledged,
	Comments,CollectionStatus,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,
	IsActive,IsDeleted,RowId,FileNames,ChkOutHdrId,InvoiceNo,
	InvoiceType,InvoiceDate,DepositDetilsId,HeaderId) --
	VALUES
	(@ClientId,CONVERT(DATE,@SubmittedOn,103),CONVERT(DATE,@Expected,103),@Physical,@Acknowledged,@Comments,@CollectionStatus,
	@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),1,0,NEWID(),@FileName,@ChkOutHdrId,@InvoiceNo,
	@InvoiceType,CONVERT(DATE,@InvoiceDate,103),@DepositDetilsId,@HdrId)	--
	SELECT Id,RowId   FROM WRBHBBTCSubmission --HeaderId
	WHERE Id=@@IDENTITY  
END


Go

ALTER PROCEDURE [dbo].[SP_BTCSubmission_Update](
@ClientId			BIGINT,
@Acknowledged		NVARCHAR(100)=NULL,
@Comments           NVARCHAR(100)=NULL, 
@Filename			NVARCHAR(100)=NULL, 
@Physical			NVARCHAR(100)=NULL,
@Expected			NVARCHAR(100)=NULL,	
@SubmittedOn		NVARCHAR(100)=NULL,
@CollectionStatus	NVARCHAR(100)=NULL,
@CreatedBy			BIGINT,
@DepositDetilsId	BIGINT,
@ChkOutHdrId        BIGINT, 
@InvoiceNo			NVARCHAR(100)=NULL, 
@InvoiceType		NVARCHAR(100)=NULL,
@InvoiceDate		NVARCHAR(100)=NULL,	
@Id					BIGINT
)
AS
BEGIN  
	UPDATE WRBHBBTCSubmission SET 
	ClientId=@ClientId,
	SubmittedOnDate=CONVERT(DATE,@SubmittedOn,103),
	ExpectedDate=CONVERT(DATE,@Expected,103),
	PhysicalInvoice=@Physical,
	Acknowledged=@Acknowledged,
	Comments=@Comments,
	CollectionStatus=@CollectionStatus,		
	ChkOutHdrId=@ChkOutHdrId,
	InvoiceNo=@InvoiceNo,
	InvoiceType=@InvoiceType,
	InvoiceDate=CONVERT(DATE,@InvoiceDate,103),
	DepositDetilsId=@DepositDetilsId,
	ModifiedBy=@CreatedBy,
	ModifiedDate=GETDATE(),	
	FileNames=@FileName
	WHERE DepositDetilsId=@Id
	
	SELECT DepositDetilsId,RowId FROM WRBHBBTCSubmission 
	WHERE DepositDetilsId=@Id
END
GO
 

CREATE PROCEDURE [dbo].[SP_BTCConsolidate_Bill]
(@Action NVARCHAR(100)=NULL,
@Str1 NVARCHAR(100)=NULL,
@Str2 INT=NULL,
@Id1 INT=NULL,
@Id2 INT=NULL
)
AS
BEGIN
IF @Action='PageLoad'
	BEGIN
	
DECLARE @CompanyName VARCHAR(100),@Address NVARCHAR(100),@PanCardNo VARCHAR(100),
	@ServiceTaxNo VARCHAR(100),@LOGO VARCHAR(MAX),@LuxuryTax NVARCHAR(100),
	@TariffAmount DECIMAL(27,2),@ClientAddress NVARCHAR(500),@ClientId BIGINT,
	@Miscellaneous DECIMAL(27,2),@MiscellaneousRemarks NVARCHAR(100),@Food DECIMAL(27,2),
	@Laundry DECIMAL(27,2),@Service DECIMAL(27,2);
 
	SET @CompanyName=(SELECT 'Humming Bird Digital Pvt Ltd., (Formerly Humming Bird Travel & Stay Pvt Ltd)' FROM WRBHBCompanyMaster)--LegalCompanyName
	SET @Address=(SELECT Address FROM WRBHBCompanyMaster)
	SET @PanCardNo =(SELECT PanCardNo FROM WRBHBCompanyMaster)
	SET @LOGO=(SELECT Logo FROM WRBHBCompanyMaster)
	
	SELECT @ClientId=I.ClientId  FROM WRBHBChechkOutHdr H
	JOIN WRBHBBooking I WITH(NOLOCK) ON I.Id=H.BookingId
	WHERE H.Id=@Id1
    SELECT @ClientAddress=CAddress1+','+CCity+','+CState+','+CPincode FROM WRBHBClientManagement H   
	WHERE H.Id=@ClientId
	
	SELECT @Food=SUM(ISNULL(D.ChkOutSerAmount,0)) FROM  WRBHBCheckOutServiceDtls D 
	WHERE D.IsActive=1 AND D.IsDeleted=0
    AND ltrim(D.TypeService)=ltrim('Food And Beverages')
    AND D.CheckOutServceHdrId=@Id1 
    
    SELECT @Laundry=SUM(ISNULL(D.ChkOutSerAmount,0)) FROM  WRBHBCheckOutServiceDtls D 
	WHERE D.IsActive=1 AND D.IsDeleted=0
    AND D.TypeService='Laundry'
    AND D.CheckOutServceHdrId=@Id1

    

    SELECT @Service=SUM(ISNULL(D.ChkOutSerAmount,0)) FROM  WRBHBCheckOutServiceDtls D 
	WHERE D.IsActive=1 AND D.IsDeleted=0
    AND D.TypeService='Services'
    AND D.CheckOutServceHdrId=@Id1
    
    SELECT @Miscellaneous=ISNULL(MiscellaneousAmount,0)--,@MiscellaneousRemarks=MiscellaneousRemarks 
    FROM dbo.WRBHBCheckOutServiceHdr H
    WHERE H.CheckOutHdrId=@Id1 AND H.IsActive=1 AND H.IsDeleted=0
    
    SELECT @MiscellaneousRemarks=MiscellaneousRemarks 
    FROM dbo.WRBHBCheckOutServiceHdr H
    WHERE H.CheckOutHdrId=@Id1 AND H.IsActive=1 AND H.IsDeleted=0
    
    Declare @CessName NVARCHAR(100),@DateNew NVARCHAR(100);
    SET @DateNew=(SELECT CONVERT(date,CreatedDate,103) FROM WRBHBChechkOutHdr where Id=@Id1)
    DECLARE @Type NVARCHAR(100);
	SET @Type=(SELECT PropertyType FROM WRBHBChechkOutHdr WHERE Id=@Id1)

    if(@DateNew >= '2015-11-15')
    begin
    SET @CessName='Swatch Bharath Cess @ 0.3% on Service Tax'
    end
    else
    begin
    SET @CessName='Education Cess @ 2% on Service Tax';
    end
	
IF @Type='MMT'
BEGIN
 select h.GuestName as GuestName,h.Name,h.Stay,h.Type,h.BookingLevel,
    convert(nvarchar(100),h.BillDate,103) as BillDate,h.InVoiceNo,h.NoOfDays,
	h.ClientName,isnull(h.ChkOutTariffNetAmount,0) as ChkOutTariffNetAmount,
	h.ChkOutTariffTotal as TotalTariff,h.ChkOutTariffLT as LuxuryTax,isnull(h.ChkOutTariffST1,0) as SerivceNet,
	(isnull(h.ChkOutTariffST2,0)+isnull(cs.ChkOutServiceST,0)) as ServiTarFood,
	h.ChkOutTariffSC as ServiceCharge,h.ChkOutTariffST3 as SerivceTax,(isnull(h.ChkOutTariffCess,0)+isnull(cs.Cess,0)) as Cess,
	(isnull(h.ChkOutTariffHECess,0)+isnull(cs.HECess,0)) as HCess,convert(nvarchar(100),d.ArrivalDate,103) as ArrivalDate,
	ROUND (d.Tariff,0) Tariff,(p.HotalName+','+p.Line1) as Propertyaddress,(c.CityName+','+
	s.StateName+','+p.Pincode) as Propcity,c.CityName,s.StateName,p.Pincode as Postal,
	p.Phone,p.Email,isnull(Cs.ChkOutServiceNetAmount,0) ChkOutServiceNetAmount,isnull(cs.ChkOutServiceAmtl,0) as Amount,	
	isnull(CS.ChkOutServiceNetAmount,0) as ServiceNetAmt,isnull(cs.ChkOutServiceVat,0) as Vat,
	@CompanyName as CompanyName,'PAN NO :'+@PanCardNo AS PanCardNo,@LOGO AS logo,
	CONVERT(nvarchar(100),h.BillFromDate,103) ChkinDT,CONVERT(nvarchar(100),h.BillEndDate,103) as ChkoutDT,isnull(h.KKCess,0) as Krishkalyan,
	CASE WHEN CONVERT(date,h.CreatedDate,103) >= CONVERT(date,'01/02/2016',103) THEN 
	 'Issued by Hummingbird Digital Pvt Ltd.
	 Treebo is engaged in marketing the services of this hotel and in providing expertise to this hotel in maintaining service standards. 
	 It does not own or operate the hotel. This invoice has been generated by HummingBird 
	 Travel & Stay Pvt. Ltd. and the taxes collected above have been collected directly by the hotel under the below mentioned registrations
	 Regd Office : No. 122, Amarjyothi Layout, Domlur, Bangalore - 560071'+'.'+'www.hummingbirdindia.com' ELSE 
	 'Regd Office : No. 122, Amarjyothi Layout, Domlur, Bangalore - 560071'+'.'+'www.hummingbirdindia.com' END AS CompanyAddress,	
	'INVOICE : For any invoice clarification revert within 7 days from the date of receipt' as Invoice,
	'All cheque or demand drafts in payment of bills should be drawn in favor of Hummingbird Digital Pvt Ltd.
	and should be crossed A/C PAYEE ONLY.' as Cheque,
	'LATE PAYMENT : Interest @18% per annum will be charged on all outstanding bill after due date.' as Latepay ,
	'PAN NO :'+@PanCardNo+'   |   '+'TIN :'+ t.TINNumber+'   |   '+'L Tax No :'+ t.LuxuryNo+'  |  '
	 +'CIN No: '+t.CINNumber as TaxNo,'Service Tax Regn. No : AABCH5874RST001' as ServiceTaxNo,
	'Taxable Category : Accommodation Service,Business Support Services and Restaurant Services' as Taxablename,
	(isnull(h.ChkOutTariffNetAmount,0)+isnull(CS.ChkOutServiceNetAmount,0)) as BillAmount,
	--round((round(isnull(h.ChkOutTariffTotal,0),0)+round(isnull(ChkOutTariffExtraAmount,0),0)+round(isnull(@Food,0),0)+
	--round(isnull(@Laundry,0),0)+round(isnull(@Service,0),0)+round(isnull(@Miscellaneous,0),0)+round(isnull(h.ChkOutTariffLT,0),0)+
	--round(isnull(h.ChkOutTariffST1,0),0)+round(isnull(h.ChkOutTariffSC,0),0)+round(sum(CS.ChkOutServiceST),0)+round(sum(CS.OtherService),0)+
	--(round (isnull(h.ChkOutTariffST3,0),0)+round(isnull(h.ChkOutTariffCess,0),0)+round(sum(cs.Cess),0))+
	--(round(isnull(h.ChkOutTariffHECess,0),0)+round(sum(cs.HECess),0)+round(sum(cs.ChkOutServiceVat),0))),0) as 	BillAmount,
	@ClientAddress as Address,'Service Tax Regn. No : AABCH5874RST001' as ServiceTaxNo,
	'Luxury Tax @ '+CAST(H.LuxuryTaxPer AS NVARCHAR)+'% on Tariff' LTPer,'Service Tax @ 8.4 % on Tariff' STPer,--'Service Tax @ '+CAST(H.ServiceTaxPer AS NVARCHAR)+'%' STPer,
	 'VAT @'+CAST(H.VATPer AS NVARCHAR(100))+'% on Food and Beverages' VATPer, ISNULL(@Food,0) AS Food,ISNULL(@Laundry,0) Laundry,ISNULL(@Service,0) Service,
    ISNULL(@Miscellaneous,0) Miscellaneous,'Miscellaneous - '+@MiscellaneousRemarks MiscellaneousRemarks,
    'Service Tax @'+CAST(h.RestaurantSTPer  AS NVARCHAR)+'% on Food and Beverages' ServiceFB,
    'Service Tax @'+CAST(h.BusinessSupportST AS NVARCHAR)+'% on Others' ServiceOT,
     h.ChkOutTariffExtraAmount ExtraMatress,
    'CIN No: U72900KA2005PTC035942' as CINNo,CONVERT(nvarchar(100),h.CreatedDate,103) as InVoicedate,
    'Rupees : '+dbo.fn_NtoWord(round((isnull(h.ChkOutTariffNetAmount,0)+isnull(CS.ChkOutServiceNetAmount,0)),0),'','') AS AmtWords,
    'Extra Matress' ExtraMatr,'Food and Beverages' FoodBev,'Laundry' LaundryName,'Service' ServiceName,
    'Service Charge  @ 2.5% on Tariff' ServChrg,'Service Tax@12.00% on ServiceCharge'ServChrg1,@CessName Bank,'KK cess @ 0.3 %' as  LabelKrishkalyan
    ,P.Id AS PropertyId,CASE WHEN CONVERT(date,h.CreatedDate,103) >= CONVERT(date,'01/01/2016',103) THEN 'AFTER' ELSE 'BEFORE' END AS LogoFinal
	--CSDD.BillAmount
	
	
	from WRBHBChechkOutHdr h 
	join  WRBHBCheckInHdr d on h.ChkInHdrId = d.Id and d.IsActive = 1 and d.IsDeleted = 0
    left outer join WRBHBStaticHotels p on d.PropertyId =  p.HotalId  --and p.IsActive = 1 and p.IsDeleted = 0
	join WRBHBState s on s.Id=h.StateId
	join WRBHBCity c on c.Id=h.CityId 
	join WRBHBTaxMaster t on t.StateId=17 
	--join WRBHBBooking b on b.Id = d.BookingId
	left outer join WRBHBCheckOutServiceHdr CS on h.Id = cs.CheckOutHdrId and CS.IsActive = 1 and cs.IsDeleted = 0
	where h.IsActive = 1 and h.IsDeleted = 0
	and h.Id = @Id1
	group by h.GuestName ,h.Name,h.Stay,h.Type,h.BookingLevel,
	BillDate,h.ClientName,h.Id,	h.ChkOutTariffTotal ,h.ChkOutTariffLT ,h.ChkOutTariffNetAmount,
	h.ChkOutTariffST2 ,h.ChkOutTariffST3 ,h.ChkOutTariffCess ,
	h.ChkOutTariffHECess ,h.ChkOutTariffSC,h.CheckInDate,d.Tariff,p.HotalName,p.Line1,
	c.CityName,s.StateName,p.Phone,p.Pincode,p.Email,	
    H.VATPer,h.RestaurantSTPer ,
    h.BusinessSupportST,h.ChkOutTariffST1 ,H.LuxuryTaxPer,H.ServiceTaxPer,h.ChkOutTariffExtraAmount,
    h.InVoiceNo,h.NoOfDays,h.BillFromDate,h.BillEndDate,h.CreatedDate,t.LuxuryNo,d.ArrivalDate,
    t.TINNumber,t.CINNumber,CS.ChkOutServiceNetAmount,CS.ChkOutServiceAmtl,CS.ChkOutServiceLT,CS.ChkOutServiceST,
    CS.Cess,CS.HECess,CS.ChkOutServiceVat,CS.OtherService,
    CS.ChkOutServiceST,CS.Cess,CS.HECess,P.Id,h.KKCess
END
ELSE
BEGIN
    select h.GuestName as GuestName,h.Name,h.Stay,h.Type,h.BookingLevel,
    convert(nvarchar(100),h.BillDate,103) as BillDate,h.InVoiceNo,h.NoOfDays,
	h.ClientName,isnull(h.ChkOutTariffNetAmount,0) as ChkOutTariffNetAmount,
	h.ChkOutTariffTotal as TotalTariff,h.ChkOutTariffLT as LuxuryTax,isnull(h.ChkOutTariffST1,0) as SerivceNet,
	(isnull(h.ChkOutTariffST2,0)+isnull(cs.ChkOutServiceST,0)) as ServiTarFood,
	h.ChkOutTariffSC as ServiceCharge,h.ChkOutTariffST3 as SerivceTax,(isnull(h.ChkOutTariffCess,0)+isnull(cs.Cess,0)) as Cess,
	(isnull(h.ChkOutTariffHECess,0)+isnull(cs.HECess,0)) as HCess,convert(nvarchar(100),d.ArrivalDate,103) as ArrivalDate,
	ROUND (d.Tariff,0) Tariff,(p.PropertyName+','+p.Propertaddress) as Propertyaddress,
	(c.CityName+','+ s.StateName+','+p.Postal) as Propcity,c.CityName,s.StateName,p.Postal,
	p.Phone,p.Email,isnull(Cs.ChkOutServiceNetAmount,0) ChkOutServiceNetAmount,isnull(cs.ChkOutServiceAmtl,0) as Amount,	
	isnull(CS.ChkOutServiceNetAmount,0) as ServiceNetAmt,isnull(cs.ChkOutServiceVat,0) as Vat,
	@CompanyName as CompanyName,'PAN NO :'+@PanCardNo AS PanCardNo,@LOGO AS logo,
	CONVERT(nvarchar(100),h.BillFromDate,103) ChkinDT,CONVERT(nvarchar(100),h.BillEndDate,103) as ChkoutDT,isnull(h.KKCess,0) as Krishkalyan,
	CASE WHEN CONVERT(date,h.CreatedDate,103) >= CONVERT(date,'01/02/2016',103) THEN 
	 'Issued by HummingBird Travel & Stay Pvt. Ltd.
	 Treebo is engaged in marketing the services of this hotel and in providing expertise to this hotel in maintaining service standards. 
	 It does not own or operate the hotel. This invoice has been generated by HummingBird 
	 Travel & Stay Pvt. Ltd. and the taxes collected above have been collected directly by the hotel under the below mentioned registrations
	 Regd Office : No. 122, Amarjyothi Layout, Domlur, Bangalore - 560071'+'.'+'www.hummingbirdindia.com' ELSE 
	 'Regd Office : No. 122, Amarjyothi Layout, Domlur, Bangalore - 560071'+'.'+'www.hummingbirdindia.com' END AS CompanyAddress,	
	'INVOICE : For any invoice clarification revert within 7 days from the date of receipt' as Invoice,
	'All cheque or demand drafts in payment of bills should be drawn in favor of Hummingbird Digital Pvt Ltd.
	and should be crossed A/C PAYEE ONLY.' as Cheque,
	'LATE PAYMENT : Interest @18% per annum will be charged on all outstanding bill after due date.' as Latepay ,
	'PAN NO :'+@PanCardNo+'   |   '+'TIN :'+ t.TINNumber+'   |   '+'L Tax No :'+ t.LuxuryNo+'  |  '
	 +'CIN No: '+t.CINNumber as TaxNo,'Service Tax Regn. No : AABCH5874RST001' as ServiceTaxNo,
	'Taxable Category : Accommodation Service,Business Support Services and Restaurant Services' as Taxablename,
	(isnull(h.ChkOutTariffNetAmount,0)+isnull(CS.ChkOutServiceNetAmount,0)) as BillAmount,
	--round((round(isnull(h.ChkOutTariffTotal,0),0)+round(isnull(ChkOutTariffExtraAmount,0),0)+round(isnull(@Food,0),0)+
	--round(isnull(@Laundry,0),0)+round(isnull(@Service,0),0)+round(isnull(@Miscellaneous,0),0)+round(isnull(h.ChkOutTariffLT,0),0)+
	--round(isnull(h.ChkOutTariffST1,0),0)+round(isnull(h.ChkOutTariffSC,0),0)+round(sum(CS.ChkOutServiceST),0)+round(sum(CS.OtherService),0)+
	--(round (isnull(h.ChkOutTariffST3,0),0)+round(isnull(h.ChkOutTariffCess,0),0)+round(sum(cs.Cess),0))+
	--(round(isnull(h.ChkOutTariffHECess,0),0)+round(sum(cs.HECess),0)+round(sum(cs.ChkOutServiceVat),0))),0) as 	BillAmount,
	@ClientAddress as Address,'Service Tax Regn. No : AABCH5874RST001' as ServiceTaxNo,
	'Luxury Tax @ '+CAST(H.LuxuryTaxPer AS NVARCHAR)+'% on Tariff' LTPer,'Service Tax @ 8.4 % on Tariff' STPer,--'Service Tax @ '+CAST(H.ServiceTaxPer AS NVARCHAR)+'%' STPer,
	 'VAT @'+CAST(H.VATPer AS NVARCHAR(100))+'% on Food and Beverages' VATPer, ISNULL(@Food,0) AS Food,ISNULL(@Laundry,0) Laundry,ISNULL(@Service,0) Service,
    ISNULL(@Miscellaneous,0) Miscellaneous,'Miscellaneous - '+@MiscellaneousRemarks MiscellaneousRemarks,
    'Service Tax @'+CAST(h.RestaurantSTPer  AS NVARCHAR)+'% on Food and Beverages' ServiceFB,
    'Service Tax @'+CAST(h.BusinessSupportST AS NVARCHAR)+'% on Others' ServiceOT,
     h.ChkOutTariffExtraAmount ExtraMatress,
    'CIN No: U72900KA2005PTC035942' as CINNo,CONVERT(nvarchar(100),h.CreatedDate,103) as InVoicedate,
    'Rupees : '+dbo.fn_NtoWord(round((isnull(h.ChkOutTariffNetAmount,0)+isnull(CS.ChkOutServiceNetAmount,0)),0),'','') AS AmtWords,
    'Extra Matress' ExtraMatr,'Food and Beverages' FoodBev,'Laundry' LaundryName,'Service' ServiceName,
    'Service Charge  @ 2.5% on Tariff' ServChrg,'Service Tax@12.00% on ServiceCharge'ServChrg1,@CessName Bank,'KK cess @ 0.3 %' as  LabelKrishkalyan
    ,P.Id AS PropertyId,CASE WHEN CONVERT(date,h.CreatedDate,103) >= CONVERT(date,'01/01/2016',103) THEN 'AFTER' ELSE 'BEFORE' END AS LogoFinal
	--CSDD.BillAmount
	
	
	from WRBHBChechkOutHdr h 
	join  WRBHBCheckInHdr d on h.ChkInHdrId = d.Id and d.IsActive = 1 and d.IsDeleted = 0
    left outer join WRBHBProperty p on d.PropertyId = p.Id --and p.IsActive = 1 and p.IsDeleted = 0
	join WRBHBState s on s.Id=h.StateId
	join WRBHBCity c on c.Id=p.CityId 
	join WRBHBTaxMaster t on t.StateId=17 
	--join WRBHBBooking b on b.Id = d.BookingId
	left outer join WRBHBCheckOutServiceHdr CS on h.Id = cs.CheckOutHdrId and CS.IsActive = 1 and cs.IsDeleted = 0
	where h.IsActive = 1 and h.IsDeleted = 0
	and h.Id = @Id1
	group by h.GuestName ,h.Name,h.Stay,h.Type,h.BookingLevel,
	BillDate,h.ClientName,h.Id,	h.ChkOutTariffTotal ,h.ChkOutTariffLT ,h.ChkOutTariffNetAmount,
	h.ChkOutTariffST2 ,h.ChkOutTariffST3 ,h.ChkOutTariffCess ,
	h.ChkOutTariffHECess ,h.ChkOutTariffSC,h.CheckInDate,d.Tariff,p.PropertyName,p.Propertaddress,
	c.CityName,s.StateName,p.Postal,p.Phone,p.Email,	
    H.VATPer,h.RestaurantSTPer ,
    h.BusinessSupportST,h.ChkOutTariffST1 ,H.LuxuryTaxPer,H.ServiceTaxPer,h.ChkOutTariffExtraAmount,
    h.InVoiceNo,h.NoOfDays,h.BillFromDate,h.BillEndDate,h.CreatedDate,t.LuxuryNo,d.ArrivalDate,
    t.TINNumber,t.CINNumber,CS.ChkOutServiceNetAmount,CS.ChkOutServiceAmtl,CS.ChkOutServiceLT,CS.ChkOutServiceST,
    CS.Cess,CS.HECess,CS.ChkOutServiceVat,CS.OtherService,
    CS.ChkOutServiceST,CS.Cess,CS.HECess,P.Id,h.KKCess
    
    END
	END
	
END



GO

-- ===============================================================================
-- Author:Arunprasath
-- Create date:13-08-2014
-- ModifiedBy :-Velmurugan 
-- ModifiedDate:-13-05-2016
-- Description:	BTCSubmission Help
-- =================================================================================
Alter PROCEDURE [dbo].[SP_BTCSubmission_Help](
@Action NVARCHAR(100),
@Param1	 BIGINT, 
@Param2	 BIGINT,
@Param3	 NVARCHAR(100),
@Param4	 NVARCHAR(100),
@Param5	 NVARCHAR(100),
@UserId  BIGINT)			
AS
BEGIN
IF @Action ='Client'
BEGIN
	SELECT ClientName ,Id ZId FROM WRBHBClientManagement
	WHERE IsActive=1 AND IsDeleted=0 
	--and id=1528 
	
	SELECT FirstName,Id ZId FROM WRBHBUser WHERE IsActive=1 AND IsDeleted=0
END	
IF @Action ='Not Submitted'
BEGIN
	SELECT CONVERT(NVARCHAR,H.DepositedDate,103) as SubmittedDate,D.InvoiceNo InvoiceNo,
	BillType InvoiceType,CONVERT(NVARCHAR,R.CreatedDate,103) InvoiceDate,
	'Not Submitted' CollectionStatus,D.ChkOutHdrId,D.ClientId,D.Id DepositDetilsId,
	 0 Id,0 checks,R.ChkOutTariffST1 ST1,R.ChkOutTariffST3 ST3,R.ChkOutTariffSC SC,R.ChkOutTariffCess Cess,R.ChkOutTariffHECess HECess,R.ChkOutTariffLT LT,
	R.ServiceTaxPer TaxPer, R.ChkOutTariffTotal TariffTotal,R.ChkOutTariffNetAmount Total-- Convert(Decimal(27,2), '0.00') Total
	FROM WRBHBDeposits H
	JOIN WRBHBDepositsDlts D WITH(NOLOCK) ON D.DepHdrId=H.Id AND D.IsActive=1 AND D.IsDeleted=0
	AND D.ClientId=@Param1
	AND D.Id NOT IN(SELECT DepositDetilsId FROM WRBHBBTCSubmission WHERE IsActive=1 AND IsDeleted=0)
	JOIN dbo.WRBHBChechkOutHdr R WITH(NOLOCK) ON D.ChkOutHdrId=R.Id AND D.IsActive=1 AND D.IsDeleted=0
	WHERE H.Mode='BTC' AND  H.IsActive=1 AND H.IsDeleted=0 AND BTCTo='Commercial'
END	
IF @Action ='Submitted'
BEGIN
	CREATE TABLE #TEMPSubmitted(SubmittedDate NVARCHAR(100),InvoiceNo NVARCHAR(100),InvoiceType NVARCHAR(100),
	InvoiceDate NVARCHAR(100),CollectionStatus NVARCHAR(100),ChkOutHdrId BIGINT,ClientId BIGINT,
	DepositDetilsId BIGINT,Id BIGINT,checks BIGINT,ST1 DECIMAL(27,2),ST3 DECIMAL(27,2),SC DECIMAL(27,2),Cess DECIMAL(27,2),HECess DECIMAL(27,2),
	LT DECIMAL(27,2),TaxPer NVARCHAR(200),TariffTotal DECIMAL(27,2), Total DECIMAL(27,2))
	
	INSERT INTO #TEMPSubmitted (SubmittedDate,InvoiceNo,InvoiceType,InvoiceDate,CollectionStatus,ChkOutHdrId,
	ClientId,DepositDetilsId,Id,checks,ST1,ST3,SC,Cess,HECess,LT,TaxPer,TariffTotal,Total)
	SELECT CONVERT(NVARCHAR,H.DepositedDate,103) as SubmittedDate,D.InvoiceNo InvoiceNo,
	BillType InvoiceType,CONVERT(NVARCHAR,R.CreatedDate,103) InvoiceDate,
	'Submitted' CollectionStatus,D.ChkOutHdrId,D.ClientId,D.Id DepositDetilsId,
	0 Id,0 checks,R.ChkOutTariffST1 ST1,R.ChkOutTariffST3 ST3,R.ChkOutTariffSC SC,R.ChkOutTariffCess Cess,R.ChkOutTariffHECess HECess,R.ChkOutTariffLT LT,
	R.ServiceTaxPer TaxPer, R.ChkOutTariffTotal TariffTotal,R.ChkOutTariffNetAmount Total
	FROM WRBHBDeposits H
	JOIN WRBHBDepositsDlts D WITH(NOLOCK) ON D.DepHdrId=H.Id AND D.IsActive=1 AND D.IsDeleted=0
	AND H.ClientId=@Param1 
	AND D.Id NOT IN(SELECT DepositDetilsId FROM WRBHBBTCSubmission WHERE IsActive=1 AND IsDeleted=0)
	JOIN dbo.WRBHBChechkOutHdr R WITH(NOLOCK) ON D.ChkOutHdrId=R.Id AND D.IsActive=1 AND D.IsDeleted=0
	WHERE H.Mode='BTC' AND  H.IsActive=1 AND H.IsDeleted=0 AND BTCTo='Client'
	
	INSERT INTO #TEMPSubmitted(SubmittedDate,InvoiceNo,InvoiceType,InvoiceDate,CollectionStatus,ChkOutHdrId,
	ClientId,DepositDetilsId,Id,checks,ST1,ST3,SC,Cess,HECess,LT,TaxPer,TariffTotal,Total)
	SELECT ISNULL(B.SubmittedOnDate,''),ISNULL(B.InvoiceNo,''),ISNULL(InvoiceType,''),CONVERT(NVARCHAR,InvoiceDate,103),CollectionStatus,ISNULL(ChkOutHdrId,0),
	B.ClientId,ISNULL(DepositDetilsId,0),B.Id,0,COH.ChkOutTariffST1 ST1,COH.ChkOutTariffST3 ST3,COH.ChkOutTariffSC SC,COH.ChkOutTariffCess Cess,COH.ChkOutTariffHECess HECess,COH.ChkOutTariffLT LT,
	COH.ServiceTaxPer TaxPer, COH.ChkOutTariffTotal TariffTotal,COH.ChkOutTariffNetAmount 
	FROM WRBHBBTCSubmission B
	JOIN WRBHBChechkOutHdr COH ON B.ChkOutHdrId=COH.Id 
	WHERE B.IsActive=1 AND B.IsDeleted=0 AND CollectionStatus='Submitted' AND B.ClientId=@Param1
	
	SELECT SubmittedDate,InvoiceNo,InvoiceType,InvoiceDate,CollectionStatus,ChkOutHdrId,
	ClientId,DepositDetilsId,Id,checks,ST1,ST3,SC,Cess,HECess,LT,TaxPer,TariffTotal,Total FROM #TEMPSubmitted	
END
IF @Action ='IMAGEUPLOAD'
BEGIN
	UPDATE WRBHBBTCSubmission SET FilePath=@Param3 WHERE Id=@Param1
END
END

GO
CREATE PROCEDURE [dbo].[SP_WarsoftBTCSubmission_Help] 
(  
@HId NVARCHAR(200)
)  
AS  
BEGIN  
		 DECLARE @CompanyName VARCHAR(100),   
		 @PanCardNo VARCHAR(100);   
		 SET @CompanyName=(SELECT LegalCompanyName FROM WRBHBCompanyMaster)  
		 SET @PanCardNo =(SELECT PanCardNo FROM WRBHBCompanyMaster)  
   
		 CREATE TABLE #ConBTC(ConsolidateNo NVARCHAR(100),headerid BIGINT, clientID BIGINT,  
		 Property NVARCHAR(100),PropertyId BIGINT,NoOfDays int,TariffPerDay DECIMAL(27,2),TotalTariffAmount DECIMAL(27,2),  
		 LT  DECIMAL(27,2),ServiTarFood DECIMAL(27,2), ServiceTax DECIMAL(27,2),[Amount] DECIMAL(27,2),  
		 [ServiceNetAmt] DECIMAL(27,2),TariffNetAmount DECIMAL(27,2),[Vat] DECIMAL(10,2),  
		 Cess DECIMAL(27,2),HCess DECIMAL(27,2),SBCess DECIMAL(27,2),Krishkalyan DECIMAL(27,2), 
		 Total DECIMAL(27,2),CheckInDate Nvarchar(50),   
		 CheckOutDate Nvarchar(50),ChkOutHdrId BIGINT,invoiceNo Nvarchar(100),GuestName Nvarchar(100),ExtraMatress DECIMAL(27,2),BillType NVARCHAR(100),
		 SC DECIMAL(27,2),SCST DECIMAL(27,2));  
    

		 --Tariff
		 INSERT INTO #ConBTC  
  
		 SELECT h.ConsolidateNo,B.headerid,B.clientID,R.Property,R.PropertyId, R.NoOfDays,  
		 R.ChkOutTariffAdays as [TariffPerDay],R.ChkOutTariffTotal   as [TotalTariffAmount],  
		 R.ChkOutTariffLT AS [LT],0 AS   [ServiTarFood] ,  
		 ISNULL(R.ChkOutTariffST1,0) AS [ServiceTax],0 as [Amount],     
		 0 as [ServiceNetAmt],ISNULL(R.ChkOutTariffNetAmount,0) as [TariffNetAmount],   
		 0 as [Vat],0 as  Cess,0 as HCess ,ISNULL(R.ChkOutTariffCess,0) as SBCess,   
		 ISNULL(R.KKCess,0) as Krishkalyan,ISNULL(R.ChkOutTariffNetAmount,0)   as Total,    
		 R.CheckInDate,R.CheckOutDate,B.ChkOutHdrId, B.invoiceNo, R.GuestName,ISNULL(R.ChkOutTariffExtraAmount,0) as ExtraMatress,'Tariff',
		 R.ChkOutTariffSC,R.ChkOutTariffST3   
		 FROM WRBHBChechkOutHdr R  
		 JOIN WRBHBBTCSubmission B ON r.Id = b.ChkOutHdrId   
		 JOIN WRBHBBTCSubmission_Header h ON b.headerid= h.id    
		 JOIN  WRBHBCheckInHdr d ON R.ChkInHdrId = d.Id and d.IsActive = 1 and d.IsDeleted = 0  
		 INNER JOIN WRBHBClientManagement j  ON b.ClientId = j.id     
		 WHERE  R.IsActive = 1 and R.IsDeleted = 0 and b.IsActive=1 AND b.IsDeleted=0 and R.IsActive=1 AND R.IsDeleted=0 and b.HeaderId = @HId  
		 AND CONVERT(DATE,R.CreatedDate,103) >= CONVERT(DATE,'15/11/2015',103)  
		 GROUP BY B.ChkOutHdrId, h.ConsolidateNo,B.headerid,B.clientID,R.Property,R.PropertyId, R.NoOfDays,  
		 R.ChkOutTariffAdays,R.ChkOutTariffTotal,R.ChkOutTariffLT,R.ChkOutTariffST2,R.ChkOutTariffCess,R.ChkOutTariffHECess,h.CreatedDate,  
		 R.ChkOutTariffNetAmount, R.CheckInDate,R.CheckOutDate,B.ChkOutHdrId, B.invoiceNo, R.GuestName, 
		 R.ChkOutTariffExtraAmount,R.ChkOutTariffST1,R.KKCess,R.ChkOutTariffSC,R.ChkOutTariffST3   
   

		 INSERT INTO #ConBTC  
  
		 SELECT h.ConsolidateNo,B.headerid,B.clientID,R.Property,R.PropertyId, R.NoOfDays,  
		 R.ChkOutTariffAdays as [TariffPerDay],R.ChkOutTariffTotal   as [TotalTariffAmount],  
		 R.ChkOutTariffLT AS [LT],0 AS   [ServiTarFood] ,  
		 ISNULL(R.ChkOutTariffST1,0) AS [ServiceTax],0 as [Amount],      
		 0 as [ServiceNetAmt],ISNULL(R.ChkOutTariffNetAmount,0) as TariffNetAmount,     
		 0 as [Vat],ISNULL(R.ChkOutTariffCess,0) as Cess, 
		 ISNULL(R.ChkOutTariffHECess,0) as HCess,0 as  SBCess,ISNULL(R.KKCess,0) as Krishkalyan,  
		 ISNULL(R.ChkOutTariffNetAmount,0) as Total,    
		 R.CheckInDate,R.CheckOutDate,B.ChkOutHdrId, B.invoiceNo, R.GuestName ,ISNULL(R.ChkOutTariffExtraAmount,0) as ExtraMatress,'Tariff' 
		 ,R.ChkOutTariffSC,R.ChkOutTariffST3          
		 FROM WRBHBChechkOutHdr R  
		 JOIN WRBHBBTCSubmission B on r.Id = b.ChkOutHdrId   
		 JOIN WRBHBBTCSubmission_Header h on b.headerid= h.id    
		 JOIN  WRBHBCheckInHdr d on R.ChkInHdrId = d.Id and d.IsActive = 1 and d.IsDeleted = 0  
		 INNER JOIN WRBHBClientManagement j  on b.ClientId = j.id     
		 LEFT OUTER JOIN WRBHBCheckOutServiceHdr CS on R.Id = cs.CheckOutHdrId and CS.IsActive = 1 and cs.IsDeleted = 0   
		 WHERE  R.IsActive = 1 and R.IsDeleted = 0 and b.IsActive=1 AND b.IsDeleted=0 and R.IsActive=1 AND R.IsDeleted=0 and b.HeaderId = @HId   
		 AND CONVERT(date,R.CreatedDate,103) < = CONVERT(date,'15/11/2015',103)  
		 
		 GROUP BY B.ChkOutHdrId, h.ConsolidateNo,B.headerid,B.clientID,R.Property,R.PropertyId, R.NoOfDays,  
		 R.ChkOutTariffAdays,R.ChkOutTariffTotal,R.ChkOutTariffLT,R.ChkOutTariffST2,R.ChkOutTariffCess,R.ChkOutTariffHECess,h.CreatedDate,  
		 R.ChkOutTariffNetAmount, R.CheckInDate,R.CheckOutDate,B.ChkOutHdrId, B.invoiceNo, R.GuestName,R.KKCess,R.ChkOutTariffST1,  
		 R.ChkOutTariffExtraAmount,R.ChkOutTariffSC,R.ChkOutTariffST3 
  
		 --Service
		 INSERT INTO #ConBTC  
  
		 SELECT h.ConsolidateNo,B.headerid,B.clientID,R.Property,R.PropertyId, R.NoOfDays,  
		 0 [TariffPerDay],0 as [TotalTariffAmount],  
		 R.ChkOutTariffLT AS [LT],ISNULL(cs.ChkOutServiceST,0) AS   [ServiTarFood] ,  
		 0 AS [ServiceTax],ISNULL(cs.ChkOutServiceAmtl,0) as [Amount],     
		 ISNULL(CS.ChkOutServiceNetAmount,0) as [ServiceNetAmt],CS.OtherService as [TariffNetAmount],   
		 ISNULL(CS.ChkOutServiceVat,0) as [Vat],0 as Cess,0 as HCess ,ISNULL(cs.Cess,0) as SBCess,   
		 ISNULL(CS.KKCess,0) as Krishkalyan,ISNULL(CS.ChkOutServiceNetAmount,0)   as Total,    
		 R.CheckInDate,R.CheckOutDate,B.ChkOutHdrId, B.invoiceNo, R.GuestName,CS.MiscellaneousAmount as ExtraMatress,'Service'
		 ,0,0    
		 FROM WRBHBChechkOutHdr R  
		 JOIN WRBHBBTCSubmission B ON r.Id = b.ChkOutHdrId   
		 JOIN WRBHBBTCSubmission_Header h ON b.headerid= h.id    
		 JOIN  WRBHBCheckInHdr d ON R.ChkInHdrId = d.Id and d.IsActive = 1 and d.IsDeleted = 0  
		 INNER JOIN WRBHBClientManagement j  ON b.ClientId = j.id     
		 JOIN WRBHBCheckOutServiceHdr CS ON R.Id = cs.CheckOutHdrId and CS.IsActive = 1 and cs.IsDeleted = 0   
		 WHERE  R.IsActive = 1 and R.IsDeleted = 0 and b.IsActive=1 AND b.IsDeleted=0 and R.IsActive=1 AND R.IsDeleted=0 and b.HeaderId = @HId  
		 AND CONVERT(DATE,R.CreatedDate,103) >= CONVERT(DATE,'15/11/2015',103) AND CS.ChkOutServiceNetAmount !=0

		 GROUP BY B.ChkOutHdrId, h.ConsolidateNo,B.headerid,B.clientID,R.Property,R.PropertyId, R.NoOfDays,  
		 R.ChkOutTariffAdays,R.ChkOutTariffTotal,R.ChkOutTariffLT,R.ChkOutTariffST2,cs.ChkOutServiceST,  
		 cs.ChkOutServiceVat,cs.Cess,cs.HECess,R.ChkOutTariffCess,R.ChkOutTariffHECess,h.CreatedDate,  
		 R.ChkOutTariffNetAmount, R.CheckInDate,R.CheckOutDate,B.ChkOutHdrId, B.invoiceNo, R.GuestName,cs.ChkOutServiceAmtl,CS.ChkOutServiceNetAmount,  
		 R.ChkOutTariffExtraAmount,R.ChkOutTariffST1,CS.KKCess,CS.OtherService,CS.MiscellaneousAmount
   

		 INSERT INTO #ConBTC  
  
		 SELECT h.ConsolidateNo,B.headerid,B.clientID,R.Property,R.PropertyId, R.NoOfDays,  
		 0 [TariffPerDay],0 as [TotalTariffAmount],  
		 R.ChkOutTariffLT AS [LT],ISNULL(cs.ChkOutServiceST,0) AS   [ServiTarFood] ,  
		 0 AS [ServiceTax],ISNULL(cs.ChkOutServiceAmtl,0) as [Amount],     
		 ISNULL(CS.ChkOutServiceNetAmount,0) as [ServiceNetAmt],CS.OtherService as [TariffNetAmount],   
		 ISNULL(cs.ChkOutServiceVat,0) as [Vat],ISNULL(cs.Cess,0) as Cess, 
		 ISNULL(cs.HECess,0) as HCess,0 as  SBCess,ISNULL(cs.KKCess,0) as Krishkalyan,  
		 ISNULL(CS.ChkOutServiceNetAmount,0) as Total,    
		 R.CheckInDate,R.CheckOutDate,B.ChkOutHdrId, B.invoiceNo, R.GuestName ,CS.MiscellaneousAmount as ExtraMatress,'Service' 
		 ,0,0
		 FROM WRBHBChechkOutHdr R  
		 JOIN WRBHBBTCSubmission B on r.Id = b.ChkOutHdrId   
		 JOIN WRBHBBTCSubmission_Header h on b.headerid= h.id    
		 JOIN  WRBHBCheckInHdr d on R.ChkInHdrId = d.Id and d.IsActive = 1 and d.IsDeleted = 0  
		 INNER JOIN WRBHBClientManagement j  on b.ClientId = j.id     
		 JOIN WRBHBCheckOutServiceHdr CS on R.Id = cs.CheckOutHdrId and CS.IsActive = 1 and cs.IsDeleted = 0   
		 WHERE  R.IsActive = 1 and R.IsDeleted = 0 and b.IsActive=1 AND b.IsDeleted=0 and R.IsActive=1 AND R.IsDeleted=0 and b.HeaderId = @HId   
		 AND CONVERT(date,R.CreatedDate,103) < = CONVERT(date,'15/11/2015',103)  AND CS.ChkOutServiceNetAmount !=0

		 GROUP BY B.ChkOutHdrId, h.ConsolidateNo,B.headerid,B.clientID,R.Property,R.PropertyId, R.NoOfDays,  
		 R.ChkOutTariffAdays,R.ChkOutTariffTotal,R.ChkOutTariffLT,R.ChkOutTariffST2,cs.ChkOutServiceST,  
		 cs.Cess,cs.HECess,R.ChkOutTariffCess,R.ChkOutTariffHECess,h.CreatedDate,  
		 R.ChkOutTariffNetAmount, R.CheckInDate,R.CheckOutDate,B.ChkOutHdrId, B.invoiceNo, R.GuestName,CS.ChkOutServiceNetAmount,R.KKCess,cs.KKCess,R.ChkOutTariffST1,  
		 R.ChkOutTariffExtraAmount,cs.ChkOutServiceAmtl,cs.ChkOutServiceVat ,CS.OtherService ,CS.MiscellaneousAmount

         SELECT ConsolidateNo  ,headerid , clientID  ,  
		 Property  ,PropertyId ,NoOfDays  ,TariffPerDay  ,TotalTariffAmount ,  
		 LT  ,ServiTarFood , ServiceTax ,[Amount] ,  
		 [ServiceNetAmt] ,TariffNetAmount ,[Vat] ,  
		 Cess ,HCess ,SBCess ,Krishkalyan , 
		 Total ,CheckInDate ,   
		 CheckOutDate ,ChkOutHdrId ,invoiceNo ,GuestName ,ExtraMatress ,
		 SC ,SCST from #ConBTC  WHERE BillType='Tariff'
		 group by ConsolidateNo  ,headerid , clientID  ,  
		 Property  ,PropertyId ,NoOfDays  ,TariffPerDay  ,TotalTariffAmount ,  
		 LT  ,ServiTarFood , ServiceTax ,[Amount] ,  
		 [ServiceNetAmt] ,TariffNetAmount ,[Vat] ,  
		 Cess ,HCess ,SBCess ,Krishkalyan , 
		 Total ,CheckInDate ,   
		 CheckOutDate ,ChkOutHdrId ,invoiceNo ,GuestName ,ExtraMatress ,
		 SC ,SCST

		 select 'Annexe For Tariff' Tariff, isnull(sum(NoOfDays),0) NoOfDaysSum,Isnull(sum(TariffPerDay),0) TariffPerDaySum, Isnull(sum(TotalTariffAmount),0) TotalTariffAmountSum,
		 Isnull(Sum(LT),0) LTSum,Isnull(sum(ServiTarFood),0) ServiTarFoodSum,Isnull(Sum(ServiceTax),0) ServiceTaxSum,Isnull(sum(Amount),0) AmountSum,Isnull(sum(ServiceNetAmt),0) ServiceNetAmtSum,
		 Isnull(sum(TariffNetAmount),0) TariffNetAmountSum,
		 Isnull(sum(vat),0) VatSum,Isnull(sum(cess),0) CessSum,Isnull(sum(Hcess),0) HcessSum,Isnull(sum(SBcess),0) SBcessSum,Isnull(sum(Krishkalyan),0) KrishkalyanSum,
		 Isnull(Sum(Total),0) TotalSum,Isnull(sum(ExtraMatress),0) ExtraMatressSum,
		 Isnull(Sum(SC),0) SCSum, Isnull(Sum(SCST),0) SCSTSum,
		  dbo.fn_NtoWord(ROUND((ISNULL(SUM(Total),0)),0),'','') AS AmtTariffWords
		 
		  from #ConBTC  WHERE BillType='Tariff'  

		   SELECT ConsolidateNo  ,headerid , clientID  ,  
		 Property  ,PropertyId ,NoOfDays  ,TariffPerDay  ,TotalTariffAmount ,  
		 LT  ,ServiTarFood , ServiceTax ,[Amount] ,  
		 [ServiceNetAmt] ,TariffNetAmount ,[Vat] ,  
		 Cess ,HCess ,SBCess ,Krishkalyan , 
		 Total ,CheckInDate ,   
		 CheckOutDate ,ChkOutHdrId ,invoiceNo ,GuestName ,ExtraMatress ,
		 SC ,SCST from #ConBTC  WHERE BillType='Service'
		 group by ConsolidateNo  ,headerid , clientID  ,  
		 Property  ,PropertyId ,NoOfDays  ,TariffPerDay  ,TotalTariffAmount ,  
		 LT  ,ServiTarFood , ServiceTax ,[Amount] ,  
		 [ServiceNetAmt] ,TariffNetAmount ,[Vat] ,  
		 Cess ,HCess ,SBCess ,Krishkalyan , 
		 Total ,CheckInDate ,   
		 CheckOutDate ,ChkOutHdrId ,invoiceNo ,GuestName ,ExtraMatress ,
		 SC ,SCST 


		 SELECT 'Annexe For Service' [Service], Isnull(sum(NoOfDays),0) NoOfDaysSum,Isnull(sum(TariffPerDay),0) TariffPerDaySum,  Isnull(sum(TotalTariffAmount),0) TotalTariffAmountSum,
		  Isnull(Sum(LT),0) LTSum, Isnull(sum(ServiTarFood),0) ServiTarFoodSum, Isnull(Sum(ServiceTax),0) ServiceTaxSum, Isnull(sum(Amount),0) AmountSum, Isnull(sum(ServiceNetAmt),0) ServiceNetAmtSum,
		  Isnull(sum(TariffNetAmount),0) TariffNetAmountSum,
		  Isnull(sum(vat),0) VatSum, Isnull(sum(cess),0) CessSum, Isnull(sum(Hcess),0) HcessSum, Isnull(sum(SBcess),0) SBcessSum, Isnull(sum(Krishkalyan),0) KrishkalyanSum,
		  Isnull(Sum(Total),0) TotalSum, Isnull(sum(ExtraMatress),0) ExtraMatressSum,
		  Isnull(Sum(SC),0) SCSum,  Isnull(Sum(SCST),0) SCSTSum,
		  dbo.fn_NtoWord(ROUND((ISNULL(SUM(Total),0)),0),'','') AS AmtServiceWords 
		  FROM #ConBTC  WHERE BillType='Service' 

		 CREATE TABLE #TempBTC(ConsolidateNo NVARCHAR(100),headerid NVARCHAR(100), clientID BIGINT,ClientName NVARCHAR(100),  
		 CAddress1 NVARCHAR(100), Ccity NVARCHAR(40),  CState NVARCHAR (30),  Pincode NVARCHAR(100),
		 ContactNo NVARCHAR(100),  LuxuryNo NVARCHAR(50),   AnnexeDays BIGINT,
		 Vat decimal(10,2),RestPer decimal(10,2), OtherTax decimal(10,2),LtaxPer decimal(27,2),  
		 AnnexeTariffPerDay DECIMAL(27,2), AnnexeTotalTariffAmount DECIMAL(27,2), AnnexeLT DECIMAL(27,2),AnnexeServiTarFood DECIMAL(27,2), 
		 AnnexeServiceTax DECIMAL (27,2),  AnnexeAmount DECIMAL(27,2),  AnnexeServiceNetAmt DECIMAL(27,2),AnnexeTaiffNetAmount DECIMAL(27,2),
		 AnnexeVat DECIMAL(27,2),AnnexeCess DECIMAL(27,2), AnnexeHCess DECIMAL(27,2), AnnexeSBCess DECIMAL(27,2), AnnexeKrishkalyan DECIMAL(27,2),
		 AnnexeTotal DECIMAL(27,2), AnnexeSC DECIMAL(27,2),AnnexeSCST DECIMAL(27,2), AnnexeExtraMatress Decimal(27,2), AnnexeMiscellaneousAmount Decimal(27,2));   
     
		 INSERT INTO #TempBTC  
  
		 SELECT  h.ConsolidateNo as ConsolidateNo ,B.headerid, B.clientID,J.ClientName as ClientName,
		 J.CAddress1 ,J.Ccity, J.CState, J.CPincode as Pincode , J.ContactNo , t.LuxuryNo, R.NoOfDays as AnnexeDays,  
		  R.VATPer as Vat,  
		 R.RestaurantSTPer as  RestPer,  
		  R.BusinessSupportST as OtherTax,  
		  R.LuxuryTaxPer as LtaxPer,  
		 R.ChkOutTariffAdays as AnnexeTariffPerDay,R.ChkOutTariffTotal as AnnexeTotalTariffAmount,   
		 R.ChkOutTariffLT AS AnnexeLT,  (ISNULL(R.ChkOutTariffST2,0)+ISNULL(cs.ChkOutServiceST,0)) as AnnexeServiTarFood ,  
		 ISNULL(R.ChkOutTariffST1,0) AS AnnexeServiceTax,ISNULL(cs.ChkOutServiceAmtl,0) as AnnexeAmount,   
		 ISNULL(CS.ChkOutServiceNetAmount,0) as AnnexeServiceNetAmt,ISNULL(R.ChkOutTariffNetAmount,0) as AnnexeTaiffNetAmount,  
		 ISNULL(cs.ChkOutServiceVat,0) as AnnexeVat,0 AS AnnexeCess,0 AS AnnexeHCess,ISNULL(R.ChkOutTariffCess,0)+ISNULL(cs.Cess,0) AS AnnexeSBCess,
		 ISNULL(R.KKCess,0) as AnnexeKrishkalyan,ROUND((ISNULL(R.ChkOutTariffNetAmount,0)+ISNULL(CS.ChkOutServiceNetAmount,0)),0)  as AnnexeTotal,
		   R.ChkOutTariffSC as AnnexeSC,R.ChkOutTariffST3  as AnnexeSCST  ,
		   R.ChkOutTariffExtraAmount  as AnnexeExtraMatress, CS.MiscellaneousAmount as AnnexeMiscellaneousAmount

		 FROM WRBHBChechkOutHdr R  
		 JOIN WRBHBBTCSubmission B on r.Id = b.ChkOutHdrId   
		 JOIN WRBHBBTCSubmission_Header h on b.headerid= h.id    
		 JOIN  WRBHBCheckInHdr d on R.ChkInHdrId = d.Id and d.IsActive = 1 and d.IsDeleted = 0  
		 INNER JOIN WRBHBClientManagement j  on b.ClientId = j.id     
		 LEFT OUTER JOIN WRBHBCheckOutServiceHdr CS on R.Id = cs.CheckOutHdrId and CS.IsActive = 1 and cs.IsDeleted = 0    
		 JOIN WRBHBTaxMaster t on t.StateId=17  
		 WHERE   b.IsActive=1 AND b.IsDeleted=0 and R.IsActive=1 AND R.IsDeleted=0 and t.IsActive = 1  AND b.HeaderId = @HId  
		 AND CONVERT(date,R.CreatedDate,103) > = CONVERT(date,'15/11/2015',103)  

		 INSERT INTO #TempBTC  
  
		 SELECT  h.ConsolidateNo as ConsolidateNo ,B.headerid, B.clientID,J.ClientName as ClientName,
		 J.CAddress1 ,J.Ccity, J.CState, J.CPincode as Pincode , J.ContactNo , t.LuxuryNo [LuxuryNo], R.NoOfDays as [AnnexeDays],
		  R.VATPer as Vat,  
		 R.RestaurantSTPer as  RestPer,  
		  R.BusinessSupportST as OtherTax,  
		  R.LuxuryTaxPer as LtaxPer,  
		 R.ChkOutTariffAdays as [AnnexeTariffPerDay],R.ChkOutTariffTotal   as [AnnexeTotalTariffAmount],   
		 R.ChkOutTariffLT AS [AnnexeLT],  (ISNULL(R.ChkOutTariffST2,0)+ISNULL(cs.ChkOutServiceST,0)) as [AnnexeServiTarFood] ,  
		 ISNULL(R.ChkOutTariffST1,0) AS [AnnexeServiceTax], ISNULL(cs.ChkOutServiceAmtl,0) as [AnnexeAmount],   
		 ISNULL(CS.ChkOutServiceNetAmount,0) as [AnnexeServiceNetAmt],ISNULL(R.ChkOutTariffNetAmount,0) as [AnnexeTaiffNetAmount],  
		 ISNULL(cs.ChkOutServiceVat,0) as  [AnnexeVat],
		 ISNULL(R.ChkOutTariffCess,0)+ISNULL(cs.Cess,0) AS [AnnexeCess],
		 ISNULL(R.ChkOutTariffHECess,0)+ISNULL(cs.HECess,0) AS [AnnexeHCess] 
		 ,0 AS AnnexeSBCess,ISNULL(R.KKCess,0) as [AnnexeKrishkalyan],
		 ROUND((ISNULL(R.ChkOutTariffNetAmount,0)+ISNULL(CS.ChkOutServiceNetAmount,0)),0)  as [AnnexeTotal] ,
		  R.ChkOutTariffSC as AnnexeSC,R.ChkOutTariffST3  as AnnexeSCST  ,
		  R.ChkOutTariffExtraAmount as  AnnexeExtraMatress, CS.MiscellaneousAmount as AnnexeMiscellaneousAmount
		
		 FROM WRBHBChechkOutHdr R  
		 JOIN WRBHBBTCSubmission B on r.Id = b.ChkOutHdrId   
		 JOIN WRBHBBTCSubmission_Header h on b.headerid= h.id    
		 JOIN  WRBHBCheckInHdr d on R.ChkInHdrId = d.Id and d.IsActive = 1 and d.IsDeleted = 0  
		 INNER JOIN WRBHBClientManagement j  on b.ClientId = j.id     
		 LEFT OUTER JOIN WRBHBCheckOutServiceHdr CS on R.Id = cs.CheckOutHdrId and CS.IsActive = 1 and cs.IsDeleted = 0    
		 JOIN WRBHBTaxMaster t on t.StateId=17  
		 WHERE   b.IsActive=1 AND b.IsDeleted=0 and R.IsActive=1 AND R.IsDeleted=0 and t.IsActive = 1  AND b.HeaderId = @HId  
		 AND CONVERT(date,R.CreatedDate,103) < = CONVERT(date,'15/11/2015',103)  

		 GROUP BY h.ConsolidateNo ,B.headerid, B.clientID,J.ClientName ,
		 J.CAddress1 ,J.Ccity, J.CState, J.CPincode, J.ContactNo , t.LuxuryNo, R.NoOfDays ,  
		 R.ChkOutTariffAdays ,R.ChkOutTariffTotal ,R.ChkOutTariffLT ,  R.ChkOutTariffST2,cs.ChkOutServiceST ,  
		 R.ChkOutTariffST1,  cs.ChkOutServiceAmtl, CS.ChkOutServiceNetAmount,   
		 R.ChkOutTariffNetAmount,cs.ChkOutServiceVat,h.CreatedDate,R.ChkOutTariffCess,cs.Cess ,R.ChkOutTariffHECess,cs.HECess,     
		 R.KKCess,R.ChkOutTariffNetAmount,CS.ChkOutServiceNetAmount, R.VATPer ,  
		 R.RestaurantSTPer  ,  
		  R.BusinessSupportST  ,  
		  R.LuxuryTaxPer ,
		    R.ChkOutTariffSC,
			R.ChkOutTariffST3,
			 R.ChkOutTariffExtraAmount,CS.MiscellaneousAmount
  
  
		 SELECT CONVERT(VARCHAR(11),GETDATE(),106) AS [Invoice Date],ClientId,ClientName,  
		 ConsolidateNo,CAddress1,Ccity,CState,Pincode as Pincode,ContactNo as [ContactNo] ,LuxuryNo,  
		 @CompanyName as CompanyName,  @PanCardNo as  PanCardNo,'AABCH5874RST001' as ServiceTaxNo,  
		 'Accommodation Service' as Taxablename,'Humming Bird Travel & Stay Pvt Ltd' as [PaymentFavour],  
		 'HSBC Bangalore' as Bank,'071358154001(CA)' as AccNo, 'HSBC0560002' AS IFSCCode ,
		  'VAT @'  +CAST(Vat  AS NVARCHAR)+ '% on Food and Beverages' LabelVATPer,  
		'Service Tax @' + CAST(RestPer AS NVARCHAR) + '% on Food and Beverages' LabelFoodAndBeverages,  
		'Service Tax @' + CAST(OtherTax AS NVARCHAR) +'% on Others' LabelOtherTax, 
		'Service Tax @' + CAST(OtherTax AS NVARCHAR) +'% on Others' LabelSCTax,   
		 'Luxury Tax @'+ CAST(LtaxPer AS NVARCHAR) +'% on Tariff' LabelLuxarytax,  
		'Cess 2%' LabelCess,'HCess 1%' LabelHCess,'Service Tax @ 8.40% On Tariff' LabelServiceTax,  
		 'Swach Bharat Cess @ 0.3% on Tariff' LabelSwachBharat,'KrishKalyan  @ 0.3%' LabelKrishkalyan,  
		 'Service Tax @ 12.00% on service charge' LabelServiceChargeOnSC,
		  Vat, RestPer, OtherTax,LtaxPer,  
		 SUM(AnnexeDays) as SumAnnexeDays,dbo.fn_NtoWord(ROUND((ISNULL(SUM(AnnexeTotal),0)),0),'','') AS AmtWords, 
		 sum(Vat) as SumVat,  
		 sum(RestPer) as SumRestPer,  
		 sum(OtherTax) as SumOtherTax,  
		 sum(AnnexeSC) as SumST,
		 sum(AnnexeSCST) as SumSCST,
		sum(AnnexeExtraMatress) as SumExtraMatress,
		 dbo.fn_NtoWord(ROUND((ISNULL(SUM(AnnexeTaiffNetAmount),0)),0),'','') AS AmtTariffWords,
		 dbo.fn_NtoWord(ROUND((ISNULL(SUM(AnnexeServiceTax),0)),0),'','') AS AmtServiceWords,  
		 SUM(AnnexeServiTarFood) AS SumAnnexeServiTarFood,
		 SUM(AnnexeVat) AS SumAnnexeVat,  
		 SUM(AnnexeTariffPerDay) AS SumAnnexeTariffPerDay,
		 SUM(AnnexeTotalTariffAmount) AS SumAnnexeTotalTariffAmount,  
		 SUM(AnnexeLT) AS SumAnnexeLT,
		 SUM(AnnexeServiceTax) AS SumAnnexeServiceTax,  
		 SUM(AnnexeServiceNetAmt) AS SumAnnexeServiceNetAmt,
		 SUM(AnnexeCess) AS SumAnnexeCess,  
		 SUM(AnnexeHCess) AS SumAnnexeHCess,
		 SUM(AnnexeSBCess) AS SumAnnexeSBCess,  
		 SUM(AnnexeKrishkalyan) AS SumAnnexeKrishkalyan,
		 round(SUM(AnnexeTotal),0) AS SumAnnexeTotal,
		 Sum(AnnexeAmount)  AS SumAnnexeAmount,
		 
		  SUM(AnnexeTaiffNetAmount) AS SumAnnexeTaiffNetAmount,
		  isnull(sum(AnnexeMiscellaneousAmount),0) As SumAnnexeMiscellaneousAmount
	--	AnnexeCess  

		 FROM #TempBTC 
		 GROUP BY HeaderId,ConsolidateNo,clientid,ClientName,CState,CAddress1,ContactNo,Ccity,Pincode,LuxuryNo,Vat,RestPer,OtherTax,LtaxPer --,AnnexeCess 
 --Drop table #TempBTC  

 END

Go



