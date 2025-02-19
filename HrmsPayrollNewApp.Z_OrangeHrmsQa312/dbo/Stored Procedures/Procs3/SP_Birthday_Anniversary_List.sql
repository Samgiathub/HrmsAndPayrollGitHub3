

-- =============================================
-- Author:		<Jaina Desai>
-- Create date: <30-06-2017>
-- Description:	<Birthday-anniversary list>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Birthday_Anniversary_List]
	@Cmp_Id numeric(18,0),
    @pPrivilage_ID  varchar(Max) = 0,
    @pPrivilage_Department varchar(max) = '', 
    @pPrivilage_Vertical varchar(max) = '',  
    @pPrivilage_Sub_Vertical varchar(max) = '',
    @Emp_Login_Id numeric(18,0) = 0 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	IF	@pPrivilage_ID = '' or @pPrivilage_ID = '0'
		set @pPrivilage_ID = NULL
	
	IF @pPrivilage_Vertical = '' or @pPrivilage_Vertical = '0'
		set @pPrivilage_Vertical = NULL
			
	IF @pPrivilage_Sub_Vertical = '' or @pPrivilage_Sub_Vertical='0'
		set @pPrivilage_Sub_Vertical = NULL
		
	IF @pPrivilage_Department = '' or @pPrivilage_Department='0'
		set @pPrivilage_Department = NULL
		
	if @pPrivilage_ID is null
		Begin	
			select   @pPrivilage_ID = COALESCE(@pPrivilage_ID + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			set @pPrivilage_ID = @pPrivilage_ID + '#0'
		End
		
		if @pPrivilage_Vertical is null
		Begin	
			select   @pPrivilage_Vertical = COALESCE(@pPrivilage_Vertical + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			
			If @pPrivilage_Vertical IS NULL
				set @pPrivilage_Vertical = '0';
			else
				set @pPrivilage_Vertical = @pPrivilage_Vertical + '#0'		
		End
		if @pPrivilage_Sub_Vertical is null
		Begin	
			select   @pPrivilage_Sub_Vertical = COALESCE(@pPrivilage_Sub_Vertical + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			
			If @pPrivilage_Sub_Vertical IS NULL
				set @pPrivilage_Sub_Vertical = '0';
			else
				set @pPrivilage_Sub_Vertical = @pPrivilage_Sub_Vertical + '#0'
		End
		IF @pPrivilage_Department is null
		Begin
			select   @pPrivilage_Department = COALESCE(@pPrivilage_Department + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
			
			if @pPrivilage_Department is null
				set @pPrivilage_Department = '0';
			else
				set @pPrivilage_Department = @pPrivilage_Department + '#0'
		End
		
		CREATE TABLE #Birthday 
		(
			Emp_Full_Name varchar(max),     --modified jimit 02022016  
			Date_Of_birth datetime,
			Month_Name varchar(20),			--modified jimit 02022016 due to error when size is 10 for month name (2-FEBRUARY) contains 11 charactrer
			Branch_ID Numeric,
			Branch_Name Varchar(100),
			Image_Name Varchar(100), -- Prakash Patel 25072014
			Row_Id numeric,
			Sorting_No numeric, --Added by Ramiz 30/09/2015
			Alpha_Emp_Code Varchar(100),--Mukti 08012016
			Designation_Name Varchar(100),--Mukti 08012016
			Department_Name Varchar(100),--Mukti 08012016
			Emp_Id Numeric,--Mukti 08012016
			Date_Of_Join datetime, --Mukti 05022016
			Total_Completed_Years int, --Mukti 05022016
			Cmp_Id numeric,
			Reminder_Type varchar(250),
			Company_Name varchar(500),
			Today_Date varchar(100),
			Is_Like numeric,
			Is_Comment numeric,
			Emp_Login_Id numeric(18,0)
			
			
		)
		
		create table #Emp_Like_Comment
		(
			Emp_Id numeric,
			Reminder_Type varchar(150),
			For_Date datetime,
			Emp_Like_Count numeric default 0,
			Like_flag numeric,
			Emp_Cmt_Count numeric default 0
		)
		
		
		Declare @From_Date DateTime
	    Declare @To_Date DateTime
	    Declare @display_cmp_name as Varchar(100)
	    Declare @display_cmp_id as Numeric(18,0)
	    DECLARE @Todays_date as varchar(20)  --Mukti 11012016
	    DECLARE @Setting_Value as INT
	    declare @Display_Actual_Birthdate as tinyint --Added by Sumit on 15122016
	    
	    set @Setting_Value=0
	    Select @Setting_Value=Setting_Value from T0040_SETTING WITH (NOLOCK) where Setting_Name='Show Work Anniversary Reminder on Dashboard' and cmp_ID=@Cmp_ID 
	    
	    set @From_Date = GETDATE() + 1
	    set @To_Date=   GETDATE() + 5
	    
	      Declare @show_grpcmp_birthday as Numeric(18,0)
	     
	    select @show_grpcmp_birthday = isnull(Setting_Value , 0)  from T0040_SETTING WITH (NOLOCK) where Setting_Name = 'Show Birthday Reminder Group Company wise' and Cmp_ID = @Cmp_ID
	    
	    select @Display_Actual_Birthdate=isnull(Setting_Value , 0)  from T0040_SETTING WITH (NOLOCK) where Setting_Name = 'Display Actual Birth Date' and Cmp_ID = @Cmp_ID
	    
	    IF (ISNULL(@pPrivilage_ID,'0')) <> '0'	 	 	
	    BEGIN		--Admin/ESS Side							
			Declare Cur_Today cursor for         	
				select dbo.ProperCase(Cmp_name), Cmp_id from  T0010_COMPANY_MASTER WITH (NOLOCK) where  
				1 = ( case when @show_grpcmp_birthday = 1 and is_GroupOFCmp = 1  then 1 
				when @show_grpcmp_birthday=0 and cmp_id = @cmp_id then 1 else 0 end )
			open Cur_Today        
				fetch next from Cur_Today into  @display_cmp_name , @display_cmp_id
			While @@Fetch_Status=0        
				Begin 
					
					set @Todays_date=(cast(Day(GETDATE()) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(GETDATE())))) 
	    			
	    			--insert into #Birthday Values('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' '+ @Todays_date +' </i></b>' ,null,'',0,'','',null,2 ,'','','',0,'','',@display_cmp_id)  --Mukti 13012016
	    			--insert into #Birthday Values('' ,null,'',0,'','',null,2 ,'','','',0,'','',@display_cmp_id,'TODAYS BIRTHDAY','','',1) --Added By Mukti 12012016 
					insert into #Birthday
					 Select (Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name),
					 --CONVERT(VARCHAR(11),ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth) , 106) as Date_Of_Birth
					 case when @Display_Actual_Birthdate=0 then CONVERT(VARCHAR(11),Date_Of_Birth,106) 
						Else
						 --CONVERT(VARCHAR(11),ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth) , 106) 
						 case when ISNULL(E.Actual_Date_Of_Birth,'1900-01-01 00:00:00.000') ='1900-01-01 00:00:00.000' then
								Date_Of_birth else E.Actual_Date_Of_Birth end 
						End as Date_Of_Birth --Changed by Sumit to show dob as per admin setting on 15122016
					 ,'',E.Branch_ID,
					 BM.Branch_Name,E.Image_Name ,ROW_NUMBER() Over (order by month(Date_Of_Birth),day(Date_Of_Birth)) , 2 
					 ,E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID,'' as Date_Of_join,0 as Total_Completed_Years, @display_cmp_id--Mukti 11012016
					 ,'TODAYS BIRTHDAY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id
					 from T0080_Emp_master E WITH (NOLOCK)  -- Prakash Patel 25072014
					 inner join T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
					  inner join     
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
					 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID
					left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.Cat_ID
					left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID   --Mukti 11012016
					left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID   --Mukti 11012016
					where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
							 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where 
							 Emp_Left_Date is null or CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) and I.cmp_id = @display_cmp_id) 
							 and Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(Getdate()) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(Getdate())
							 and 1=( case when @show_grpcmp_birthday =0 and I.Branch_ID  not in (select data from dbo.split(@pPrivilage_ID,'#'))  then 0 else 1 end)
							 --Added By Jaina 11-08-2016 Start
							 and 1=( case when @show_grpcmp_birthday =0   
									 and I.Dept_ID NOT in (SELECT data from dbo.split(@pPrivilage_Department,'#')) THEN 0 ELSE 1 end)
							 and 1=( case when @show_grpcmp_birthday =0 
									 and I.Vertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Vertical,'#')) THEN 0 ELSE 1 end)
							 and 1=( case when @show_grpcmp_birthday =0 
									 and I.SubVertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Sub_Vertical,'#')) THEN 0 ELSE 1 END)
							--Added By Jaina 11-08-2016 End
							
					
			--If Above Transaction Does not Returs any employee then we have deleted the name of that company also.
			
					If @@rowcount > 0
						BEGIN
							insert into #Birthday Values('' ,null,'',0,'','',null,2 ,'','','',0,'','',@display_cmp_id,'TODAYS BIRTHDAY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id) --Added By Mukti 12012016 
						END
