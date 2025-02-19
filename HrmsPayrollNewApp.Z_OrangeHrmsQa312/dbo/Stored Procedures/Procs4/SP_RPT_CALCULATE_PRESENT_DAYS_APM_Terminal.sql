

CREATE PROCEDURE [dbo].[SP_RPT_CALCULATE_PRESENT_DAYS_APM_Terminal]      
  @Cmp_ID    numeric      
 ,@From_Date   datetime      
 ,@To_Date    datetime       
 ,@Branch_ID   numeric      
 ,@Cat_ID    numeric       
 ,@Grd_ID    numeric      
 ,@Type_ID    numeric      
 ,@Dept_ID    numeric      
 ,@Desig_ID    numeric      
 ,@Emp_ID    numeric      
 ,@constraint   varchar(max)      
 ,@Return_Record_set numeric =1  
 ,@StrWeekoff_Date varchar(max) = ''     
 ,@PBranch_ID varchar(200) = '0'  
 ,@max_OTDaily numeric (18,2) = 0
 ,@max_OTMonthly numeric(18,2)  =0
 ,@Report_Type	tinyint = 0   --Added By Jaina 12-09-2016
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON        
         
Declare @Count   numeric       
Declare @Tmp_Date datetime

Declare @Sal_St_Date as datetime
Declare @Sal_End_Date as datetime
declare @Manual_Salary as tinyint
declare @Month numeric
declare @year numeric
set @Month=MONTH(@FROM_DATE);
set @year= YEAR(@FROM_DATE);--YEAR(@FROM_DATE)-1;        

set @Tmp_Date = @From_Date      


--Added By Ramiz on 27/11/2015------
/*---Added by Sumit on 16-feb-2017----------------------------*/
if(charindex('#',@constraint,0)=0 and @constraint<>'')
	Begin
		set @Emp_ID=@constraint
	
	   SELECT @Branch_ID =I.Branch_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
				(
					select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
					(
							Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
							Where Increment_effective_Date <= @to_date 
							and Emp_ID=@Emp_ID 
							Group by emp_ID
					)		new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							Where TI.Increment_effective_Date <= @to_date 
							and TI.Emp_ID=@Emp_ID
							group by ti.emp_id
				) Qry on I.Increment_Id = Qry.Increment_Id 
							
	End	
		
		SELECT	@Sal_St_Date = GS.Sal_St_Date,@Manual_Salary=ISNULL(GS.Manual_Salary_Period,0)
			FROM T0040_GENERAL_SETTING GS WITH (NOLOCK) INNER JOIN
								( 
									SELECT MAX(For_Date) AS For_Date,Branch_ID FROM T0040_GENERAL_SETTING WITH (NOLOCK)
									WHERE  Cmp_ID = @cmp_ID AND Branch_ID = isnull(@BRANCH_ID,Branch_ID) 
									GROUP BY Branch_ID
								) Qry ON Qry.Branch_ID = GS.Branch_ID AND GS.For_Date = Qry.For_Date
							WHERE Cmp_ID = @cmp_ID AND GS.Branch_ID = isnull(@BRANCH_ID,GS.Branch_ID)
		
		if (@Manual_Salary=1)
		Begin
			select @Sal_St_Date = from_date,@SAL_END_DATE=end_date from Salary_Period 
			where MONTH=@Month and year=@year;
		End							  
							  
		set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date));	


		if (DAY(@FROM_DATE) < DAY(@Sal_St_Date))
				Begin					
					if (@Month = 1 )
						Begin
							set @Month=12;
							set @year= YEAR(@FROM_DATE) - 1;
						End
					Else
						Begin
							set @Month=@Month-1;							
						End	
					set @Sal_St_Date =CAST(CAST(@Month AS VARCHAR(20)) + '-' + CAST(DAY(@Sal_St_Date) AS VARCHAR(20)) + '-' + CAST(@year AS VARCHAR(20)) AS DATETIME)
				End
			Else
				Begin	
					set @Sal_St_Date =CAST(CAST(MONTH(@FROM_DATE) AS VARCHAR(20)) + '-' + CAST(DAY(@Sal_St_Date) AS VARCHAR(20)) + '-' + CAST(YEAR(@FROM_DATE) AS VARCHAR(20)) AS DATETIME)
				End
			
			set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 			
			
		if(@Sal_St_Date is not null and @Sal_End_Date is not null)
			Begin
				set @From_Date=@Sal_St_Date
				set @To_Date=@Sal_End_Date
			End	


IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY
			(
				EMP_ID NUMERIC,
				FOR_DATE DATETIME,
				IS_CANCEL BIT,
				Is_Half tinyint,
				Is_P_Comp tinyint,
				H_DAY numeric(3,1)
			);
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END 
	  
