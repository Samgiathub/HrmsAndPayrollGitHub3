



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0011_COMPANY_DETAIL]
    @Tran_Id			INT
   ,@Cmp_Id				NUMERIC(18,0)
   ,@Cmp_Name			varchar(100)
   ,@Cmp_Address		varchar(250)
   ,@LoginId			numeric(9)
   ,@Effect_Date		Datetime 
   ,@Uploaded_Header	varchar(1000)
   ,@Uploaded_Footer	varchar(1000)
   ,@System_Date		Datetime 
   ,@Tran_type			Char(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
					    
If @Cmp_Name = ''
	Set @Cmp_Name = ''
	
If @Cmp_Address = ''
    Set @Cmp_Address = ''
    
 IF @Uploaded_Header = ''
	SET @Uploaded_Header = NULL

 IF @Uploaded_Footer = ''
	SET @Uploaded_Footer = NULL
    
   
    --COMMON FUNCTION FOR SELECT COMPANY NAME AND ADDRESS
	DECLARE @OLD_CMPNAME AS VARCHAR(50),@OLD_CMPADDRESS AS VARCHAR(500),@FROM_DATE AS DATETIME = NULL
	SELECT @OLD_CMPNAME=CMP_NAME,@OLD_CMPADDRESS=CMP_ADDRESS,@FROM_DATE=FROM_DATE FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK) 
			WHERE Cmp_Id=@Cmp_Id
			
	
				
	IF @OLD_CMPNAME = ''
	   SET @OLD_CMPNAME =''
	IF @OLD_CMPADDRESS = ''
	   SET @OLD_CMPADDRESS=''  
	--END    
    
    IF @TRAN_TYPE  = 'E'
    BEGIN
		SELECT * from  V0011_COMPANY_DETAIL where cmp_id=@Cmp_Id  ORDER BY  Effect_Date DESC  --added by Ankit - Desc 08082022
		
	END
 	
 IF @TRAN_TYPE  = 'I'
 BEGIN	 
			
			IF(@Effect_Date < @FROM_DATE)
				BEGIN
					RAISERROR('@@ Effect Date must be greater then Company From Date  @@',16,2)  		
					RETURN
				END		
			
			IF EXISTS(SELECT EFFECT_DATE FROM DBO.T0011_COMPANY_DETAIL WITH (NOLOCK) WHERE Effect_Date=@Effect_Date AND CMP_ID=@CMP_ID)
				BEGIN	
					IF EXISTS(SELECT EFFECT_DATE FROM DBO.T0011_COMPANY_DETAIL WITH (NOLOCK) WHERE EFFECT_DATE=@EFFECT_DATE AND CMP_ADDRESS=@CMP_ADDRESS AND CMP_NAME=@CMP_NAME AND CMP_ID=@CMP_ID)
						BEGIN
								UPDATE dbo.T0011_COMPANY_DETAIL 
								SET System_Date=GETDATE(),
									Cmp_Header = ISNULL(@Uploaded_Header , Cmp_Header) , 
									Cmp_Footer = ISNULL(@Uploaded_Footer , Cmp_Footer)
								WHERE Cmp_Id=@Cmp_Id  AND Effect_Date=@Effect_Date
							RETURN
						END
					ELSE
						BEGIN
							UPDATE dbo.T0011_COMPANY_DETAIL 
							SET Cmp_Name=@Cmp_Name,Cmp_Address=@Cmp_Address,LoginId=@LoginId,
								Old_Cmp_Name=@OLD_CMPNAME,Old_Cmp_Address=@OLD_CMPADDRESS,Effect_Date=@Effect_Date,System_Date=GETDATE(),
								Cmp_Header = ISNULL(@Uploaded_Header , Cmp_Header) , Cmp_Footer = ISNULL(@Uploaded_Footer , Cmp_Footer)
							WHERE Cmp_Id=@Cmp_Id  AND Effect_Date=@Effect_Date
						END
					
				END
			ELSE
				BEGIN
					INSERT INTO dbo.T0011_COMPANY_DETAIL
						(Cmp_Id,Cmp_Name,Cmp_Address,LoginId,Effect_Date,Old_Cmp_Name,Old_Cmp_Address,System_Date , Cmp_Header , Cmp_Footer)
					VALUES
						(@Cmp_Id,@Cmp_Name,@Cmp_Address,@LoginId,@Effect_Date,@OLD_CMPNAME,@OLD_CMPADDRESS,GETDATE() ,@Uploaded_Header , @Uploaded_Footer )
				END
				
			--COMPANY MASTER(COMPANY NAME AND ADDRESS UPDATE ACCORDING EFFECTIVE DATE)
				SELECT @Cmp_Name=CMP_NAME,@Cmp_Address=Cmp_Address 
				FROM (	SELECT  QRY1.EFFECT_DATE,CM.CMP_ID, ISNULL(CD.CMP_NAME,CM.CMP_NAME) AS CMP_NAME,CD.Cmp_Address
						FROM         T0010_COMPANY_MASTER CM WITH (NOLOCK)
							LEFT JOIN ( SELECT	MAX(Effect_Date) AS Effect_Date,I1.Cmp_Id
										FROM	T0011_COMPANY_DETAIL I1 WITH (NOLOCK)
										GROUP BY I1.Cmp_Id) QRY1 ON Cm.Cmp_Id=QRY1.Cmp_Id
						LEFT JOIN T0011_COMPANY_DETAIL CD WITH (NOLOCK) ON CD.CMP_ID = CM.CMP_ID and CD.Effect_Date = QRY1.Effect_Date
						WHERE	CM.Cmp_Id=@Cmp_Id
					 ) CmpTable
				
			if(@Cmp_Name IS NOT NULL AND @Cmp_Address IS NOT NULL)
				BEGIN
					UPDATE dbo.T0010_COMPANY_MASTER	 
					SET Cmp_Name=@Cmp_Name,Cmp_Address=@Cmp_Address
					where Cmp_Id=@Cmp_Id
				END
				
			
 END  
 
 IF @TRAN_TYPE  = 'D'
 BEGIN
           IF EXISTS(SELECT EFFECT_DATE FROM DBO.T0011_COMPANY_DETAIL WITH (NOLOCK) WHERE Effect_Date=@Effect_Date)
			BEGIN
			    DECLARE @TOTALCOUNT AS NUMERIC(18,0)
				SELECT @TOTALCOUNT= COUNT(*) FROM T0011_COMPANY_DETAIL WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id
				IF(@TOTALCOUNT>1)
					BEGIN
						DELETE FROM dbo.T0011_COMPANY_DETAIL
						WHERE Tran_Id=@Tran_Id and Effect_Date=@Effect_Date
					   
						---COMPANY MASTER(COMPANY NAME AND ADDRESS UPDATE DUTION DELETE)
						SELECT @Cmp_Name=CMP_NAME,@Cmp_Address=Cmp_Address from (SELECT  QRY1.EFFECT_DATE,CM.CMP_ID, ISNULL(CD.CMP_NAME,CM.CMP_NAME) AS CMP_NAME,CD.Cmp_Address
						FROM         T0010_COMPANY_MASTER CM WITH (NOLOCK)
							LEFT JOIN (SELECT	MAX(Effect_Date) AS Effect_Date,I1.Cmp_Id
									FROM	T0011_COMPANY_DETAIL I1 WITH (NOLOCK)
									GROUP BY I1.Cmp_Id) QRY1 ON Cm.Cmp_Id=QRY1.Cmp_Id
							LEFT JOIN T0011_COMPANY_DETAIL CD WITH (NOLOCK) ON CD.CMP_ID = CM.CMP_ID and CD.Effect_Date = QRY1.Effect_Date
						WHERE	CM.Cmp_Id=@Cmp_Id) CmpTable
						
						if(@Cmp_Name IS NOT NULL AND @Cmp_Address IS NOT NULL)
							BEGIN
								UPDATE dbo.T0010_COMPANY_MASTER	
								SET Cmp_Name=@Cmp_Name,Cmp_Address=@Cmp_Address
								WHERE Cmp_Id=@Cmp_Id
							END
				   END
			END
 
 End


IF @TRAN_TYPE='F'
BEGIN	
     SELECT CMP_NAME,CMP_ADDRESS,EFFECT_DATE
            FROM fn_getCompanyDetail(@Cmp_Id,@Effect_Date)
            
            

END	
	
	
END