-----------------------for Birthday Reminder of todays date(end)--------------------------------------------------
					
					
					
					-----------------------Marriage anniversary Reminder of todays date(start)------------------------------------------------																			
					--insert into #Birthday Values('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' '+ @Todays_date +'</i></b>' ,null,'',0,'','',null,4 ,'','','',0,'','',@display_cmp_id) --Added By Mukti 12012016 
					
					insert into #Birthday
					 Select (Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name)
					 ,Emp_Annivarsary_Date,'',I.Branch_ID,BM.Branch_Name,E.Image_Name ,ROW_NUMBER() Over (order by month(Emp_Annivarsary_Date),day(Emp_Annivarsary_Date)) ,4 ,
					 E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID
					 ,'' as Date_Of_join,0 as Total_Completed_Years,@display_cmp_id  --Mukti 11012016
					 ,'TODAYS MARRIAGE ANNIVERSARY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id
					 from T0080_Emp_master E WITH (NOLOCK)  -- Prakash Patel 25072014
					 inner join
					T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
					  inner join     
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
					 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
					left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
					left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID   --Mukti 11012016
					left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID   --Mukti 11012016
					where E.Cmp_ID=@display_cmp_id  and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
							 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) and cmp_id=@display_cmp_id) 
							 and Month(Emp_Annivarsary_Date)=Month(Getdate()) And day(Emp_Annivarsary_Date)=day(Getdate())
							 and Emp_Annivarsary_Date <> '' AND Cast(IsNull(Emp_Annivarsary_Date,'1900-01-01') as DateTime) <> '1900-01-01'
							 and 1=( case when @show_grpcmp_birthday =0 and I.Branch_ID  not in (select data from dbo.split(@pPrivilage_ID,'#'))  then 0 else 1 end)
							 --Added By Jaina 11-08-2016 Start
							 and 1=( case when @show_grpcmp_birthday =0   
									 and I.Dept_ID NOT in (SELECT data from dbo.split(@pPrivilage_Department,'#')) THEN 0 ELSE 1 end)
							 and 1=( case when @show_grpcmp_birthday =0 
									 and I.Vertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Vertical,'#')) THEN 0 ELSE 1 end)
							 and 1=( case when @show_grpcmp_birthday =0 
									 and I.SubVertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Sub_Vertical,'#')) THEN 0 ELSE 1 END)
							--Added By Jaina 11-08-2016 End
							 
			--If Above Transaction Does not Returs any employee then we have deleted the name of that company also.	
					--print @@rowcount
					If @@rowcount > 0
						BEGIN
							insert into #Birthday Values('' ,null,'',0,'','',null,4 ,'','','',0,'','',@display_cmp_id,'TODAYS MARRIAGE ANNIVERSARY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id) --Added By Mukti 12012016 
							
						END
					
-----------------------Marriage anniversary Reminder of todays date(start)------------------------------------------------														

				-----------------------Work anniversary Reminder of todays date(start)------------------------------------------------																			
					if(@Setting_Value=1)
					BEGIN
						--insert into #Birthday Values('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' '+ @Todays_date +'</i></b>' ,null,'',0,'','',null,6 ,'','','',0,'','',@display_cmp_id) --Added By Mukti 12012016 
						insert into #Birthday
						 Select (Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name)
						 ,E.Date_Of_Join as Emp_Annivarsary_Date,  
						 '',I.Branch_ID,
						 BM.Branch_Name,E.Image_Name ,ROW_NUMBER() Over (order by month(Date_Of_Join),day(Date_Of_Join)) ,6 ,
						 E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID
						 ,E.Date_Of_Join,DATEDIFF(YEAR,E.Date_Of_Join,GETDATE()) as Total_Completed_Years,@display_cmp_id  --Mukti 11012016
						 ,'TODAYS WORK ANNIVERSARY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id
						 from T0080_Emp_master E WITH (NOLOCK) -- Prakash Patel 25072014
						 inner join
						T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
						  inner join     
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
							(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
							Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
							on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
						 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
						INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
						left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
						left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID   --Mukti 11012016
						left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID   --Mukti 11012016
						where E.Cmp_ID=@display_cmp_id  and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
								 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) and cmp_id=@display_cmp_id) 
								 and Month(Date_Of_Join)=Month(Getdate()) And day(Date_Of_Join)=day(Getdate()) --Mukti(25012016) for Work Anniversary
								 and Year(Date_Of_Join) <> Year(Getdate()) --Added By Nilesh patel for Work Anniversary Same Date show in Anniversary 
								 and 1=( case when @show_grpcmp_birthday =0 and I.Branch_ID  not in (select data from dbo.split(@pPrivilage_ID,'#'))  then 0 else 1 end)
								 --Added By Jaina 11-08-2016 Start
							 and 1=( case when @show_grpcmp_birthday =0   
									 and I.Dept_ID NOT in (SELECT data from dbo.split(@pPrivilage_Department,'#')) THEN 0 ELSE 1 end)
							 and 1=( case when @show_grpcmp_birthday =0 
									 and I.Vertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Vertical,'#')) THEN 0 ELSE 1 end)
							 and 1=( case when @show_grpcmp_birthday =0 
									 and I.SubVertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Sub_Vertical,'#')) THEN 0 ELSE 1 END)
							--Added By Jaina 11-08-2016 End
				--If Above Transaction Does not Returs any employee then we have deleted the name of that company also.	
						--print @@rowcount
						If @@rowcount > 0
							BEGIN
								insert into #Birthday Values('' ,null,'',0,'','',null,6,'','','',0,'','',@display_cmp_id,'TODAYS WORK ANNIVERSARY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id) --Added By Mukti 12012016 							
							END
					END
						fetch next from Cur_Today into  @display_cmp_name , @display_cmp_id
				End        
			close Cur_Today        
			Deallocate Cur_Today 
	
