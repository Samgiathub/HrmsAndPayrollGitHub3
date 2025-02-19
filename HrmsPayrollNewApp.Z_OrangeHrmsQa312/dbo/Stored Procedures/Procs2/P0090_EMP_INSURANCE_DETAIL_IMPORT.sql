

--P0090_EMP_INSURANCE_DETAIL_IMPORT 2,'JSHOP0001','LIC','UNITD','Jivan Kiran2','01-Jan-2013','01-Jan-2013','01-Dec-2013',100,50
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_INSURANCE_DETAIL_IMPORT]
(
 @Cmp_ID		  NUMERIC
,@Alpha_Emp_Code  VARCHAR(50)
,@Ins_Name    VARCHAR(50)
,@Ins_Cmp_Name    VARCHAR(50)
,@Ins_Policy_No VARCHAR(50)
,@Ins_Taken_Date  DATETIME
,@Ins_Due_Date	  DATETIME
,@Ins_Exp_Date    DATETIME
,@Ins_Amount	  NUMERIC(18,2)
,@Ins_Anual_Amt   NUMERIC(18,2)
,@Monthly_Premium numeric(18,2)  -- Added by Gadriwala Muslim 23072015
,@Deduct_From_Salary varchar(10)-- Added by Gadriwala Muslim 23072015
,@Salary_Effect_Date datetime -- Added by Gadriwala Muslim 23072015
,@Login_ID        NUMERIC=0 
,@Log_Status Int = 0 Output
,@GUID Varchar(2000) = '' --Addded by nilesh patel on 16062016
)

as

BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Ins_Tran_ID		 NUMERIC
Declare @Emp_Ins_Tran_ID     NUMERIC
Declare @Emp_id Numeric
			
If @Deduct_From_Salary = 'Yes'
	set @Deduct_From_Salary = 1	
else
	set @Deduct_From_Salary = 0

if @Ins_Name = ''
	Set @Ins_Name = NULL
	
if @Ins_Cmp_Name = ''
	Set @Ins_Cmp_Name = NULL
	
if @Ins_Policy_No = ''
	Set @Ins_Policy_No = NULL
	
if @Ins_Taken_Date = '01/01/1900'  -- Added by Gadriwala Muslim 25072015
	set @Ins_Taken_Date = null

if @Ins_Due_Date = '01/01/1900'  -- Added by Gadriwala Muslim 25072015
	set @Ins_Due_Date = null

if @Ins_Exp_Date = '01/01/1900' -- Added by Gadriwala Muslim 25072015
	set @Ins_Exp_Date = null
	
if @Salary_Effect_Date = '01/01/1900'  -- Added by Gadriwala Muslim 25072015
	set @Salary_Effect_Date = null
			
			SET @Emp_id = NULL;
			select @Emp_id= emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
			
			if isnull(@EMP_ID,0) = 0 
				Begin
					SET @Log_Status=1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code ,'Employee Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Code',GetDate(),'Insurance Import',@GUID)			
					RETURN
				End
			
			--Added By Jimit 14032019
				If @Ins_Taken_Date > getdate() AND @INS_TAKEN_DATE IS NOT NULL
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Fuuter Date is not allow as Insurance Taken date.','Insurance Name','Enter Valid Insurance Taken date.',GETDATE(),'Insurance Import',@GUID)  
					Return
					END
			--Ended


			if @Ins_Name is NULL
				Begin
					set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Insurance Name',GETDATE(),'Insurance Name cannot be blank.',GetDate(),'Insurance Import',@GUID)
					RETURN
				End 
			
			if @Ins_Policy_No is NULL
				Begin
					set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Policy No',GETDATE(),'Policy No cannot be blank.',GetDate(),'Insurance Import',@GUID)
					RETURN
				End
			
			if @Ins_Cmp_Name is NULL
				Begin
					set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Insurance Company Name',GETDATE(),'Insurance Company Name cannot be blank.',GetDate(),'Insurance Import',@GUID)
					RETURN
				End 
				
			if @Deduct_From_Salary = 1
				Begin
					IF @Salary_Effect_Date is NULL
						Begin
							set @Log_Status = 1
							INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Salay Effected Date Does not Exists',GETDATE(),'Salary Effected Date cannot be blank.',GetDate(),'Insurance Import',@GUID)
							RETURN
						End
				End  
			
			IF Not EXISTS(SELECT Ins_Tran_ID FROM T0040_INSURANCE_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Ins_Name = @Ins_Name)
			Begin
				SELECT @Ins_Tran_ID = isnull(MAX(Ins_Tran_ID),0)+1 from T0040_INSURANCE_MASTER 	WITH (NOLOCK)
				INSERT INTO T0040_INSURANCE_MASTER (Ins_Tran_ID,Cmp_ID,Ins_Name,Ins_Desc) 
				VALUES (@Ins_Tran_ID,@Cmp_ID,@Ins_Name,'')
		    end

			SELECT @Ins_Tran_ID = isnull(Ins_Tran_ID,0) from T0040_INSURANCE_MASTER WITH (NOLOCK)	WHERE Cmp_ID = @Cmp_ID AND Ins_Name = @Ins_Name
	    
			SELECT 	@Emp_Ins_Tran_ID = ISNULL(MAX(Emp_Ins_Tran_ID),0)+1 FROM T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK)
				
			
			
			If Exists(select  Emp_Ins_Tran_ID from T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK) where  Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Ins_Tran_ID=@Ins_Tran_ID and Ins_Cmp_name=@Ins_Cmp_name 
																				and Ins_Policy_No=@Ins_Policy_No and Ins_Taken_Date=@Ins_Taken_Date  
																				and Ins_Due_Date=@Ins_Due_Date	and Ins_Exp_Date=@Ins_Exp_Date    
																				and Ins_Amount=@Ins_Amount	 and Ins_Anual_Amt= @Ins_Anual_Amt and Monthly_Premium =  @Monthly_Premium and Deduct_From_Salary = @Deduct_From_Salary and Sal_Effective_Date = @Salary_Effect_Date )
					Begin 
						set @Emp_Ins_Tran_ID = 0
						Return
					End

			INSERT INTO T0090_EMP_INSURANCE_DETAIL (Emp_Ins_Tran_ID,Cmp_ID,Emp_Id,Ins_Tran_ID,Ins_Cmp_name,Ins_Policy_No,Ins_Taken_Date,Ins_Due_Date,Ins_Exp_Date,Ins_Amount,Ins_Anual_Amt,Login_ID,Monthly_Premium,Deduct_From_Salary,Sal_Effective_Date)
									VALUES(@Emp_Ins_Tran_ID,@Cmp_ID,@Emp_ID,@Ins_Tran_ID,@Ins_Cmp_Name,@Ins_Policy_No,@Ins_Taken_Date,@Ins_Due_Date,@Ins_Exp_Date,@Ins_Amount,@Ins_Anual_Amt,@Login_ID,@Monthly_Premium,@Deduct_From_Salary,@Salary_Effect_Date)	
									
		
END
		

