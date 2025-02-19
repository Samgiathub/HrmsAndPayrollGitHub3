

 
 ---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0501_Lead_Application]
	 @Lead_App_ID NUMERIC(18,0) = 0
	 , @Cmp_ID NUMERIC(18,0) = 0
	 , @Emp_ID NUMERIC(18,0) = 0
	 , @Cust_Name VARCHAR(500) = ''
	 , @Cust_Address VARCHAR(500) = ''
	 , @Cust_City VARCHAR(30) = ''
	 , @Cust_State  VARCHAR(30) = ''
	 , @Cust_Pincode NUMERIC(6,0) = 0
	 , @Cust_Mobile NUMERIC(15,0) = 0
	 , @Cust_Email  VARCHAR(50) = ''
	 , @Cust_PANNO  VARCHAR(30) = ''
	 , @BackOfficeCode  VARCHAR(30) = ''
	 , @Lead_Type_ID NUMERIC(18,0) = 0
	 , @Lead_Product_ID NUMERIC(18,0) = 0
	 , @Visit_Type_ID NUMERIC(18,0) = 0
	 , @Visit_Date DATETIME = '1900-01-01'
	 , @Follow_Up_Date DATETIME = '1900-01-01'
	 , @Lead_Status_ID NUMERIC(18,0) = 0
	 , @Remarks VARCHAR(1000) = ''
	 , @Collected_Amt NUMERIC(18,2) = 0
	 , @Login_ID NUMERIC(18,0) = 0
	 , @TransType CHAR(1)
	 , @Result VARCHAR(256) OUTPUT
AS