-----------------------Work anniversary Reminder of todays date(start)------------------------------------------------														
	
				--BEGIN
			Declare Cur_Upcoming cursor for         	
				select dbo.ProperCase(Cmp_name), Cmp_id from  T0010_COMPANY_MASTER WITH (NOLOCK) where  1 = ( case when @show_grpcmp_birthday = 1 and is_GroupOFCmp = 1  then 1 
				when @show_grpcmp_birthday=0 and cmp_id=@cmp_id then 1 else 0 end )
			open Cur_Upcoming        
				fetch next from Cur_Upcoming into  @display_cmp_name , @display_cmp_id
				While @@Fetch_Status=0        
			Begin
			
-----------------------for Birthday Reminder upcoming date(start)--------------------------------------------------			
				--insert into #Birthday Values( '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' ,null,'',0,'','',null,8,'','','',0,'','',@display_cmp_id)       
				--insert into #Birthday
				Select (Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name) As Emp_Full_Name,
				 --CONVERT(VARCHAR(11),ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth) , 106) as Date_Of_Birth,
				--(cast(Day(Date_Of_birth) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)))) As Month_Name,	''Commented By Ramiz on 06/10/2016
				--(cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Date_Of_birth)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)))) As Month_Name, --Added By Ramiz on 06/10/2016 for Proper Sorting
				--case when @Display_Actual_Birthdate=0 then CONVERT(VARCHAR(11),Date_Of_Birth,106) Else CONVERT(VARCHAR(11),ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth) , 106) 
				--	 End as Date_Of_Birth,
				case when @Display_Actual_Birthdate=0 then CONVERT(VARCHAR(11),Date_Of_Birth,106) 
						Else
						 --CONVERT(VARCHAR(11),ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth) , 106) 
						 case when ISNULL(E.Actual_Date_Of_Birth,'1900-01-01 00:00:00.000') ='1900-01-01 00:00:00.000' then
								Date_Of_birth else E.Actual_Date_Of_Birth end 
						End as Date_Of_Birth, --Changed by Sumit to show dob as per admin setting on 15122016
				
				--(cast(Day(Date_Of_birth) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)))) As Month_Name,	''Commented By Ramiz on 06/10/2016
				case when @Display_Actual_Birthdate=0 then (cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Date_Of_birth)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)))) Else (cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Actual_Date_Of_Birth)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Actual_Date_Of_Birth)))) 
					 End As Month_Name,
					 
				E.Branch_ID,BM.Branch_Name,E.Image_Name ,ROW_NUMBER() Over (order by month(Date_Of_Birth),day(Date_Of_Birth)) As Row_ID
				 ,8 As Sorting_no,E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID ,'' as Date_Of_join,0 as Total_Completed_Years,@display_cmp_id as Cmp_Id  --Mukti 11012016
				 ,'UPCOMING BIRTHDAY'As Reminder_Type,@display_cmp_name aS Company_Name,NULL as Today_Date,0as Is_Like,0 As Is_Comment,@Emp_Login_Id As Emp_Login_Id
				 INTO #UpcomingBDay1   --Mukti 11012016
				 from T0080_Emp_master E WITH (NOLOCK)
				 inner join	T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
				  inner join     
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
					(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
					Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
					on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
					Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
				 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID
				left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
				left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID --Mukti 11012016
				left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID --Mukti 11012016
				 where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
				 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or (CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),@From_Date,120) 
									and 
										day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth)) <= day(Emp_Left_Date)) 
									--day(Emp_Left_Date)>=DAY(case when @Display_Actual_Birthdate=1 
									--										or ISNULL(Actual_Date_Of_Birth,'01-Jan-1900')='01-Jan-1900' 
									--							 then Date_of_birth Else Actual_Date_of_Birth 
									--						End)
				 
									and cmp_id=@display_cmp_id
								 ) 
				 and 1=( case when @show_grpcmp_birthday =0 and I.Branch_ID  not in (select data from dbo.split(@pPrivilage_ID,'#'))  then 0 else 1 end)
				 --Added By Jaina 11-08-2016 Start
				 and 1=( case when @show_grpcmp_birthday =0   
						 and I.Dept_ID NOT in (SELECT data from dbo.split(@pPrivilage_Department,'#')) THEN 0 ELSE 1 end)
				 and 1=( case when @show_grpcmp_birthday =0 
						 and I.Vertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Vertical,'#')) THEN 0 ELSE 1 end)
				 and 1=( case when @show_grpcmp_birthday =0 
						 and I.SubVertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Sub_Vertical,'#')) THEN 0 ELSE 1 END)
				--Added By Jaina 11-08-2016 End				  
				 and (
						(
							Month(@From_Date)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date)=day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)--day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=						
						)
						 OR
						(
							Month(@From_Date+1)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+1)=	day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)				
						) OR
						(
							Month(@From_Date+2)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+2)=	day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)					
						) or
						(
							Month(@From_Date+3)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+3)=	day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						) or
						(
							Month(@From_Date+4)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+4)= day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						) or
						(
							Month(@From_Date+5)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+5)=day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						) or
						(
							Month(@From_Date+6)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+6)=day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						) or
						(
							Month(@From_Date+7)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+7)=day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						)
				  )		 
				  order by
							Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End),							
							DAY(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
				 --((Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date)) OR 
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+1) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+1)) OR
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+2) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+2)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+3) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+3)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+4) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+4)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+5) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+5)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+6) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+6)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+7) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+7))
				 -- )order by month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth)),day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))

				
				
				--Mukti 11012016(start)
				insert into #Birthday
				Select * FROM
				(
					Select Emp_Full_Name,Date_Of_Birth,Month_Name,Branch_ID,Branch_Name,Image_Name,Row_ID,Sorting_No,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID ,Date_Of_Join,Total_Completed_Years,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment,Emp_Login_Id
					From #UpcomingBDay1
					--Union All
					--Select '' As Emp_Full_Name,'' As Date_Of_Birth,Month_Name,0 As Branch_ID,'' As Branch_Name,'' As Image_Name,0 As Row_ID,Sorting_No,'' As Alhpa_Emp_Code,'' As Desig_Name,'' As Dept_Name,0 As Emp_ID,'' As Date_Of_Join,'' As Total_Completed_Years, Cmp_ID,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
					--From #UpcomingBDay1 Group BY Month_Name, Sorting_No, Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
				) T
				Order By Cast(Month_Name + '-2000' As DateTime), Alpha_Emp_Code
				--Mukti 11012016(end)
				
				--If Above Transaction Does not Returs any employee then we have deleted the name of that company also.
				If @@rowcount > 0
					BEGIN
						 insert into #Birthday Values('' ,null,'',0,'','',null,8,'','','',0,'','',@display_cmp_id,'UPCOMING BIRTHDAY',@display_cmp_name,null,0,0,@Emp_Login_Id) --Added By Mukti 12012016 							
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' and Sorting_No =8
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>UPCOMING BIRTHDAY <u></b>'
					END
				drop table #UpcomingBDay1
-----------------------for Birthday Reminder upcoming date(end)--------------------------------------------------			

