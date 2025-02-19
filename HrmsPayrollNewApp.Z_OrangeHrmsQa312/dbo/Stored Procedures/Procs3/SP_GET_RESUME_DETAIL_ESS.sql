---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_RESUME_DETAIL_ESS]
	-- @Cmp_ID	    Numeric (18,0)
	@Rec_Post_Id   Numeric (18,0)
	,@key_words		varchar(500)
	,@location		varchar(100)
	,@experiance	varchar(15)
	,@from_date     datetime  
	,@to_date		datetime
	,@age			varchar(15)
	,@status		int  
	,@screendempby	numeric(18,0)=0 --sneha on 19 dec 2014
	,@screening_status numeric(18,0)=0 
	,@Type NUMERIC(18,0)= 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @experiance= '0'
		set @experiance = null
	if @age = '0'
		set @age = null

Declare @Experiance_Yrs as varchar(100)
Declare @sign as varchar(2)
Set @Experiance_Yrs	= @experiance

If not @Experiance_Yrs is null
	begin
		Set @sign = LEFT(@experiance,1)
		Set @experiance = Replace(RIGHT(@Experiance_Yrs,2),@sign,'')
	End	
	
Declare @Search_Age as varchar(15)
Declare @Age_Sign as varchar(2)
Set @Search_Age = @age

