
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_EXPERIENCE_DETAIL_APP]
	
		 @Row_ID int output
		,@Emp_Tran_ID bigint
		,@Emp_Application_ID int
		,@Cmp_ID int
		,@Employer_Name varchar(100)
		,@Desig_Name varchar(100)
		,@St_Date datetime
		,@End_Date datetime	
		,@tran_type varchar(1)
		,@Login_Id int=0 -- Rathod '18/04/2012'
		,@CTC_Amount numeric(18,0) = 0		--Hiral 17/04/2013
		,@Gross_Salary numeric(18,0) = 0	--Hiral 17/04/2013
		,@Exp_Remarks  nvarchar(500) = ''	--Hiral 17/04/2013
		,@Emp_Branch varchar(100) = ''		-- Added by Ali 01022014 
		,@Emp_Location varchar(100) = ''	-- Added by Ali 01022014 
		,@Manager_Name varchar(100) = ''	-- Added by Ali 01022014 
		,@Mgr_Contact_number nvarchar(50) = ''   -- Added by Ali 01022014 
		,@IndustryType varchar(150) = ''	--added by jimit 21032017
		,@Approved_Emp_ID int=0
		,@Approved_Date datetime = Null
		,@Rpt_Level int
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		declare @Empexp as Float
		select @Empexp = dbo.F_GET_AGE(@St_Date,@End_Date,'Y','M')   --Added by Ramiz on 03/11/2014
		
		If @Empexp = 0
			set @Empexp = NULL
			
		If @CTC_Amount = 0
			Set @CTC_Amount = NULL
		
		If @Gross_Salary = 0
			Set @Gross_Salary = NULL
		
		If @Exp_Remarks = ''
			Set @Exp_Remarks = NULL
		-- Added by rohit For update if Same entry is Inserted on 08-apr-2014	
		if  exists(select row_id from T0065_EMP_EXPERIENCE_DETAIL_APP WITH (NOLOCK)  where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and UPPER(Employer_Name)=UPPER(@Employer_Name) and St_Date=@St_Date and End_Date=@End_Date and UPPER(IndustryType) = UPPER(@IndustryType))
		BEGIN
			select @Row_ID = row_id from T0065_EMP_EXPERIENCE_DETAIL_APP WITH (NOLOCK) where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and UPPER(Employer_Name)=UPPER(@Employer_Name) and St_Date=@St_Date and End_Date=@End_Date and UPPER(IndustryType) = UPPER(@IndustryType)
			set @tran_type='u'
		END
		
		-- Ended by rohit For update if Same entry is Inserted on 08-apr-2014	
		if @tran_type ='i' 
			begin
					select @Row_ID = isnull(max(Row_ID),0) from T0065_EMP_EXPERIENCE_DETAIL_APP WITH (NOLOCK)
					if @Row_ID is null or @Row_ID = 0
						set @Row_ID =1
					else
						set @Row_ID = @Row_ID + 1			
						
					insert into T0065_EMP_EXPERIENCE_DETAIL_APP (
						 Row_ID 
						,Emp_Tran_ID
						,Emp_Application_ID
		                ,Cmp_ID 
		                ,Employer_Name 
		                ,Desig_Name 
		                ,St_Date 
		                ,End_Date
		                ,CTC_Amount
		                ,Gross_Salary
		                ,Exp_Remarks
		                ,Emp_Branch
		                ,Emp_Location
		                ,Manager_Name
		                ,Contact_number
		                ,EmpExp
		                ,IndustryType
		                ,Approved_Emp_ID
						,Approved_Date
						,Rpt_Level
						)
				 values(
						 @Row_ID 
						,@Emp_Tran_ID
						,@Emp_Application_ID
		                ,@Cmp_ID 
		                ,@Employer_Name 
		                ,@Desig_Name 
		                ,@St_Date 
		                ,@End_Date
		                ,@CTC_Amount
		                ,@Gross_Salary
		                ,@Exp_Remarks
		                ,@Emp_Branch
		                ,@Emp_Location
		                ,@Manager_Name
		                ,@Mgr_Contact_number
		                ,@Empexp
		                ,@IndustryType
		                ,@Approved_Emp_ID
						,@Approved_Date
						,@Rpt_Level
						)	
					/*	
					insert into T0065_EMP_EXPERIENCE_DETAIL_APP _Clone(
						 Row_ID 
						,Emp_ID 
		                ,Cmp_ID 
		                ,Employer_Name 
		                ,Desig_Name 
		                ,St_Date 
		                ,End_Date
		                ,System_Date
		                ,Login_Id
		                ,CTC_Amount
		                ,Gross_Salary
		                ,Exp_Remarks
		                ,Emp_Branch
		                ,Emp_Location
		                ,Manager_Name
		         ,Contact_number
		                ,EmpExp
		                ,IndustryType
						)
				 values(
						 @Row_ID 
						,@Emp_ID 
		                ,@Cmp_ID 
		                ,@Employer_Name 
		                ,@Desig_Name 
		                ,@St_Date 
		                ,@End_Date
		                ,GETDATE()
		                ,@Login_Id 
		                ,@CTC_Amount
		                ,@Gross_Salary
		                ,@Exp_Remarks
		                ,@Emp_Branch
		                ,@Emp_Location
		                ,@Manager_Name
		                ,@Mgr_Contact_number
		                ,@Empexp
		                ,@IndustryType
						)	
						*/	
				end 
	else if @tran_type ='u' 
				begin
					UPDATE    T0065_EMP_EXPERIENCE_DETAIL_APP 
					SET			Cmp_ID = @Cmp_ID,
								Employer_Name = @Employer_Name,
								Desig_Name = @Desig_Name, 
								St_Date = @St_Date, End_Date = @End_Date, CTC_Amount = @CTC_Amount,
								Gross_Salary = @Gross_Salary, Exp_Remarks = @Exp_Remarks,
								Emp_Branch = @Emp_Branch,Emp_Location = @Emp_Location
							   ,Manager_Name = @Manager_Name,Contact_number = @Mgr_Contact_number , EmpExp = @Empexp
							   ,IndustryType = @IndustryType
							   ,Approved_Emp_ID=@Approved_Emp_ID
								,Approved_Date=@Approved_Date
								,Rpt_Level=@Rpt_Level
							   			
					where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Row_ID = @Row_ID
			/*		
					insert into T0065_EMP_EXPERIENCE_DETAIL_APP _Clone(
						 Row_ID 
						,Emp_ID 
		                ,Cmp_ID 
		                ,Employer_Name 
		                ,Desig_Name 
		                ,St_Date 
		                ,End_Date
		                ,System_Date
		                ,Login_Id
		                ,CTC_Amount
		                ,Gross_Salary
		                ,Exp_Remarks
		                ,Emp_Branch
		                ,Emp_Location
		                ,Manager_Name
		                ,Contact_number
		                ,EmpExp
		                 ,IndustryType
						)
				 values(
						 @Row_ID 
						,@Emp_ID 
		                ,@Cmp_ID 
		                ,@Employer_Name 
		                ,@Desig_Name 
		                ,@St_Date 
		                ,@End_Date
		                ,GETDATE()
		                ,@Login_Id 
		                ,@CTC_Amount
		                ,@Gross_Salary
		                ,@Exp_Remarks
		                ,@Emp_Branch
		                ,@Emp_Location
		                ,@Manager_Name
		                ,@Mgr_Contact_number
		                ,@Empexp
		                 ,@IndustryType
						)	*/	
					
				end
	else if @tran_type ='d'
					delete  from T0065_EMP_EXPERIENCE_DETAIL_APP where Row_ID = @Row_ID
	RETURN