-----------------------Marriage anniversary Reminder of upcoming date(start)------------------------------------------------														
				--insert into #Birthday Values( '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' ,null,'',0,'','',null,10,'','','',0,'','',@display_cmp_id)         
				--insert into #Birthday
				Select (Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name) As Emp_Full_Name,
				 Emp_Annivarsary_Date as Date_Of_Birth,
				 --(cast(Day(Emp_Annivarsary_Date) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Emp_Annivarsary_Date)))) As Month_Name,  --''Commented By Ramiz on 06/10/2016
				 (cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Emp_Annivarsary_Date)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Emp_Annivarsary_Date)))) As Month_Name,	--Added By Ramiz on 06/10/2016 for Proper Sorting
				 E.Branch_ID, BM.Branch_Name,E.Image_Name ,ROW_NUMBER() Over (order by month(Emp_Annivarsary_Date),day(Emp_Annivarsary_Date)) As Row_ID
				 ,10 As Sorting_no,E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID ,'' as Date_Of_join,0 as Total_Completed_Years,@display_cmp_id as Cmp_Id
				 ,'UPCOMING MARRIAGE ANNIVERSARY' As Reminder_Type,@display_cmp_name As Company_Name,null As Today_date,0as Is_Like,0 As Is_Comment,@Emp_Login_Id as Emp_Login_Id
				 INTO #UpcomingAnniversary1 --Mukti 11012016
				 from T0080_Emp_master E WITH (NOLOCK) -- Prakash Patel 25072014
				 inner join T0095_Increment I  WITH (NOLOCK) on I.Emp_ID = e.emp_id 
				  inner join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
					(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
					Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
					on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
					Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
				 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
				left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
				left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID
				left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID
				where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
				 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or (CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),@From_Date,120)
				 and day(Date_Of_Join) <= day(Emp_Left_Date)) and cmp_id=@display_cmp_id) 
				 and Emp_Annivarsary_Date <> '' AND Cast(IsNull(Emp_Annivarsary_Date,'1900-01-01') as DateTime) <> '1900-01-01'
				 and 1=( case when @show_grpcmp_birthday = 0 and I.Branch_ID  not in (select data from dbo.split(@pPrivilage_ID,'#'))  then 0 else 1 end)
				 --Added By Jaina 11-08-2016 Start
				and 1=( case when @show_grpcmp_birthday =0   
					 and I.Dept_ID NOT in (SELECT data from dbo.split(@pPrivilage_Department,'#')) THEN 0 ELSE 1 end)
				 and 1=( case when @show_grpcmp_birthday =0 
					 and I.Vertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Vertical,'#')) THEN 0 ELSE 1 end)
				 and 1=( case when @show_grpcmp_birthday =0 
					 and I.SubVertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Sub_Vertical,'#')) THEN 0 ELSE 1 END)
				--Added By Jaina 11-08-2016 End				
				 and ((Month(Emp_Annivarsary_Date)=Month(@From_Date) And day(Emp_Annivarsary_Date)=day(@From_Date)) OR 
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+1) And day(Emp_Annivarsary_Date)=day(@From_Date+1)) OR
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+2) And day(Emp_Annivarsary_Date)=day(@From_Date+2)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+3) And day(Emp_Annivarsary_Date)=day(@From_Date+3)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+4) And day(Emp_Annivarsary_Date)=day(@From_Date+4)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+5) And day(Emp_Annivarsary_Date)=day(@From_Date+5)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+6) And day(Emp_Annivarsary_Date)=day(@From_Date+6)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+7) And day(Emp_Annivarsary_Date)=day(@From_Date+7))				
				  )order by month(Emp_Annivarsary_Date),day(Emp_Annivarsary_Date) 
			
				insert into #Birthday
				Select * FROM
				(
					Select Emp_Full_Name,Date_Of_Birth,Month_Name,Branch_ID,Branch_Name,Image_Name,Row_ID,Sorting_No,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID ,Date_Of_Join,Total_Completed_Years,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment,Emp_Login_Id
					From #UpcomingAnniversary1
					--Union All
					--Select '' As Emp_Full_Name,'' As Date_Of_Birth,Month_Name,0 As Branch_ID,'' As Branch_Name,'' As Image_Name,0 As Row_ID,Sorting_No,'' As Alhpa_Emp_Code,'' As Desig_Name,'' As Dept_Name,0 As Emp_ID,'' As Date_Of_Join,'' As Total_Completed_Years,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
					--From #UpcomingAnniversary1 Group BY Month_Name, Sorting_No, Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
				) T
				Order By Cast(Month_Name + '-2000' As DateTime), Alpha_Emp_Code
				
				
		   --If Above Transaction Does not Returs any employee then we have deleted the name of that company also.
			If @@rowcount > 0
				BEGIN	
					--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' and Sorting_No = 10
					insert into #Birthday Values('' ,null,'',0,'','',null,10,'','','',0,'','',@display_cmp_id,'UPCOMING MARRIAGE ANNIVERSARY',@display_cmp_name,null,0,0,@Emp_Login_Id) --Added By Mukti 12012016 							
					--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>UPCOMING MARRIAGE ANNIVERSARY <u></b>'
				END
				drop TABLE #UpcomingAnniversary1
-----------------------Marriage anniversary Reminder of upcoming date(end)------------------------------------------------														

-----------------------Work anniversary Reminder of upcoming date(start)------------------------------------------------														
				if(@Setting_Value=1)
				BEGIN
					--insert into #Birthday Values( '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' ,null,'',0,'','',null,12,'','','',0,'','',@display_cmp_id)         
					--insert into #Birthday
					Select (Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name) As Emp_Full_Name,
					 Emp_Annivarsary_Date as Date_Of_Birth,  --Commented By Mukti(25012016)
					 --(cast(Day(Date_Of_Join) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_Join)))) As Month_Name,  --''Commented By Ramiz on 06/10/2016
					 (cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Date_Of_Join)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_Join)))) As Month_Name,	--Added By Ramiz on 06/10/2016 for Proper Sorting
					 E.Branch_ID, BM.Branch_Name,E.Image_Name ,ROW_NUMBER() Over (order by month(Date_Of_Join),day(Date_Of_Join)) As Row_ID
					 ,12 As Sorting_no,E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID ,E.Date_Of_Join,DATEDIFF(YEAR,E.Date_Of_Join,GETDATE())as Total_Completed_Years,@display_cmp_id as Cmp_Id
					 ,'UPCOMING WORK ANNIVERSARY' As Reminder_Type,@display_cmp_name As Company_Name,NULL As Today_Date,0 as Is_Like,0 as Is_Comment,@Emp_Login_Id as Emp_Login_Id
					 INTO #UpcomingWorkAnniversary1 --Mukti 11012016
					 from T0080_Emp_master E WITH (NOLOCK) -- Prakash Patel 25072014
					 inner join T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
					  inner join
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
					 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
					left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
					left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID
					left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID
					where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
					 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or (CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),@From_Date,120)
					 and day(Date_Of_Join) <= day(Emp_Left_Date)) and cmp_id=@display_cmp_id) 
					 and 1=( case when @show_grpcmp_birthday = 0 and I.Branch_ID  not in (select data from dbo.split(@pPrivilage_ID,'#'))  then 0 else 1 end)
					 --Added By Jaina 11-08-2016 Start
					 and 1=( case when @show_grpcmp_birthday =0   
							 and I.Dept_ID NOT in (SELECT data from dbo.split(@pPrivilage_Department,'#')) THEN 0 ELSE 1 end)
					 and 1=( case when @show_grpcmp_birthday =0 
							 and I.Vertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Vertical,'#')) THEN 0 ELSE 1 end)
					 and 1=( case when @show_grpcmp_birthday =0 
							 and I.SubVertical_ID NOT in (SELECT data from dbo.split(@pPrivilage_Sub_Vertical,'#')) THEN 0 ELSE 1 END)
					--Added By Jaina 11-08-2016 End
					 and ((Month(Date_Of_Join)=Month(@From_Date) And day(Date_Of_Join)=day(@From_Date)) OR 
					 (Month(Date_Of_Join)=Month(@From_Date+1) And day(Date_Of_Join)=day(@From_Date+1)) OR
					 (Month(Date_Of_Join)=Month(@From_Date+2) And day(Date_Of_Join)=day(@From_Date+2)) or
					 (Month(Date_Of_Join)=Month(@From_Date+3) And day(Date_Of_Join)=day(@From_Date+3)) or
					 (Month(Date_Of_Join)=Month(@From_Date+4) And day(Date_Of_Join)=day(@From_Date+4)) or
					 (Month(Date_Of_Join)=Month(@From_Date+5) And day(Date_Of_Join)=day(@From_Date+5)) or
					 (Month(Date_Of_Join)=Month(@From_Date+6) And day(Date_Of_Join)=day(@From_Date+6)) or
					 (Month(Date_Of_Join)=Month(@From_Date+7) And day(Date_Of_Join)=day(@From_Date+7))
					  )order by month(Date_Of_Join),day(Date_Of_Join) 
					 
					 
				
		       		insert into #Birthday
					Select * FROM
					(
						Select Emp_Full_Name,Date_Of_Birth,Month_Name,Branch_ID,Branch_Name,Image_Name,Row_ID,Sorting_No,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID ,Date_Of_Join,Total_Completed_Years,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment,Emp_Login_Id
						From #UpcomingWorkAnniversary1
						--Union All
						--Select '' As Emp_Full_Name,'' As Date_Of_Birth,Month_Name,0 As Branch_ID,'' As Branch_Name,'' As Image_Name,0 As Row_ID,Sorting_No,'' As Alhpa_Emp_Code,'' As Desig_Name,'' As Dept_Name,0 As Emp_ID,'' As Date_Of_Join,'' As Total_Completed_Years,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
						--From #UpcomingWorkAnniversary1 Group BY Month_Name, Sorting_No, Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
					) T
					Order By Cast(Month_Name + '-2000' As DateTime), Alpha_Emp_Code
									
			   --If Above Transaction Does not Returs any employee then we have deleted the name of that company also.
				If @@rowcount > 0
					BEGIN
						insert into #Birthday Values('' ,null,'',0,'','',null,12,'','','',0,'','',@display_cmp_id,'UPCOMING WORK ANNIVERSARY',@display_cmp_name,null,0,0,@Emp_Login_Id) --Added By Mukti 12012016 							
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' and Sorting_No = 12
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>UPCOMING WORK ANNIVERSARY <u></b>'
					END
					drop TABLE #UpcomingWorkAnniversary1
				END
