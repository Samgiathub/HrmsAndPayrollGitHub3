
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_HRMS_TRAINING_PLAN_IMPORT] 
	 @Cmp_ID	numeric(18, 0) 
	,@Training_Title	varchar(300)	
	,@Training_Scope	varchar(max)
	,@Training_Type		varchar(200)
	,@Training_Provider	varchar(500)
	,@Provider_Type_ID numeric(18,0)--for External or Internal
	,@Training_Location	varchar(500)
	,@Faculty			varchar(500)
	,@Venue				varchar(500)
	,@Training_From_Date datetime
	,@Training_To_Date datetime
	,@From_Time			DATETIME
	,@To_Time			DATETIME
	,@User_Id numeric(18,0) = 0
    ,@IP_Address varchar(30)= ''
    ,@Row_No int
    ,@Log_Status Int = 0 Output    
    ,@GUID Varchar(2000) = ''
AS


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Training_Apr_ID as numeric(18,0)
	declare @Training_Code varchar(50)
	declare @Training_id as numeric(18,0)
	declare @Training_Type_ID as numeric(18,0)
	declare @Training_Provider_id as numeric(18,0)
	declare @ctrEmp_ID as numeric(18,0) = 0
	declare @Training_Institute_LocId as numeric(18,0)
	declare @Training_App_ID as numeric(18,0)
	declare	@emp_id as numeric(18,0)
	declare @Emp_Full_Name as VARCHAR(500)
	declare @Faculty_Name as VARCHAR(500)
	declare @Training_InstituteId as numeric(18,0)
											
	set @Training_Institute_LocId = 0
	set @Training_Provider_id = 0
	set @Training_Type_ID = 0
	set @Training_InstituteId = 0
	set @Faculty_Name = ''
	create table #Emp_Cons 
	(
		Emp_ID	numeric,
		Emp_Full_Name varchar(500)	
	)
	Begin
			If @Training_Title = ''
				BEGIN
					Set @Training_id = 0
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training Title is required',0,'Enter Proper Training Title',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END
			ELSE if exists(select Training_id from T0040_Hrms_Training_master WITH (NOLOCK) where upper(Training_name) = upper(@Training_Title)  and Cmp_ID = @cmp_id)
				select @Training_id = Training_id from T0040_Hrms_Training_master WITH (NOLOCK) where upper(Training_name) = upper(@Training_Title)  and Cmp_ID = @cmp_id
			ELSE
				BEGIN	
					select @Training_id = isnull(max(Training_id),0) + 1  from T0040_Hrms_Training_master WITH (NOLOCK)	
	    			EXEC P0040_HRMS_Training_master @Training_id OUTPUT,@Training_Title,@Training_Scope,@CMP_ID,'i',0
				END
				--select  Training_id from T0040_Hrms_Training_master where upper(Training_name) = upper(@Training_Title)  and Cmp_ID = @cmp_id
	  		If @Training_Scope = ''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training Scope is required',0,'Enter Proper Training Scope',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END
			
			If @Training_Type = ''
				BEGIN
					Set @Training_Type_ID = 0
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training Type is required',0,'Enter Proper Training Type',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END
			ELSE if exists(select Training_Type_ID from T0030_Hrms_Training_Type WITH (NOLOCK) where upper(Training_TypeName) = upper(@Training_Type)  and Cmp_ID = @cmp_id)
				select @Training_Type_ID = Training_Type_ID from T0030_Hrms_Training_Type WITH (NOLOCK) where upper(Training_TypeName) = upper(@Training_Type)  and Cmp_ID = @cmp_id
			ELSE
				BEGIN	
					select @Training_Type_ID = isnull(max(Training_Type_ID),0) + 1  from T0030_Hrms_Training_Type WITH (NOLOCK)	
	    			EXEC P0030_Hrms_Training_Type @Training_Type_ID OUTPUT,@CMP_ID,@Training_Type,'I',NULL,NULL,0,@USER_ID,@IP_ADDRESS
				END
			
			if @Training_Provider <> ''
				BEGIN
					select @Training_Provider_id = Training_Pro_ID from T0050_HRMS_Training_Provider_master WITH (NOLOCK) where upper(Provider_Name) = upper(@Training_Provider)  and Cmp_ID = @cmp_id
					if @Training_Provider_id = 0	
					BEGIN
						Set @Training_Provider_id = 0
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training Provider not exist',0,'Enter Proper Training Provider',GetDate(),'Training Plan',@GUID)						
						Set @Log_Status=1
						Return
					END
					
					--for Training Provider Type(External and Internal)
					if NOT exists(select Training_Pro_ID from T0050_HRMS_Training_Provider_master WITH (NOLOCK) where Provider_TypeId=@Provider_Type_ID  and Cmp_ID = @cmp_id)
						BEGIN	
							Set @Training_Provider_id = 0
							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training Provider Type not exist',0,'Enter Proper Training Provider Type',GetDate(),'Training Plan',@GUID)						
							Set @Log_Status=1
							Return
						END	
						
					if EXISTS(SELECT Training_InstituteId from T0050_Training_Institute_Master WITH (NOLOCK) where upper(Training_InstituteName) = upper(@Training_Provider)  and Cmp_ID = @cmp_id)
						BEGIN
							SELECT @Training_InstituteId=Training_InstituteId from T0050_Training_Institute_Master WITH (NOLOCK) where upper(Training_InstituteName) = upper(@Training_Provider)  and Cmp_ID = @cmp_id
						END
					
					if @Training_Location <> ''
					BEGIN
						select @Training_Institute_LocId = Training_Institute_LocId from T0050_Training_Location_Master WITH (NOLOCK) where upper(Institute_LocationCode) = upper(@Training_Location)  and Cmp_ID = @cmp_id
						if @Training_Institute_LocId = 0
							BEGIN
								Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training Location not exist',0,'Enter Proper Training Location',GetDate(),'Training Plan',@GUID)						
								Set @Log_Status=1
								Return
							END
						if @Training_Institute_LocId > 0
							BEGIN
								IF NOT EXISTS(select 1 from T0050_HRMS_Training_Provider_master WITH (NOLOCK) where Training_Institute_LocId=@Training_Institute_LocId and Cmp_ID = @cmp_id)
									BEGIN	
										Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training Location not mapped with Provider',0,'Enter Proper Training Location',GetDate(),'Training Plan',@GUID)						
										Set @Log_Status=1
										Return
									END
							END
					END
					
					if @Faculty <> ''
						BEGIN
							if @Provider_Type_ID <> 2
								BEGIN
									if @Provider_Type_ID = 1 --for Internal type 
										BEGIN
											Insert Into #Emp_Cons
											SELECT Emp_ID,Alpha_Emp_Code + '- ' + Emp_Full_Name  FROM T0080_EMP_MASTER WITH (NOLOCK)
											WHERE Alpha_Emp_Code IN (select  cast(data  as varchar(30)) from dbo.Split (@Faculty,',') where data <> '')
											and Cmp_ID=@cmp_id
																						
											--select * from #Emp_Cons
											DECLARE FACULTY_DETAILS CURSOR FOR
												select Emp_ID,Emp_Full_Name from #Emp_Cons
											OPEN FACULTY_DETAILS
												fetch next from FACULTY_DETAILS into @emp_id,@Emp_Full_Name
													while @@fetch_status = 0
													Begin
														--select @emp_id,@Training_Provider,@Training_id
														if EXISTS(SELECT 1 FROM T0050_HRMS_Training_Provider_master WITH (NOLOCK) WHERE cmp_id=@cmp_id and Training_id=@Training_id 
																  and Provider_TypeId=1 and Provider_Name=@Training_Provider and
																  CHARINDEX('#' + CAST(@emp_id as VARCHAR(10)) + '#' , '#' + Provider_Emp_Id + '#') > 0)
														BEGIN														
															if @Faculty_Name <> ''
																set @Faculty_Name += ','+ @Emp_Full_Name
															else
																set @Faculty_Name = @Emp_Full_Name
														END																
													fetch next from FACULTY_DETAILS into @emp_id,@Emp_Full_Name
												End
											close FACULTY_DETAILS																																						
										END
									ELSE
										BEGIN  --for external type										
											--select @Training_InstituteId,@Training_id
											Insert Into #Emp_Cons
											SELECT Training_FacultyId,Faculty_Name FROM T0055_Training_Faculty WITH (NOLOCK)
											WHERE cmp_id=@cmp_id and Training_id=@Training_id and Training_InstituteId=@Training_InstituteId 
											and Faculty_Name IN (select  cast(data  as varchar(30)) from dbo.Split (@Faculty,',')) 
											
											--select * from #Emp_Cons
											SELECT @Faculty_Name = COALESCE(@Faculty_Name + ',', '') + Emp_Full_Name
											FROM #Emp_Cons 
											--print @Faculty_Name
										END	
										PRINT @Faculty_Name
										if @Faculty_Name = ''
											BEGIN
												Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training Faculty not exist',0,'Enter Proper Training Faculty',GetDate(),'Training Plan',@GUID)						
												Set @Log_Status=1
												Return
											END
								END	
						END
				END	
				--print @Faculty_Name
			If CONVERT(VARCHAR,@Training_From_Date,103) = '01/01/1900'
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training From Date is required',0,'Enter Proper Training From Date',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END
				
			If CONVERT(VARCHAR,@Training_To_Date,103) = '01/01/1900'
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training To Date is required',0,'Enter Proper Training To Date',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END
				
			If CONVERT(VARCHAR,@From_Time,103) = '01/01/1900'
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training From Time is required',0,'Enter Proper Training From Time',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END
				
			If CONVERT(VARCHAR,@To_Time,103) = '01/01/1900'
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training To Time is required',0,'Enter Proper Training To Time',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END	
			
			if @Training_To_Date < @Training_From_Date 
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training From Date should be smaller than To Date',0,'Enter Proper Training From/To Date',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END	
				
			set  @From_Time  =cast ( cast(@Training_From_Date as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@From_Time AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@From_Time AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
			set  @To_Time  =cast ( cast(@Training_From_Date as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@To_Time AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@To_Time AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
			
			if @To_Time < @From_Time 
				BEGIN				
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training From Time should be smaller than To Time',0,'Enter Proper Training From/To Time',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END	
		
			if @To_Time = @From_Time 
				BEGIN						
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Training From Time and To Time cannot be same',0,'Enter Proper Training From/To Time',GetDate(),'Training Plan',@GUID)						
					Set @Log_Status=1
					Return
				END	
				
			EXEC P0120_HRMS_TRAINING_APPROVAL @Training_Apr_ID=0,@Training_App_ID=0,@Login_ID=@user_id,
			@Training_id=@Training_id,@Training_name=@Training_Title,@Place=@Training_Location,@Faculty=@Faculty_Name,@Training_Pro_ID=@Training_Provider_id,
			@Description=@Training_Scope,@Training_Cost=0,@Training_Cost_per_Emp=0,@Apr_Status=1,@Cmp_ID=@Cmp_ID,@Training_Type=@Training_Type_ID,
			@Training_Leave_Type=0,@Impact_Salary=0,@emp_feedback=1,@sup_feedback=1,@skill_id=0,@Comments='',@branch_id='',@dept_id='',@desig_id='',
			@grd_id='',@Trans_Type='I',@Training_Code='',@flag=0,@User_Id=@user_id,@IP_Address=@IP_Address,@Bond_Month=0,@Attachment='',
			@Manager_FeedbackDays=0,@PublishTraining=0,@VideoURL='',@latitude=0,@longitude=0,@category_id=''
			
			--delete from T0120_HRMS_TRAINING_SCHEDULE where TRAINING_APP_ID
		   select @Training_App_ID = isnull(max(Training_App_ID),0)   from T0100_HRMS_TRAINING_APPLICATION	WITH (NOLOCK)
		   --print @Training_App_ID
		   declare @From_Time_t as VARCHAR(10)
		   declare @To_Time_t as VARCHAR(10)
		   set  @From_Time_t  =RIGHT(convert(varchar(20), @From_Time, 100), 7)--cast(datepart(hh,(CAST(@From_Time AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@From_Time AS SMALLDATETIME))) as varchar(4))
		   set  @To_Time_t  =RIGHT(convert(varchar(20), @To_Time, 100), 7)
		--  10:00 AM
		
		  -- print @From_Time
		    EXEC P0120_HRMS_TRAINING_SCHEDULE_INSERT @SCHEDULE_ID=0,@TRAINING_APP_ID=@Training_App_ID,@FROM_DATE=@Training_From_Date,
			@TO_DATE=@Training_To_Date,@FROM_TIME=@From_Time_t,@TO_TIME=@To_Time_t,@Cmp_Id=@Cmp_Id
		End

RETURN
