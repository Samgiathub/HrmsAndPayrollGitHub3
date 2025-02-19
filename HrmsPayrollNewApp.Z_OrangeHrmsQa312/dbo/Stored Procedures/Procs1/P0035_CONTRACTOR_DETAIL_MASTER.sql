
--exec P0035_CONTRACTOR_DETAIL_MASTER 2,'Test Name','Test@gmail.com',1234567891,123456789123,1234567891234,'Test Nature Of work',100,'2020-01-01','2020-02-01',70090,'I'
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0035_CONTRACTOR_DETAIL_MASTER]  
    @BranchID			NUMERIC(18,0)
   ,@ContPersonName		VARCHAR(50)
   ,@ContEmail			VARCHAR(50)
   ,@ContMobileNo		varchar(30)
   ,@ContAadhaar		VARCHAR(30)
   ,@ContGSTNumber		VARCHAR(30)
   ,@NatureOfWork		VARCHAR(500)
   ,@NoOfLabourEmp		NUMERIC(18,0)
   ,@DateOfCommencement	DATETIME
   ,@DateOfTermination	DATETIME
   ,@VendorCode			varchar(20)
   ,@TransType			VARCHAR(1)
   ,@ContDetId			NUMERIC(18,0)
   ,@LICENCE_DOC VArchar(50) = ''
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
   IF @TransType  = 'I'
   BEGIN
		 INSERT INTO dbo.T0035_CONTRACTOR_DETAIL_MASTER  
				(Branch_ID ,Contr_PersonName ,Contr_Email ,Contr_MobileNo ,Contr_Aadhaar ,Contr_GSTNumber ,Nature_Of_Work ,No_Of_LabourEmployed ,Date_Of_Commencement ,Date_Of_Termination ,Vendor_Code,LICENCE_DOC)
		 VALUES (@BranchID ,@ContPersonName	 ,@ContEmail  ,@ContMobileNo  ,@ContAadhaar	 ,@ContGSTNumber  ,@NatureOfWork  ,@NoOfLabourEmp       ,@DateOfCommencement  ,@DateOfTermination  ,@VendorCode,@LICENCE_DOC)
		--select * from  dbo.T0035_CONTRACTOR_DETAIL_MASTER 
   END
   ELSE IF @TransType = 'U'  
   BEGIN	
			--DECLARE @CONTID INT = 0
			--SELECT TOP 1 @CONTID = CONTR_DET_ID  FROM T0035_CONTRACTOR_DETAIL_MASTER WHERE BRANCH_ID = 841 ORDER BY CONTR_DET_ID DESC
			
			--if @CONTID <> 0
			--BEGIN
				UPDATE   dbo.T0035_CONTRACTOR_DETAIL_MASTER  
				SET      Contr_PersonName = @ContPersonName,    
						 Contr_Email=@ContEmail,  
				         Contr_MobileNo = @ContMobileNo,   
				         Contr_Aadhaar = @ContAadhaar,   
				         Contr_GSTNumber = @ContGSTNumber,  
				         Nature_Of_Work = @NatureOfWork,   
				         No_Of_LabourEmployed = @NoOfLabourEmp,
				         Date_Of_Commencement = @DateOfCommencement,
						 Date_Of_Termination = @DateOfTermination,
						 Vendor_Code = @VendorCode
						 ,LICENCE_DOC = @LICENCE_DOC
				WHERE BRANCH_ID = @BRANCHID and CONTR_DET_ID =@ContDetId
			--END
   END 
END  