-----------------------Work anniversary Reminder of upcoming date(end)------------------------------------------------														
			fetch next from Cur_Upcoming into  @display_cmp_name , @display_cmp_id
			End        
			close Cur_Upcoming        
			Deallocate Cur_Upcoming 
	    END
	 
	 Else		--Admin Side
		BEGIN
			Declare Cur_Today cursor for         	
				select dbo.ProperCase(Cmp_name), Cmp_id from  T0010_COMPANY_MASTER WITH (NOLOCK) where  1 = ( case when @show_grpcmp_birthday = 1 and is_GroupOFCmp = 1  then 1 
				when @show_grpcmp_birthday=0 and cmp_id=@cmp_id then 1 else 0 end )
			open Cur_Today        
				fetch next from Cur_Today into  @display_cmp_name , @display_cmp_id
			While @@Fetch_Status=0        
				Begin 				
					--set @Todays_date=(cast(Day(GETDATE()) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(GETDATE()))))  --''Commented By Ramiz on 06/10/2016
					set @Todays_date=(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, GETDATE())), 2) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(GETDATE()))))	--Added By Ramiz on 06/10/2016 for Proper Sorting

	-----------------------for Birthday Reminder of todays date(start)--------------------------------------------------
					--insert into #Birthday Values('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' '+ @Todays_date +' </i></b>' ,null,'',0,'','',null,2 ,'','','',0,'','',@display_cmp_id) 
					insert into #Birthday
					 Select ( Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name),
						 CONVERT(VARCHAR(11),ISNULL(Actual_Date_Of_birth,E.Date_Of_Birth) , 106) as Date_Of_Birth,	----Actual DOB --Ankit 13102015
						 (cast(Day(Date_Of_birth) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)))) As Month_Name,E.Branch_ID,
						 BM.Branch_Name,E.Image_Name ,ROW_NUMBER() Over (order by month(Date_Of_Birth),day(Date_Of_Birth)) , 2,
						 E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID,'',0 as Total_Completed_Years,@display_cmp_id,
						 'TODAYS BIRTHDAY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id
					 from T0080_Emp_master E WITH (NOLOCK) -- Prakash Patel 25072014
					 inner join T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
					  inner join     
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
					 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID
					left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.Cat_ID
					left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID --Mukti(11012016)
					left join T0040_DEPARTMENT_MASTER DM on I.Dept_ID = DM.Dept_ID --Mukti(11012016)
					where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
					 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) and cmp_id=@display_cmp_id) 
					 and Month(ISNULL(Actual_Date_Of_birth,E.Date_Of_Birth))=Month(Getdate()) And day(ISNULL(Actual_Date_Of_birth,E.Date_Of_Birth))=day(Getdate())
					
				--If Above Transaction Does not Returs any employee then we have deleted the name of that company also.
					If @@rowcount > 0
					BEGIN	
							insert into #Birthday Values('' ,null,'',0,'','',null,2 ,'','','',0,'','',@display_cmp_id,'TODAYS BIRTHDAY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id) --Added By Mukti 12012016 
					--print @@rowcount
						--delete from #Birthday where Emp_Full_Name ='&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' '+ @Todays_date +' </i></b>' and Cast(Sorting_No as INT) = 2  --commented By Mukti 12012016 
						--delete from #Birthday where Emp_Full_Name ='&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>TODAYS BIRTHDAY <u></b>'
					END
	-----------------------for Birthday Reminder of todays date(end)------------------------------------------------------

	-----------------------Marriage anniversary Reminder of todays date(start)------------------------------------------------														
				--insert into #Birthday Values('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' '+ @Todays_date +'</i></b>' ,null,'',0,'','',null,4,'','','',0,'','',@display_cmp_id)      
				insert into #Birthday
					 Select ( Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name)
					 ,Emp_Annivarsary_Date as Date_Of_Birth,'',E.Branch_ID,BM.Branch_Name,E.Image_Name ,
					 ROW_NUMBER() Over (order by month(Emp_Annivarsary_Date),day(Emp_Annivarsary_Date)), 
					 4 ,E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID,'' as Date_Of_join,0 as Total_Completed_Years,@display_cmp_id
					 ,'TODAYS MARRIAGE ANNIVERSARY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id
					 from T0080_Emp_master E  WITH (NOLOCK) -- Prakash Patel 25072014
					 inner join
					T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
					  inner join     
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
					 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
					left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
					left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID --Mukti(11012016)
					left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID --Mukti(11012016)
					where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
					 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) and cmp_id=@display_cmp_id) 
					 and Month(Emp_Annivarsary_Date)=Month(Getdate()) And day(Emp_Annivarsary_Date)=day(Getdate())
					
			--If Above Transaction Does not Returs any employee then we have deleted the name of that company also.	
					If @@rowcount > 0
					BEGIN
						insert into #Birthday Values('' ,null,'',0,'','',null,4 ,'','','',0,'','',@display_cmp_id,'TODAYS MARRIAGE ANNIVERSARY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id) --Added By Mukti 12012016 
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' '+ @Todays_date +'</i></b>' and Cast(Sorting_No as INT) = 4  --commented by Mukti 12012016
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>TODAYS MARRIAGE ANNIVERSARY <u></b>'
					END
-----------------------Marriage anniversary Reminder of todays date(end)------------------------------------------------																			
				
