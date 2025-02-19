

 ---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[MP0100_CLAIM_APPLICATION]  
 @Claim_App_ID Numeric(18,0)=0,  
 @Cmp_ID numeric(18,0),    
 @Emp_ID numeric(18,0),    
 @Claim_App_Status char(1),    
 @Claim_App_Docs varchar(max),    
 @ClaimDetail XML,
 @Login_ID numeric(18,0),
 @Tran_type char(1),
 @Result varchar(250) output 
AS    

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   
DECLARE @Claim_ID Numeric(18,0)    
DECLARE @Claim_Name varchar(50)    
DECLARE @Kilometer Numeric(18,2)    
DECLARE @Rate Numeric(18,2)    
DECLARE @Amount Numeric(18,2)    
DECLARE @Remarks varchar(MAX)    
DECLARE @Claim_Date datetime    
DECLARE @Claim_App_Date Datetime  
DECLARE @S_Emp_ID numeric(18, 0)  
SET @Claim_App_Date = (Select CAST(GETDATE() AS varchar(11)))  

--SELECT @S_Emp_ID = ISNULL(Emp_id,0) from V0080_Employee_Master where Cmp_ID= @Cmp_ID AND Emp_ID IN (SELECT Emp_Superior FROM T0080_Emp_Master WHERE Emp_id = @Emp_ID)  
SELECT @S_Emp_ID = ISNULL(Emp_Superior,0) FROM V0080_Employee_Master WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
  
BEGIN TRY

	EXEC P0100_CLAIM_APPLICATION @Claim_App_ID = @Claim_App_ID OUTPUT,@Claim_ID = 0 ,@Cmp_ID = @Cmp_ID,@Emp_ID=@Emp_ID, @Claim_App_Date=@Claim_App_Date,@Claim_App_Code='',@Claim_App_Amount=0,@Claim_App_Status=@Claim_App_Status, @Claim_App_Description='',@Claim_App_Docs=@Claim_App_Docs,@tran_type=@tran_type,@S_Emp_ID=@S_Emp_ID,@Submit_Flag=0,@User_Id=@Login_ID,@IP_Address=''
     
	IF @tran_type = 'U'  
		BEGIN  
			DELETE FROM T0110_CLAIM_APPLICATION_DETAIL WHERE Claim_App_ID = @Claim_App_ID  
		END  
	--ELSE  
	--	BEGIN  
	--		SELECT @Claim_App_ID = MAX(Claim_App_ID) FROM T0100_CLAIM_APPLICATION WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND S_Emp_ID = @S_Emp_ID  
	--	END   
  
	SELECT Table1.value('(Claim_ID/text())[1]','numeric(18,0)') AS Claim_ID,
			Table1.value('(Claim_Name/text())[1]','varchar(50)') AS Claim_Name,    
			ISNULL(Table1.value('(Kilometer/text())[1]','numeric(18,2)'),0) AS Kilometer,
			ISNULL(Table1.value('(Rate/text())[1]','numeric(18,2)'),0) AS Rate,
			Table1.value('(Amount/text())[1]','numeric(18,2)') AS Amount,
			Table1.value('(Remarks/text())[1]','varchar(MAX)') AS Remarks,
			CONVERT(datetime , Table1.value('(Date/text())[1]','varchar(11)'),103) AS DATE
		INTO #ClaimTemp FROM @ClaimDetail.nodes('/NewDataSet/Table1') AS Temp(Table1)     
	   
	DECLARE CLAIM_CURSOR CURSOR FAST_FORWARD FOR
	SELECT Claim_ID,Claim_Name,Kilometer,Rate,Amount,Remarks,Date FROM #ClaimTemp    
	OPEN CLAIM_CURSOR    
	FETCH NEXT FROM CLAIM_CURSOR INTO @Claim_ID,@Claim_Name,@Kilometer,@Rate,@Amount,@Remarks,@Claim_Date    
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC P0110_CLAIM_APPLICATION_DETAIL 0,@Cmp_ID=@Cmp_ID,@Claim_App_ID=@Claim_App_ID,@Claim_ID=@Claim_ID,@For_Date=@Claim_Date,@Application_Amount=@Amount,@Description=@Remarks,@Curr_ID=0,@Curr_Rate=@Rate,@Claim_Amount=@Amount,@Tran_Type='I',@Petrol_KM=@Kilometer,@User_Id=@Login_ID,@IP_Address=''
		 
			FETCH NEXT FROM CLAIM_CURSOR INTO @Claim_ID,@Claim_Name,@Kilometer,@Rate,@Amount,@Remarks,@Claim_Date    
		END  
	CLOSE CLAIM_CURSOR         
	DEALLOCATE CLAIM_CURSOR    

	SET @Result = 'Claim Application Done'
	
END TRY
BEGIN CATCH
	SET @Result = ERROR_MESSAGE()
	ROLLBACK 
END CATCH
