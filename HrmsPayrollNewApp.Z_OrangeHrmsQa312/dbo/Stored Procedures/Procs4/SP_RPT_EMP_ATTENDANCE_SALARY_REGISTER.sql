

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_ATTENDANCE_SALARY_REGISTER]      
     @Company_Id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric	
	,@Grade_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
	,@Cat_ID        numeric = 0
	,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID Numeric = 0 
	,@Vertical Numeric = 0 
	,@SubVertical Numeric = 0 
	,@subBranch Numeric = 0 
	,@Summary varchar(max)=''
	,@PBranch_ID varchar(200) = '0'
	,@Order_By   varchar(30) = 'Code' 
	,@Report_call varchar(20) = 'IN-OUT'   
    ,@Weekoff_Entry varchar(1) = 'Y'


AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  
     
     declare @Export_Type varchar(50)
	 declare @Type	numeric 
	 declare @Is_Whosoff tinyint 
	 declare @Report_For	varchar(50)
	 Declare @Actual_From_Date datetime
     Declare @Actual_To_Date datetime
	
	Declare @P_Days as numeric(22,2)
	Declare @Arear_Days as Numeric(18,2)
	Declare @Basic_Salary As Numeric(22,2)
	Declare @TDS As Numeric(22,2)
	Declare @Settl As Numeric(22,2)
	Declare @OTher_Allow As Numeric(22,2)
	Declare @Total_Allowance As Numeric(22,2)
	Declare @CO_Amount As Numeric(22,2)
	Declare @Total_Deduction As Numeric(22,2)
	Declare @PT As Numeric(22,2)
	Declare @Loan As Numeric(22,2)
	Declare @Advance As Numeric(22,2)	
	Declare @Net_Salary As Numeric(22,2)	
	Declare @Revenue_Amt As Numeric(22,2)	
	Declare @LWF_Amt As Numeric(22,2)	
	Declare @Other_Dedu As Numeric(22,2)	
	
	Declare @Absent_Day numeric(18,2)
	Declare @Holiday_Day numeric(18,2)
	Declare @WeekOff_Day numeric(18,2)
	--Declare @Leave_Day numeric(18,2) -- Added By Ali 18122013
	Declare @Sal_Cal_Day numeric(18,2)
	
	-- Rohit 26-sep-2012
	Declare @OT_Hours numeric(18,2)
	Declare @OT_Amount numeric(18,2)
	Declare @OT_Rate Numeric(18,2)
	declare @Fix_OT_Shift_Hours varchar(40)
	declare @Fix_OT_Shift_seconds numeric(18,2)
    Declare @Net_Round As Numeric(22,2)
    
	declare @Travel_Amount as numeric(18,2)
	      
	        set @Export_Type= 'EXCEL'
	        set @Type =0
	        set @Is_Whosoff=0
	        set @Report_For=''

	CREATE table #Att_Muster_Excel 
	  (	
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			Status		varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Leave_Count	numeric(5,2),
			WO_HO		varchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Status_2	varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Row_ID		numeric ,
			WO_HO_Day	numeric(3,2) default 0,
			P_days		numeric(5,2) default 0,
			A_days		numeric(5,2) default 0 ,
			Join_Date	Datetime default null,
			Left_Date	Datetime default null,
			Gate_Pass_Days numeric(18,2) default 0, 
			Late_Deduct_Days numeric(18,2) default 0, -- Added by Gadriwala Muslim 07042015
			Early_Deduct_Days numeric(18,2) default 0, -- Added by Gadriwala Muslim 07042015
			Emp_code    varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Emp_Full_Name  varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Branch_Address varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
			comp_name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Branch_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Dept_Name  varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Grd_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Desig_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
			P_From_date  datetime,
			P_To_Date datetime,
			BRANCH_ID numeric(18,0),
			Desig_Dis_No numeric(18,2) default 0,          ---added jimit 31082015 
			SUBBRANCH_NAME VARCHAR(200) DEFAULT '' COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
	  )
	  
	  	  
CREATE NONCLUSTERED INDEX IX_Data ON dbo.#Att_Muster_Excel
	(	Emp_Id,Emp_code,Row_ID ) 
	
	
  
exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Company_Id,@From_Date,@To_Date,@Branch_ID,
									  @Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,
									  @Emp_ID,@Constraint,@Report_For,@Export_Type
			
  	
  				  
Create Table #Leave_Code
(
	Leave_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
)

					  
Insert into #Leave_Code 									  
select Status from #Att_Muster_Excel where status_2 is not null and status_2 <>'' and Status_2 <>'LC' Group by Status

Update dbo.#Att_Muster_Excel set status = status  +  '-LC'  where status_2 = 'LC' 

 CREATE table #CrossTab        --Added by Gadriwala Muslim 24042015 
  (   
  Code varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
  Alpha_Emp_Code varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,       
  NAME_OF_THE_EMPLOYEE   varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
  Father_Name   varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
  Gender Varchar(10),
  Designation varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
  Department varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
  Date_of_joining varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
 -- Enroll_No numeric    ,
  ESI_No varchar(150),
  PF_No VARCHAR(150),
  Wages_Fixed_Including_VDA numeric(18,2),
  Emp_id int,     -------------- Add by Jignesh 31-07-2014 -------
  Late_with_leave bit, --Added by Nimesh 15-Jul-2015 (To Adjust Late Comming in Leave)  
  )              

 CREATE table #Unpaid_Leave
  (   
  Code varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,         
  Unpaid_Leave numeric(18,2)
  )              
	Declare @Month_Days as numeric
	Set @Month_Days = DATEDIFF (DD,@From_Date,@To_Date) + 1
      
  declare @Description as varchar(900)        
  Declare @Description_Org as varchar(900)        
  declare @test as Varchar(4000)        
  declare @test1 as varchar(4000)        

If @Month_Days = 31
		Begin 
			DECLARE Att_Muster CURSOR FOR   
			Select Top 38
			Case When cast(Row_ID as varchar(2)) ='32' then 'P' 
			else 
			case When cast(Row_ID as varchar(2)) ='33' then 'A' 
			else
			case When cast(Row_ID as varchar(2)) ='34' then 'L'
			else 
			case When cast(Row_ID as varchar(2)) ='35' then 'W'
			else
			case When cast(Row_ID as varchar(2)) ='36' then 'H'
			else
			case When cast(Row_ID as varchar(2)) ='37' then 'LC'
			else
			case When cast(Row_ID as varchar(2)) ='38' then 'GP'  -- Changed by Gadriwala Muslim 27042015
			
			else
			Cast(DATEPART(day,For_Date) as varchar(2))
			end
			end
			end
			end
			end
			end
			End as Row_ID, For_Date
			from #Att_Muster_Excel  order by Emp_ID,For_Date --asc  
		End
Else If @Month_Days = 30
		Begin 
			DECLARE Att_Muster CURSOR FOR   
			Select Top 38
			Case When cast(Row_ID as varchar(2)) ='31' then '0' 
			Else
			Case When cast(Row_ID as varchar(2)) ='32' then 'P' 
			else 
			case When cast(Row_ID as varchar(2)) ='33' then 'A' 
			else
			case When cast(Row_ID as varchar(2)) ='34' then 'L'
			else 
			case When cast(Row_ID as varchar(2)) ='35' then 'W'
			else
			case When cast(Row_ID as varchar(2)) ='36' then 'H'
			else
			case When cast(Row_ID as varchar(2)) ='37' then 'LC'
			else
			case When cast(Row_ID as varchar(2)) ='38' then 'GP'  
			
			else
			Cast(DATEPART(day,For_Date) as varchar(2))
			end
			end
			end
			end
			end
			end
			end
			End as Row_ID, For_Date
			from #Att_Muster_Excel  order by Emp_ID,For_Date --asc  
		End