-----------------------Work anniversary Reminder of todays date(start)------------------------------------------------										
				if(@Setting_Value=1)
				BEGIN
					--insert into #Birthday Values('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' '+ @Todays_date +'</i></b>' ,null,'',0,'','',null,6,'','','',0,'','',@display_cmp_id)      
					insert into #Birthday
					 Select ( Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name)
					 ,E.Date_Of_Join as Date_Of_Birth,'',E.Branch_ID,
					 BM.Branch_Name,E.Image_Name ,		
					 ROW_NUMBER() Over (order by month(Date_Of_Join),day(Date_Of_Join)), 
					 6 ,E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID, E.Date_Of_Join,DATEDIFF(YEAR,E.Date_Of_Join,GETDATE()) as Total_Completed_Years,@display_cmp_id
					 ,'TODAYS WORK ANNIVERSARY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id
					 from T0080_Emp_master E WITH (NOLOCK) -- Prakash Patel 25072014
					 inner join
					T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
					  inner join     
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
					 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
					left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
					left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID --Mukti(11012016)
					left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID --Mukti(11012016)
					where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
					 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) and cmp_id=@display_cmp_id) 
					 and Month(Date_Of_Join)=Month(Getdate()) And day(Date_Of_Join)=day(Getdate()) 

			--If Above Transaction Does not Returs any employee then we have deleted the name of that company also.	
					If @@rowcount > 0
					BEGIN
						insert into #Birthday Values('' ,null,'',0,'','',null,6,'','','',0,'','',@display_cmp_id,'TODAYS WORK ANNIVERSARY',@display_cmp_name,@Todays_date,1,1,@Emp_Login_Id) --Added By Mukti 12012016 							
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' '+ @Todays_date +'</i></b>' and Cast(Sorting_No as INT) = 6  --commented by Mukti 12012016
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>TODAYS WORK ANNIVERSARY <u></b>'						
					END
				END
	-----------------------------Work anniversary Reminder of todays date(end)----------------------------------------		
	
				fetch next from Cur_Today into  @display_cmp_name , @display_cmp_id
				End        
			close Cur_Today        
			Deallocate Cur_Today 
		--END
		
		--BEGIN
			Declare Cur_Upcoming cursor for         	
				select dbo.ProperCase(Cmp_name), Cmp_id from  T0010_COMPANY_MASTER WITH (NOLOCK) where  1 = ( case when @show_grpcmp_birthday = 1 and is_GroupOFCmp = 1  then 1 
				when @show_grpcmp_birthday=0 and cmp_id=@cmp_id then 1 else 0 end )
			open Cur_Upcoming        
				fetch next from Cur_Upcoming into  @display_cmp_name , @display_cmp_id
				While @@Fetch_Status=0        
			Begin
-----------------------for Birthday Reminder upcoming date(start)--------------------------------------------------			
				--insert into #Birthday Values( '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' ,null,'',0,'','',null,8,'','','',0,'','',@display_cmp_id)      
				Select (Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name) As Emp_Full_Name,
				 --CONVERT(VARCHAR(11),ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth) , 106) as Date_Of_Birth,
				 --(cast(Day(Date_Of_birth) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)))) As Month_Name,  --''Commented By Ramiz on 06/10/2016
				 --(cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Date_Of_birth)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)))) As Month_Name,	--Added By Ramiz on 06/10/2016 for Proper Sorting
				 --case when @Display_Actual_Birthdate=0 then CONVERT(VARCHAR(11),Date_Of_Birth,106) Else CONVERT(VARCHAR(11),ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth) , 106) 
					-- End as Date_Of_Birth,
				case when @Display_Actual_Birthdate=0 then CONVERT(VARCHAR(11),Date_Of_Birth,106) 
						Else
						 --CONVERT(VARCHAR(11),ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth) , 106) 
						 case when ISNULL(E.Actual_Date_Of_Birth,'1900-01-01 00:00:00.000') ='1900-01-01 00:00:00.000' then
								Date_Of_birth else E.Actual_Date_Of_Birth end 
						End as Date_Of_Birth, --Changed by Sumit to show dob as per admin setting on 15122016	
				--(cast(Day(Date_Of_birth) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)))) As Month_Name,	''Commented By Ramiz on 06/10/2016
				case when @Display_Actual_Birthdate=0 then (cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Date_Of_birth)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)))) Else (cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Actual_Date_Of_Birth)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Actual_Date_Of_Birth)))) 
					 End As Month_Name,
				 E.Branch_ID,BM.Branch_Name,E.Image_Name ,ROW_NUMBER() Over (order by month(Date_Of_Birth),day(Date_Of_Birth)) As Row_ID
				 , 8 As Sorting_no,E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID,'' as Date_Of_join,0 as Total_Completed_Years,@display_cmp_id as Cmp_Id
				 ,'UPCOMING BIRTHDAY'as Reminder_Type,@display_cmp_name as Company_Name,null as Today_Date,0 as Is_Like,0 As Is_Comment,@Emp_Login_Id  as Emp_Login_Id
				 INTO #UpcomingBDay
				 from T0080_Emp_master E WITH (NOLOCK)
				 inner join	T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
				  inner join     
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
					(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
					Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
					on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
					Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
				 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID
				left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
				left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID
				left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID
				 where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
				 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or (CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),@From_Date,120) and day(Date_Of_Birth) <= day(Emp_Left_Date)) and cmp_id=@display_cmp_id) 
				  and (
						(
							Month(@From_Date)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date)=day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)--day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=						
						)
						 OR
						(
							Month(@From_Date+1)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+1)=	day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)				
						) OR
						(
							Month(@From_Date+2)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+2)=	day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)					
						) or
						(
							Month(@From_Date+3)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+3)=	day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						) or
						(
							Month(@From_Date+4)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+4)= day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						) or
						(
							Month(@From_Date+5)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+5)=day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						) or
						(
							Month(@From_Date+6)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+6)=day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						) or
						(
							Month(@From_Date+7)=Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
							And day(@From_Date+7)=day(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
						)
				  )		 
				  order by
							Month(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End),							
							DAY(case when @Display_Actual_Birthdate=0 then Date_Of_birth Else Actual_Date_Of_Birth End)
				 
				 --and				 
				 -- ((Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date)) OR 
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+1) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+1)) OR
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+2) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+2)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+3) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+3)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+4) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+4)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+5) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+5)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+6) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+6)) or
				 --(Month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=Month(@From_Date+7) And day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))=day(@From_Date+7))
				 -- )order by month(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth)),day(ISNULL(E.Actual_Date_Of_Birth,Date_Of_birth))
			
				insert into #Birthday
				Select * FROM
				(
					Select Emp_Full_Name,Date_Of_Birth,Month_Name,Branch_ID,Branch_Name,Image_Name,Row_ID,Sorting_No,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID ,Date_Of_Join,Total_Completed_Years,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
					From #UpcomingBDay
					--Union All
					--Select '' As Emp_Full_Name,'' As Date_Of_Birth,Month_Name,0 As Branch_ID,'' As Branch_Name,'' As Image_Name,0 As Row_ID,Sorting_No,'' As Alhpa_Emp_Code,'' As Desig_Name,'' As Dept_Name,0 As Emp_ID,'' As Date_Of_Join,'' As Total_Completed_Years,cmp_id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
					--From #UpcomingBDay Group BY Month_Name, Sorting_No,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
				) T
				Order By Cast(Month_Name + '-2000' As DateTime), Alpha_Emp_Code
							
				--If Above Transaction Does not Returs any employee then we have deleted the name of that company also.
				If @@rowcount > 0
					BEGIN
						insert into #Birthday Values('' ,null,'',0,'','',null,8,'','','',0,'','',@display_cmp_id,'UPCOMING BIRTHDAY',@display_cmp_name,null,0,0,@Emp_Login_Id) --Added By Mukti 12012016 							
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' and Cast(Sorting_No as INT) = 8
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>UPCOMING BIRTHDAY <u></b>'
					END
				drop table #UpcomingBDay
