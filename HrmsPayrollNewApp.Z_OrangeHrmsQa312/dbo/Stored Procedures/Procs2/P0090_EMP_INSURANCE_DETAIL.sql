


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_INSURANCE_DETAIL] 
 @Emp_Ins_Tran_ID NUMERIC OUTPUT
,@Cmp_ID		  NUMERIC
,@Emp_ID		  NUMERIC
,@Ins_Tran_ID     NUMERIC
,@Ins_Cmp_Name    VARCHAR(50)
,@Ins_Policy_No VARCHAR(50)
,@Ins_Taken_Date  DATETIME
,@Ins_Due_Date	  DATETIME
,@Ins_Exp_Date    DATETIME
,@Ins_Amount	  NUMERIC(18,2)
,@Ins_Anual_Amt   NUMERIC(18,2)
,@tran_type       CHAR(1) 
,@Login_ID        NUMERIC=0 --Rathod '19/04/2012'
,@Monthly_Premium  numeric(18,2) = 0 -- Added by Gadriwala Muslim 14072015
,@Deduct_From_Salary tinyint = 0 -- Added by Gadriwala Muslim 14072015
,@Sal_Effective_Date datetime = null -- Added by Gadriwala Muslim 14072015
,@Emp_Dependent_ID	VARCHAR(MAX) = NULL	--Ankit 12102015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Ins_Taken_Date = '01/01/1900'  -- Added by Gadriwala Muslim 25072015
	set @Ins_Taken_Date = null

if @Ins_Due_Date = '01/01/1900'  -- Added by Gadriwala Muslim 25072015
	set @Ins_Due_Date = null

if @Ins_Exp_Date = '01/01/1900' -- Added by Gadriwala Muslim 25072015
	set @Ins_Exp_Date = null
	
if @Sal_Effective_Date = '01/01/1900'  -- Added by Gadriwala Muslim 25072015
	set @Sal_Effective_Date = null
IF @Emp_Dependent_ID = ''
	set @Emp_Dependent_ID = NULL	
	
IF @tran_type = 'I'
		BEGIN
			IF EXISTS(SELECT Emp_Ins_Tran_ID FROM T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Ins_Tran_ID = @Ins_Tran_ID AND Ins_Policy_No = @Ins_Policy_No)
				BEGIN
					SET @Emp_Ins_Tran_ID=0
					RETURN
				END
			SELECT 	@Emp_Ins_Tran_ID = ISNULL(MAX(Emp_Ins_Tran_ID),0)+1 FROM T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK)
			
			INSERT INTO T0090_EMP_INSURANCE_DETAIL (Emp_Ins_Tran_ID,Cmp_ID,Emp_Id,Ins_Tran_ID,Ins_Cmp_name,Ins_Policy_No,Ins_Taken_Date,Ins_Due_Date,Ins_Exp_Date,Ins_Amount,Ins_Anual_Amt,Login_ID,Monthly_Premium,Deduct_From_Salary,Sal_Effective_Date,Emp_Dependent_ID) -- changed by Gadriwala Muslim 14072015
									VALUES(@Emp_Ins_Tran_ID,@Cmp_ID,@Emp_ID,@Ins_Tran_ID,@Ins_Cmp_Name,@Ins_Policy_No,@Ins_Taken_Date,@Ins_Due_Date,@Ins_Exp_Date,@Ins_Amount,@Ins_Anual_Amt,@Login_ID,@Monthly_Premium,@Deduct_From_Salary,@Sal_Effective_Date,@Emp_Dependent_ID)	
									
			INSERT INTO T0090_EMP_INSURANCE_DETAIL_Clone (Emp_Ins_Tran_ID,Cmp_ID,Emp_Id,Ins_Tran_ID,Ins_Cmp_name,Ins_Policy_No,Ins_Taken_Date,Ins_Due_Date,Ins_Exp_Date,Ins_Amount,Ins_Anual_Amt,System_Date,Login_ID,Monthly_Premium,Deduct_From_Salary,Sal_Effective_Date) -- changed by Gadriwala Muslim 14072015
			VALUES(@Emp_Ins_Tran_ID,@Cmp_ID,@Emp_ID,@Ins_Tran_ID,@Ins_Cmp_Name,@Ins_Policy_No,@Ins_Taken_Date,@Ins_Due_Date,@Ins_Exp_Date,@Ins_Amount,@Ins_Anual_Amt,GETDATE(),@Login_ID,@Monthly_Premium,@Deduct_From_Salary,@Sal_Effective_Date)		
		END
ELSE IF @tran_type = 'U'
		BEGIN
			IF EXISTS(SELECT Emp_Ins_Tran_ID FROM T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Ins_Tran_ID = @Ins_Tran_ID AND Ins_Policy_No = @Ins_Policy_No And Ins_Taken_Date = @Ins_Taken_Date And Emp_Ins_Tran_ID <> @Emp_Ins_Tran_ID)
				BEGIN
					SET @Emp_Ins_Tran_ID=0
					RETURN
				END
			UPDATE T0090_EMP_INSURANCE_DETAIL 
			SET 
			Ins_Tran_ID=@Ins_Tran_ID
			,Ins_Cmp_name=@Ins_Cmp_Name
			,Ins_Policy_No=@Ins_Policy_No
			,Ins_Taken_Date=@Ins_Taken_Date
			,Ins_Due_Date=@Ins_Due_Date
			,Ins_Exp_Date=@Ins_Exp_Date
			,Ins_Amount=@Ins_Amount
			,Ins_Anual_Amt=@Ins_Anual_Amt
			,Login_ID=@Login_ID
			,Monthly_Premium = @Monthly_Premium -- Added by Gadriwala Muslim 14072015
			,Deduct_From_Salary = @Deduct_From_Salary -- Added by Gadriwala Muslim 14072015
			,Sal_Effective_Date = @Sal_Effective_Date -- Added by Gadriwala Muslim 14072015
			,Emp_Dependent_ID = @Emp_Dependent_ID
			WHERE Emp_Ins_Tran_ID=@Emp_Ins_Tran_ID	AND Cmp_ID=@Cmp_ID AND Emp_Id=@Emp_ID
			
			INSERT INTO T0090_EMP_INSURANCE_DETAIL_Clone (Emp_Ins_Tran_ID,Cmp_ID,Emp_Id,Ins_Tran_ID,Ins_Cmp_name,Ins_Policy_No,Ins_Taken_Date,Ins_Due_Date,Ins_Exp_Date,Ins_Amount,Ins_Anual_Amt,System_Date,Login_ID,Monthly_Premium,Deduct_From_Salary,Sal_Effective_Date)
			VALUES(@Emp_Ins_Tran_ID,@Cmp_ID,@Emp_ID,@Ins_Tran_ID,@Ins_Cmp_Name,@Ins_Policy_No,@Ins_Taken_Date,@Ins_Due_Date,@Ins_Exp_Date,@Ins_Amount,@Ins_Anual_Amt,GETDATE(),@Login_ID,@Monthly_Premium,@Deduct_From_Salary,@Sal_Effective_Date)						
							
		END
ELSE IF @tran_type = 'D'		
		BEGIN
			DELETE FROM T0090_EMP_INSURANCE_DETAIL WHERE Emp_Ins_Tran_ID = @Emp_Ins_Tran_ID 
		END
			
RETURN