BEGIN

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON  
	
	DECLARE @OldFollowDate DATETIME
	DECLARE @HistoryFollowDate VARCHAR(500)
	DECLARE @OldRemarks VARCHAR(1000)
	DECLARE @Reg_HeadID NUMERIC(18,0)
	
	SET @Reg_HeadID = 0
	
	IF EXISTS(SELECT 1 FROM [dbo].fn_getRegionalHead(@Cmp_ID,CAST(@Emp_ID AS VARCHAR(18)),GETDATE()))
		BEGIN
		  SELECT @Reg_HeadID = Emp_ID FROM [dbo].fn_getRegionalHead(@Cmp_ID,CAST(@Emp_ID AS VARCHAR(18)),GETDATE())
		END

	IF @TransType = 'I'
		BEGIN
			IF EXISTS(SELECT 1 FROM T0501_Lead_Application WITH (NOLOCK) WHERE Lead_Product_ID = @Lead_Product_ID AND (Cust_Mobile = @Cust_Mobile OR Cust_Email = @Cust_Email))
				BEGIN
					SET @Result = '0:Lead with Same Product and Mobile No/Email already Exists..!!!'
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0501_Lead_Application WITH (NOLOCK) WHERE Lead_Product_ID = @Lead_Product_ID AND Cust_PANNO = @Cust_PANNO AND ISNULL(@Cust_PANNO,'') <> '')
				BEGIN
					SET @Result = '0:Lead with Same Product and PAN No already Exists..!!!'
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE ((Mobile_No = CAST(@Cust_Mobile AS varchar(30))) OR (Work_Email = @Cust_Email) OR (Other_Email = @Cust_Email)))
				BEGIN
					SET @Result = '0:Mobile No/Email already exists in Payroll..!!!'
					RETURN
				END
			IF EXISTS(SELECT Lead_Status_ID FROM T0500_Lead_Status WITH (NOLOCK) WHERE Lead_Status_ID = @Lead_Status_ID AND UPPER(Lead_Status_Name) = UPPER('Followup') AND Cmp_ID = @Cmp_ID AND @Remarks <> '')
				BEGIN
					SET @Remarks = REPLACE(CONVERT(VARCHAR(20),GETDATE(),105),'-','/') + ' ' + CONVERT(VARCHAR(15),CAST(CONVERT(VARCHAR(20),Getdate(),108) AS TIME),100) + ' ' + @Remarks
				END
				
			SELECT @Lead_App_ID = ISNULL(MAX(Lead_App_ID),0) + 1 FROM T0501_Lead_Application WITH (NOLOCK)
			INSERT INTO T0501_Lead_Application (Lead_App_ID, Cmp_ID, Emp_ID, Cust_Name, Cust_Address, Cust_City, Cust_State
						, Cust_Pincode, Cust_Mobile, Cust_Email, Cust_PANNO, BackOfficeCode, Lead_Type_ID, Lead_Product_ID
						, Visit_Type_ID, Visit_Date, Follow_Up_Date, Lead_Status_ID, Remarks, Collected_Amt, Modify_Date
						, Modify_By,Reg_HeadID)
				VALUES(@Lead_App_ID, @Cmp_ID, @Emp_ID, @Cust_Name, @Cust_Address, @Cust_City, @Cust_State, @Cust_Pincode
					, @Cust_Mobile,@Cust_Email,@Cust_PANNO,@BackOfficeCode,@Lead_Type_ID,@Lead_Product_ID, @Visit_Type_ID
					, @Visit_Date, @Follow_Up_Date, @Lead_Status_ID, @Remarks, @Collected_Amt, GETDATE()
					, @Login_ID,@Reg_HeadID)
								
			SET @Result = CAST(@Lead_App_ID AS VARCHAR) + ':Record Inserted Successfully.!!'
		END
	IF @TransType = 'U'
		BEGIN
			IF EXISTS(SELECT 1 FROM T0501_Lead_Application WITH (NOLOCK) WHERE Lead_App_ID <> @Lead_App_ID AND Lead_Product_ID = @Lead_Product_ID AND (Cust_Mobile = @Cust_Mobile OR Cust_Email = @Cust_Email))
				BEGIN
					SET @Result = '0:Lead with Same Product and Mobile No/Email already Exists..!!!'
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0501_Lead_Application WITH (NOLOCK) WHERE Lead_App_ID <> @Lead_App_ID AND Lead_Product_ID = @Lead_Product_ID AND Cust_PANNO = @Cust_PANNO AND ISNULL(@Cust_PANNO,'') <> '')
				BEGIN
					SET @Result = '0:Lead with Same Product and PAN No already Exists..!!!'
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE ((Mobile_No = CAST(@Cust_Mobile AS VARCHAR(30))) OR (Work_Email = @Cust_Email) OR (Other_Email = @Cust_Email)))
				BEGIN
					SET @Result = '0:Mobile No/Email already exists in Payroll..!!!'
					RETURN
				END
			IF(CONVERT(DATETIME,@Follow_Up_Date,103)<CONVERT(DATETIME,@OldFollowDate,103))
				BEGIN
					SET @Result = '0:New followup date should be after previous follow date.!!'
					RETURN
				END
				
			SELECT @OldFollowDate = Follow_Up_Date,@HistoryFollowDate = ISNULL(Follow_Date_History,''),@OldRemarks = Remarks 
				FROM  T0501_Lead_Application WITH (NOLOCK)
				WHERE Lead_App_ID = @Lead_App_ID
			
			IF (@Remarks <> '' AND ISNULL(REPLACE(@Remarks,@OldRemarks,''),'') <> '' ) 
				BEGIN
					SET @Remarks = REPLACE(@OldRemarks, @Remarks,'') + ' | ' + REPLACE(CONVERT(VARCHAR(20),GETDATE(),105),'-','/') + ' ' + CONVERT(VARCHAR(15),CAST(CONVERT(VARCHAR(20),Getdate(),108) AS TIME),100) + ' ' + REPLACE(@Remarks,@OldRemarks,'')
				END
			IF(CONVERT(DATETIME,@Follow_Up_Date,103)>CONVERT(DATETIME,@OldFollowDate,103))
				BEGIN
					
					IF(@HistoryFollowDate = '')
						SET @HistoryFollowDate = CONVERT(VARCHAR(11),@Follow_Up_Date,103)
					ELSE 
						SET @HistoryFollowDate = @HistoryFollowDate + '#' + CONVERT(VARCHAR(11),@Follow_Up_Date,103)					
				END
				
			UPDATE T0501_Lead_Application SET Lead_App_ID = @Lead_App_ID, Cmp_ID = @Cmp_ID, Cust_Name = @Cust_Name
				, Cust_Address = @Cust_Address, Cust_City = @Cust_City, Cust_State = @Cust_State, Cust_Pincode = @Cust_Pincode
				, Cust_Mobile = @Cust_Mobile, Cust_Email = @Cust_Email, Cust_PANNO = @Cust_PANNO, BackOfficeCode = @BackOfficeCode
				, Lead_Type_ID = @Lead_Type_ID, Lead_Product_ID = @Lead_Product_ID, Visit_Type_ID = @Visit_Type_ID
				, Visit_Date = @Visit_Date, Follow_Up_Date = @Follow_Up_Date, Lead_Status_ID = @Lead_Status_ID, Remarks = @Remarks
				, Collected_Amt = @Collected_Amt, Modify_Date = GETDATE(), Modify_By = @Login_ID
			WHERE Lead_App_ID = @Lead_App_ID
			
			SET @Result = CAST(@Lead_App_ID AS VARCHAR) + ':Record Updated Successfully.!!'
		END 
	IF @TransType = 'E'
		BEGIN
			SELECT * FROM V0501_Lead_Application WHERE Lead_App_ID = @Lead_App_ID
		END
	IF @TransType = 'D'
		BEGIN
			
			DELETE FROM T0501_Lead_Application WHERE Lead_App_ID = @Lead_App_ID
			
			SET @Result = CAST(@Lead_App_ID AS VARCHAR) + ':Record Deleted Successfully.!!'
		END 
	IF @TransType = 'A'
		BEGIN
			DECLARE @AssignDate DATETIME			
			DECLARE @History_EmpID NUMERIC(18,0)
			
			SET @AssignDate = GETDATE()
			SELECT @History_EmpID = ISNULL(Emp_ID,0) FROM T0501_Lead_Application WITH (NOLOCK) WHERE Lead_App_ID = @Lead_App_ID
	
			IF @History_EmpID = @Emp_ID
				BEGIN
					SET @Result = '0:same lead is already assigned to same Employee.!!'
					Return
				END
			EXEC P0501_FollowLead_History @Tran_ID = 0, @Lead_ID = @Lead_App_ID, @Assigned_TO = @History_EmpID, @Assigned_Date = @AssignDate
						,@Login_ID = @Login_ID, @CmpID = @Cmp_ID, @TranType = 'I', @Result = @Result OUTPUT
						
			UPDATE T0501_Lead_Application SET Emp_ID =  @Emp_ID, Assign_TO = @History_EmpID, Assign_Date = @AssignDate
					,Reg_HeadID = @Reg_HeadID
				WHERE Lead_App_ID = @Lead_App_ID						
				
			SET @Result = '1:Lead assigned Successfully.!!'
		END
END