-----------------------for Birthday Reminder of upcoming date(END)--------------------------------------------------			
				
-----------------------Marriage anniversary Reminder of upcoming date(start)------------------------------------------------														
				--insert into #Birthday Values( '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' ,null,'',0,'','',null,10,'','','',0,'','',@display_cmp_id)        
				--insert into #Birthday
				Select (Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name) As Emp_Full_Name,
				 Emp_Annivarsary_Date as Date_Of_Birth, 
				 --(cast(Day(Emp_Annivarsary_Date) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Emp_Annivarsary_Date)))) As Month_Name,  --''Commented By Ramiz on 06/10/2016
				 (cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Emp_Annivarsary_Date)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Emp_Annivarsary_Date)))) As Month_Name,	--Added By Ramiz on 06/10/2016 for Proper Sorting
				 E.Branch_ID,BM.Branch_Name,E.Image_Name ,
				 ROW_NUMBER() Over (order by month(Emp_Annivarsary_Date),day(Emp_Annivarsary_Date)) As Row_ID,				
				 10 As Sorting_no,E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID,'' as Date_Of_join,0 as Total_Completed_Years ,@display_cmp_id as Cmp_Id
				 ,'UPCOMING MARRIAGE ANNIVERSARY' As  Reminder_Type,@display_cmp_name As  Company_Name,NULL As Today_Date,0 As Is_Like,0 As Is_Comment,@Emp_Login_Id as Emp_Login_Id
				 INTO #UpcomingAnniversary --Mukti 11012016
				 from T0080_Emp_master E WITH (NOLOCK) -- Prakash Patel 25072014
				 inner join T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
				  inner join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
					(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
					Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
					on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
					Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
				 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
				left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
				left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID
				left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID
				where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
				 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or (CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),@From_Date,120) 
				 and day(Emp_Annivarsary_Date) <= day(Emp_Left_Date)) and cmp_id=@display_cmp_id)  
				 and Emp_Annivarsary_Date <> '' AND Cast(IsNull(Emp_Annivarsary_Date,'1900-01-01') as DateTime) <> '1900-01-01'
				 and ((Month(Emp_Annivarsary_Date)=Month(@From_Date) And day(Emp_Annivarsary_Date)=day(@From_Date)) OR 
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+1) And day(Emp_Annivarsary_Date)=day(@From_Date+1)) OR
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+2) And day(Emp_Annivarsary_Date)=day(@From_Date+2)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+3) And day(Emp_Annivarsary_Date)=day(@From_Date+3)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+4) And day(Emp_Annivarsary_Date)=day(@From_Date+4)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+5) And day(Emp_Annivarsary_Date)=day(@From_Date+5)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+6) And day(Emp_Annivarsary_Date)=day(@From_Date+6)) or
				 (Month(Emp_Annivarsary_Date)=Month(@From_Date+7) And day(Emp_Annivarsary_Date)=day(@From_Date+7))
				  )order by month(Emp_Annivarsary_Date),day(Emp_Annivarsary_Date) 
				--Commented By Mukti(end)25012016 for Marriage anniversary
	
				insert into #Birthday
				Select * FROM
				(
					Select Emp_Full_Name,Date_Of_Birth,Month_Name,Branch_ID,Branch_Name,Image_Name,Row_ID,Sorting_No,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID ,Date_Of_Join,Total_Completed_Years,Cmp_Id ,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment,Emp_Login_Id
					From #UpcomingAnniversary
					--Union All
					--Select '' As Emp_Full_Name,'' As Date_Of_Birth,Month_Name,0 As Branch_ID,'' As Branch_Name,'' As Image_Name,0 As Row_ID,Sorting_No - 0.00005,'' As Alhpa_Emp_Code,'' As Desig_Name,'' As Dept_Name,0 As Emp_ID,'' As Date_Of_Join,'' As Total_Completed_Years,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
					--From #UpcomingAnniversary Group BY Month_Name, Sorting_No,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
				) T
				Order By Cast(Month_Name + '-2000' As DateTime), Alpha_Emp_Code
						
		   --If Above Transaction Does not Returs any employee then we have deleted the name of that company also.
			If @@rowcount = 0
				BEGIN
					insert into #Birthday Values('' ,null,'',0,'','',null,10,'','','',0,'','',@display_cmp_id,'UPCOMING MARRIAGE ANNIVERSARY',@display_cmp_name,null,0,0,@Emp_Login_Id) --Added By Mukti 12012016 							
					--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' and Cast(Sorting_No AS INT) = 10
					--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>UPCOMING MARRIAGE ANNIVERSARY <u></b>'
				END
				drop table #UpcomingAnniversary
-----------------------Marriage anniversary Reminder of upcoming date(end)------------------------------------------------														

-----------------------Work anniversary Reminder of upcoming date(start)------------------------------------------------														
				if(@Setting_Value=1)
				BEGIN
					--insert into #Birthday Values( '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' ,null,'',0,'','',null,12,'','','',0,'','',@display_cmp_id)        
					Select ( Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name) As Emp_Full_Name,
					 E.Date_Of_Join as Date_Of_Birth,
					 --(cast(Day(Date_Of_Join) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_Join)))) As Month_Name,  --''Commented By Ramiz on 06/10/2016
					 (cast(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Date_Of_Join)), 2) as varchar(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(Month(Date_Of_Join)))) As Month_Name,	--Added By Ramiz on 06/10/2016 for Proper Sorting
					 E.Branch_ID,BM.Branch_Name,E.Image_Name ,
					 ROW_NUMBER() Over (order by month(Date_Of_Join),day(Date_Of_Join)) As Row_ID,--Mukti(25012016) for Work Anniversary
					 12 As Sorting_no,E.Alpha_Emp_Code,desg.Desig_Name,dm.Dept_Name,e.Emp_ID,E.Date_Of_Join,DATEDIFF(YEAR,E.Date_Of_Join,GETDATE()) as Total_Completed_Years ,@display_cmp_id as Cmp_Id
					 ,'UPCOMING WORK ANNIVERSARY' As Reminder_Type,@display_cmp_name As Company_Name,NULL As Today_Date,0 As Is_Like,0 As Is_Comment,@Emp_Login_Id as Emp_Login_Id
					 INTO #UpcomingWorkAnniversary --Mukti 11012016
					 from T0080_Emp_master E WITH (NOLOCK) -- Prakash Patel 25072014
					 inner join T0095_Increment I WITH (NOLOCK) on I.Emp_ID = e.emp_id 
					  inner join
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id)	
					 qry2 on qry2.Emp_ID=e.Emp_ID and qry2.Increment_Id=I.Increment_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
					left join T0030_CATEGORY_MASTER CM WITH (NOLOCK) on I.Cat_ID = CM.cat_id
					left join T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) on I.Desig_Id = Desg.Desig_ID
					left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_ID
					where E.Cmp_ID=@display_cmp_id and 1 = (Case When isnull(CM.chk_Birth,1) = 1 then 1 Else 0 End )
					 and E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or (CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),@From_Date,120) 
					 and day(Date_Of_Join) <= day(Emp_Left_Date)) and cmp_id=@display_cmp_id) 
					 and ((Month(Date_Of_Join)=Month(@From_Date) And day(Date_Of_Join)=day(@From_Date)) OR 
					 (Month(Date_Of_Join)=Month(@From_Date+1) And day(Date_Of_Join)=day(@From_Date+1)) OR
					 (Month(Date_Of_Join)=Month(@From_Date+2) And day(Date_Of_Join)=day(@From_Date+2)) or
					 (Month(Date_Of_Join)=Month(@From_Date+3) And day(Date_Of_Join)=day(@From_Date+3)) or
					 (Month(Date_Of_Join)=Month(@From_Date+4) And day(Date_Of_Join)=day(@From_Date+4)) or
					 (Month(Date_Of_Join)=Month(@From_Date+5) And day(Date_Of_Join)=day(@From_Date+5)) or
					 (Month(Date_Of_Join)=Month(@From_Date+6) And day(Date_Of_Join)=day(@From_Date+6)) or
					 (Month(Date_Of_Join)=Month(@From_Date+7) And day(Date_Of_Join)=day(@From_Date+7))
					  )order by month(Date_Of_Join),day(Date_Of_Join) 
					
					insert into #Birthday
					Select * FROM
					(
						Select Emp_Full_Name,Date_Of_Birth,Month_Name,Branch_ID,Branch_Name,Image_Name,Row_ID,Sorting_No,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID ,Date_Of_Join,Total_Completed_Years,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment,Emp_Login_Id
						From #UpcomingWorkAnniversary
						--Union All
						--Select '' As Emp_Full_Name,'' As Date_Of_Birth,Month_Name,0 As Branch_ID,'' As Branch_Name,'' As Image_Name,0 As Row_ID,Sorting_No - 0.00005,'' As Alhpa_Emp_Code,'' As Desig_Name,'' As Dept_Name,0 As Emp_ID,'' As Date_Of_Join,'' As Total_Completed_Years,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
						--From #UpcomingWorkAnniversary Group BY Month_Name, Sorting_No,Cmp_Id,Reminder_Type,Company_Name,Today_Date,Is_Like,Is_Comment
					) T
					Order By Cast(Month_Name + '-2000' As DateTime), Alpha_Emp_Code
					
					
			   --If Above Transaction Does not Returs any employee then we have deleted the name of that company also.
				If @@rowcount = 0
					BEGIN
						insert into #Birthday Values('' ,null,'',0,'','',null,12,'','','',0,'','',@display_cmp_id,'UPCOMING WORK ANNIVERSARY',@display_cmp_name,null,0,0,@Emp_Login_Id) --Added By Mukti 12012016 							
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @display_cmp_name +' </i></b>' and Cast(Sorting_No AS INT) = 12
						--delete from #Birthday where Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>UPCOMING WORK ANNIVERSARY <u></b>'
					END
					drop table #UpcomingWorkAnniversary
				END