Else If @Month_Days = 28
		Begin 
			DECLARE Att_Muster CURSOR FOR   
			Select Top 38
			Case When cast(Row_ID as varchar(2)) ='29' then 'AA' 
			Else
			Case When cast(Row_ID as varchar(2)) ='30' then 'BB' 
			Else
			Case When cast(Row_ID as varchar(2)) ='31' then 'CC' 
			Else
			Case When cast(Row_ID as varchar(2)) ='32' then 'P' 
			else 
			case When cast(Row_ID as varchar(2)) ='33' then 'A' 
			else
			case When cast(Row_ID as varchar(2)) ='34' then 'L'
			else 
			case When cast(Row_ID as varchar(2)) ='35' then 'W'
			else
			case When cast(Row_ID as varchar(2)) ='36' then 'H'
			else
			case When cast(Row_ID as varchar(2)) ='37' then 'LC'
			else
			case When cast(Row_ID as varchar(2)) ='38' then 'GP'  -- Changed by Gadriwala Muslim 27042015
			else
			Cast(DATEPART(day,For_Date) as varchar(2))
			end
			end
			end
			end
			end
			end
			End
			End
			end
			End as Row_ID, For_Date
			from #Att_Muster_Excel  order by Emp_ID,For_Date --asc  
		End
Else If @Month_Days = 29
		Begin 
			DECLARE Att_Muster CURSOR FOR   
			Select Top 38
			Case When cast(Row_ID as varchar(2)) ='30' then 'AA' 
			Else
			Case When cast(Row_ID as varchar(2)) ='31' then 'BB' 
			Else
			Case When cast(Row_ID as varchar(2)) ='32' then 'P' 
			else 
			case When cast(Row_ID as varchar(2)) ='33' then 'A' 
			else
			case When cast(Row_ID as varchar(2)) ='34' then 'L'
			else 
			case When cast(Row_ID as varchar(2)) ='35' then 'W'
			else
			case When cast(Row_ID as varchar(2)) ='36' then 'H'
			else
			case When cast(Row_ID as varchar(2)) ='37' then 'LC'
			else
			case When cast(Row_ID as varchar(2)) ='38' then 'GP'  -- Changed by Gadriwala Muslim 27042015
			else
			Cast(DATEPART(day,For_Date) as varchar(2))
			end
			end
			end
			end
			end
			end
			End
			end
			End as Row_ID, For_Date
			from #Att_Muster_Excel  order by Emp_ID,For_Date --asc  
		End
		
 
  DECLARE @INSERT_WEEKDAY VARCHAR(MAX);
  DECLARE @VALUE_WEEKDAY VARCHAR(MAX);
  DECLARE @WEEKDAY VARCHAR(2);	
  DECLARE @FOR_DATE DATETIME;
  
  SET @INSERT_WEEKDAY = '';
  SET @VALUE_WEEKDAY = ''

  OPEN Att_Muster        
   fetch next from Att_Muster into @Description, @FOR_DATE
   while @@fetch_status = 0        
    Begin        
             
        
        IF ISNUMERIC(@Description) = 1
        BEGIN
			
			IF CAST(@Description AS NUMERIC) > 0
			BEGIN
				
				SET @WEEKDAY = DATENAME(DW, @FOR_DATE);
				SET @INSERT_WEEKDAY = @INSERT_WEEKDAY + '[' + @Description + '],'
				SET @VALUE_WEEKDAY = @VALUE_WEEKDAY + '''' + @WEEKDAY + ''','
				
			END
        END
        
		set @Description_Org=@Description        
		set @Description=replace(@Description,' ','_')        
		set @Description=replace (@Description,'.','_')        

			If @Description <> 'AA' And @Description <>'BB' and @Description <> 'CC' and @Description <> '0'
			Begin
				Set @test ='alter table  #CrossTab ADD ['+ @Description +']  varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS default '''''        
				exec(@test)         				
				set @test=''        
				
			End             
    fetch next from Att_Muster into @Description, @FOR_DATE        
    End        
  close Att_Muster         
  deallocate Att_Muster        
  
	IF @Is_Whosoff <> 1
		BEGIN
			SET @INSERT_WEEKDAY = 'INSERT INTO #CrossTab(' + @INSERT_WEEKDAY + 'Code)Values(' + @VALUE_WEEKDAY + '0)';
			EXEC (@INSERT_WEEKDAY);
		END
	
 
Set @test ='alter table  #CrossTab ADD [Payable_Present_Days] varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS default '''''        
exec(@test)         
set @test='' 

Set @test ='alter table  #CrossTab ADD [Early_Deduct_Days] numeric(18,2) default 0'        
exec(@test)         
set @test=''

Set @test ='alter table  #CrossTab ADD [WO_HO_Day] numeric(18,2) default 0'        
exec(@test)         
set @test='' 

