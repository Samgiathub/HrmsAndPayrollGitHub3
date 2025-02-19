--EXEC SP_Mobile_HRMS_WebService_Claim_Approval_Final_Update 0,404,149,23216,14843,'2020-04-18 00:00:00','','A','Bulk Approve',8051,'','I',''
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Claim_Approval_Final_Update]
	 @Claim_Apr_ID			NUMERIC(18,0)	OUTPUT
	,@Claim_App_ID			NUMERIC(18,0)
	,@Cmp_ID				NUMERIC(18,0)
	,@Emp_ID				NUMERIC(18,0)
	,@S_Emp_ID				NUMERIC(18,0)
	,@Approval_Date			Datetime
	,@Claim_App_Date		Datetime
	--,@Claim_Apr_By          varchar(20)  
	,@Claim_App_Status		varchar(20)
	,@Claim_Apr_Comments	Varchar(250)
	,@Login_ID				NUMERIC(18,0)
	,@Claim_Details			XML
	,@Tran_Type				Char(1) 	
	,@Result VARCHAR(100) OUTPUT
AS

BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Create_Date As Datetime
	
	Set @Create_Date = GETDATE()
	
	If @S_Emp_ID = 0
		Set @S_Emp_ID = NULL
	
	If UPPER(@Tran_Type) = 'I'
	BEGIN
			--IF Exists(Select 1 From T0115_CLAIM_LEVEL_APPROVAL Where Emp_ID=@Emp_ID 
			--and Claim_App_ID=@Claim_App_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
			--BEGIN
			--	Set @Claim_Apr_ID = 0
			--	Select @Claim_Apr_ID
			--	Return 
			--END
			--SELECT @Claim_Apr_ID = ISNULL(MAX(Tran_ID),0) + 1 From T0115_CLAIM_LEVEL_APPROVAL
			SELECT @Claim_Apr_ID = Isnull(max(Claim_Apr_ID),0) + 1  FROM T0120_Claim_APPROVAL WITH (NOLOCK) 
			 
			UPDATE  T0100_Claim_APPLICATION  
			SET     Claim_App_status = @Claim_App_Status  
	        WHERE   (Claim_App_ID = @Claim_App_ID and Cmp_ID=@Cmp_ID)  
			--INSERT INTO T0115_CLAIM_LEVEL_APPROVAL
			--		(Tran_ID,Claim_App_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Claim_Apr_Status,Claim_Apr_Comments, Login_ID,System_date,Rpt_Level,Claim_Apr_Amount,Claim_Apr_Pending_Amnt,Claim_App_Amount,Curr_ID,Curr_Rate,Claim_App_Total_Amount,Attached_Doc_File,Deduct_from_salary,Claim_ID,for_date,Claim_App_Purpose,Approved_Petrol_Km)
			--VALUES (@Claim_Apr_ID, @Claim_App_ID, @Cmp_ID, @S_Emp_ID, @Emp_ID, @Approval_Date,@Approval_Status, @Approval_Comments, @Login_ID,@Create_Date,@Rpt_Level,0,0,0,NULL,NULL,0,NULL,0,0,GETDATE(),NULL,0)

			--INSERT INTO T0120_CLAIM_APPROVAL (Claim_Apr_ID,Cmp_ID,Claim_App_ID,Emp_ID,Claim_ID,Claim_Apr_Date,Claim_Apr_Code  
			--,Claim_Apr_Amount,Claim_Apr_Comments,Claim_Apr_By,Claim_Apr_Deduct_From_Sal,Claim_Apr_Pending_Amount,Claim_Apr_Status,Claim_App_Date
			--,Claim_App_Amount,Curr_ID,Curr_Rate,Purpose
			--,Claim_App_Total_Amount,S_Emp_ID,Petrol_KM)  
			--VALUES (@Claim_Apr_ID,@Cmp_ID,@Claim_App_ID,@Emp_ID,NULL,GETDATE(),@Claim_Apr_ID  
			--,0.000,@Claim_Apr_Comments,@Claim_Apr_By,0,0.000,@Claim_App_Status,@Claim_App_Date,0.000
			--,0,0.000,NULL,0.000,@S_Emp_ID,0)

			INSERT INTO T0120_CLAIM_APPROVAL (Claim_Apr_ID,Cmp_ID,Claim_App_ID,Emp_ID,Claim_ID,Claim_Apr_Date,Claim_Apr_Code  
			,Claim_Apr_Amount,Claim_Apr_Comments,Claim_Apr_By,Claim_Apr_Deduct_From_Sal,Claim_Apr_Pending_Amount,Claim_Apr_Status,Claim_App_Date
			,Claim_App_Amount,Curr_ID,Curr_Rate,Purpose
			,Claim_App_Total_Amount,S_Emp_ID,Petrol_KM,Is_Mobile_Entry)  
			VALUES (@Claim_Apr_ID,@Cmp_ID,@Claim_App_ID,@Emp_ID,NULL,@Approval_Date,@Claim_Apr_ID  
			,0.000,@Claim_Apr_Comments,'Blank',0,0.000,@Claim_App_Status,@Claim_App_Date,0.000
			,0,0.000,NULL,0.000,@S_Emp_ID,0,1)
			
			IF (@Claim_Details.exist('/NewDataSet/ClaimDetails') = 1)
				BEGIN
					--SELECT CONVERT(DATETIME, Table1.value('(ClaimDate/text())[1]','varchar(20)'),103) AS ClaimDate,
					SELECT 
						ROW_NUMBER() OVER(ORDER BY (SELECT NULL) ) AS Row_No,
						Table1.value('(CLAIM_APP_ID/text())[1]','varchar(20)') AS Claim_App_ID,
						Table1.value('(CMP_ID/text())[1]','numeric(18,0)') AS Cmp_ID,
						@Emp_ID As Emp_ID, 
						@S_Emp_ID as S_Emp_ID,
						Table1.value('(CLAIM_ID/text())[1]','numeric(18,0)') AS CLAIM_ID,
						Table1.value('(FOR_DATE/text())[1]','varchar(20)') AS Claim_Apr_Date,
						Table1.value('0','numeric(18,0)') AS Claim_Apr_code,
						Table1.value('(APPLICATION_AMOUNT/text())[1]','numeric(18,2)') AS Claim_Apr_Amount,
						Table1.value('(Claim_Status/text())[1]','varchar(20)') AS Claim_Status,
						Table1.value('(TOTALAMOUNT/text())[1]','numeric(18,2)') AS Claim_App_Amnt,
						Table1.value('0','numeric(18,0)') AS Curr_ID,
						Table1.value('(CURR_RATE/text())[1]','numeric(18,2)') AS Curr_rate,
						Table1.value('(DESCRIPTION/text())[1]','varchar(20)') AS Purpose,
						Table1.value('(TOTALAMOUNT/text())[1]','numeric(18,2)') AS Claim_App_Total_Amnt,
						Table1.value('(PETROL_KM/text())[1]','numeric(18,2)') AS PETROL_KM,
						@Login_ID as Login_ID,
						Table1.value('(FOR_DATE/text())[1]','varchar(20)') AS For_Date
						INTO #ClaimDetailsTemp FROM @Claim_Details.nodes('/NewDataSet/ClaimDetails') AS Temp(Table1)
				END
			--Select * from #ClaimDetailsTemp

			DECLARE @Counter INT 
			DECLARE @TableCount INT 
			Select @TableCount = Count(1) from #ClaimDetailsTemp
			SET @Counter=1
			
			Declare @Claim_Apr_Dtl_ID numeric(18, 0) = 0
			
			WHILE ( @Counter <= @TableCount)
			BEGIN
				select @Claim_Apr_Dtl_ID = Isnull(max(Claim_Apr_Dtl_ID),0) + 1  From T0130_CLAIM_APPROVAL_DETAIL WITH (NOLOCK)

				--Insert Into T0130_Claim_APPROVAL_DETAIL
				--(Claim_Apr_Dtl_ID,Claim_Apr_ID,Cmp_ID,Emp_ID,Claim_ID,Claim_Apr_date
				--,Claim_App_ID,Claim_Apr_Code
				--,Claim_Apr_Amount,Claim_Status,Claim_App_Amount,Curr_ID,Curr_rate,Purpose,Claim_App_Ttl_Amount,S_Emp_ID,Petrol_KM)
				--values
				--(@Claim_Apr_Dtl_ID,@Claim_Apr_ID,@Cmp_ID,@Emp_ID,@Claim_ID,@Claim_Apr_Date,@Claim_App_ID
				--,@Claim_Apr_Code,@Claim_Apr_Amount,@Claim_App_Status,@Claim_App_Amount,@Curr_ID,@Curr_Rate,@Purpose
				--,@Claim_App_Total_Amount,@S_Emp_ID,@Petrol_KM)

				Insert Into T0130_Claim_APPROVAL_DETAIL  (Claim_Apr_Dtl_ID,Claim_Apr_ID,Cmp_ID,Emp_ID,Claim_ID,Claim_Apr_Date,Claim_App_ID,Claim_Apr_Code,Claim_Apr_Amount
				,Claim_Status,Claim_App_Amount,Curr_ID,Curr_rate,Purpose,Claim_App_Ttl_Amount,S_Emp_ID,Petrol_KM)
				SELECT @Claim_Apr_Dtl_ID,@Claim_Apr_ID,Cmp_ID,Emp_ID,CLAIM_ID,CONVERT(VARCHAR(20), CONVERT(DATEtime, Claim_Apr_Date, 103), 20) as Claim_Apr_Date
				,Claim_App_ID,Claim_Apr_code
				,Claim_Apr_Amount
				,case when Claim_Status = 'Pending' then 'P' When Claim_Status = 'Approved' Then 'A'  else 'R' end as Claim_Status
				,Claim_App_Amnt,Curr_ID,Curr_rate,Purpose,Claim_App_Total_Amnt as Claim_App_Ttl_Amount,S_Emp_ID,PETROL_KM
				FROM #ClaimDetailsTemp WHERE Row_No = @Counter

				SET @Counter  = @Counter  + 1
			END

			SET @Result = 'Claim Approval Detail Final Insert Successfully#True#'+CAST(@Claim_Apr_ID AS varchar(11))
			Select @Result
	END
END