if @Return_Record_set = 1 or @Return_Record_set = 2 or @Return_Record_set =3  or @Return_Record_set =6   or    @Return_Record_set =7 or @Return_Record_set = 8 OR @Return_Record_set = 9 or @Return_Record_set = 10 or @Return_Record_set = 11
 Begin      
   CREATE table #Data         
   (         
   Emp_Id   numeric ,         
   For_date datetime,        
   Duration_in_sec numeric,        
   Shift_ID numeric ,        
   Shift_Type numeric ,        
   Emp_OT  numeric ,        
   Emp_OT_min_Limit numeric,        
   Emp_OT_max_Limit numeric,        
   P_days  numeric(12,3) default 0,	
   OT_Sec  numeric default 0  ,
   In_Time datetime,
   Shift_Start_Time datetime,
   OT_Start_Time numeric default 0,
   Shift_Change tinyint default 0,
   Flag int default 0,
   Weekoff_OT_Sec  numeric default 0,
   Holiday_OT_Sec  numeric default 0,   
   Chk_By_Superior numeric default 0,
   IO_Tran_Id	   numeric default 0, 
   OUT_Time datetime,
   Shift_End_Time datetime,			
   OT_End_Time numeric default 0,	
   Working_Hrs_St_Time tinyint default 0, 
   Working_Hrs_End_Time tinyint default 0, 
   GatePass_Deduct_Days numeric(18,2) default 0 
   )     

   exec SP_CALCULATE_PRESENT_DAYS_APM @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID
   ,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@constraint=@constraint,@Return_Record_set=4

   		select  @Return_Record_set
		return
  
   Alter Table  #Data Add Weekoff_OT_Hour   numeric(22,2);
   Alter Table  #Data Add Holiday_OT_Hour   numeric(22,2);
  
  
  
   Declare @Data_temp1 table---For Multi inout Solution         
   (         
	   Emp_Id   numeric ,         
	   For_date datetime,        
	   Duration_in_sec numeric,        
	   Shift_ID numeric ,        
	   Shift_Type numeric ,        
	   Emp_OT  numeric ,        
	   Emp_OT_min_Limit numeric,        
	   Emp_OT_max_Limit numeric,        
	   P_days  numeric(12,3) default 0,        
	   OT_Sec  numeric default 0  ,
	   In_Time datetime,
	   Shift_Start_Time datetime,
	   OT_Start_Time numeric default 0,
	   Shift_Change tinyint default 0,
	   Flag int default 0,
	   Weekoff_OT_Sec  numeric default 0,
	   Holiday_OT_Sec  numeric default 0,	   
	   Chk_By_Superior numeric default 0,
	   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
	   OUT_Time datetime,
	   Shift_End_Time datetime,			--Ankit 16112013
	   OT_End_Time numeric default 0,	--Ankit 16112013
	   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
	   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
	   GatePass_Deduct_Days numeric(18,2) default 0, -- Add by Gadriwala Muslim 05012014
	   Weekoff_OT_Hour   numeric(22,2),
	   Holiday_OT_Hour   numeric(22,2)
   )        
 end        
        

 --Ankit 05112015
 IF @Return_Record_set = 8 OR @Return_Record_set = 9 
	BEGIN
		
		ALTER TABLE  #Data 
		ADD Duration varchar(10)
		
		ALTER TABLE  #Data 
		ADD No_of_Days numeric(18,2)
		
		DECLARE @BRANCH_ID_OD NUMERIC
		DECLARE @Emp_ID_OD NUMERIC
		DECLARE @Is_Cancel_Holiday INT
		Declare @StrHoliday_Date varchar(Max)
		Declare @Is_Cancel_Weekoff  Numeric(1,0) 
		declare @StrHoliday_Date_W varchar(max)
		declare @Holiday_days_W varchar(max)
		declare @Cancel_Holiday_W varchar (max)
		Declare @StrWeekoff_Date_W varchar(max)
		declare @Weekoff_Days_W varchar(max)
		declare @Cancel_Weekoff_w varchar(max)
		Declare @For_date_W Datetime
		
		Set @StrHoliday_Date = ''
		
		CREATE TABLE #OD_Emp_Weekoff
		  (
				Emp_Id		numeric , 
				For_Date	datetime,
				W_Day		numeric(3,1)
		  )	
		  
		 CREATE TABLE #Emp_Weekoff_temp
		  (
				Emp_Id		numeric , 
				For_Date	datetime
		  )
	END
  

  


 IF @Branch_ID = 0        
  set @Branch_ID = null      
        
 IF @Cat_ID = 0        
  set @Cat_ID = null      
      
 IF @Grd_ID = 0        
  set @Grd_ID = null      
      
 IF @Type_ID = 0        
  set @Type_ID = null      
      
 IF @Dept_ID = 0        
  set @Dept_ID = null      
      
 IF @Desig_ID = 0        
  set @Desig_ID = null      
      
 IF @Emp_ID = 0        
  set @Emp_ID = null      
     
    
      
 

 if @Return_Record_set = 1 
	BEGIN
	SELECT	OA.Emp_ID,For_Date,Duration_in_Sec,OA.Shift_ID,Shift_Type,Emp_OT,Emp_OT_min_Limit,
			P_days,OT_Sec,Emp_Full_Name,Emp_Code,Shift_Name,Cmp_Name,Cmp_Address,Branch_Address,
			Dept_Name,Comp_Name,Desig_Name,[Type_Name],Grd_Name,Branch_Name,Date_of_Join,Gender,0 As Working_Hour,
			0 As OT_Hour,Basic_Salary,Weekoff_OT_Sec,Holiday_OT_Sec,Holiday_OT_Sec,Weekoff_OT_Hour,Holiday_OT_Hour
	FROM	#Data   OA      
			inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   inner join    
			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID inner join
			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join  
			 ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join     
				 ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   -- Ankit 06092014 for Same Date Increment
				 where Increment_Effective_date <= @To_Date    
				 and Cmp_ID = @Cmp_ID    
				 group by emp_ID  ) Qry on    
				 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
				on E.Emp_ID = I_Q.Emp_ID  inner join    
				 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
				 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
				 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
				 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN            
				 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID         
	Where	OT_Sec > 0  or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0       
    order by For_Date 
 END
  if @Return_Record_set =2       
	BEGIN   
		--print 45678--mansi
			--Added By Jaina 12-09-2016
		    If @Report_Type = 1 --Pending
			begin
		  
     				select OA.Emp_Id,OA.For_date,OA.Duration_in_sec,OA.Shift_ID,OA.Shift_Type,OA.Emp_OT,OA.Emp_OT_min_Limit,OA.Emp_OT_max_Limit,OA.P_days,
				 case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else oa.OT_Sec end as OT_Sec   ,
				   E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				  ,Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour ,
				 case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
				  E.Basic_Salary , OA.Weekoff_OT_Sec,
				  OA.Holiday_OT_Sec,oa.Weekoff_OT_Hour,oa.Holiday_OT_Hour
				  ,DGM.Desig_Dis_No
				  --, OTA.Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				   , case when isnull(OTA.Comments,'')<>'' then OTA.Comments else case when oa.Weekoff_OT_Sec>0 then 'Week Off' when Oa.Holiday_OT_Sec>0 then 'Holiday' else '' end end as Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				  ,case when OTA.Is_Approved = 1 then 'Approved' else  case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end end as OT_Status,
				  OTA.Remark
				  INTO #Data_T
				  from #Data   OA      
					 inner join			T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
					 inner join			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID AND E.Cmp_ID=SM.Cmp_ID 
					 inner join			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID 
					 inner join			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK)
					 inner join			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 06092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
										I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID  
					inner join			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					Left OUTER JOIN	T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date		--Added By Ramiz
					
					Where				(OA.OT_Sec > 0  or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0)       
										and Is_Approved  is null    
					 order by For_Date 

				END
		ELSE IF @REPORT_TYPE = 2 -- APPROVED
			BEGIN
				--print 12324
				select OA.Emp_Id,OA.For_date,OA.Duration_in_sec,OA.Shift_ID,OA.Shift_Type,OA.Emp_OT,OA.Emp_OT_min_Limit,OA.Emp_OT_max_Limit,OA.P_days,
				 case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else oa.OT_Sec end as OT_Sec   ,
				   E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				  ,Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour ,
				 case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
				  E.Basic_Salary , OA.Weekoff_OT_Sec,
				  OA.Holiday_OT_Sec,oa.Weekoff_OT_Hour,oa.Holiday_OT_Hour
				  ,DGM.Desig_Dis_No
				  --, OTA.Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				   , case when isnull(OTA.Comments,'')<>'' then OTA.Comments else case when oa.Weekoff_OT_Sec>0 then 'Week Off' when Oa.Holiday_OT_Sec>0 then 'Holiday' else '' end end as Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				  ,case when OTA.Is_Approved = 1 then 'Approved' else  case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end end as OT_Status,
				  OTA.Remark
				  INTO #Data_T1
				  from #Data   OA      
					 inner join			T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
					 inner join			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID AND E.Cmp_ID=SM.Cmp_ID 
					 inner join			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID 
					 inner join			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK)
					 inner join			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 06092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
										I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID  
					inner join			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					Left OUTER JOIN	T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date		--Added By Ramiz
					
					Where				(OA.OT_Sec > 0  or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0)       
										and ota.Is_Approved = 1    
					 order by For_Date 
					
			
			END
			
			ELSE IF @REPORT_TYPE = 3 -- REJECTED
			BEGIN
		
				select OA.Emp_Id,OA.For_date,OA.Duration_in_sec,OA.Shift_ID,OA.Shift_Type,OA.Emp_OT,OA.Emp_OT_min_Limit,OA.Emp_OT_max_Limit,OA.P_days,
				 case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else oa.OT_Sec end as OT_Sec   ,
				   E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				  ,Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour ,
				 case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
				  E.Basic_Salary , OA.Weekoff_OT_Sec,
				  OA.Holiday_OT_Sec,oa.Weekoff_OT_Hour,oa.Holiday_OT_Hour
				  ,DGM.Desig_Dis_No
				  --, OTA.Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				   , case when isnull(OTA.Comments,'')<>'' then OTA.Comments else case when oa.Weekoff_OT_Sec>0 then 'Week Off' when Oa.Holiday_OT_Sec>0 then 'Holiday' else '' end end as Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				  ,case when OTA.Is_Approved = 1 then 'Approved' else  case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end end as OT_Status,
				  OTA.Remark
				  INTO #Data_T2
				  from #Data   OA      
					 inner join			T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
					 inner join			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID AND E.Cmp_ID=SM.Cmp_ID 
					 inner join			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID 
					 inner join			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK)
					 inner join			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 06092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
										I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID  
					inner join			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					Left OUTER JOIN	T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date		--Added By Ramiz
					
					Where				(OA.OT_Sec > 0  or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0)
										and Is_Approved = 0    
					 order by For_Date 
			END
			ELSE  --All
			BEGIN
			--print 444--mansi
				select OA.Emp_Id,OA.For_date,OA.Duration_in_sec,OA.Shift_ID,OA.Shift_Type,OA.Emp_OT,OA.Emp_OT_min_Limit,OA.Emp_OT_max_Limit,OA.P_days,
				 case when @max_OTDaily = 0 then OA.OT_Sec when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) else oa.OT_Sec end as OT_Sec   ,
				   E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				  ,Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour ,
				 case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
				  E.Basic_Salary , OA.Weekoff_OT_Sec,
				  OA.Holiday_OT_Sec
				  --,oa.Weekoff_OT_Hour,oa.Holiday_OT_Hour
				  ,DGM.Desig_Dis_No
				  --, OTA.Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				   , case when isnull(OTA.Comments,'')<>'' then OTA.Comments else case when oa.Weekoff_OT_Sec>0 then 'Week Off' when Oa.Holiday_OT_Sec>0 then 'Holiday' else '' end end as Comments      --added jimit 24082015	--Comments Added By Ramiz on 04/09/2015
				  ,case when OTA.Is_Approved = 1 then 'Approved' else  case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end end as OT_Status,
				  OTA.Remark
				  INTO #Data_T3
				  from #Data   OA      
					 inner join			T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
					 inner join			T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID AND E.Cmp_ID=SM.Cmp_ID 
					 inner join			T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID 
					 inner join			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK)
					 inner join			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 06092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
										I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID  
					inner join			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					Left OUTER JOIN	T0160_OT_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date		--Added By Ramiz
					
					Where				OA.OT_Sec > 0  or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0       
										
					 order by For_Date 
			ENd
			--select * from #Data--mansi
    -- 			if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData')
				--	BEGIN 
				--		drop table #MaxOtData	
				--	END
				
				--if isnull(@max_OTMonthly,0) <> 0 or isnull(@max_OTDaily,0) <> 0
				--	BEGIN
				--		select sum(b.OT_Sec ) as Sum_ot,a.* into #MaxOtData
				--		from #Data_T a cross join #Data_T b
				--		where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
				--		group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
				--		a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
				--		a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
				--		a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments	--Comments Added By Ramiz on 04/09/2015
				--	END
   
     	if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData')
				begin 
					drop table #MaxOtData	
				end
		else if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData1')
				begin 
					drop table #MaxOtData1	
				end
		else if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData2')
				begin 
					drop table #MaxOtData2	
				end		
		else if exists(select 1 from tempdb.sys.tables where name ='#MaxOtData3')
				begin 
					drop table #MaxOtData3
				end		
			
				if exists(select 1 from tempdb.sys.tables where name ='#TotalMaxOtData')
				begin 
					drop table #TotalMaxOtData	
				end
		        else if exists(select 1 from tempdb.sys.tables where name ='#TotalMaxOtData1')
				begin 
					drop table #TotalMaxOtData1
				end
		       else if exists(select 1 from tempdb.sys.tables where name ='#TotalMaxOtData2')
				begin 
					drop table #TotalMaxOtData2	
				end		
		       else if exists(select 1 from tempdb.sys.tables where name ='#TotalMaxOtData3')
				begin 
					drop table #TotalMaxOtData3
				end	
				
					if isnull(@max_OTMonthly,0) <> 0 or isnull(@max_OTDaily,0) <> 0
					begin
				
						if @Report_Type = 1 -- Pending
							begin
								select ((a.OT_Sec+a.Weekoff_OT_Sec+a.Holiday_OT_Sec)/3600)as ot_hr_cnt,cast(a.OT_Hour as numeric(18,0)) as ot_hr_cnt_1,sum(b.OT_Sec ) as Sum_ot,a.*
								into #MaxOtData
								from #Data_T a cross join #Data_T b
								where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
								group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
								a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
								a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
								a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments,a.OT_Status	--Comments Added By Ramiz on 04/09/2015
							end
						else if  @Report_Type = 2 -- Approved
							begin
								select ((a.OT_Sec+a.Weekoff_OT_Sec+a.Holiday_OT_Sec)/3600)as ot_hr_cnt,cast(a.OT_Hour as numeric(18,0)) as ot_hr_cnt_1,sum(b.OT_Sec ) as Sum_ot,a.* into #MaxOtData1
								from #Data_T1 a cross join #Data_T1 b
								where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
								group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
								a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
								a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
								a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments,a.OT_Status	--Comments Added By Ramiz on 04/09/2015
							end
						else if  @Report_Type = 3 -- Rejected
							begin
								select ((a.OT_Sec+a.Weekoff_OT_Sec+a.Holiday_OT_Sec)/3600)as ot_hr_cnt,cast(a.OT_Hour as numeric(18,0)) as ot_hr_cnt_1,sum(b.OT_Sec ) as Sum_ot,a.* into #MaxOtData2
								from #Data_T2 a cross join #Data_T2 b
								where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
								group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
								a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
								a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
								a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments,a.OT_Status	--Comments Added By Ramiz on 04/09/2015
							end
						
						else  -- All
							begin
							--print 3333--mansi
							  select  ((a.OT_Sec+a.Weekoff_OT_Sec+a.Holiday_OT_Sec)/3600)as ot_hr_cnt,cast(a.OT_Hour as numeric(18,0)) as ot_hr_cnt_1, sum(b.OT_Sec ) as Sum_ot,a.* into #MaxOtData3 
								from #Data_T3 a cross join #Data_T3 b
								where b.for_date <= a.for_date and a.Emp_Id =b.Emp_Id 
								group by a.Basic_Salary,a.Branch_Address ,a.Branch_Name ,a.Cmp_Address ,a.Cmp_Name ,a.Comp_Name ,a.Date_of_Join ,a.Date_of_Join ,
								a.Dept_Name ,a.Desig_Name ,a.Duration_in_sec ,a.Alpha_Emp_Code ,a.Emp_Full_Name ,a.Emp_Id ,a.Emp_OT ,a.Emp_OT_max_Limit ,a.Emp_OT_min_Limit ,
								a.For_date ,a.Gender ,a.Grd_Name ,a.Holiday_OT_Hour ,a.Holiday_OT_Sec ,a.OT_Hour ,a.OT_Sec ,a.P_days ,a.Shift_ID ,a.Shift_Name ,
								a.Shift_Type ,a.Type_Name ,a.Weekoff_OT_Hour ,a.Weekoff_OT_Sec ,a.Working_Hour , a.Desig_Dis_No , a.Comments,a.OT_Status--Comments Added By Ramiz on 04/09/2015
								,a.Remark--added by mansi		
							end
					end		
			
			if isnull(@max_OTMonthly,0) <> 0
					begin
					 
						if @Report_Type = 1
							begin
								select sum(ot_hr_cnt)as total_ot_cnt,Emp_Id into #TotalMaxOtData
								from #MaxOtData --where For_date >=@From_Date and For_date >=@To_Date
								group by Emp_Id

								--select * from #MaxOtData  --where  sum_ot_hr<@max_OTMonthly 
								--order by For_date
							end
						else if @Report_Type = 2
							begin
									select sum(ot_hr_cnt)as total_ot_cnt,Emp_Id into #TotalMaxOtData1
								from #MaxOtData1 --where For_date >=@From_Date and For_date >=@To_Date
								group by Emp_Id

								--select * from #MaxOtData1  --where  sum_ot_hr<@max_OTMonthly 
								--order by For_date
							end
						else if @Report_Type = 3
							begin
								select sum(ot_hr_cnt)as total_ot_cnt,Emp_Id into #TotalMaxOtData2
								from #MaxOtData2 --where For_date >=@From_Date and For_date >=@To_Date
								group by Emp_Id
								--where  sum_ot_hr<@max_OTMonthly  
								--order by For_date 
								--select * from #MaxOtData2  --where  sum_ot_hr<@max_OTMonthly 
								--order by For_date	
							end
						else
							begin
							 	select sum(ot_hr_cnt)as total_ot_cnt,Emp_Id into #TotalMaxOtData3
								from #MaxOtData3 --where For_date >=@From_Date and For_date >=@To_Date
								group by Emp_Id
								--where  sum_ot_hr<@max_OTMonthly  
								--order by For_date 
								--select * from #MaxOtData3  --where  sum_ot_hr<@max_OTMonthly 
								--order by For_date
							end
					end
  
				if isnull(@max_OTDaily,0) = 0   and isnull(@max_OTMonthly,0) = 0
					begin
						if @Report_Type = 1
							begin
								select * from #Data_T order by For_date 
							end
						else if @Report_Type = 2
							begin
								select * from #Data_T1 order by For_date
							end
						else if @Report_Type = 3
							begin
								select * from #Data_T2 order by For_date	
							end
						else
							begin
								select * from #Data_T3 order by For_date
							end
					end
				else if isnull(@max_OTDaily,0) <> 0   and isnull(@max_OTMonthly,0) = 0
					begin
					  print 1111111111
						if @Report_Type = 1
							begin
								select * from #MaxOtData where  (ot_hr_cnt<@max_OTDaily or ot_hr_cnt=@max_OTDaily )
								order by For_date 
							end
						else if @Report_Type = 2
							begin
								select * from #MaxOtData1  where  (ot_hr_cnt<@max_OTDaily or ot_hr_cnt=@max_OTDaily )
								--ot_hr_cnt<@max_OTDaily
								order by For_date
							end
						else if @Report_Type = 3
							begin
								select * from #MaxOtData2  where (ot_hr_cnt<@max_OTDaily or ot_hr_cnt=@max_OTDaily )
								--ot_hr_cnt<@max_OTDaily
								order by For_date	
							end
						else
							begin
								select * from #MaxOtData3  where  (ot_hr_cnt<@max_OTDaily or ot_hr_cnt=@max_OTDaily )
								--ot_hr_cnt<=@max_OTDaily
								order by For_date
							end
					end
				else if isnull(@max_OTDaily,0) = 0   and isnull(@max_OTMonthly,0) <> 0
					begin
					  
						if @Report_Type = 1
							begin
							  	select * from #MaxOtData o1
								inner join #TotalMaxOtData o2 on o1.Emp_Id=o2.Emp_Id
								 where  o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData where  ot_hr_cnt<=@max_OTDaily  
								--order by For_date 
							end
						else if @Report_Type = 2
							begin
									select * from #MaxOtData1 o1
								inner join #TotalMaxOtData1 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData1  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date
							end
						else if @Report_Type = 3
							begin
									select * from #MaxOtData2 o1
								inner join #TotalMaxOtData2 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData2  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date	
							end
						else
							begin
								select * from #MaxOtData3 o1
								inner join #TotalMaxOtData3 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								
							
								--select * from #MaxOtData3  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date
							end
					end

				else 
					begin
					  
						if @Report_Type = 1
							begin
						        select * from #MaxOtData o1
								inner join #TotalMaxOtData o2 on o1.Emp_Id=o2.Emp_Id
								 where  o1.ot_hr_cnt<=@max_OTDaily  and o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData where  ot_hr_cnt<=@max_OTDaily  
								--order by For_date 
							end
						else if @Report_Type = 2
							begin
								select * from #MaxOtData1 o1
								inner join #TotalMaxOtData1 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o1.ot_hr_cnt<=@max_OTDaily  and o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData1  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date
							end
						else if @Report_Type = 3
							begin
								select * from #MaxOtData2 o1
								inner join #TotalMaxOtData2 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o1.ot_hr_cnt<=@max_OTDaily  and o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData2  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date	
							end
						else
							begin
								select * from #MaxOtData3 o1
								inner join #TotalMaxOtData3 o2 on o1.Emp_Id=o2.Emp_Id
								 where  o1.ot_hr_cnt<=@max_OTDaily  and o2.total_ot_cnt<=@max_OTMonthly
								order by For_date 
								--select * from #MaxOtData3  where  ot_hr_cnt<=@max_OTDaily
								--order by For_date
							end
					end
  end      
  Else if @Return_Record_set=3 or @Return_Record_set =6 or @Return_Record_set = 7
    BEGIN
			update #Data 
			set OT_Sec = 0
			from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID 

			update #Data 
			set OT_Sec = isnull(Approved_OT_Sec,0)  --* 3600 comment by : Falak on 27-OCT-2010
			from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date 
				
				
			If @Return_Record_set =3
				BEGIN
					
					select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, dbo.F_Return_Hours(sum(Duration_in_Sec)) as Working_Hour ,dbo.F_Return_Hours(sum(OT_SEc)) as OT_Hour ,
					sum(P_days) as Present_Days,
					E.Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
						
					From #Data  OA inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID
					inner join  T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID inner join   
					T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join  
					 
	  
					(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join     
					(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment    WITH (NOLOCK) -- Ankit 06092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date    
							and Cmp_ID = @Cmp_ID    
							group by emp_ID  ) Qry on    
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
					on E.Emp_ID = I_Q.Emp_ID  inner join    
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN     
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID     
					Group by  OA.Emp_Id,E.Emp_Full_Name,E.Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
				END
			If @Return_Record_set =6
				BEGIN
			
					select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, dbo.F_Return_Hours(sum(Duration_in_Sec)) as Working_Hour ,dbo.F_Return_Hours(sum(OT_SEc)) as OT_Hour ,
					sum(P_days) as Present_Days,
					E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,I_Q.Branch_ID,isnull(Leave_Qry.Leave_Used,0) as od_leave
					,Vs.Vertical_Name,sv.SubVertical_Name  --added jimit 28042016
					From #Data  OA inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID
					inner join  T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID inner join   
					T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join  
					(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join     
						(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   -- Ankit 06092014 for Same Date Increment
							where Increment_Effective_date <= @To_Date    
							and Cmp_ID = @Cmp_ID    
							group by emp_ID  ) Qry on    
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
					on E.Emp_ID = I_Q.Emp_ID  inner join    
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN     
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID   Left Outer JOIN
					T0040_Vertical_Segment Vs WITH (NOLOCK) On vs.Vertical_ID = I_Q.Vertical_ID Left Outer JOIN
					T0050_SubVertical sv WITH (NOLOCK) On sv.SubVertical_ID = I_Q.SubVertical_ID Left Outer join 
					( select SUM(leave_used) as Leave_Used, LT.Emp_ID from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  inner join
						T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID = LT.Leave_ID --inner join
						--#Emp_Cons ec on ec.Emp_ID = LT.Emp_ID --Modified by Nimesh 29-May-2015 (We are using SP_CALCULATE_PRESENT_DAYS sp.)
						--#Data ec on ec.Emp_ID = LT.Emp_ID Commented by Sumit on 02082016 after discussion with Nimesh bhai...
						where  LT.cmp_ID = @Cmp_ID  and LM.Leave_Paid_Unpaid = 'P' And Leave_Type = 'Company Purpose' and LT.For_Date >= @From_Date and LT.For_Date <= @To_Date Group By LT.Emp_ID)  Leave_Qry on  Leave_Qry.Emp_ID = E.Emp_ID
					Group by  OA.Emp_Id,E.Emp_Full_Name,E.Emp_Code,E.ALPHA_EMP_CODE,E.Emp_First_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,I_Q.Branch_ID,Leave_Qry.Leave_Used
								,vs.vertical_Name,sv.SubVertical_Name
					Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
					--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
			END
			If @Return_Record_set = 7
				BEGIN
					select Emp_Id,sum(P_days) as p_days from #Data group by Emp_Id
				END
				
	END		      
	--Added By Ramiz on 14/10/2015 for counting No. of Extra days Worked like on Week-Off & Holiday 
  Else If @Return_Record_set = 8
				BEGIN
					UPDATE #Data SET Duration = dbo.F_Return_Hours(Datediff(s,In_Time,OUT_Time)) 
					FROM #Data D WHERE Emp_ID = D.Emp_ID and For_Date = d.For_date
					
					UPDATE #Data SET No_of_Days = Qry.Calculate_Days
					FROM	#Data T
							INNER JOIN  (
											SELECT	SD.Calculate_Days , D.For_date, d.Emp_Id
											FROM	T0050_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #Data D on D.Shift_ID = SD.Shift_ID 
													and Emp_Id = D.Emp_Id and For_Date = d.For_date
													and Cast(replace(D.Duration,':','.') as numeric(18,2)) >= From_Hour 
													and Cast(replace(D.Duration,':','.') as numeric(18,2)) <= To_Hour
													LEFT OUTER JOIN T0160_OT_APPROVAL ot WITH (NOLOCK) ON D.Emp_Id=ot.Emp_ID and D.For_date=ot.For_Date
											WHERE P_days = 0 and (D.Weekoff_OT_Sec > 0 or D.Holiday_OT_Sec > 0)	or ot.For_Date is not null	
										 ) QRY  ON t.Emp_Id=QRY.Emp_Id and t.For_date=QRY.For_date
							LEFT OUTER JOIN T0160_OT_APPROVAL OT WITH (NOLOCK) ON T.EMP_ID=OT.EMP_ID and T.FOR_DATE=OT.FOR_DATE
					WHERE (P_days = 0 AND (t.Weekoff_OT_Sec > 0 or t.Holiday_OT_Sec > 0)) 
							OR (OT.Weekoff_OT_Sec > 0 or OT.Holiday_OT_Sec > 0)
					

					SELECT D.Emp_Id,E.Alpha_Emp_Code , E.Emp_Full_Name, Branch_name, Desig_Name, Dept_Name, Grd_Name, Type_Name , Vertical_Name , 
					SubVertical_Name, sum(D.P_days) as Present_Days ,Isnull(sum(D.No_of_Days),0) as Extra_Days
					, ISnull((sum(D.P_days) + sum(ISNULL(D.NO_of_Days,0))),0) as Total_Worked_Days , CM.Cmp_Name,CM.Cmp_Address 	
					 FROM #Data D 
					 INNER JOIN T0080_emp_master E WITH (NOLOCK) on D.Emp_ID = E.Emp_ID
					 INNER JOIN T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID
					 INNER JOIN  
							(SELECT I.Emp_Id ,Branch_ID,Cat_ID,Desig_ID,Dept_ID , Grd_ID ,Type_ID , Vertical_ID , SubVertical_ID  from T0095_Increment I WITH (NOLOCK)
							INNER JOIN 
								(SELECT max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @To_Date    
										and Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID 
										and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID 
					 INNER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
					 INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
					 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
					 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
					 LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
					 LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON I_Q.Vertical_ID = VS.Vertical_ID
					 LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON I_Q.SubVertical_ID = SV.SubVertical_ID	 	
					GROUP BY D.Emp_Id ,E.Alpha_Emp_Code,E.Emp_Full_Name,Branch_name,Desig_Name,Dept_Name ,Grd_Name , Type_Name ,Vertical_Name , SubVertical_Name , CM.Cmp_Name,CM.Cmp_Address--,LQry.OD_Days
					
				END	
	-- For RKM 1. OD Leave ON WO/HO	2. Single punch then calculate Full day --- Ankit 05112015
  Else If @Return_Record_set = 9
				BEGIN
					Set @StrHoliday_Date = ''
						
					DECLARE WO_HO_Emp_ID CURSOR FAST_FORWARD FOR  
						 SELECT DISTINCT Emp_ID From #Data 
					OPEN WO_HO_Emp_ID  
					FETCH NEXT FROM WO_HO_Emp_ID INTO @Emp_ID_OD
					WHILE @@FETCH_STATUS = 0  
						BEGIN
							SET @StrWeekoff_Date = ''
							SET @StrHoliday_Date = ''
							SET @Is_Cancel_Holiday = 0
							SET @Is_Cancel_Weekoff = 0
							
							SELECT @BRANCH_ID_OD =	Branch_id 
							FROM t0095_increment  WITH (NOLOCK)
							WHERE Increment_ID =( SELECT MAX(Increment_ID) FROM t0095_increment WITH (NOLOCK) WHERE emp_id=@Emp_ID_OD AND increment_effective_date <=@To_Date) 
							AND emp_id = @Emp_ID_OD
							
							Select @Is_Cancel_Holiday = Is_Cancel_Holiday , @Is_Cancel_Weekoff = Is_Cancel_Weekoff
							From dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
							Where cmp_ID = @cmp_ID and Branch_ID = @BRANCH_ID_OD    
							and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @BRANCH_ID_OD and Cmp_ID = @Cmp_ID)    
							
							Exec dbo.SP_EMP_HOLIDAY_DATE_GET1 @Emp_ID_OD,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date_W output,@Holiday_days_W output,@Cancel_Holiday_W output,0,@Branch_ID,@StrWeekoff_Date_W
							Exec dbo.SP_EMP_WEEKOFF_DATE_GET1 @Emp_ID_OD,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date_W output,@Weekoff_Days_W output ,@Cancel_Weekoff_w output,@constraint=''
							
							INSERT INTO #Emp_Weekoff_temp
							SELECT @Emp_ID_OD, CAST(DATA  AS DATETIME) FROM dbo.Split ( (@StrHoliday_Date_W) ,';')
							 
							INSERT INTO #Emp_Weekoff_temp
							SELECT @Emp_ID_OD, CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrWeekoff_Date_W) ,';') WHERE CAST(DATA AS DATETIME) <> '1900-01-01 00:00:00.000' AND CAST(DATA AS DATETIME) NOT IN (SELECT  CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrHoliday_Date_W) ,';') )
							 	
							INSERT INTO #OD_Emp_Weekoff
							SELECT LT.Emp_ID,LT.For_Date,LT.Leave_Used FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN
									T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = LT.Leave_ID
							WHERE  LT.cmp_ID = @Cmp_ID AND lt.Leave_Used > 0 AND LM.Leave_Paid_Unpaid = 'P' AND Leave_Type = 'Company Purpose' 
									--AND LT.For_Date IN ( SELECT  CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrHoliday_Date_W) ,';'))
									AND EXISTS (SELECT  CAST(DATA  AS DATETIME) FROM dbo.Split ( (@StrHoliday_Date_W) ,';') WHERE Data = LT.For_Date )
									and LT.Emp_ID = @Emp_ID_OD
							 
							INSERT INTO #OD_Emp_Weekoff
							SELECT LT.Emp_ID,LT.For_Date,LT.Leave_Used FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)INNER JOIN
									T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = LT.Leave_ID
							WHERE  LT.cmp_ID = @Cmp_ID AND lt.Leave_Used > 0 AND LM.Leave_Paid_Unpaid = 'P' AND Leave_Type = 'Company Purpose' 
									AND LT.For_Date IN ( SELECT  CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrWeekoff_Date_W) ,';') WHERE CAST(DATA AS DATETIME) NOT IN (SELECT  CAST(DATA  AS DATETIME) AS For_date  FROM dbo.Split ( (@StrHoliday_Date_W) ,';') ))
									and LT.Emp_ID = @Emp_ID_OD
   
							FETCH NEXT FROM WO_HO_Emp_ID INTO @Emp_ID_OD
						END
					 CLOSE WO_HO_Emp_ID  
					 DEALLOCATE WO_HO_Emp_ID  	
					
					--For single punch then calculate Full day
					
					update #Data set Duration = dbo.F_Return_Hours(Datediff(s,In_Time,OUT_Time)) from #Data D where Emp_ID = D.Emp_ID and For_Date = d.For_date
					
					update #Data 
					set Duration = dbo.F_Return_Hours(Datediff(s, case when In_Time is null THEN D.Shift_Start_Time ELSE D.In_Time END,case when OUT_Time IS NULL THEN D.Shift_End_Time ELSE D.OUT_Time end)) 
						,Weekoff_OT_Sec = DATEDIFF(s,case when In_Time is null THEN D.Shift_Start_Time ELSE D.In_Time END,case when OUT_Time IS NULL THEN D.Shift_End_Time ELSE D.OUT_Time end ) 
					from #Data D where Emp_ID = D.Emp_ID and For_Date = d.For_date
					   AND (D.In_Time is NULL or D.OUT_Time is NULL)
					   and EXISTS ( SELECT For_date FROM #Emp_Weekoff_temp WHERE For_date = D.For_Date AND Emp_Id = D.Emp_ID ) 
					
					
					update #Data set No_of_Days = Qry.Calculate_Days
					from	#Data T
							INNER JOIN  (
											SELECT	SD.Calculate_Days , D.For_date, d.Emp_Id
											FROM	T0050_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #Data D on D.Shift_ID = SD.Shift_ID 
													and Emp_Id = D.Emp_Id and For_Date = d.For_date
													and Cast(replace(D.Duration,':','.') as numeric(18,2)) >= From_Hour 
													and Cast(replace(D.Duration,':','.') as numeric(18,2)) <= To_Hour
													LEFT OUTER JOIN T0160_OT_APPROVAL ot WITH (NOLOCK) ON D.Emp_Id=ot.Emp_ID and D.For_date=ot.For_Date
											where P_days = 0 and (D.Weekoff_OT_Sec > 0 or D.Holiday_OT_Sec > 0)	or ot.For_Date is not null			
										) QRY  ON t.Emp_Id=QRY.Emp_Id and t.For_date=QRY.For_date
							LEFT OUTER JOIN T0160_OT_APPROVAL ot WITH (NOLOCK) ON T.Emp_Id=ot.Emp_ID and T.For_date=ot.For_Date
					where (P_days = 0 and (t.Weekoff_OT_Sec > 0 or t.Holiday_OT_Sec > 0))
							OR (OT.Weekoff_OT_Sec > 0 or OT.Holiday_OT_Sec > 0)
					
					
					--DELETE FROM #Data WHERE No_of_Days > 0 AND EXISTS (SELECT For_date FROM #OD_Emp_Weekoff WHERE For_date = #Data.For_Date )
					
					-----OD Leave ON WO/HO	--------
					
					
					select D.Emp_Id,E.Alpha_Emp_Code , E.Emp_Full_Name, Branch_name, Desig_Name, Dept_Name, Grd_Name, Type_Name , Vertical_Name , SubVertical_Name, sum(D.P_days) as Present_Days ,Isnull(sum(D.No_of_Days),0) as Extra_Days,ISNULL(LQry.OD_Days,0) AS OD_Leave_Days , ISnull((sum(D.P_days) + sum(ISNULL(D.NO_of_Days,0)) + ISNULL(LQry.OD_Days,0)  ),0) as Total_Worked_Days , CM.Cmp_Name,CM.Cmp_Address 
						
					 from #Data D 
					 INNER JOIN T0080_emp_master E WITH (NOLOCK) on D.Emp_ID = E.Emp_ID
					 INNER JOIN T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID
					 INNER JOIN  
							(select I.Emp_Id ,Branch_ID,Cat_ID,Desig_ID,Dept_ID , Grd_ID ,Type_ID , Vertical_ID , SubVertical_ID  from T0095_Increment I WITH (NOLOCK)
							INNER JOIN 
								(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @To_Date    
										and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID 
										and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID 
					 INNER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
					 INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
					 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
					 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
					 LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
					 LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON I_Q.Vertical_ID = VS.Vertical_ID
					 LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON I_Q.SubVertical_ID = SV.SubVertical_ID
					 LEFT OUTER JOIN ( SELECT SUM(W_Day) AS OD_Days,Emp_Id FROM #OD_Emp_Weekoff WHERE For_Date >= @From_Date AND For_Date <= @To_Date GROUP BY  Emp_ID ) LQry ON LQry.Emp_ID = I_Q.Emp_Id
					
					group by D.Emp_Id ,E.Alpha_Emp_Code,E.Emp_Full_Name,Branch_name,Desig_Name,Dept_Name ,Grd_Name , Type_Name ,Vertical_Name , SubVertical_Name , CM.Cmp_Name,CM.Cmp_Address,LQry.OD_Days
				
				END	 
  		
  Else If @Return_Record_set = 10
		BEGIN			
			SELECT t1.Emp_id,t1.Emp_code,t1.Emp_Full_Name,Sum(WorkDay) As WorkDay,Shift
			INTO #TMP
			from(
				Select QRy.emp_id , QRy.Emp_code ,  QRy.Emp_Full_Name ,  Sum(Qry.P_days) as WorkDay, 
					(Case WHEN QRy.Shift_ID in (SELECT Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK)
												where 
													(CASE WHEN CONVERT(VARCHAR(8),Shift_St_Time,108) > CONVERT(VARCHAR(8),Shift_End_Time,108) OR CONVERT(VARCHAR(8),Shift_St_Time,108) = '00:00' THEN 
														1
													END
													) = 1
												) THEN 'Night' ELSE 'Day' END) As Shift from 
						(	
							SELECT D.Emp_id , D.Shift_ID , SM.Shift_Name, Em.Emp_code , Em.Emp_Full_Name , D.P_days as P_days , D.For_date
							from #Data D
							Inner JOin T0040_Shift_master SM WITH (NOLOCK) ON SM.Shift_ID = D.Shift_ID
							INNER JOIN T0080_EMP_MASTER Em WITH (NOLOCK) on Em.Emp_ID = D.Emp_Id
						)QRy

				GROUP BY QRy.Shift_ID , QRy.emp_id , QRy.Emp_code , QRy.Emp_Full_Name 
			) t1 
			GROUP BY t1.Emp_id,t1.Emp_Full_Name,t1.Emp_code , Shift


					 SELECT D.Emp_Id,E.Alpha_Emp_Code , E.Emp_Full_Name, Branch_name, Desig_Name, Dept_Name, Grd_Name, Type_Name , Vertical_Name , 
					 SubVertical_Name, CM.Cmp_Name,CM.Cmp_Address , QryShift.Work_day , QryShift.WorkNight	
					 from #Data D 
					 INNER JOIN T0080_emp_master E WITH (NOLOCK) on D.Emp_ID = E.Emp_ID
					 INNER JOIN T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID
					 INNER JOIN  
							(select I.Emp_Id ,Branch_ID,Cat_ID,Desig_ID,Dept_ID , Grd_ID ,Type_ID , Vertical_ID , SubVertical_ID  from T0095_Increment I WITH (NOLOCK)
							INNER JOIN 
								(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @To_Date    
										and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID 
										and I.Increment_ID = Qry.Increment_ID  ) I_Q on E.Emp_ID = I_Q.Emp_ID 
					 INNER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
					 INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
					 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
					 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
					 LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
					 LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON I_Q.Vertical_ID = VS.Vertical_ID
					 LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON I_Q.SubVertical_ID = SV.SubVertical_ID
					 Inner JOIN (	
					 --SELECT t1.emp_id as Emp_id, t1.WorkDay as Work_day , Isnull(t2.WorkDayNight,0) as WorkNight FROM #tmp t1	 -- change by rohit for Case employee do work for night whole month on 04012017
					 --LEFT OUTER JOIN (select WorkDay  As WorkDayNight, emp_id from #TMP where Shift = 'Night') t2 ON t1.emp_id=t2.emp_id
					 --where t1.Shift='Day'
					 SELECT isnull(t1.emp_id,t2.emp_id) as Emp_id, isnull(t1.WorkDay,0) as Work_day , Isnull(t2.WorkDayNight,0) as WorkNight FROM (select WorkDay  As WorkDay, emp_id ,shift from #TMP where Shift = 'Day') t1	
						full OUTER JOIN (select WorkDay  As WorkDayNight, emp_id ,shift from #TMP where Shift = 'Night') t2 ON t1.emp_id=t2.emp_id
						where (isnull(t1.Shift,'Day')='Day' )
									)QryShift on QryShift.Emp_id = I_Q.Emp_ID					 
					group by D.Emp_Id ,E.Alpha_Emp_Code,E.Emp_Full_Name,Branch_name,Desig_Name,Dept_Name ,Grd_Name , Type_Name ,Vertical_Name , SubVertical_Name , CM.Cmp_Name,CM.Cmp_Address , QryShift.Work_day , QryShift.WorkNight			
					
	END	 
	ELSE IF @RETURN_RECORD_SET = 11  --For OverTime Tracking Report Added By Jimit 07052018------
		 BEGIN
				
						IF OBJECT_ID('DBO.TEMPDB..#RMRORM') IS NOT NULL
						DROP TABLE #RMRORM
					
						CREATE TABLE #RMRORM
						(
							EMP_ID				NUMERIC,
							R_EMP_ID			NUMERIC				
						)
						
						CREATE table #Emp_Cons 
						(      
							Emp_ID numeric ,     
							Branch_ID numeric,
							Increment_ID numeric    
						)     				 
						
						if @Constraint <> ''
							begin
								Insert Into #Emp_Cons
								Select	cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) 
								From	dbo.Split(@Constraint,'#') 
							end
						
						Insert	INTO #RMRORM
						SELECT	EC.Emp_Id,RM.R_Emp_ID 
						From	#Emp_Cons EC Inner Join 
								V0010_Get_Max_Reporting_manager RM ON EC.Emp_ID = RM.Emp_ID
						
						
						UPDATE  RM
						SET	    RM.R_Emp_Id = Q.R_Emp_ID 
						FROM	#RMRORM RM INNER JOIN
								#Emp_Cons EC On Ec.Emp_ID = Rm.Emp_ID INNER JOIN
								(
									SELECT	ERD.R_Emp_ID , ERD.Emp_ID
									FROM	
											T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN
											(
												SELECT	 MAX(Effect_Date) as Effect_Date, Emp_ID 
												FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												WHERE	 Effect_Date <= GETDATE()
												GROUP BY emp_ID
											) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
											INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = ERD.R_EMP_ID 
									WHERE EXISTS (
													SELECT	DISTINCT ERD1.EMP_ID
													FROM	T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) INNER JOIN
															(
																SELECT	 MAX(Effect_Date) as Effect_Date, Emp_ID 
																from	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
																WHERE	 Effect_Date <= GETDATE()
																GROUP BY emp_ID
															) RQry on  ERD1.Emp_ID = RQry.Emp_ID and ERD1.Effect_Date = RQry.Effect_Date
													INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = ERD1.R_EMP_ID AND ERD.Emp_ID = E.Emp_ID 
													Inner Join #Emp_Cons ECS On ECS.Emp_ID  = ERD1.Emp_ID 				
												)
								)Q On Q.Emp_ID = Rm.R_EMP_ID
								
								
								
						SELECT * FROM 
					(
							select	distinct OA.Emp_Id,OA.For_date,OA.P_days,case when @max_OTDaily = 0 then OA.OT_Sec 
											   when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) 
											   else oa.OT_Sec end as OT_Sec,
									E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,
									Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,DGM.Desig_Dis_No,
									Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour,
									case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
									OA.Weekoff_OT_Sec,OA.Holiday_OT_Sec,Replace(dbo.F_Return_Hours(OA.Weekoff_OT_Sec),':','.') Weekoff_OT_Hour, Replace(dbo.F_Return_Hours(OA.Holiday_OT_Sec),':','.') Holiday_OT_Hour,			  							
									case when OTA.Is_Approved = 1 then 'Approved' 
									else case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end 
									end as OT_Status,
									(Qry_Reporting.Alpha_Emp_Code + ' - ' + Qry_Reporting.Emp_Full_Name) as Manager	
									,SD.Rpt_Level
									,@FROM_DATE as FROM_DATE ,@TO_DATE as TO_DATE,ota.System_Date as Approved_Date	  
							from	#Data   OA   inner join			
									T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID		inner join			
									T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID	inner join			
									( 
										select	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
										from	T0095_Increment I WITH (NOLOCK) inner join			
												(
													select	max(Increment_ID) as Increment_ID , Emp_ID 
													from	T0095_Increment WITH (NOLOCK)
													where	Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID 
													group by emp_ID
												) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
									) I_Q on E.Emp_ID = I_Q.Emp_ID inner join			
									T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN		
									T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN		
									T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN		
									T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN			
									T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 	Left Outer join
									(
										SELECT  R1.Emp_ID, Effect_Date AS Effect_Date,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
										FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) INNER JOIN 
												(
													SELECT		MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
													FROM		T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) INNER JOIN 
																(
																	SELECT	MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID 
																	FROM	T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK) 
																	WHERE	R3.Effect_Date < GETDATE() 
																	GROUP BY R3.Emp_ID
																)R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date 
													GROUP BY R2.Emp_ID
												) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID	INNER JOIN 
												T0080_EMP_MASTER Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id
									) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID	Left Outer join 
									T0095_EMP_SCHEME ES WITH (NOLOCK) on OA.Emp_ID = ES.Emp_ID Inner Join
										 (
											select	 MAX(Effective_Date) as For_Date, Emp_ID,Cmp_ID 
											from	 T0095_EMP_SCHEME WITH (NOLOCK)
											where    Effective_Date<=GETDATE() And Type = 'Over Time' and Cmp_ID = @Cmp_ID
											GROUP BY emp_ID,Cmp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID AND ES.Effective_Date = QES.For_Date AND Type = 'Over Time'	
										 AND ES.Cmp_ID = QES.Cmp_ID INNER JOIN 
									T0050_Scheme_Detail SD WITH (NOLOCK) on ES.Scheme_ID=SD.Scheme_Id AND ES.Type='Over Time'	 Left OUTER JOIN	
									T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date
									and OTA.Rpt_Level = Sd.Rpt_Level		
						Where		(OA.OT_Sec > 0 or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0)  AND
									(SD.Is_RM=1 and sd.Is_RMToRM = 0)
						--						order by	For_Date
						
						UNION 
						
						select	distinct OA.Emp_Id,OA.For_date,OA.P_days,case when @max_OTDaily = 0 then OA.OT_Sec 
											   when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) 
											   else oa.OT_Sec end as OT_Sec,
								E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,
								Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,E.Date_of_Join,DGM.Desig_Dis_No,
								Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour,
								case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
								OA.Weekoff_OT_Sec,OA.Holiday_OT_Sec,Replace(dbo.F_Return_Hours(OA.Weekoff_OT_Sec),':','.') Weekoff_OT_Hour, Replace(dbo.F_Return_Hours(OA.Holiday_OT_Sec),':','.') Holiday_OT_Hour,			  										  							
								case when OTA.Is_Approved = 1 then 'Approved' 
								else case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end 
								end as OT_Status,
								(isnull(RM.Alpha_Emp_Code,E.Alpha_Emp_Code) + ' - ' + isnull(RM.Emp_Full_Name,E.Emp_Full_Name)) as Manager	,SD.Rpt_Level			  
								,@FROM_DATE as FROM_DATE ,@TO_DATE as TO_DATE,ota.System_Date as Approved_Date	
						from	T0050_Scheme_Detail SD WITH (NOLOCK)
								inner join T0095_EMP_SCHEME ES WITH (NOLOCK)
								Inner Join
										 (select	MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
													where Effective_Date<=GETDATE() And Type = 'Over Time'
													GROUP BY emp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID and ES.Effective_Date = QES.For_Date and Type = 'Over Time'										  
								on ES.Scheme_ID=SD.Scheme_Id and ES.Type='Over Time'   inner join 
								T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=ES.Emp_ID	 LEFt Outer Join
								#Data   OA On oa.Emp_Id = E.Emp_Id  inner join			
								T0080_emp_master RM WITH (NOLOCK) ON RM.Emp_ID=SD.App_Emp_ID  inner join			
								T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join			
								( 
									select	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
									from	T0095_Increment I WITH (NOLOCK) inner join			
											(
												select	max(Increment_ID) as Increment_ID , Emp_ID 
												from	T0095_Increment WITH (NOLOCK)
												where	Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID 
												group by emp_ID
											) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
								) I_Q on E.Emp_ID = I_Q.Emp_ID inner join			
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN		
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN		
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN		
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN			
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID Left OUTER JOIN	
								T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date and  OTA.Rpt_Level = Sd.Rpt_Level		Left join
								(
									SELECT  R1.Emp_ID, Effect_Date AS Effect_Date,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
									FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) INNER JOIN 
											(
												SELECT		MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
												FROM		T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) INNER JOIN 
															(
																SELECT	MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID 
																FROM	T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK)
																WHERE	R3.Effect_Date < GETDATE() 
																GROUP BY R3.Emp_ID
															)R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date 
												GROUP BY R2.Emp_ID
											) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID	INNER JOIN 
											T0080_EMP_MASTER Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id
								) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID				
						Where	(OA.OT_Sec > 0 or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0) and
								(SD.Is_RM=0 and SD.Is_RMToRM =0)       									
						
						
						UNION
						
						select DISTINCT	OA.Emp_Id,OA.For_date,OA.P_days,case when @max_OTDaily = 0 then OA.OT_Sec 
											   when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) 
											   else oa.OT_Sec end as OT_Sec,
								E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,
								Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,E.Date_of_Join,DGM.Desig_Dis_No,
								Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour,
								case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
								OA.Weekoff_OT_Sec,OA.Holiday_OT_Sec,Replace(dbo.F_Return_Hours(OA.Weekoff_OT_Sec),':','.') Weekoff_OT_Hour, Replace(dbo.F_Return_Hours(OA.Holiday_OT_Sec),':','.') Holiday_OT_Hour,			  										  							
								case when OTA.Is_Approved = 1 then 'Approved' 
								else case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end 
								end as OT_Status,
								(Q.Alpha_Emp_Code + ' - ' + Q.Emp_Full_Name) as Manager	,SD.Rpt_Level			  
								,@FROM_DATE as FROM_DATE ,@TO_DATE as TO_DATE,ota.System_Date as Approved_Date	
						from	#Data  OA inner join			
								T0080_emp_master E WITH (NOLOCK) ON E.Emp_ID = OA.Emp_ID Left OUTER JOIN 
								(
									select		R1.Emp_ID,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
									 FROM		#RMRORM R1 Inner JOIN 
												T0080_EMP_MASTER Em WITH (NOLOCK) On R1.R_emp_id = Em.emp_id											 
								) Q On Q.EMP_ID = e.Emp_ID inner join			
								T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join			
								( 
									select	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
									from	T0095_Increment I WITH (NOLOCK) inner join			
											(
												select	max(Increment_ID) as Increment_ID , Emp_ID 
												from	T0095_Increment WITH (NOLOCK)
												where	Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID 
												group by emp_ID
											) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
								) I_Q on E.Emp_ID = I_Q.Emp_ID inner join			
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN		
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN		
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN		
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN			
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 	Left join								(
									SELECT  R1.Emp_ID, Effect_Date AS Effect_Date,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
									FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) INNER JOIN 
											(
												SELECT		MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
												FROM		T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) INNER JOIN 
															(
																SELECT	MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID 
																FROM	T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK)
																WHERE	R3.Effect_Date < GETDATE() 
																GROUP BY R3.Emp_ID
															)R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date 
												GROUP BY R2.Emp_ID
											) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID	INNER JOIN 
											T0080_EMP_MASTER Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id
								) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID	Left join 
								T0095_EMP_SCHEME ES WITH (NOLOCK) on OA.Emp_ID = ES.Emp_ID Inner Join
								 (
									select	MAX(Effective_Date) as For_Date, Emp_ID,Cmp_ID 
									from	T0095_EMP_SCHEME WITH (NOLOCK)
									where	Effective_Date<=GETDATE() And Type = 'Over Time' and Cmp_ID = @Cmp_ID
									GROUP BY emp_ID,Cmp_ID
								 ) QES on ES.Emp_ID = QES.Emp_ID AND ES.Effective_Date = QES.For_Date
										 AND Type = 'Over Time' AND ES.Cmp_ID = QES.Cmp_ID INNER JOIN 
								T0050_Scheme_Detail SD 	WITH (NOLOCK) on ES.Scheme_ID=SD.Scheme_Id AND ES.Type='Over Time' Left OUTER JOIN	
								T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date
								and OTA.Rpt_Level = Sd.Rpt_Level		
						Where	(OA.OT_Sec > 0 or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0) and
								(SD.Is_RM=0 and sd.Is_RMToRM = 1) 
						
						
						
						UNION
						
						select	distinct OA.Emp_Id,OA.For_date,OA.P_days,case when @max_OTDaily = 0 then OA.OT_Sec 
											   when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) 
											   else oa.OT_Sec end as OT_Sec,
								E.Emp_Full_Name as Emp_Full_Name,E.Alpha_Emp_Code,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,
								Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,E.Date_of_Join,DGM.Desig_Dis_No,
								Replace(dbo.F_Return_Hours(Duration_in_Sec),':','.') as Working_Hour,
								case when @max_OTDaily = 0 then replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') when dbo.F_Return_Sec(replace(@max_OTDaily,'.',':')) < OA.OT_Sec then replace(@max_OTDaily,':','.') else replace(dbo.F_Return_Hours(OA.OT_Sec),':','.') end as OT_Hour,
								OA.Weekoff_OT_Sec,OA.Holiday_OT_Sec,Replace(dbo.F_Return_Hours(OA.Weekoff_OT_Sec),':','.') Weekoff_OT_Hour, Replace(dbo.F_Return_Hours(OA.Holiday_OT_Sec),':','.') Holiday_OT_Hour,			  										  							
								case when OTA.Is_Approved = 1 then 'Approved' 
								else case when OTA.Is_Approved = 0 then 'Rejected' else 'Pending' end 
								end as OT_Status,
								(isnull(EM1.Alpha_Emp_Code,E.Alpha_Emp_Code) + ' - ' + isnull(EM1.Emp_Full_Name,E.Emp_Full_Name)) as Manager
								,SD.Rpt_Level			  
								,@FROM_DATE as FROM_DATE ,@TO_DATE as TO_DATE,ota.System_Date as Approved_Date	
						from	T0050_Scheme_Detail SD WITH (NOLOCK)
								inner join T0095_EMP_SCHEME ES WITH (NOLOCK)
								Inner Join
										 (select	MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
													where Effective_Date<=GETDATE() And Type = 'Over Time'
													GROUP BY emp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID and ES.Effective_Date = QES.For_Date and Type = 'Over Time'										  
								on ES.Scheme_ID=SD.Scheme_Id and ES.Type='Over Time' and Sd.Is_Bm = 1  inner join 
								T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID=ES.Emp_ID	 LEFt Outer Join
								#Data OA On oa.Emp_Id = E.Emp_Id and Oa.Emp_Id = Es.Emp_ID inner join											
								T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join			
								( 
									select	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
									from	T0095_Increment I WITH (NOLOCK) inner join			
											(
												select	max(Increment_ID) as Increment_ID , Emp_ID 
												from	T0095_Increment WITH (NOLOCK)
												where	Increment_Effective_date <= @To_Date  and Cmp_ID = @Cmp_ID 
												group by emp_ID
											) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
								) I_Q on E.Emp_ID = I_Q.Emp_ID inner join			
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN		
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN		
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN		
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN			
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID Left OUTER JOIN	
								T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK) on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = OA.For_date and OTA.Rpt_Level = Sd.Rpt_Level	 	Left join
								(
									SELECT  R1.Emp_ID, Effective_Date AS Effect_Date,R1.Branch_ID
									FROM    dbo.T0095_MANAGERS R1 WITH (NOLOCK) INNER JOIN 
											(
												SELECT		MAX(R2.Tran_id) AS ROW_ID, R2.Emp_ID
												FROM		T0095_MANAGERS R2 WITH (NOLOCK) INNER JOIN 
															(
																SELECT	MAX(R3.Effective_Date) AS Effect_Date, R3.Emp_ID 
																FROM	T0095_MANAGERS R3 WITH (NOLOCK)
																WHERE	R3.Effective_Date < GETDATE() 
																GROUP BY R3.Emp_ID
															)R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effective_Date=R3.Effect_Date 
												GROUP BY R2.Emp_ID
											) R2 ON R1.Emp_ID=R2.Emp_ID 	
								) AS Qry_Reporting ON E.Branch_ID = Qry_Reporting.branch_id	 	Inner join
								T0080_Emp_Master Em1 WITH (NOLOCK) On Em1.Emp_Id = Qry_Reporting.Emp_id								
						Where	(OA.OT_Sec > 0 or OA.Weekoff_OT_Sec > 0 or OA.Holiday_OT_Sec > 0) and
								(SD.Is_BM=1)
						
						)Q
					order by Emp_Id,For_Date,rpt_Level
						
								
				
		 END 

  		
RETURN      