Set @test ='alter table  #CrossTab ADD [Total_Days] varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS default '''''        
exec(@test)         
set @test='' 

  
 --Added by Gadriwala Muslim 24042015 - Start
 insert into #CrossTab(Code,Alpha_Emp_Code,NAME_OF_THE_EMPLOYEE,Father_Name,Gender,Designation,Department,Date_of_joining,ESI_No,PF_No,Wages_Fixed_Including_VDA,Emp_id,Late_with_leave)   
 select distinct  AM.Emp_Code,EM.Alpha_Emp_Code,AM.Emp_Full_Name,em.Father_name,
 Case WHEN EM.Gender='M' THEN 'Male' Else 'Female' End Gender,
 AM.Desig_Name,Am.Dept_Name,convert(varchar,Date_of_join ,103),EM.SIN_No,EM.SSN_No,I.Gross_Salary,EM.Emp_Id,0
 from #Att_Muster_Excel AM 
 Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) on AM.Emp_Id = EM.Emp_Id
 Left outer join T0095_INCREMENT I WITH (NOLOCK) on em.Increment_ID=I.Increment_ID

--P A L W H LC
  declare @Code as varchar(50)        
  Declare @EmpName as varchar(200) 
  Declare @Status as varchar(50)  
  Declare @Status_2 as varchar(50)  
  Declare @Extra_AB_Deduction as numeric(18,2)
  Declare @Present_days as numeric(18,2)
  Declare @A_Days as Numeric(18,2)
  Declare @Unpaid_Leave_Days as Numeric(18,2)
  Declare @Pre_Emp_Code as varchar(50)
  Declare @Absent_Days as numeric(18,2)
  Declare @Leave_Count as Numeric(18,2)
  Declare @Gate_Pass_Days as numeric(18,2) -- Gadriwala Muslim 27032015
  Declare @Late_Deduct_Days as numeric(18,2) -- Gadriwala Muslim 27032015
  Declare @Early_Deduct_Days as numeric(18,2)-- Gadriwala Muslim 27032015
  Declare @WO_HO_Days as numeric(18,2) -- Gadriwala Muslim 27032015   
                 
  SET @Description = ''        
  Set @Extra_AB_Deduction = 0
  Set @Present_days = 0
  Set @A_Days = 0
  Set @P_Days = 0
  Set @Unpaid_Leave_Days = 0
  Set @Leave_Count = 0
  set @Gate_Pass_Days = 0 -- Gadriwala Muslim 27032015
  set @Late_Deduct_Days = 0 -- Gadriwala Muslim 27032015
  set @Early_Deduct_Days = 0 -- Gadriwala Muslim 27032015
  set @WO_HO_Days = 0 -- Gadriwala Muslim 27032015
        
  DECLARE Att_MusterValue CURSOR FOR        
  --select Acc_Id,sum(TotalValue) as TotalValue ,LocationName from View_AssetItem_Master where CoCode  = @CoCode and YearId = @YearId group by Acc_ID,LocationName order by Acc_id        
  select A.Emp_code,A.Emp_Full_Name,Status,isnull(Status_2,'') as  Status_2, P_Days,A_Days,WO_HO_Day,
  --Row_ID 
  case When cast(Row_ID as varchar(2) ) ='32' then 'P' 
  else 
  case When cast(Row_ID as varchar(2) ) ='33' then 'A' 
  else
  case When cast(Row_ID as varchar(2) ) ='34' then 'L'
  else 
  case When cast(Row_ID as varchar(2)) ='35' then 'W'
  else
  case When cast(Row_ID as varchar(2)) ='36' then 'H'
  else
  case When cast(Row_ID as varchar(2)) ='37' then 'LC'
  else
  case When cast(Row_ID as varchar(2)) ='38' then 'GP'
  else
  Cast(DATEPART(day,For_Date) as varchar(2))
  end
  end
  end
  end
  end
  end
  End as Row_ID,
  Isnull(Extra_AB_Deduction,0), Leave_Count,Early_Deduct_Days
  from #Att_Muster_Excel A Inner Join T0080_EMP_MASTER E WITH (NOLOCK) on A.Emp_Id = E.Emp_ID
  order by A.Emp_Id,For_Date      
   
  OPEN Att_MusterValue        
   fetch next from Att_MusterValue into @Code,@EmpName,@Status,@Status_2,@P_Days,@A_Days,@WO_Ho_Days,@Description,@Extra_AB_Deduction,@Leave_Count,@Early_Deduct_Days
   while @@fetch_status = 0        
    Begin        
		If @Pre_Emp_Code <> @Code
			Set @Unpaid_Leave_Days = 0

     set @Description_Org=@Description        
     set @Description=replace(@Description,' ','_')        
     set @Description=replace (@Description,'.','_')                 
             
     Set @test1 ='Update #CrossTab set [' + cast(@Description as varchar(2)) + '] = ''' +  Cast(@Status as varchar(50))  + '''  Where  Code = '''+ @Code + ''''        
     
     exec(@test1)        
     set @test=''
     
        --Added by Gadriwala Muslim 27032015 - Start
       Update  #CrossTab set Early_Deduct_Days = Early_Deduct_Days + isnull(@Early_Deduct_Days,0) where Code = @Code 
						     
						     IF (isnull(@P_Days,0) = 1)  -- For Present Day in Week off or Holiday Day
								begin
								 Update #CrossTab  set  WO_HO_Day =  isnull(WO_HO_Day,0) + isnull(@WO_Ho_Days,0) where Code =@Code
								end
							 else IF (ISNULL(@P_days,0) < isnull(@WO_HO_Days,0) and ISNULL(@P_days,0) > 0)  -- Work Half Day on Week off or Holiday
								begin
									Update #CrossTab  set  WO_HO_Day =  isnull(WO_HO_Day,0) + (isnull(@WO_Ho_Days,0) - ISNULL(@P_days,0)) 
									where Code =@Code
								end	
		--Added by Gadriwala Muslim 27032015 - End
	
	
	     If (@A_Days = 1 or @A_Days = 0.5) and not @Status_2 is null and @Status_2 <> '' and @Status_2 <> 'LC' --And @Leave_Count Is null	 --Commented by Hardik 02/12/2015 as Unpaid leave and Paid leave on same date, absent day count showing wrong							
			begin						
					Set @Unpaid_Leave_Days = @Unpaid_Leave_Days + (@Status_2 - Isnull(@Leave_Count,0))
			end
	
		If @Description = 'A'
			Begin
				If @Unpaid_Leave_Days > 0
					Insert Into #Unpaid_Leave
					Select @Code,@Unpaid_Leave_Days
					
				If @Unpaid_Leave_Days > 0 and @Status >= @Unpaid_Leave_Days And @Leave_Count Is null
					Begin
						Set @Status = @Status - @Unpaid_Leave_Days
					End
				
				--Set @Absent_Days = Isnull(@Status,0)  + (Isnull(@Status,0)  * @Extra_AB_Deduction)
				Set @Absent_Days = case when (Isnull(@Status,0)  * @Extra_AB_Deduction) % 0.50 = 0 then (Isnull(@Status,0)  * @Extra_AB_Deduction) else (Isnull(@Status,0)  * @Extra_AB_Deduction)+0.25 END
				Select @Present_days = Isnull(P,0) From #CrossTab Where Code = @Code
				If @Extra_AB_Deduction > 0
					Begin 
						If @Present_days >= @Absent_Days
							Begin
							
							 Set @test1 ='Update #CrossTab set Payable_Present_Days =  ' +  Cast(@Present_days - Isnull(@Absent_Days,0) As Varchar(50))   + ' Where  Code = '''+ @Code + ''''        
							 exec(@test1)        
							 set @test=''    
							 
							End
						Else
							Begin
								Update #CrossTab Set Payable_Present_Days=0 Where Code = @Code
							End
					End
				Else
					Begin
						Update #CrossTab Set Payable_Present_Days=@Present_days Where Code = @Code
					End
				
			End

			IF @Description = 'GP' and @Is_Whosoff = 1 -- Added by Gadriwala Muslim 17062015 - Start
			begin
				
				If isnull(@Extra_AB_Deduction,0) = 0
					begin
						
						Declare @Emp_Branch_Id  numeric(18,0)
						Declare @temp_Emp_ID as numeric(18,0)
						Declare @WO_Inc as tinyint
						Declare @HO_Inc as tinyint
						Declare @Payable_Present_days numeric(18,2)
						
						set @Emp_Branch_Id = 0
						set @temp_Emp_ID = 0
						set @WO_Inc = 0
						set @HO_Inc = 0
						set @Payable_Present_days = 0
						select @temp_Emp_ID = Emp_ID from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Code		
						
						
						select @Emp_Branch_Id = branch_id from dbo.T0095_INCREMENT WITH (NOLOCK)
						where Emp_ID = @temp_Emp_ID and Increment_ID = 
						(select MAX(Increment_ID) from dbo.T0095_INCREMENT WITH (NOLOCK) where Emp_ID = @temp_Emp_ID and Increment_Effective_Date<= @To_Date)
						
					    select @HO_Inc =  Inc_Holiday,@WO_Inc = Inc_Weekoff from T0040_GENERAL_SETTING WITH (NOLOCK) where Branch_ID = @Emp_Branch_Id
								and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
										where For_Date <= @To_Date and Branch_ID = @Emp_Branch_Id and Cmp_ID = @Company_Id)   
						
						
						declare @WeekOff_Days numeric(18,2)
						declare @Holiday_Days numeric(18,2)
						Declare @LC_Days numeric(18,2)
						Declare @GP_Days numeric(18,2)
						Declare @Paid_Leave numeric(18,2)
						
						select @WeekOff_Days = case when W = '' then 0 else cast(W as numeric(18,2)) end,
							   @Holiday_Days = case when H = '' then 0 else cast(H as numeric(18,2)) end, 
							   @LC_Days = case when LC = '' then 0 else cast(Lc as numeric(18,2)) end,
							   @GP_Days = case when GP = '' then 0 else cast(GP as numeric(18,2)) end,
							   @Paid_Leave = case when L = '' then 0 else CAST(L as numeric(18,2))end  
						from #CrossTab where Code = @Code
												
						
						set @Payable_Present_days = isnull(@Present_days,0) 
										
						 if isnull(@HO_Inc,0) = 1
							set @Payable_Present_days = @Payable_Present_days +  isnull(@Holiday_Days,0)
							
						 if ISNULL(@Wo_Inc,0) = 1
							set @Payable_Present_days = @Payable_Present_days +  isnull(@WeekOff_Days,0)	
							
						set	@Payable_Present_days = (@Payable_Present_days + isnull(@Paid_Leave,0)) - ( isnull(@LC_Days,0) + isnull(@GP_Days,0))
						
						If @Payable_Present_days < 0 
						 set @Payable_Present_days	= 0
						 
						Update #CrossTab Set Payable_Present_Days= @Payable_Present_days Where Code = @Code
					end
			end
								-- Added by Gadriwala Muslim 17062015 - End	
			Set @Pre_Emp_Code = @Code
             
    fetch next from Att_MusterValue into @Code,@EmpName,@Status,@Status_2,@P_Days,@A_Days,@WO_Ho_Days,@Description,@Extra_AB_Deduction,@Leave_Count,@Early_Deduct_Days
    End        
  close Att_MusterValue         
  deallocate Att_MusterValue                  

	
--select 1321
---- Add by Jignesh 05-08-2014---------------
	update #CrossTab set A = isnull(A,0)-isnull(ul.Unpaid_Leave,0)
	from #CrossTab inner join T0080_Emp_Master em on Code= em.Alpha_Emp_Code COLLATE SQL_Latin1_General_CP1_CI_AS and cmp_id = @Company_Id
	Left Outer Join (Select Code,isnull(SUM(Unpaid_Leave),0) as Unpaid_Leave from #Unpaid_Leave group by Code ) as UL on #CrossTab.Code = UL.Code
------------------ End ---------------------------

---- Added by rohit on 24092013
update  #CrossTab set total_Days = 
case when 
(
--isnull(cast((case When P = '' then '0.0' else isnull(P,0) end) as numeric(18,2)),0) + 
isnull(cast((case When Payable_Present_Days = '' then '0.0' else isnull(Payable_Present_Days,0) end) as numeric(18,2)),0) + 
isnull(cast((case When H = '' then '0.0' else isnull(H,0) end) as numeric(18,2)),0) + 
isnull(cast((case When W = '' then '0.0' else isnull(W,0) end) as numeric(18,2)),0) +  
isnull(cast((case When L = '' then '0.0' else isnull(L,0) end) as numeric(18,2)),0) -
isnull(cast((case When GP = '' then '0.0' else isnull(GP,0) end) as numeric(18,2)),0) -
(CASE WHEN (Late_with_leave = 0) THEN isnull(cast((case When LC = '' then '0.0' else isnull(LC,0) end) as numeric(18,2)),0) ELSE 0 END) - 
isnull(Early_Deduct_Days,0) -
isnull(WO_HO_Day,0)--+
) < 0
THEN 0
else
(
--isnull(cast((case When P = '' then '0.0' else isnull(P,0) end) as numeric(18,2)),0) + 
isnull(cast((case When Payable_Present_Days = '' then '0.0' else isnull(Payable_Present_Days,0) end) as numeric(18,2)),0) + 
isnull(cast((case When H = '' then '0.0' else isnull(H,0) end) as numeric(18,2)),0) + 
isnull(cast((case When W = '' then '0.0' else isnull(W,0) end) as numeric(18,2)),0) +  
isnull(cast((case When L = '' then '0.0' else isnull(L,0) end) as numeric(18,2)),0) -
isnull(cast((case When GP = '' then '0.0' else isnull(GP,0) end) as numeric(18,2)),0) -
(CASE WHEN Late_with_leave = 0 THEN isnull(cast((case When LC = '' then '0.0' else isnull(LC,0) end) as numeric(18,2)),0) ELSE 0 END) -
isnull(Early_Deduct_Days,0) -
isnull(WO_HO_Day,0)
) 
end
from #CrossTab inner join T0080_Emp_Master em on Code=em.Alpha_Emp_Code COLLATE SQL_Latin1_General_CP1_CI_AS and cmp_id = @Company_Id
Left Outer Join #Unpaid_Leave UL on #CrossTab.Code = UL.Code

-- Ended by rohit on 24092013

----------- Add by jignesh 31-07-2014 Leave Name ---------------
		Declare @qry as nvarchar(max)

		Create Table #EmpLaveDetail
		(
		id_num int IDENTITY(1,1),
		iEmp_id int
		)

		Create Table #EmpData
		(
		iCode varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Payable_Present_Days	 varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Total_Days varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Early_Deduct_Days numeric(18,2) default 0  -- Added by Gadriwala 27032015
	
		)

-------------------End -------------------------------



--for Salary Register(start)
Declare @Emp_Cons Table
	(
		Emp_ID	numeric ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC 
	)
			
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			INSERT INTO @Emp_Cons
			SELECT DISTINCT V.emp_id,branch_id,V.Increment_ID FROM V_Emp_Cons V 
			  Inner Join
						dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID = V.Emp_ID 
			LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = V.Emp_ID
			WHERE 
		      V.cmp_id=@Company_id 				
		       AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))          
		       AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)      
		   AND Grd_ID = ISNULL(@Grade_ID ,Grd_ID)      
		   AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))      
		   AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
		   AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
		   AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
		   And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))
		   And ISNULL(Vertical_ID,0) = ISNULL(@Vertical,IsNull(Vertical_ID,0))
		   And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical,IsNull(SubVertical_ID,0))
		   And ISNULL(subBranch_ID,0) = ISNULL(@subBranch,IsNull(subBranch_ID,0)) -- Added on 06082013
		   and month(ms.Month_End_Date)  = month(@To_Date) and year(ms.Month_End_Date)  = year(@To_Date)
		   and ms.Is_FNF = 0
		   AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id) 
		      AND Increment_Effective_Date <= @To_Date 
		      AND 
                       ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
						OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
						OR (Left_date IS NULL AND @To_Date >= Join_Date)      
						OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						)
			 
			ORDER BY Emp_ID
						
			DELETE  FROM @Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment WITH (NOLOCK)
				WHERE  Increment_effective_Date <= @to_date
				GROUP BY emp_ID )
		end	
	
	CREATE table #CTCMast
	(   Cmp_ID			numeric(18,0)
	   ,Emp_ID1			numeric(18,0) primary key
	   ,Date_of_Suspension_of_employees_if_any varchar(30)  --Left_Date
	   ,No_Of_Payable_Days numeric(18,2)  --Sal_Cal_Day
	   ,Total_OT_Hours_Worked numeric(18,2)
	   ,Basic_Salary	numeric(18,2)
	   ,Settl_Salary	Numeric(18,2)
	   ,Other_Allow		Numeric(18,2)
	   ,Payment_Mode1 VARCHAR(200)
	  -- ,Employee_Signature VARCHAR(200)--blank field
	  -- ,Enroll_No       VARCHAR(50)	DEFAULT ''	
	 )
	
	Declare @Columns nvarchar(4000)
	Declare @Leave_Columns nvarchar(Max)
	Declare @Leave_Name nvarchar(30)
	declare @Payment_Mode as VARCHAR(200)
	set @Leave_Columns = ''
	Set @Columns = '#'
	declare @count_leave as numeric(18,2)
	set @count_leave = 0
	
	declare @String as varchar(max)
	set @string=''
		
	-- Changed By Ali 22112013 EmpName_Alias
	Insert Into #CTCMast 
	SELECT e.Cmp_ID,e.Emp_ID AS Emp_ID1,
	 case when CONVERT(varchar(11), isnull(Emp_Left_Date,''), 103) ='01/01/1900' then 'NA' else CONVERT(varchar(11), isnull(Emp_Left_Date,''), 103) end,	 
	  0,0,0,0,0,Case Upper(Payment_Mode) When 'BANK TRANSFER' THEN Inc_Bank_AC_No When 'CASH' Then 'CASH' Else 'CHEQUE' End Bank_Ac_No
		from T0080_EMP_MASTER e	WITH (NOLOCK) inner join
		( select I.Emp_id,I.Basic_Salary,I.CTC,I.Inc_Bank_AC_No,Payment_Mode,I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_Id,I.Type_ID,I.Cat_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID,I.Segment_ID,I.Center_ID from T0095_Increment I WITH (NOLOCK) inner join 
			( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
			where Increment_Effective_date <= @To_Date
			and cmp_id = @Company_id
			group by emp_ID  ) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
	inner join @Emp_Cons ec on e.Emp_ID = ec.Emp_ID
	left outer join T0030_BRANCH_MASTER bm WITH (NOLOCK) on Inc_Qry.Branch_ID = bm.Branch_ID
	left outer join T0040_GRADE_MASTER ga WITH (NOLOCK) on Inc_Qry.Grd_ID = ga.Grd_ID
	left outer join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on Inc_Qry.Dept_ID = dm.Dept_Id
	left outer join T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on Inc_Qry.Desig_Id = dnm.Desig_ID
	left outer join T0040_TYPE_MASTER tm WITH (NOLOCK) on Inc_Qry.Type_ID = tm.Type_ID
	left outer join T0030_CATEGORY_MASTER CT WITH (NOLOCK) on CT.Cat_ID=Inc_Qry.Cat_Id
	left outer join T0040_Vertical_Segment VT WITH (NOLOCK) on VT.Vertical_ID=Inc_Qry.Vertical_ID
	left outer join T0050_SubVertical ST WITH (NOLOCK) on ST.SubVertical_ID=Inc_Qry.SubVertical_ID
	left outer join T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=Inc_Qry.subBranch_ID 
	left outer join T0040_Business_Segment BSG WITH (NOLOCK) on BSG.Segment_ID=Inc_Qry.Segment_ID
	left outer join T0040_Cost_Center_Master CC WITH (NOLOCK) on CC.Center_ID = Inc_Qry.Center_ID
	
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)
	Declare @AD_NAME_DYN nvarchar(100)
	declare @val nvarchar(500)
	
	DECLARE Leave_Cursor CURSOR FOR
			Select Leave_Name
				 from T0120_Leave_Approval la WITH (NOLOCK)
				 inner join @Emp_cons ec on la.emp_ID = ec.emp_ID 
				 Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
				 inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
				 inner join ( select I.Emp_Id ,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Company_id
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id	 ) I_Q on E.Emp_ID = I_Q.Emp_ID  
				where  la.cmp_ID=@Company_id  and ((lad.From_Date >=@From_Date and lad.From_Date <=@To_Date	) or 	(lad.to_Date >=@From_Date and lad.to_Date <=@To_Date	))				  
				group by Leave_Name
		OPEN Leave_Cursor
			fetch next from Leave_Cursor into @Leave_Name
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null '
					
					exec (@val)	
					Set @val = ''
					
					
					Set @Leave_Columns = @Leave_Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
					fetch next from Leave_Cursor into @Leave_Name
				End
		close Leave_Cursor	
		deallocate Leave_Cursor
		
		--SELECT * FROM #CTCMast
		
		Set @val = 'Alter table  #CTCMast Add Total_Paid_Leave_Days numeric(18,2) default 0'
		exec (@val)	   
			   
		Set @val = 'Alter table  #CTCMast Add Total_Leave_Days numeric(18,2) default 0'
		exec (@val)	 
		  
	declare @sum_of_allownaces_earning as varchar(Max)
	set @sum_of_allownaces_earning=''
	Declare @AD_LEVEL Numeric
	set @AD_LEVEL = 0
	

		
	--DECLARE @sum_of_allownaces_earning_Total As Varchar(MAX)
	--SET @sum_of_allownaces_earning_Total = ''
	
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME,AD_LEVEL from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id --and month(T.For_Date) >=  MONTH(@From_Date) and Year(T.For_Date) >= YEAR(@From_Date) and month(T.For_Date) <=  MONTH(@To_Date) and Year(T.For_Date) <= YEAR(@To_Date)
				--and T.For_Date between @From_Date and @To_Date
				and T.For_Date >= @From_Date and T.To_date <= @To_Date
				and (isnull(A.Ad_Not_Effect_Salary,0) = 0 OR ISNULL(T.ReimShow,0) = 1) and Ad_Active = 1 and AD_Flag = 'I'
		
		Group by AD_SORT_NAME ,AD_LEVEL
		ORDER BY AD_LEVEL ASC
		
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					set @sum_of_allownaces_earning=@sum_of_allownaces_earning + ',sum(' + @AD_NAME_DYN + ') as ' + @AD_NAME_DYN +''
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor

		Set @val = 'Alter table  #CTCMast Add Arear_Amount numeric(18,2) default 0 not null'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add Leave_Encash_Amount NUMERIC(18,2) DEFAULT 0 NOT NULL'	----Ankit 26102015
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add OT_Amount NUMERIC(18,2) DEFAULT 0 NOT NULL'	
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Maternity_Benefits NUMERIC(18,2) DEFAULT 0 NOT NULL'	
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Others NUMERIC(18,2) DEFAULT 0 NOT NULL'	
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Subsistence_Allowance_If_Any NUMERIC(18,2) DEFAULT 0 NOT NULL'	
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Gross_Salary numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add PT_Amount numeric(18,2) default 0 not null '
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add Loan_Amount numeric(18,2) default 0 not null'
		exec (@val)	

		--Set @val = 'Alter table  #CTCMast Add Advance_Amount numeric(18,2) default 0 not null'
		--exec (@val)	

--  Added By rohit for Add two column OT Amount and OT Hours  on 26-sep-2012
		Set @val = 'Alter table  #CTCMast Add OT_Rate numeric(18,2) default 0 not null'
		exec (@val)	
		
		--Set @val = 'Alter table  #CTCMast Add OT_Hours numeric(18,2) default 0 not null'
		--exec (@val)	
	
		--Set @val = 'Alter table  #CTCMast Add OT_Amount numeric(18,2) default 0 not null'
		--exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Society numeric(18,2) default 0 not null'
		exec (@val)	
		
		--Set @val = 'Alter table  #CTCMast Add Insurance numeric(18,2) default 0 not null'
		--exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Salary_Advance numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Fines numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Damage_Loss numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Travel_Amount numeric(18,2) default 0 not null'
		exec (@val)	--Added by Sumit 06102015
	
	declare @sum_of_allownaces_deduct as varchar(Max)
	set @sum_of_allownaces_deduct=''
	SET @AD_LEVEL = 0
		
	Declare Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME,Ad_Level from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id --and month(T.For_Date) >=  MONTH(@From_Date) and Year(T.For_Date) >= YEAR(@From_Date) and month(T.For_Date) <=  MONTH(@To_Date) and Year(T.For_Date) <= YEAR(@To_Date)
				and T.For_Date >= @From_Date and T.To_date <= @To_Date
				and (isnull(A.Ad_Not_Effect_Salary,0) = 0 OR ISNULL(T.ReimShow,0) = 1) and Ad_Active = 1 and AD_Flag = 'D'
		Group by AD_SORT_NAME  ,AD_LEVEL
		ORDER BY AD_LEVEL
		
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					set @sum_of_allownaces_deduct=@sum_of_allownaces_deduct + ',sum(' + @AD_NAME_DYN + ') as ' + @AD_NAME_DYN +''
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					exec (@val)	
					Set @val = ''
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN,@AD_LEVEL
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
		

		Set @val = 'Alter table  #CTCMast Add Revenue_Amount numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add LWF_Amount numeric(18,2) default 0  not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Other_Dedu numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Gate_Pass_Amount numeric(18,2) default 0 not null'
		exec (@val)	 -- Added by Gadriwala Muslim 09012015
		
		Set @val = 'Alter table  #CTCMast Add Asset_Installment_Amount numeric(18,2) default 0 not null'
		exec (@val)	 -- Added by Mukti 07042015
		
		Set @val = 'Alter table  #CTCMast Add Travel_Advance_Amount numeric(18,2) default 0 not null'
		exec (@val)	--Added by Sumit 06102015

		Set @val = 'Alter table  #CTCMast Add Total_Deduction numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Net_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Payment_Mode Varchar(200)'
		exec (@val)	
						
		Set @val = 'Alter table  #CTCMast Add Employee_Signature Varchar(200)'
		exec (@val)	
		
			
		-----CTC ALLOWANCE --------------
		
		DECLARE @AD_NAME_DYN_CTC nvarchar(100)
		DECLARE @Sum_Of_Allownaces_Earning_CTC as varchar(Max)
		DECLARE @Sum_Of_Allownaces_Earning_CTC_Total as varchar(Max)
		
		SET @AD_NAME_DYN_CTC = ''
		SET @Sum_Of_Allownaces_Earning_CTC = ''
		SET @Sum_Of_Allownaces_Earning_CTC_Total = ''
		
				
		declare @total_paid_leave_cur numeric(18,2)
		set @total_paid_leave_cur = 0
	
	Declare CTC_UPDATE CURSOR FOR
		select Cmp_Id,Emp_Id1,Basic_Salary,Payment_Mode1 from #CTCMast
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC,@Payment_Mode
	while @@fetch_status = 0
		Begin	
			
		--Hardik for Arear Calculation on 27/07/2012
		Declare @Arear_Basic As Numeric(22,6)
		Declare @Arear_Earn_Amount as Numeric(22,6)
		Declare @Arear_Dedu_Amount as Numeric(22,6)
		Declare @Arear_Net As Numeric(22,6)

		Set @Arear_Basic = 0 
		Set @Arear_Earn_Amount = 0
		Set @Arear_Dedu_Amount = 0
		Set @Arear_Net = 0
		
		Select @Arear_Earn_Amount = Isnull(SUM(M_Arear_Amount),0) From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
			Where Emp_ID = @CTC_EMP_ID And For_Date >= @From_Date And To_Date <= @To_Date And M_AD_Flag = 'E'

		Select @Arear_Dedu_Amount = Isnull(SUM(M_Arear_Amount),0) From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
			Where Emp_ID = @CTC_EMP_ID And For_Date >= @From_Date And To_Date <= @To_Date And M_AD_Flag = 'D'
			
		Select @Arear_Basic = Isnull(Arear_Basic,0) From T0200_MONTHLY_SALARY WITH (NOLOCK)
			Where Emp_ID = @CTC_EMP_ID And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date

		Set @Arear_Net = (@Arear_Basic + @Arear_Earn_Amount) - @Arear_Dedu_Amount
		
		----- End for Arear
		update #CTCMast SET Payment_Mode=@Payment_Mode WHERE Emp_ID1 = @CTC_EMP_ID and Cmp_ID = @CTC_CMP_ID  
					
			Set @P_Days =0 
			Set @Basic_Salary =0
			Set @TDS = 0
			Set @Settl  = 0
			Set @OTher_Allow  = 0
			Set @Total_Allowance  = 0
			Set @CO_Amount  = 0
			Set @Total_Deduction  = 0
			Set @PT  = 0
			Set @Loan  = 0
			Set @Advance  = 0	
			Set @Net_Salary  = 0	
			Set @Revenue_Amt  = 0	
			Set @LWF_Amt  = 0	
			Set @Other_Dedu  = 0	

			Set @Absent_Day = 0 
			Set @Holiday_Day = 0
			Set @WeekOff_Day = 0
			--Set @Leave_Day = 0 -- Added By Ali 18122013
			Set @Sal_Cal_Day = 0
			set @Net_Round = 0
			
			-- Rohit on 26092012
			set @OT_Hours = 0
			set @OT_AMount = 0
			Set @OT_Rate = 0
			set @Fix_OT_Shift_Hours = ''
			Set @Fix_OT_Shift_seconds = 0
			
			set @Travel_Amount=0
			
			Declare @CTC_COLUMNS nvarchar(100)
			Declare @CTC_AD_FLAG varchar(1)
			Declare @Allow_Amount numeric(18,2)
			
			-----------Added by Ramiz on 16092014 --------------
			
			Declare @Branch_id_new numeric(18,2)
			select @Branch_id_new = Branch_ID from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID =@CTC_EMP_ID and Cmp_ID = @CTC_CMP_ID
			select @Fix_OT_Shift_Hours = ot_fix_shift_hours from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @CTC_CMP_ID and Branch_ID = @Branch_id_new and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @CTC_CMP_ID and Branch_ID =@Branch_id_new)  --Modified By Ramiz on 16092014
			select @Fix_OT_Shift_seconds = dbo.F_Return_Sec(isnull(@Fix_OT_Shift_Hours,'00:00')) 
			
			-----------Ended by Ramiz on 16092014 --------------
												
						if abs(datediff(m,@To_Date,@from_date)) > 1
						begin
							select @Basic_Salary = sum(Salary_Amount),@P_Days=sum(Present_Days),@Absent_Day=sum(Absent_Days),@Holiday_Day=sum(Holiday_Days),@WeekOff_Day=sum(Weekoff_Days)
							--,@Leave_Day=sum(Total_Leave_Days) -- Added By Ali 18122013
							,@Sal_Cal_Day=sum(Sal_Cal_Days),@TDS=sum(isnull(M_IT_TAX,0)),
							@Settl = sum(Isnull(Settelement_Amount,0)),@OTher_Allow = sum(ISNULL(Other_Allow_Amount,0)),
							@Total_Allowance = sum(Isnull(Allow_Amount,0))
							,@OT_Hours = sum(isnull(OT_Hours,0)),@OT_Amount=sum(isnull(OT_Amount,0)) ,
							@OT_Rate = 0
							,@total_paid_leave_cur = sum(isnull((Paid_Leave_Days + OD_Leave_Days),0))
							,@Travel_Amount=sum(isnull(Travel_Amount,0))
							from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID 
							--and Month(Month_st_date) = Month(@From_Date) and Year(Month_st_date) = Year(@From_Date)
							and Month_st_date between @From_Date and @To_Date
							group by Emp_ID
						end
					else
						begin
							select @Basic_Salary = sum(Salary_Amount),@P_Days=sum(Present_Days),@Absent_Day=sum(Absent_Days),@Holiday_Day=sum(Holiday_Days),@WeekOff_Day=sum(Weekoff_Days)
							--,@Leave_Day=sum(Total_Leave_Days) -- Added By Ali 18122013
							,@Sal_Cal_Day=sum(Sal_Cal_Days),@TDS=sum(isnull(M_IT_TAX,0)),
							@Settl = sum(Isnull(Settelement_Amount,0)),@OTher_Allow = sum(ISNULL(Other_Allow_Amount,0)),
							@Total_Allowance = sum(Isnull(Allow_Amount,0))
							,@OT_Hours = sum(isnull(OT_Hours,0)),@OT_Amount=sum(isnull(OT_Amount,0)) ,
							@OT_Rate = case when isnull(@Fix_OT_Shift_seconds,0) = 0 then sum(Hour_Salary) else isnull(sum(Day_Salary),0)* 3600/@Fix_OT_Shift_seconds end
							,@total_paid_leave_cur = sum(isnull((Paid_Leave_Days + OD_Leave_Days),0))
							,@Travel_Amount=sum(isnull(Travel_Amount,0))
							from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID 
							--and Month(Month_st_date) = Month(@From_Date) and Year(Month_st_date) = Year(@From_Date)
							and Month_st_date between @From_Date and @To_Date
							group by Emp_ID	--,Hour_Salary,Day_Salary	--Hour_Salary And Day_salary Comment By Hardikbhai --report open as per duration	--04112015
							
						end
					
					Declare @GatePass_Amount as numeric(18,2) -- Added by Gadriwala Muslim 09012015
					set @GatePass_Amount = 0
					Declare @Asset_Installment as numeric(18,2) -- Added by Mukti 07042015
					set @Asset_Installment = 0
					
					Declare @TravelAdv_Amount as numeric(18,2)
					set @TravelAdv_Amount=0
					Declare @Leave_Encash_Amount as numeric(18,2)
					set @Leave_Encash_Amount = 0
					
					select @Total_Deduction = sum(Total_Dedu_Amount) ,@PT = sum(PT_Amount) ,@Loan =  sum(( Loan_Amount + Loan_Intrest_Amount ) )
							,@Advance =  sum(Isnull(Advance_Amount,0)) ,@Net_Salary = sum(Net_Amount) ,@Revenue_Amt = sum(Isnull(Revenue_amount,0)),@LWF_Amt =sum(Isnull(LWF_Amount,0)),@Other_Dedu= sum(Isnull(Other_Dedu_Amount,0))
							,@Arear_Days = Sum(Isnull(Arear_Day,0)),@GatePass_Amount = SUM(isnull(GatePass_Amount,0)),@Asset_Installment= SUM(isnull(Asset_Installment,0))
							,@TravelAdv_Amount=SUM(ISNULL(Travel_Advance_Amount,0)),
							--,@Net_Round = sum(ISNULL(Net_Salary_Round_Diff_Amount,0)) ,
							 @Leave_Encash_Amount = ISNULL(SUM(Leave_Salary_Amount),0)
					from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID 
							--and Month(Month_st_date) = Month(@From_Date) and Year(Month_st_date) = Year(@From_Date)
							and Month_st_date between @From_Date and @To_Date
							group by Emp_ID

					update  #CTCMast set Basic_Salary = Basic_Salary + @Basic_Salary
					--,Present_Day=Present_Day + @P_Days, Absent_Day= Absent_Day + @Absent_Day,Holiday_Day= Holiday_Day + @Holiday_Day,WeekOff_Day=WeekOff_Day + @WeekOff_Day
					    --,Leave_Day= Leave_Day + @Leave_Day -- Added By Ali 18122013
						,No_Of_Payable_Days=No_Of_Payable_Days + @Sal_Cal_Day
					    ,Settl_Salary = Settl_Salary  + @Settl,
						Other_Allow = Other_Allow + @OTher_Allow, Gross_Salary = Gross_Salary + (@Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0)),
						Total_Deduction = Total_Deduction + @Total_Deduction, PT_Amount = PT_Amount + @PT,
						Loan_Amount = Loan_Amount +  @Loan, Revenue_Amount = Revenue_Amount + @Revenue_Amt, LWF_Amount =LWF_Amount + @LWF_Amt,
						Other_Dedu =Other_Dedu + @Other_Dedu, Net_Amount =Net_Amount + @Net_Salary--,Total_Allowance = @Total_Allowance
						--,Arear_Day = @Arear_Days, Arear_Amount = @Arear_Net,OT_Hours=@OT_Hours,Advance_Amount = Advance_Amount + @Advance,OT_Amount=@OT_Amount,OT_Rate=@OT_Rate
						,Gate_Pass_Amount = @GatePass_Amount, -- Added by Gadriwala 09012014						
						Asset_Installment_Amount=@Asset_Installment ,--Mukti 07042015
						OT_Amount=@OT_Amount,						
						---Net_Round = @Net_Round
						Travel_Advance_Amount=@TravelAdv_Amount,Salary_Advance=Salary_Advance + @Advance
						,Travel_Amount=@Travel_Amount , Leave_Encash_Amount = @Leave_Encash_Amount,Total_OT_Hours_Worked=@OT_Hours											
					where #CTCMast.Cmp_ID = @CTC_CMP_ID and #CTCMast.Emp_ID1 = @CTC_EMP_ID
					
			
					Declare CRU_COLUMNS CURSOR FOR
						Select data from Split(@Columns,'#') where data <> ''
					OPEN CRU_COLUMNS
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
							while @@fetch_status = 0
								Begin					
										begin
												Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
																						
												begin
														
													select @Allow_Amount=sum(case when ded.ReimAmount >0  then ded.ReimAmount else ded.M_AD_Amount end),
													@CTC_AD_FLAG=ded.M_AD_Flag from T0210_MONTHLY_AD_DETAIL  ded WITH (NOLOCK)
														inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
														WHere  Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														--And MONTH(ded.For_Date) = MONTH(@From_Date) And YEAR(ded.For_Date) = YEAR(@From_Date)
														--and ded.For_Date between @From_Date and @To_Date
														and ded.For_Date >= @From_Date and ded.To_date <= @To_Date
														group by ded.M_AD_Flag , ded.EMP_ID , ded.AD_Id
													
													Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + @CTC_COLUMNS + ' + ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID1 = ' + convert(nvarchar,@CTC_EMP_ID)
													EXEC (@val)		
													print @CTC_COLUMNS
														   
												end
											Set @Allow_Amount = 0
										end
									fetch next from CRU_COLUMNS into @CTC_COLUMNS
								End
					close CRU_COLUMNS	
					deallocate CRU_COLUMNS
					
					Set @val = 	'update  #CTCMast set Total_Paid_Leave_Days  = ' + convert(nvarchar,isnull(@total_paid_leave_cur,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID1 = ' + convert(nvarchar,@CTC_EMP_ID)																														
			
										
		exec (@val)
				
		declare @leave_total numeric(18,2)		
		declare @leave_name_temp nvarchar(100)	
		
		
		
		set @count_leave = 0
		-- Leave detail cursor
		DECLARE Leave_Cursor CURSOR FOR
			Select data from Split(@Leave_Columns,'#') where data <> ''
		OPEN Leave_Cursor
			fetch next from Leave_Cursor into @Leave_Name
				while @@fetch_status = 0
					Begin
						
						 set @leave_total = 0
						 select @leave_total = SUM(isnull(lt.Leave_Used,0)) + Sum(isnull(lt.compOff_Used,0)) from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner join -- Changed By Gadriwala Muslim 25092014
						 T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID = LT.Leave_ID 
						 where LM.cmp_ID=@Company_id  and LT.For_Date  >=@From_Date and LT.For_Date  <=@To_Date and  Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')= @Leave_Name  -- Changed By Gadriwala Muslim 26092014 --REPLACE(rtrim(ltrim(Leave_Name)),' ','_') = @Leave_Name
								and LT.emp_id = @CTC_EMP_ID
						group by Leave_Name			
						
						Set @val = 'update #CTCMast set ' + @Leave_Name + ' = ' +  convert(nvarchar,@leave_total) + ' Where emp_id1 = ' + convert(nvarchar,@CTC_EMP_ID )
						EXEC (@val)
						
					print @leave_total
						
						set @count_leave = @count_leave + @leave_total
						
						fetch next from Leave_Cursor into @Leave_Name
					End
		close Leave_Cursor
		deallocate Leave_Cursor
						
		Set @val = 'update #CTCMast set Total_Leave_Days = ' +  convert(nvarchar,isnull(@count_leave,0)) + ' Where emp_id1 = ' + convert(nvarchar,@CTC_EMP_ID )
		EXEC (@val)
						
		
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC,@Payment_Mode
				End
	close CTC_UPDATE	
	deallocate CTC_UPDATE
	
	Update #CrossTab set Alpha_Emp_Code = '="' + Alpha_Emp_Code + '"'  
--for Salary Register(end)
			
			--Added by Nimesh 10-Jul-2015 (To sort by Code/Name/Enroll No)
			--if @Order_By = ''  OR @Order_By = 'Code'
			--	SET @Order_By = '(Case	When IsNumeric(Code) = 1 
			--								then Right(Replicate(''0'',21) + Code, 20)										
			--							Else 
			--								Code
			--					 End) '
			--Else if @Order_By = 'EmployeeName'
			--	SET @Order_By = 'EmpName ' + ', (Case	When IsNumeric(Code) = 1 
			--								then Right(Replicate(''0'',21) + Code, 20)										
			--							Else 
			--								Code
			--					 End)'
			--ELSE
			--	SET @Order_By = @Order_By + ', (Case	When IsNumeric(Code) = 1 
			--								then Right(Replicate(''0'',21) + Code, 20)										
			--							Else 
			--								Code
			--					 End) '
								 
			--print @Order_By
			
			--Hide column if there is 0 value in column(start)
			DECLARE @TOTAL_COLS VARCHAR(MAX);
			--SELECT	@TOTAL_COLS = COALESCE(@TOTAL_COLS + ',', '') + COL
			SET @TOTAL_COLS = ''
			select @TOTAL_COLS = COALESCE(@TOTAL_COLS + ',', '') + 'S.' + name from tempdb.sys.columns where object_id =object_id('tempdb..#CTCMast');
			--select * from tempdb.sys.columns where object_id =object_id('tempdb..#CTCMast');
			DECLARE @COLUMN_NAME NVARCHAR(100)
			DECLARE @COL_TOBE_REMOVED AS VARCHAR(MAX);
			SET @COL_TOBE_REMOVED  =  'PT_Amount,Loan_Amount,Revenue_Amount,LWF_Amount,Other_Dedu,Gate_Pass_Amount,Asset_Installment_Amount,Travel_Amount,Travel_Advance_Amount,Total_Paid_Leave_Days,Total_Leave_Days,Arear_Amount,Leave_Encash_Amount,OT_Rate,Settl_Salary,Other_Allow' + Replace(@Columns, '#', ',')
			
			--print @COL_TOBE_REMOVED
			DECLARE @DROP_COL_TEMPLATE AS NVARCHAR(255);
			
			--IF NOT EXISTS(SELECT 1 FROM #CTCMast WHERE Loan_Amount <> 0) 
			--	Alter table #CTCMast DROP COLUMN Loan_Amount;
			CREATE table #Eff(Cnt int);
					
			DECLARE CUR_COLUMN CURSOR FOR
			SELECT DATA FROM dbo.Split(@COL_TOBE_REMOVED, ',') T Where Data <> ''
			OPEN CUR_COLUMN
				fetch next from CUR_COLUMN into @COLUMN_NAME
				while @@fetch_status = 0
					BEGIN
						--EXEC sp_executesql @DROP_COL_TEMPLATE, N'@COLUMN_NAME NVARCHAR(100),@TOTAL_COLS VARCHAR(MAX) OUTPUT', @COLUMN_NAME,@TOTAL_COLS OUTPUT
						SET @DROP_COL_TEMPLATE = 'IF NOT EXISTS(SELECT 1 FROM #CTCMast WHERE ' + @COLUMN_NAME + ' <> 0) 
													Select 1'
						
						Insert INTO #Eff
						EXEC(@DROP_COL_TEMPLATE)
												
						IF EXISTS(Select 1 FROM #Eff)
							SET @TOTAL_COLS = replace(@TOTAL_COLS, 'S.' + @COLUMN_NAME + ',' ,'');							
						
						Truncate table #Eff;						
						fetch next from CUR_COLUMN into @COLUMN_NAME
					END
			close CUR_COLUMN
			deallocate CUR_COLUMN
		
			drop table #Eff;
			--Hide column if there is 0 value in column(end)
				
			set @Qry = 'select ROW_NUMBER() OVER(ORDER BY ' + @Order_By + ' ASC) AS Sr_No1,C.*' + @TOTAL_COLS + ' 
			into #CrossTabData 
			from #CrossTab as C 
			inner join #CTCMast S on C.EMP_ID=S.EMP_ID1
			left outer join 
			#EmpLaveDetail as EL on C.Emp_id = EL.iEmp_Id
			order by ' + @Order_By + '
			alter Table   #CrossTabData DROP COLUMN Emp_id
			alter Table   #CrossTabData DROP COLUMN Payable_Present_Days
			alter Table   #CrossTabData DROP COLUMN Total_Days
			alter Table   #CrossTabData DROP COLUMN Early_Deduct_Days
			alter Table   #CrossTabData DROP COLUMN WO_HO_Day
			
			select ROW_NUMBER() OVER(ORDER BY ' + @Order_By + ' ASC) AS Sr_No,C.* 
			into #Temp
			from #CrossTabData as C left outer join #EmpData as ED on C.Code = ED.iCode
			order by Sr_No

			Alter Table  #Temp Drop COLUMN Sr_No1
			
			Select * from #Temp
			
			drop table #Temp
			drop table #CrossTab
			drop table #Att_Muster_Excel'
			
			exec (@Qry)	
	
-------------------------------- End ----------------------------------
