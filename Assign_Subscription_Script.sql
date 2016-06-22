/* 
        Author Name : <Naharjun.U>
		Created On 	: <Created Date (25/06/2014)  >
		Section  	: ClientWisePricingModel Help
		Altered By  : Velmurugan V(While deleting add modified by)
		Purpose  	: ClientWisePricingModel Help
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
ALTER PROCEDURE [dbo].[Sp_ClientWisePricingModel_Help]
(
@Action		NVARCHAR(100),
@Str		NVARCHAR(100),
@Id			INT
) 
AS
BEGIN
IF @Action='PAGELOAD'
	BEGIN
		SELECT Name AS label,Id AS data FROM WRBHBTransSubsPriceModel WHERE IsActive=1 AND IsDeleted=0
	END
IF @Action='CLIENTLOAD'
	BEGIN
		SELECT ClientName,Id AS ClientId,CONVERT(nvarchar(100),GETDATE(),103) as DateId
		FROM WRBHBClientManagement 
		WHERE Id NOT IN (SELECT ClientId FROM WRBHBClientwisePricingModel WHERE IsActive=1) AND IsActive=1 AND IsDeleted=0 
		ORDER BY ClientName
	END
IF @Action='LASTCLIENT'	
	BEGIN	
		SELECT CM.ClientName,CPM.ClientId,CPM.Id,
		ISNULL (CONVERT(NVARCHAR(100),EffectivefromDate,103),CONVERT(NVARCHAR(100),GETDATE(),103)) AS FromDate
		,Convert(NVARCHAR(100),EffectiveToDate,103) AS ToDate
		FROM WRBHBClientwisePricingModel CPM
		JOIN WRBHBTransSubsPriceModel PM ON PM.Id=CPM.PricingModelId
		JOIN WRBHBClientManagement CM ON CM.Id=CPM.ClientId
		WHERE CPM.PricingModelId=@Id AND CPM.IsActive=1 AND CPM.IsDeleted=0 AND PM.IsActive=1 and PM.IsDeleted=0
		ORDER BY ClientName
	END
IF @Action='CLIENTDELETE'
	BEGIN
		UPDATE WRBHBClientwisePricingModel SET IsActive=0,IsDeleted=1,ModifiedBy=@Str,ModifiedDate=getdate() WHERE Id=@Id 
	END	
END

Go

 /* 
        Author Name : <NAHARJUN.U>
		Created On 	: <Created Date (19/02/2014)  >
		Section  	: CLIENT MANAGEMENT ADD NEW CLIENT
		Purpose  	: CLIENT UPDATE
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
ALTER PROCEDURE [dbo].[Sp_ClientWisePricingModel_Update]
(
@Id				BIGINT,
@PricingModelId		BIGINT,
@ClientId			BIGINT,
@CreatedBy			INT,
@FromDate			NVARCHAR(100),
@ToDate				NVARCHAR(100)
)
AS 
BEGIN
 IF EXISTS(SELECT NULL FROM WRBHBClientwisePricingModel WHERE PricingmodelId=@PricingModelId AND ClientId=@ClientId
			AND IsActive=1 AND IsDeleted=0)
BEGIN
 UPDATE WRBHBClientwisePricingModel SET PricingModelId=@PricingModelId,ClientId=@ClientId,ModifiedBy=@CreatedBy,
	ModifiedDate=GETDATE(),EffectivefromDate=CONVERT(datetime,@FromDate,103),
	EffectiveToDate=CONVERT(datetime,@ToDate,103) WHERE PricingmodelId=@PricingModelId AND ClientId=@ClientId
	
	SELECT Id,RowId FROM WRBHBClientwisePricingModel WHERE Id=@Id; 

 END
 ELSE
 BEGIN
 INSERT INTO WRBHBClientwisePricingModel(PricingModelId,ClientId,IsActive,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,
			ModifiedDate,RowId,EffectivefromDate,EffectiveToDate)
VALUES (@PricingModelId,@ClientId,1,0,@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),NEWID(),
		CONVERT(datetime,@FromDate,103),CONVERT(datetime,@ToDate,103))
	
	 SELECT Id,RowId FROM WRBHBClientwisePricingModel WHERE Id=@@IDENTITY;
	
END	
END

GO

/* 
        Author Name : <Naharjun.U>
		Created On 	: <Created Date (25/06/2014)  >
		Section  	: ClientWisePricingModel INSERT
		Purpose  	: ClientWisePricingModel INSERT
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
ALTER PROCEDURE [dbo].[Sp_ClientWisePricingModel_Insert]
(
@PricingModelId		BIGINT,
@ClientId			BIGINT,
@CreatedBy			INT,
@FromDate			NVARCHAR(100),
@ToDate				NVARCHAR(100)
) 
AS
BEGIN
IF EXISTS(SELECT NULL FROM WRBHBClientwisePricingModel WHERE PricingmodelId=@PricingModelId AND ClientId=@ClientId
			AND IsActive=1 AND IsDeleted=0)
BEGIN
 UPDATE WRBHBClientwisePricingModel SET PricingModelId=@PricingModelId,ClientId=@ClientId,ModifiedBy=@CreatedBy,
	ModifiedDate=GETDATE(),EffectivefromDate=Convert(datetime,@FromDate),
	EffectiveToDate=CONVERT(datetime,@ToDate,103) WHERE PricingmodelId=@PricingModelId AND ClientId=@ClientId
	
	SELECT Id,RowId FROM WRBHBClientwisePricingModel WHERE PricingmodelId=@PricingModelId AND ClientId=@ClientId; 

 END
 ELSE
 BEGIN
INSERT INTO WRBHBClientwisePricingModel(PricingModelId,ClientId,IsActive,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,
			ModifiedDate,RowId,EffectivefromDate,EffectiveToDate)
VALUES (@PricingModelId,@ClientId,1,0,@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),NEWID(),
CONVERT(datetime,@FromDate,103),CONVERT(datetime,@ToDate,103))
		
 SELECT Id,RowId FROM WRBHBClientwisePricingModel WHERE Id=@@IDENTITY;		
END	
END

GO