-----------------------Work anniversary Reminder of upcoming date(end)------------------------------------------------														
			fetch next from Cur_Upcoming into  @display_cmp_name , @display_cmp_id
			End        
			close Cur_Upcoming        
			Deallocate Cur_Upcoming 
	    END

		
			insert INTO #Emp_Like_Comment
			select L.Emp_Id,B2.Reminder_Type,L.For_date,SUM(like_flag)as Like_Count,
				   CASE WHEN L.Emp_Like_Id = @Emp_Login_Id THEN 1 ELSE 0 END As Like_Flag
				   ,C1.Cmt_Count
			 from T0400_Employee_Like L WITH (NOLOCK) left OUTER JOIN
				#Birthday B2 ON B2.Emp_Id = L.Emp_Id AND B2.Date_Of_birth = L.For_date
				left OUTER JOIN 
				(
					select COUNT(1) as Cmt_Count ,C.Emp_Id
					from T0400_Employee_Comment C WITH (NOLOCK) left OUTER JOIN
						 #Birthday B2 ON B2.Emp_Id = C.Emp_Id AND B2.Date_Of_birth = C.For_date 
					GROUP BY C.Emp_Id,C.For_date
				) C1 ON c1.Emp_Id=B2.Emp_Id
				
			 GROUP BY L.Emp_Id,L.For_date,B2.Reminder_Type,Emp_Like_Id,Cmt_Count
			
			
			--insert INTO #Emp_Like_Comment
			--select C.Emp_Id,b2.Reminder_Type,C.For_date,0,COUNT(1) as Cmt_Count
			--from T0400_Employee_Comment C left OUTER JOIN
			--	#Birthday B2 ON B2.Emp_Id = C.Emp_Id AND B2.Date_Of_birth = C.For_date 
			--GROUP BY C.Emp_Id,C.For_date,B2.Reminder_Type
		
		
	Select	Sorting_No,B.Cmp_Id,B.Emp_Full_Name,B.Month_Name,B.Branch_Name,
		 (CASE WHEN E.Image_Name = '' OR E.Image_Name = '0.jpg'  THEN 
					(Case When E.Gender = 'M' THEN 'Emp_default.png' ELSE 'Emp_Default_Female.png' END) 
				 Else 
					E.Image_Name 
				 END) as Image_Name,
		 B.Alpha_Emp_Code,B.Department_Name,B.Designation_Name,B.Emp_Id,
		 CASE WHEN B.Date_Of_Join = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), B.Date_Of_Join, 103)END AS Date_Of_Join, B.Total_Completed_Years,E.Gender
		 ,B.Reminder_Type,B.Company_Name,B.Today_Date,B.Is_Like,B.Is_Comment,CONVERT(varchar(11), B.Date_Of_birth,103) as Date_Of_birth
		 ,lC.Emp_Like_Count as Like_Count,LC.Emp_Cmt_Count As Comment_Count,B.Emp_Login_Id,LC.Like_Flag
		 
		 from #Birthday B Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) ON B.Emp_Id=E.Emp_ID 
			  left OUTER JOIN #Emp_Like_Comment LC on LC.Emp_Id = B.Emp_Id and LC.Reminder_Type = B.Reminder_Type
				 
		-- left OUTER JOIN(
		--					select SUM(like_flag)as Like_Count ,L.Emp_Id
		--					from T0400_Employee_Like L left OUTER JOIN
		--					#Birthday B2 ON B2.Emp_Id = L.Emp_Id AND B2.Date_Of_birth = L.For_date 
		--					GROUP BY L.Emp_Id,L.For_date,L.Notification_Flag
		--				) L1 on L1.Emp_Id = b.emp_id
		--left OUTER JOIN(
		--					 select like_flag,B2.Emp_Id
		--					 from T0400_Employee_Like L left OUTER JOIN
		--						  #Birthday B2 ON B2.Emp_Id = L.Emp_Id AND B2.Date_Of_birth = L.For_date 
		--					 where L.Emp_Like_Id = @Emp_Login_Id
		--				) L2 on L2.Emp_Id = b.emp_id
						
		-- left OUTER JOIN(
		--					select COUNT(1) as Cmt_Count ,C.Emp_Id
		--						from T0400_Employee_Comment C left OUTER JOIN
		--					#Birthday B2 ON B2.Emp_Id = C.Emp_Id AND B2.Date_Of_birth = C.For_date 
		--					GROUP BY C.Emp_Id,C.For_date
		--				) C1 on C1.Emp_Id = b.emp_id
		--where B.cmp_Id = @Cmp_id 
		order by Sorting_No,Cmp_ID,
		 CAST((CASE WHEN IsNull(Month_Name,'') = '' Then '01-January' Else Month_Name End) + (CASE WHEN CHARINDEX('JANUARY', B.Month_Name) > 0 Then '-2001' Else '-2000' End) As DateTime),Alpha_Emp_Code -- Prakash Patel 25072014		
		 
			 

		--select SUM(like_flag)as Like_Count ,L.Emp_Id,L.Notification_Flag
		--					from T0400_Employee_Like L left OUTER JOIN
		--					#Birthday B2 ON B2.Emp_Id = L.Emp_Id AND B2.Date_Of_birth = L.For_date 
		--					GROUP BY L.Emp_Id,L.For_date,L.Notification_Flag
		
			--GROUP BY L.Emp_Id,L.For_date
			
END