If not @Search_Age is null
	begin
		Set @Age_Sign = LEFT(@age,1)
		Set @age = Replace(RIGHT(@Search_Age,2),@Age_Sign,'')
	End	

 if @Rec_Post_Id =0 
	set @Rec_Post_Id=null
 
 if @status=4
  set @status = null
 set nocount on  
 declare @fromdate as datetime
 declare @todate as datetime
 
 if @from_date='01/01/1900 00:00:00'
	set @fromdate = dateadd(yy,-5,cast(getdate() as varchar(11)))
 else
    set @fromdate = @from_date
    
 if @to_date='01/01/1900 00:00:00'
	set @todate = cast(getdate() as varchar(11))
 else
    set @todate = @to_date
  
 declare @Resume_Master table
 (
	resume_id numeric(18,0)
	
 )   
 declare @skill table
 (
	resume_id numeric(18,0)
	,SKill_detail varchar(500)
 ) 
 declare @QUALIFICATION table
 (
	resume_id numeric(18,0)
	,Qual_Name varchar(500)
	,Specialization varchar(100)
	,education_detail varchar(500)
 ) 
  declare @skill_d table
 (
	resume_id numeric(18,0)
  ) 
 declare @key table
 (
	kew_detail varchar(50)
 ) 
 declare @location_data table
 (
	location_detail varchar(50)
 ) 
 
 Insert Into @key(kew_detail)
 select  cast(data  as varchar(50)) from dbo.Split (@key_words,',') 
 --Insert Into @location_data(location_detail)
 --select  cast(data  as varchar(50)) from dbo.Split (@location,',') 
 
	declare @Resume_ID as numeric(18,0)
	declare @Education_detail as varchar(500)
	declare @SKill_name as varchar(500)
	  
	If @sign = '<' or @experiance is null
		Begin
		
			if @Age_Sign = '<' or @age is null
				begin
					
					insert into @Resume_Master(Resume_ID)
					select Resume_ID from t0055_resume_master WITH (NOLOCK)
						where
						-- cmp_id=@cmp_id and 
							  resume_status=isnull(@status,resume_status) and 
							  CONVERT(Datetime,Resume_Posted_date) >= CONVERT(Datetime,@from_date) and CONVERT(Datetime,Resume_Posted_date) <= CONVERT(Datetime,@todate) and
							  isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0) <= isnull(@age,isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0)) and
							  isnull(Rec_Post_Id,0) = isnull(@Rec_Post_Id,isnull(Rec_Post_Id,0)) and
							  isnull(total_exp,0) <= isnull(@experiance,isnull(total_exp,0))
				end
			else if @Age_Sign = '>'
				begin
					insert into @Resume_Master(Resume_ID)
					select Resume_ID from t0055_resume_master WITH (NOLOCK)
						where 
						--cmp_id=@cmp_id and 
							  resume_status=isnull(@status,resume_status) and 
							  CONVERT(Datetime,Resume_Posted_date) >= CONVERT(Datetime,@from_date) and CONVERT(Datetime,Resume_Posted_date) <= CONVERT(Datetime,@todate) and
							  isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0) >= isnull(@age,isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0)) and
							  isnull(Rec_Post_Id,0) = isnull(@Rec_Post_Id,isnull(Rec_Post_Id,0)) and
							  isnull(total_exp,0) <= isnull(@experiance,isnull(total_exp,0))
				end
			else if @Age_Sign = '='
				begin
					
					insert into @Resume_Master(Resume_ID)
					select Resume_ID from t0055_resume_master WITH (NOLOCK)
						where
						-- cmp_id=@cmp_id and 
							  resume_status=isnull(@status,resume_status) and 
							  CONVERT(Datetime,Resume_Posted_date) >= CONVERT(Datetime,@from_date) and CONVERT(Datetime,Resume_Posted_date) <= CONVERT(Datetime,@todate) and
							  isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0) = isnull(@age,isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0)) and
							  isnull(Rec_Post_Id,0) = isnull(@Rec_Post_Id,isnull(Rec_Post_Id,0)) and
							  isnull(total_exp,0) <= isnull(@experiance,isnull(total_exp,0))
				end
			
		End
	Else if @sign = '>' 
		Begin
		
			if @Age_Sign = '<' or @age is null
				begin
					insert into @Resume_Master(Resume_ID)
					select Resume_ID from t0055_resume_master WITH (NOLOCK)
						where 
						--cmp_id=@cmp_id and 
							  resume_status=isnull(@status,resume_status) and 
							  CONVERT(Datetime,Resume_Posted_date) >= CONVERT(Datetime,@from_date) and CONVERT(Datetime,Resume_Posted_date) <= CONVERT(Datetime,@todate) and
							  isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0) <= isnull(@age,isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0)) and
							  isnull(Rec_Post_Id,0) = isnull(@Rec_Post_Id,isnull(Rec_Post_Id,0)) and
							  isnull(total_exp,0) >= isnull(@experiance,isnull(total_exp,0))
				end
			else if @Age_Sign = '>'
				begin
					insert into @Resume_Master(Resume_ID)
					select Resume_ID from t0055_resume_master WITH (NOLOCK)
						where 
						--cmp_id=@cmp_id and 
							  resume_status=isnull(@status,resume_status) and 
							  CONVERT(Datetime,Resume_Posted_date) >= CONVERT(Datetime,@from_date) and CONVERT(Datetime,Resume_Posted_date) <= CONVERT(Datetime,@todate) and
							  isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0) >= isnull(@age,isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0)) and
							  isnull(Rec_Post_Id,0) = isnull(@Rec_Post_Id,isnull(Rec_Post_Id,0)) and
							  isnull(total_exp,0) >= isnull(@experiance,isnull(total_exp,0))
				end
			else if @Age_Sign = '='
				begin
					insert into @Resume_Master(Resume_ID)
					select Resume_ID from t0055_resume_master WITH (NOLOCK)
						where 
						--cmp_id=@cmp_id and 
							  resume_status=isnull(@status,resume_status) and 
							  Resume_Posted_date>=@from_date and Resume_Posted_date<=@todate and
							  isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0) = isnull(@age,isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0)) and
							  isnull(Rec_Post_Id,0) = isnull(@Rec_Post_Id,isnull(Rec_Post_Id,0)) and
							  isnull(total_exp,0) >= isnull(@experiance,isnull(total_exp,0))
				end
		
		End
	Else if @sign = '=' 
		Begin
			
			if @Age_Sign = '<'  or @age is null
				begin
					
					insert into @Resume_Master(Resume_ID)
					select Resume_ID from t0055_resume_master WITH (NOLOCK)
						where 
						--cmp_id=@cmp_id and 
							  resume_status=isnull(@status,resume_status) and 
							  CONVERT(Datetime,Resume_Posted_date) >= CONVERT(Datetime,@from_date) and CONVERT(Datetime,Resume_Posted_date) <= CONVERT(Datetime,@todate) and
							  isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0) <= isnull(@age,isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0)) and
							  isnull(Rec_Post_Id,0) = isnull(@Rec_Post_Id,isnull(Rec_Post_Id,0)) and
							  isnull(total_exp,0) = isnull(@experiance,isnull(total_exp,0))
				end
			else if @Age_Sign = '>'
				begin
					insert into @Resume_Master(Resume_ID)
					select Resume_ID from t0055_resume_master WITH (NOLOCK)
						where 
						--cmp_id=@cmp_id and 
							  resume_status=isnull(@status,resume_status) and 
							  CONVERT(Datetime,Resume_Posted_date) >= CONVERT(Datetime,@from_date) and CONVERT(Datetime,Resume_Posted_date) <= CONVERT(Datetime,@todate) and
							  isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0) >= isnull(@age,isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0)) and
							  isnull(Rec_Post_Id,0) = isnull(@Rec_Post_Id,isnull(Rec_Post_Id,0)) and
							  isnull(total_exp,0) = isnull(@experiance,isnull(total_exp,0))
				end
			else if @Age_Sign = '='
				begin
					insert into @Resume_Master(Resume_ID)
					select Resume_ID from t0055_resume_master WITH (NOLOCK)
						where 
						--cmp_id=@cmp_id and 
							  resume_status=isnull(@status,resume_status) and 
							  CONVERT(Datetime,Resume_Posted_date) >= CONVERT(Datetime,@from_date) and CONVERT(Datetime,Resume_Posted_date) <= CONVERT(Datetime,@todate) and
							  isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0) = isnull(@age,isnull(DATEDIFF(yy,t0055_resume_master.Date_Of_Birth,GETDATE()),0)) and
							  isnull(Rec_Post_Id,0) = isnull(@Rec_Post_Id,isnull(Rec_Post_Id,0)) and
							  isnull(total_exp,0) = isnull(@experiance,isnull(total_exp,0))
				end
			
		End					  
	
	Declare curUser cursor Local for 
	select skill_name,Resume_ID from v0090_HRMS_RESUME_SKILL where resume_id in (select resume_id from @Resume_Master)
	open curUser
	Fetch next from curUser Into @SKill_name,@Resume_ID
	   while @@Fetch_Status = 0
		begin
			if exists (select resume_id from @skill where resume_id=@Resume_ID)
				update @skill set SKill_detail = SKill_detail + ' , ' +@SKill_name where resume_id=@Resume_ID  
				else
				insert into @skill(resume_id,SKill_detail)values(@Resume_ID,@SKill_name)
				Fetch next from curUser Into @SKill_name,@Resume_ID
		end
		Close curUser
		
		
	declare @Qual_Name varchar(50)
	declare @Specialization  varchar(50)
	Declare curUser1 cursor Local for 
	select Qual_Name,Specialization ,Resume_ID  from V0090_HRMS_RESUME_EDU where resume_id in (select resume_id from @Resume_Master)
	open curUser1
	Fetch next from curUser1 Into @Qual_Name,@Specialization,@Resume_ID
	   while @@Fetch_Status = 0
			begin
				set @Education_detail = @Qual_Name + '-' + @Specialization
				if exists (select resume_id from @QUALIFICATION where resume_id=@Resume_ID)
					update @QUALIFICATION set Qual_Name = Qual_Name + ' , ' + @Qual_Name
							,Specialization=@Specialization
							,education_detail = education_detail + ' / ' + @Education_detail
					 where resume_id=@Resume_ID  
				else
					insert into @QUALIFICATION(resume_id,Qual_Name,Specialization)values(@Resume_ID,@Qual_Name,@Specialization)
				Fetch next from curUser1 Into @Qual_Name,@Specialization,@Resume_ID
			End
			Close curUser1	
	
	if @key_words <> ''
	 begin
	 
		declare @kew_detail as varchar(100)
		Declare curUser2 cursor Local for 
			select kew_detail from @key
			open curUser2
			Fetch next from curUser2 Into @kew_detail
			 while @@Fetch_Status = 0
				begin
					
					if exists (select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
													T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id 
													where Q.Resume_ID in (select * from @Resume_Master)
													and (Q.resume_code  like '%' + @kew_detail + '%'))
						Begin
							delete from @Resume_Master where resume_id
								not in(				
								select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
														T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id 
														where Q.Resume_ID in (select * from @Resume_Master)
														and (Q.resume_code  like '%' + @kew_detail + '%')
								)
						end
					else if exists (select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
													T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id 
													where Q.Resume_ID in (select * from @Resume_Master)
													and (PS.Rec_Post_Code  like '%' + @kew_detail + '%'))
							begin
								delete from @Resume_Master where resume_id
									not in(				
									select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
															T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id 
															where Q.Resume_ID in (select * from @Resume_Master)
															and (PS.Rec_Post_Code  like '%' + @kew_detail + '%')
									)
							end	
					else if exists(select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
													T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id 
													where Q.Resume_ID in (select * from @Resume_Master)
													and (Ps.job_title like '%' + @kew_detail + '%'))
							begin
								delete from @Resume_Master where resume_id
									not in(				
									select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
															T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id 
															where  Q.Resume_ID in (select * from @Resume_Master)
															and (Ps.job_title like '%' + @kew_detail + '%')
									)
							end
					else if exists(select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
													T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id LEFT OUTER JOIN      
													(select * from @skill)SK ON SK.Resume_ID=Q.Resume_ID LEFT OUTER JOIN      
													(select * from @QUALIFICATION) ETM ON ETM.Resume_ID=Q.Resume_ID 
													where  Q.Resume_ID in (select * from @Resume_Master)
													and (SK.SKill_detail like '%' + @kew_detail + '%'))
							begin
								delete from @Resume_Master where resume_id
									not in(				
									select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
															T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id LEFT OUTER JOIN      
															(select * from @skill)SK ON SK.Resume_ID=Q.Resume_ID LEFT OUTER JOIN      
															(select * from @QUALIFICATION) ETM ON ETM.Resume_ID=Q.Resume_ID 
															where  Q.Resume_ID in (select * from @Resume_Master)
															and (SK.SKill_detail like '%' + @kew_detail + '%')
									)
							end
					else if exists(select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
													T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id LEFT OUTER JOIN      
													(select * from @skill)SK ON SK.Resume_ID=Q.Resume_ID LEFT OUTER JOIN      
													(select * from @QUALIFICATION) ETM ON ETM.Resume_ID=Q.Resume_ID 
													where  Q.Resume_ID in (select * from @Resume_Master)
													and (ETM.Qual_Name like '%' + @kew_detail + '%'))
							begin
								delete from @Resume_Master where resume_id
									not in(				
									select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
															T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id LEFT OUTER JOIN      
															(select * from @skill)SK ON SK.Resume_ID=Q.Resume_ID LEFT OUTER JOIN      
															(select * from @QUALIFICATION) ETM ON ETM.Resume_ID=Q.Resume_ID 
															where  Q.Resume_ID in (select * from @Resume_Master)
															and (ETM.Qual_Name like '%' + @kew_detail + '%')
									)
							end
					else if exists (select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
													T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id LEFT OUTER JOIN      
													(select * from @skill)SK ON SK.Resume_ID=Q.Resume_ID LEFT OUTER JOIN      
													(select * from @QUALIFICATION) ETM ON ETM.Resume_ID=Q.Resume_ID 
													where Q.Resume_ID in (select * from @Resume_Master)
													and (ETM.Specialization like '%' + @kew_detail + '%'))
							begin
								delete from @Resume_Master where resume_id
									not in(				
									select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
															T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id LEFT OUTER JOIN      
															(select * from @skill)SK ON SK.Resume_ID=Q.Resume_ID LEFT OUTER JOIN      
															(select * from @QUALIFICATION) ETM ON ETM.Resume_ID=Q.Resume_ID 
															where  Q.Resume_ID in (select * from @Resume_Master)
															and (ETM.Specialization like '%' + @kew_detail + '%')
									)
							end
					else 
						begin
							delete from @Resume_Master
						end
										
					Fetch next from curUser2 Into @kew_detail
				End
		Close curUser2
		deallocate curUser2
		
	 end
	 
	 if @location <> ''
	 begin
			
		delete from @Resume_Master where resume_id
			not in(
					select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
							T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id 
							where Q.Resume_ID in (select * from @Resume_Master) and 
							(isnull(Q.Present_City,'') like '%' + @location + '%' or isnull(Q.Present_State,'') like '%' + @location + '%')
				  )
	 end
	 
	 --added by sneha on 19 dec 2014
	 if @screendempby <>0
		begin
			delete from @Resume_Master where resume_id
			not in(
					select Q.Resume_ID from t0055_resume_master Q WITH (NOLOCK) inner join
							T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id 
							where Q.Resume_ID in (select * from @Resume_Master) and 
							Q.Resume_ScreeningBy = @screendempby and q.Resume_ScreeningStatus=1
				  )
		End
	 --added by sneha on 19 dec 2014 end
	 
	 
	  IF @screening_status > 0
		BEGIN 			
					 select isnull(SK.SKill_detail,'#') as SKill_detail,
							isnull(ETM.Qual_Name+':'+ETM.Specialization,'#') as Education_detail,
							isnull(PS.Rec_Post_Code,'#') as job_code,
							Q.Resume_ID,
							Q.Rec_post_ID,
							Ps.job_title,
							q.Resume_Posted_date as posted_date,
							q.emp_first_name + ' ' + isnull(q.emp_last_name,'') as App_Full_name,
							datediff(yy,q.Date_Of_Birth,getdate()) as age,
							isnull(Q.mobile_no,'#') as mobile_no,
							case when Q.gender='M' then 'Male' else 'Female' end as gender,
							isnull(Primary_email,'#') as Primary_email,
							Total_Exp as Experiance_detail,
							case when isnull(Q.Present_City,'') + '>' + isnull(Q.Present_State,'')='>' then '#' else isnull(Q.Present_City,'') + ' > ' + isnull(Q.Present_State,'') end as Location,
							--case when isnull(Resume_name,'#')='' then 'not define' else isnull(Resume_name,'#') end as Resume_name, 
							CASE WHEN isnull(Resume_name,'')<>'' THEN Resume_name
								 WHEN isnull(Resume_name,'')='' and Q.[File_Name] <>'' THEN SUBSTRING(File_Name,CHARINDEX('_', File_Name)+1,LEN(File_Name)) 
								 ELSE 'Not Define' END AS Resume_name, 
							case when Resume_status=0 then 'Pending' when Resume_status=1 then 'Approved' when Resume_status=2 then 'Rejected' else 'Hold' end as status,
							Resume_status,
							file_name ,
							isnull(Resume_code,'R' +  cast(Q.cmp_id as varchar(50)) + ':' + cast(10000 + Q.resume_id as varchar(50))) as  Resume_code ,
							Resume_ScreeningStatus, --added by sneha on 19 dec 2014
							Resume_ScreeningBy,		--added by sneha on 19 dec 2014 
							E.Alpha_Emp_Code+'-'+ E.Emp_Full_Name as Resume_ScreeningByName   --added by sneha on 19 dec 2014
							--into #Resume_Screening
							from t0055_resume_master Q WITH (NOLOCK) left outer join	
									T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id LEFT OUTER JOIN      
									(select * from @skill)SK ON SK.Resume_ID=Q.Resume_ID LEFT OUTER JOIN      
									(select * from @QUALIFICATION) ETM ON ETM.Resume_ID=Q.Resume_ID left join
									T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=Resume_ScreeningBy   --added by sneha on 19 dec 2014
									where Q.resume_id in (select * from @Resume_Master) AND Q.Resume_ScreeningStatus=@screening_status order by q.Resume_Posted_date desc
				
		END
	ELSE
		BEGIN
		print 'm;'
			 select isnull(SK.SKill_detail,'#') as SKill_detail,
							isnull(ETM.Qual_Name+':'+ETM.Specialization,'#') as Education_detail,
							isnull(PS.Rec_Post_Code,'#') as job_code,
							Q.Resume_ID,
							Q.Rec_post_ID,
							Ps.job_title,
							q.Resume_Posted_date as posted_date,
							q.emp_first_name + ' ' + isnull(q.emp_last_name,'') as App_Full_name,
							datediff(yy,q.Date_Of_Birth,getdate()) as age,
							isnull(Q.mobile_no,'#') as mobile_no,
							case when Q.gender='M' then 'Male' else 'Female' end as gender,
							isnull(Primary_email,'#') as Primary_email,
							Total_Exp as Experiance_detail,
							case when isnull(Q.Present_City,'') + '>' + isnull(Q.Present_State,'')='>' then '#' else isnull(Q.Present_City,'') + ' > ' + isnull(Q.Present_State,'') end as Location,
							--case when isnull(Resume_name,'#')='' then 'not define' else isnull(Resume_name,'#') end as Resume_name, 
							CASE WHEN isnull(Resume_name,'')<>'' THEN Resume_name
							WHEN isnull(Resume_name,'')='' and Q.[File_Name] <>'' THEN SUBSTRING(File_Name,CHARINDEX('_', File_Name)+1,LEN(File_Name)) 
							ELSE 'Not Define' END AS Resume_name, 
							case when Resume_status=0 then 'Pending' when Resume_status=1 then 'Approved' when Resume_status=2 then 'Rejected' else 'Hold' end as status,
							Resume_status,
							file_name ,
							isnull(Resume_code,'R' +  cast(Q.cmp_id as varchar(50)) + ':' + cast(10000 + Q.resume_id as varchar(50))) as  Resume_code ,
							Resume_ScreeningStatus, --added by sneha on 19 dec 2014
							Resume_ScreeningBy,		--added by sneha on 19 dec 2014 
							E.Alpha_Emp_Code+'-'+ E.
							Emp_Full_Name as Resume_ScreeningByName,   --added by sneha on 19 dec 2014
							HR.Branch_id,HR.Dept_Id
							into #Resume_Screening
							from t0055_resume_master Q WITH (NOLOCK) left outer join	
									T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id LEFT OUTER JOIN      
									(select * from @skill)SK ON SK.Resume_ID=Q.Resume_ID LEFT OUTER JOIN      
									(select * from @QUALIFICATION) ETM ON ETM.Resume_ID=Q.Resume_ID left join
									T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=Resume_ScreeningBy  LEFT JOIN  --added by sneha on 19 dec 2014
									T0050_HRMS_Recruitment_Request HR WITH (NOLOCK) ON HR.Rec_Req_ID=PS.Rec_Req_ID 
									where Q.resume_id in (select * from @Resume_Master) order by q.Resume_Posted_date desc

				if @type=0
					begin
						select * from #Resume_Screening
					end
				else
					begin 
							IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
							BEGIN
								TRUNCATE TABLE #Notification_Value

								INSERT INTO #Notification_Value
								SELECT COUNT(1) AS ResumeScreeningCnt FROM #Resume_Screening
							END
					end
		END

				
END