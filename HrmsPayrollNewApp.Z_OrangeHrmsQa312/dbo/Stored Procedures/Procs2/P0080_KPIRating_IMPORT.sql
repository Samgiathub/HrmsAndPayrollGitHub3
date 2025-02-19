
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_KPIRating_IMPORT]
     ---details of main table
	   @Cmp_Id					numeric(18,0)
	  ,@Emp_code				varchar(50)
	  ,@Type					varchar(50)
	  ,@KPIPMS_Name				varchar(50)
	  ,@KPIPMS_FinancialYr		varchar(50)
	  ,@Main_KPI				varchar(250)
	  ,@SubKPI					varchar(250)
	 -- ,@KPIPMS_Status			int=null
	 -- ,@KPIPMS_EmpEarlyComment	varchar(500)=null
	--  ,@KPIPMS_SupEarlyComment	varchar(500)=null
	 -- ,@KPIPMS_FinalRating	    numeric(18,0)=null 
	  ---details of KPI Rating
	  --,@SubKPIId			numeric(18,0)
     -- ,@Metric				varchar(500)
      ,@Rating				numeric(18,0)
      ,@Rating_Manager		numeric(18,0) = null
      ,@Rating_Employee		numeric(18,0) = null 
      ,@Metric_Manager		varchar(500) = null 
      ,@Metric_Employee		varchar(500) = null
      ,@User_Id				numeric(18,0) = 0
	  ,@IP_Address			varchar(30)= '' 
	  ,@Row_No				numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @KPIPMS_ID	  numeric(18,0)
	DECLARE @Emp_ID		  numeric(18,0)
	DECLARE @KPI_RatingID numeric(18,0) 
	DECLARE @AchievedWeight	numeric(18,2) 
	DECLARE @AchievedWeight_Manager numeric(18,2) 
	DECLARE @AchievedWeight_Emp	numeric(18,2) 
	DECLARE @year  varchar(15)
	DECLARE @KPIPMS_Type	numeric(18,0)
	declare @SubKPIId		numeric(18,0)
	declare @rate_id numeric(18,0)
	declare @KPI_Id numeric(18,0)
	declare @EmpKPI_Id numeric(18,0)
	declare @Rating_Mang numeric(18,0)
	declare @Rating1 numeric(18,0)
	declare @rating_emp numeric(18,0)
	declare @Branch_Id varchar(15)
	declare @Branch_Id1 varchar(15)
	
	SET @AchievedWeight = null 
	SET @AchievedWeight_Manager = null
	SET @AchievedWeight_Emp = null
	SET @KPIPMS_Type =0 
	 
	if @Rating = 0
		set @Rating= null
	if @Rating_Manager = 0
		set @Rating_Manager = null
	if @Rating_Employee = 0
		set @Rating_Employee = null

	DECLARE @temp_data table
		(	
			 Emp_Id numeric(18,0)
			,Emp_code	varchar(50)
			,KPI_RatingID  varchar(50)
			,error_messge varchar(500)
		)
		
		if @KPIPMS_FinancialYr=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Financial Year is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Financial Year is required',0,'Enter Financial Year',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end	
		else
			begin
				set @year= LEFT(@KPIPMS_FinancialYr, charindex('-', @KPIPMS_FinancialYr) - 1)
			end			
			
		if @Emp_Code=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Employee Code is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,0,'Employee Code is required',0,'Enter Employee Code',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end	
		else if exists(select emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Emp_Code) and cmp_id=@cmp_id)
			begin
				select @Emp_Id=emp_id,@Branch_Id=Branch_Id from t0080_emp_master WITH (NOLOCK) where alpha_emp_code=@Emp_Code and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,@Emp_code,0,'Employee Code does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code does not Exist in System',0,'Enter Proper Employee Code',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end	
			
		if exists(select isnull(Branch_Id,'')Branch_Id  from T0040_KPI_Master WITH (NOLOCK) where cmp_id=@cmp_id and Branch_Id like ('%' + @Branch_Id + '%') and Upper(KPI)=Upper(@Main_KPI))
			begin	
				if @Main_KPI=''
					begin
						insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge)values(0,'',0,'Main KPI is required')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI is required',0,'Enter Main KPI',GetDate(),'KPI Rating')						
						select * from  @temp_data
						return
					end	
				else if exists(select KPI_Id from t0040_KPI_Master WITH (NOLOCK) where Upper(KPI)=Upper(@Main_KPI) and cmp_id=@cmp_id)
					begin
						select @KPI_Id=KPI_Id from t0040_KPI_Master WITH (NOLOCK) where KPI=@Main_KPI
					end
				else
					begin
						insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,@Emp_Code,0,'Main KPI does not Exist in System')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI does not Exist in System',0,'Enter Proper Main KPI',GetDate(),'KPI Rating')						
						select * from  @temp_data
						return
					end		
				end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(@Emp_Id,@Emp_Code,0,'Main KPI is required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Main KPI is required',0,'Enter Main KPI',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end	
			
		if exists(select EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where FinancialYr=@year and Emp_Id=@Emp_Id and cmp_id=@cmp_id)
			begin
				select @EmpKPI_Id=EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where FinancialYr=@year and Emp_Id=@Emp_Id and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_Code,KPI_RatingID,error_messge) values(0,@Emp_Code,0,'Employee KPI does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee KPI does not Exist in System',0,'Employee KPI does not Exist in System',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end		
			
		if @SubKPI=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,@Emp_code,0,'Sub KPI does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Sub KPI does not Exist in System',0,'Enter Proper Sub KPI',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end
		else
			begin
				select @SubKPIId=SubKPIId from T0080_SubKPI_Master WITH (NOLOCK) where upper(Sub_KPI)=upper(@SubKPI) and Emp_Id=@Emp_Id and KPI_Id=@KPI_Id and cmp_id=@cmp_id and EmpKPI_Id=@EmpKPI_Id
			end	
				
		if @Type='Final'
			begin
				SET @KPIPMS_Type=2
			end	
		else if @Type='Interim'
			begin
				SET @KPIPMS_Type=1
			end						
					
		if @KPIPMS_Type=0
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Enter Proper Appraisal Type')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Enter Proper Appraisal Type',0,'Enter Proper Appraisal Type',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end				
			
		if @KPIPMS_Name=''
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Enter Proper Appraisal Name')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Enter Proper Appraisal Name',0,'Enter Proper Appraisal Name',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end	
		else if exists(select KPIPMS_ID from  T0080_KPIPMS_EVAL WITH (NOLOCK) where upper(KPIPMS_Name)=upper(@KPIPMS_Name) and KPIPMS_FinancialYr=@year and cmp_id=@cmp_id)
			begin
				select @KPIPMS_ID=KPIPMS_ID from T0080_KPIPMS_EVAL WITH (NOLOCK) where upper(KPIPMS_Name)=upper(@KPIPMS_Name) and KPIPMS_FinancialYr=@year  and cmp_id=@cmp_id
			end
		else
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,@Emp_code,0,'Appraisal Name does not Exist in System')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Appraisal Name does not Exist in System',0,'Enter Proper Appraisal Name',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end	
			
		if @Rating is null and @Rating_Manager is null and @Rating_Employee is null
			begin
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,@Emp_code,0,'Rating is Required')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Rating is Required',0,'Rating is Required',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end				
									
		if isnull(@Rating,0) > 0
			begin
			--print @Rating
				select @Rating1=Rate_Id from t0030_hrms_rating_master WITH (NOLOCK) where Rate_Value=@Rating and cmp_id=@cmp_id
				if isnull(@Rating1,0) = 0
					begin
						insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Rating is not exist')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,@Emp_Code,'Rating is not exist',0,'Enter Proper Rating value',GetDate(),'KPI Rating')						
						select * from  @temp_data
						return
					end		
			 end	
		
		if isnull(@Rating_Manager,0) > 0
			begin
				select @Rating_Mang=Rate_Id from t0030_hrms_rating_master WITH (NOLOCK) where Rate_Value=@Rating_Manager and cmp_id=@cmp_id
				print @Rating_Manager
				if isnull(@Rating_Mang,0) = 0
					begin					
						insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Manager Rating is not exist')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,@Emp_Code,'Manager Rating is not exist',0,'Enter Proper Manager Rating value',GetDate(),'KPI Rating')						
						select * from  @temp_data
						return
					end		
			 end	
			 
			  
		if isnull(@Rating_Employee,0) > 0
			begin
				select @rating_emp=Rate_Id from t0030_hrms_rating_master WITH (NOLOCK) where Rate_Value=@Rating_Employee and cmp_id=@cmp_id
				if isnull(@rating_emp,0) = 0
					begin
						insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Employee Rating is not exist')
						Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
						Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Rating is not exist',0,'Enter Proper Employee Rating value',GetDate(),'KPI Rating')						
						select * from  @temp_data
						return
					end		
			 end	
			
		if exists(select * from T0080_KPIRating WITH (NOLOCK) where Emp_ID=@Emp_ID and SubKPIId=@SubKPIId and Rating=@Rate_id and KPIPMS_ID=@KPIPMS_ID)	
			begin		
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Already exist')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Already exist',0,'Already exist',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end
			
		if exists(select * from T0080_KPIRating WITH (NOLOCK) where Emp_ID=@Emp_ID and SubKPIId=@SubKPIId and Rating_Manager=@Rating_Manager and KPIPMS_ID=@KPIPMS_ID)	
			begin		
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Rating of Manager Already exist')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Rating of Manager Already exist',0,'Already exist',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end
			
		if exists(select * from T0080_KPIRating WITH (NOLOCK) where Emp_ID=@Emp_ID and SubKPIId=@SubKPIId and Rating_Employee=@Rating_Employee and KPIPMS_ID=@KPIPMS_ID)	
			begin		
				insert into @temp_data (Emp_Id,Emp_code,KPI_RatingID,error_messge) values(0,'',0,'Rating of Employee Already exist')
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (@Row_No,@Cmp_Id,@Emp_Code,'Rating of Employee Already exist',0,'Already exist',GetDate(),'KPI Rating')						
				select * from  @temp_data
				return
			end
				
	--if not exists(select * from T0080_KPIRating where Emp_ID=@Emp_ID and SubKPIId=@SubKPIId and Rating=@Rate_id and KPIPMS_ID=@KPIPMS_ID)	
		begin							
			select @KPI_RatingID = isnull(max(KPI_RatingID),0) + 1 from T0080_KPIRating WITH (NOLOCK)
			Insert Into T0080_KPIRating
			(
				 KPI_RatingID
				,Cmp_Id
				,KPIPMS_ID
				,SubKPIId
				,Emp_ID
				,Metric
				,Rating
				,AchievedWeight
				,Rating_Manager		 
				,Rating_Employee	
				,Metric_Manager		 
				,Metric_Employee	
				,AchievedWeight_Manager 
				,AchievedWeight_Emp 
			)
			Values
			(
				 @KPI_RatingID
				,@Cmp_Id
				,@KPIPMS_ID
				,@SubKPIId
				,@Emp_ID
				,''
				,@rate_id
				,@Rating
				,@Rating_Manager		
				,@Rating_Employee	
				,@Metric_Manager		 
				,@Metric_Employee	
				,@AchievedWeight_Manager 
				,@AchievedWeight_Emp 
			)
		end
End


