
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_Resume_Import]
 @cmp_id					numeric(18,0)
,@Job_Code					varchar(50)
,@Post_date					datetime =null
,@Initial					varchar(50)
,@Emp_First_Name			varchar(50)
,@Emp_Second_Name			varchar(50)
,@Emp_Last_Name				varchar(50)
,@Date_Of_Birth				datetime  =null
,@Marital_Status			varchar(20)
,@Gender					char(1)
,@Present_Street			nvarchar(250)
,@Present_City				varchar(50)
,@Present_State             varchar(50)
,@Present_Loc				varchar(50)
,@Present_Post_Box          varchar(50)
,@Home_Tel_no				varchar(30)
,@Mobile_No					varchar(30)
,@Primary_email				varchar(100)
,@Other_Email				varchar(100)
,@Non_Technical_Skill	    varchar(500)
,@Cur_CTC					numeric(18,2)
,@Exp_CTC					numeric(18,2)
,@Total_exp			        numeric(18,2)
,@Resume_Name				varchar(50)
,@File_Name                 varchar(100)
,@Blood_group				varchar(20)	
,@Height					varchar(20)	
,@weight					varchar(20)	
,@ByPass					numeric(18,0) =0
,@Source_Type				varchar(max)=''
,@Source_Name				varchar(max)=''
,@FatherName				varchar(max)=''
,@PAN						Nvarchar(Max)=''
,@PAN_Ack					Nvarchar(Max)=''
,@Response_of_Candidate		varchar(100)='' --Mukti(10012019)
,@Response_Comments			varchar(1000)='' --Mukti(10012019)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		declare @Resume_Id numeric(18,0) 
		declare @Resume_code varchar(50)
		declare @Rec_Post_Id numeric(18,0)
		declare @resume_full_name as varchar(500)
		declare @loc_id as numeric(18,0)
		Declare @Current_Date as Datetime
		--Mukti(start) 04122015
		DECLARE @prev_resume_date as datetime 
		DECLARE @resume_date as datetime 
		--Mukti(end) 04122015
		--Added by rohit on 10032014
		declare @Source_Type_id as numeric
		declare @Source_id as numeric
		
		set @Source_Type_id=0
		set @Source_id=0
		--Ended by rohit on 10032014
		
		set @File_Name ='' -- Added by rohit Due to Resume Not Save But Resume File name update in Database for Bma on 23072015.
	
		set @current_Date=getdate()
		
		if @Post_date=''
			set @Post_date=null
		if @Date_Of_Birth=''
			set @Date_Of_Birth=null
		
		if @Marital_Status=''
			set @Marital_Status='Single'
		if @Gender=''
			set @Gender='Male'	
		if @Height=''
			set @Height=0
		if @weight=''
			set @weight=0
		if @Blood_group=''
			set @Blood_group=''
			
		declare @temp_data table
		(
			resume_id	numeric(18,0)
			,resume_code  varchar(50)
			,resume_full_name varchar(500)
			,error_messge varchar(500)
			,File_Name  varchar(500)
			,Status  int
		)
		
		set @resume_full_name = upper(@Emp_First_Name) + ' ' + upper(@Emp_Last_Name)
		
		if upper(@Job_Code)<>''
		 begin
			if exists(select Rec_Post_Id from  T0052_HRMS_Posted_Recruitment WITH (NOLOCK) where cmp_id=@cmp_id and upper(rec_Post_Code)=upper(@Job_Code))
				select @Rec_Post_Id=Rec_Post_Id from  T0052_HRMS_Posted_Recruitment WITH (NOLOCK) where cmp_id=@cmp_id and Rec_Post_Code=upper(@Job_Code)
			else
				begin
					insert into @temp_data (resume_full_name,error_messge,Status) values(@resume_full_name,upper(@Job_Code) + ' : Job Code not Exist in System',0)
					select * from  @temp_data
					return
				end	
		 end	
		 
		 -- Added by rohit on 10032014
		if upper(isnull(@Source_Type,''))<>''
			 begin
				if exists(select Source_Type_id from  T0030_Source_Type_Master WITH (NOLOCK) where upper(Source_Type_Name)=upper(@Source_Type))
					select @Source_Type_id=Source_Type_id from  T0030_Source_Type_Master WITH (NOLOCK) where upper(Source_Type_Name)= upper(@Source_Type)
				else
					begin
						insert into @temp_data (resume_full_name,error_messge,Status) values(@resume_full_name,upper(@Source_Type) + ' : Source Type not Exist in System',0)
						select * from  @temp_data
						return
					end	
			 end	
		
		if upper(isnull(@Source_Name,''))<>''
		 begin
			 if upper(@Source_Type) = 'EMPLOYEE REFERRAL'
				 begin
		 			 if exists(select emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Source_Name) and cmp_id=@cmp_id)
							select @Source_Id= emp_id from  t0080_emp_master WITH (NOLOCK) where upper(Alpha_emp_code)=upper(@Source_Name) and cmp_id=@cmp_id
						else
							begin
								insert into @temp_data (resume_full_name,error_messge,Status) values(@resume_full_name,upper(@Source_Name) + ' : Source not Exist in System',0)
								select * from  @temp_data
								return
							end	
				 end
			 else
				begin
					if exists(select Source_Name from  T0040_Source_Master WITH (NOLOCK) where upper(Source_Name)=upper(@Source_Name))
						select @Source_Id=Source_id from  T0040_Source_Master WITH (NOLOCK) where upper(Source_Name)= upper(@Source_Name)
					else
						begin
							insert into @temp_data (resume_full_name,error_messge,Status) values(@resume_full_name,upper(@Source_Name) + ' : Source not Exist in System',0)
							select * from  @temp_data
							return
						end	
				end
			 end	
	
		 -- Ended by rohit on 10032014
		 
		 
		if exists(select loc_id from  T0001_LOCATION_MASTER WITH (NOLOCK) where upper(Loc_name)=upper(@Present_Loc))
			select @loc_id =loc_id from  T0001_LOCATION_MASTER WITH (NOLOCK) where upper(Loc_name)=upper(@Present_Loc)
		else
			exec P0001_LOCATION_MASTER @LOC_ID output,@Present_Loc
		
	--Mukti(start)04122015
		select @prev_resume_date=system_date from T0055_Resume_Master WITH (NOLOCK) Where cmp_id=@CMP_ID AND Emp_First_Name=@Emp_First_Name  AND Emp_Last_Name=@Emp_Last_Name AND Date_Of_Birth = @Date_Of_Birth
		set @resume_date=DateAdd(Month, 6, @prev_resume_date)
	--Mukti(end)04122015
		
		if exists(select Resume_Id from  T0055_Resume_Master WITH (NOLOCK) where cmp_id=@cmp_id and upper(Emp_First_Name)=upper(@Emp_First_Name) and upper(Emp_Last_Name)=upper(Emp_Last_Name) and Date_Of_Birth=@Date_Of_Birth and getdate()< @resume_date)  --condition added getdate()< @resume_date by Mukti 04122015)
			begin
				select @Resume_Code = isnull(Resume_Code,Resume_id) from  T0055_Resume_Master WITH (NOLOCK) where cmp_id=@cmp_id and upper(Emp_First_Name)=upper(@Emp_First_Name) and upper(Emp_Last_Name)=upper(Emp_Last_Name) and Date_Of_Birth=@Date_Of_Birth
				insert into @temp_data (resume_full_name,error_messge,Status) values(@resume_full_name,upper(@Resume_Code) + ' : Resume Exist in System',0)
				select * from  @temp_data
				return
			end	
		else	
			begin
			-- Added by rohit For Bypass to Corporate HR on 28012014
			if @ByPass=1 
				begin
						if isnull(@Rec_Post_Id,0) <> 0
						begin
							exec  P0055_Resume_Master @Resume_Id output,@cmp_id,@Rec_Post_Id,@Initial,@Emp_First_Name,@Emp_Second_Name,@Emp_Last_Name,@Date_Of_Birth,@Marital_Status,@Gender,@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@loc_id,'','','','',0,@Home_Tel_no,@Mobile_No,@Primary_email,@Other_Email,@Non_Technical_Skill,@Cur_CTC,@Exp_CTC,@Total_exp,@Resume_Name,@File_Name,1,0,'',0,0,0,@Source_Type_id,@Source_id,@FatherName,@PAN,0,0,@PAN_Ack,'','I','','',0,'','','','',@Response_of_Candidate,@Response_Comments	
							if @Resume_Id>0
								begin
									select @Resume_Code = isnull(Resume_Code,Resume_id) from  T0055_Resume_Master WITH (NOLOCK) where cmp_id=@cmp_id and Resume_Id=@Resume_Id
									update T0055_Resume_Master set Resume_Code=@Resume_Code where cmp_id=@cmp_id and Resume_Id=@Resume_Id
									insert into @temp_data (Resume_Id,resume_code,resume_full_name,error_messge,File_Name,Status) values(@Resume_Id,@Resume_Code,@resume_full_name,'Resume saved successfully',@File_Name,1)
									
									declare @p1 int
									set @p1=0
									exec P0055_HRMS_Interview_Schedule @Interview_Schedule_Id=@p1 output,@Interview_Process_detail_ID=0,@Cmp_ID=@cmp_id,@Rec_Post_ID=@Rec_Post_Id,@S_Emp_ID=0,@S_Emp_ID2=0,@S_Emp_ID3=0,@S_Emp_ID4=0,@From_Date=@current_Date,@To_Date=@current_Date,@From_Time='0',@To_Time='0',@Resume_Id=@Resume_Id,@Rating=0,@Rating2=0,@Rating3=0,@Rating4=0,@Schedule_Time='',@Schedule_Date=@current_Date,@Process_Dis_No=0,@status=0,@tran_type='Inse',@Comments='From By pass interview'

									
								 end
							else
								insert into @temp_data (resume_id,resume_full_name,error_messge,Status) values(@Resume_Id,@resume_full_name,upper(@resume_full_name) + ' : Resume not saved successfully',0)
						end
						else
							begin
								insert into @temp_data (resume_id,resume_full_name,error_messge,Status) values(@Resume_Id,@resume_full_name,upper(@resume_full_name) + ' : For ByPass Interview JobCode is Neccessary',0)	
							end
				end
				-- Ended by rohit on 28012014
			else
				begin
				exec  P0055_Resume_Master @Resume_Id output,@cmp_id,@Rec_Post_Id,@Initial,@Emp_First_Name,@Emp_Second_Name,@Emp_Last_Name,@Date_Of_Birth,@Marital_Status,@Gender,@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@loc_id,'','','','',0,@Home_Tel_no,@Mobile_No,@Primary_email,@Other_Email,@Non_Technical_Skill,@Cur_CTC,@Exp_CTC,@Total_exp,@Resume_Name,@File_Name,0,0,'',0,0,0,@Source_Type_id,@Source_id,@FatherName,@PAN,0,0,@PAN_Ack,'','I',
				'','',0,'','','','',@Response_of_Candidate,@Response_Comments	

				if @Resume_Id>0
					begin
						select @Resume_Code = isnull(Resume_Code,Resume_id) from  T0055_Resume_Master WITH (NOLOCK) where cmp_id=@cmp_id and Resume_Id=@Resume_Id
						update T0055_Resume_Master set Resume_Code=@Resume_Code where cmp_id=@cmp_id and Resume_Id=@Resume_Id
						insert into @temp_data (Resume_Id,resume_code,resume_full_name,error_messge,File_Name,Status) values(@Resume_Id,@Resume_Code,@resume_full_name,'Resume saved successfully',@File_Name,1)
					 end
				else
					insert into @temp_data (resume_id,resume_full_name,error_messge,Status) values(@Resume_Id,@resume_full_name,upper(@resume_full_name) + ' : Resume not saved successfully',0)
				end
			 end
		select * from  @temp_data	
			
RETURN




