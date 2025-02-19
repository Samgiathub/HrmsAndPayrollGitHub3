---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_INOUT_SYNCHRONIZATION_FromDate_ToDate]
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
 ,@PBranch_ID varchar(max) = '0'  
 ,@Check_Regularization_Flag numeric = 0 
 ,@PVertical_ID	varchar(max)= '' --Added By Jaina 24-09-2015
 ,@PSubVertical_ID	varchar(max)= '' --Added By Jaina 24-09-2015
 ,@PDept_ID varchar(max)=''  --Added By Jaina 24-09-2015
 ,@User_Id numeric(18,0)=0 --Added by Sumit
 ,@IPAddress varchar(50) ='' --Ended by Sumit 15022016
 ,@Return_Record int =1  --Added by Jignesh - 20-09-2017----
  
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF
	
	declare @data_count as numeric
	set @data_count = 0
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
	   
	IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 24-09-2015
		set @PBranch_ID = null   	

	if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 24-09-2015
		set @PVertical_ID = null

	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 24-09-2015
		set @PsubVertical_ID = null

	IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 24-09-2015
		set @PDept_ID = NULL	 


--Added By Jaina 24-09-2015 Start		
	if @PBranch_ID is null
	Begin	
		select @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		If @PBranch_ID IS NULL
			set @PBranch_ID = '0';
		else			
			set @PBranch_ID = @PBranch_ID + ',0';	
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		if @PDept_ID is null
			set @PDept_ID = '0';
		else
			set @PDept_ID = @PDept_ID + ',0'		
	End
	--Added By Jaina 24-09-2015 End
declare @OldValue as  varchar(max)
declare @BranchName as varchar(200)
Declare @String as varchar(max)
set @String=''
set @OldValue =''	
set @BranchName=''


			
 --Declare @Emp_Cons Table      
 --(      
 -- Emp_ID numeric      
 -- --Vertical_ID numeric(18,0),  --Added By Jaina 24-09-2015
 -- --SubVertical_ID numeric(18,0), --Added By Jaina 24-09-2015
 -- --Dept_ID numeric(18,0) --Added By Jaina 24-09-2015
 --)      
 
 --if @Constraint <> ''      
 -- begin      
 --  Insert Into @Emp_Cons(Emp_ID)      
 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')       
 -- end      
 --else      
 -- begin      
 --  if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
	--	begin			
	--		Insert Into @Emp_Cons(Emp_ID)--,Vertical_ID,SubVertical_ID,Dept_ID) --Change By Jaina 24-09-2015     
		      
	--	   select I.Emp_Id --,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID   --Change By Jaina 24-09-2015
	--	    from T0095_Increment I inner join       
	--		 ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment      
	--		 where Increment_Effective_date <= @To_Date      
	--		 and Cmp_ID = @Cmp_ID      
	--		 group by emp_ID  ) Qry on      
	--		 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date       
		             
	--	   Where Cmp_ID = @Cmp_ID       
	--	   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--	   --and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
	--	   and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(replace(PB.data,'',0) as numeric)=Isnull(I.Branch_ID,0))
	--	   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
	--	   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--	   --and Isnull(vertical_ID,0) in (select DATA from dbo.Split(@PVertical_ID,',') )		--Added By Jaina 24-09-2015
	--	   --and Isnull(SubVertical_ID,0) in (select DATA from dbo.Split(@PsubVertical_ID,',') )	--Added By Jaina 24-09-2015
	--	   --and Isnull(Dept_ID,0) in (select DATA from dbo.Split(@PDept_ID,',') )   --Added By Jaina 24-09-2015  
	--	   and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
 --  		   and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
	--       and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
		   
	--	end
	--else	
	--	begin
		   
		
	--	   Insert Into @Emp_Cons(Emp_ID) --,Vertical_ID,SubVertical_ID,Dept_ID) --Change By Jaina 24-09-2015           
	--	   select I.Emp_Id --,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID   --Change By Jaina 24-09-2015
	--	    from T0095_Increment I inner join       
	--		 ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment      
	--		 where Increment_Effective_date <= @To_Date      
	--		 and Cmp_ID = @Cmp_ID      
	--		 group by emp_ID  ) Qry on      
	--		 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date       
		             
	--	   Where Cmp_ID = @Cmp_ID       
	--	   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--	   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
	--	   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
		   
	--	end          
 -- end      
  
	CREATE TABLE #EMP_CONS 
			(      
				EMP_ID NUMERIC ,     
				BRANCH_ID NUMERIC,
				INCREMENT_ID NUMERIC
			)	
	EXEC SP_RPT_FILL_EMP_CONS @CMP_ID=@CMP_ID,@FROM_DATE=@FROM_DATE,@TO_DATE=@TO_DATE,@BRANCH_ID=@BRANCH_ID,@CAT_ID=@CAT_ID,@GRD_ID=@GRD_ID,@TYPE_ID=@TYPE_ID,@DEPT_ID=@DEPT_ID,@DESIG_ID=@DESIG_ID,@EMP_ID=@EMP_ID,@CONSTRAINT=@CONSTRAINT
	--,0,0,0,0,0,0,0,0,0,'',0,0   
	       
 Declare @IO_DATETIME DATETIME     
 Declare @IP_ADDRESS VARCHAR(50)    
 Declare @In_Out_flag numeric 
 Declare @Flag int 
 Declare @FromDate DATETIME 
 Declare @ToDate DATETIME

SET @FromDate = Null
SET @ToDate   = Null

set @In_Out_flag = 0
set @Flag = 0
	 
 Declare @In_Time Datetime     
 Declare @Out_Time Datetime     
 Declare @For_Date Datetime     
 Declare @varFor_Date varchar(22)     
 Declare @F_In_Time datetime     
 Declare @F_Out_Time Datetime     
 Declare @S_In_Time datetime     
 Declare @S_Out_Time Datetime     
 Declare @T_In_Time datetime     
 Declare @T_Out_Time Datetime     
	
	
 Declare @Shift_st_Time  Datetime     
 Declare @Shift_End_Time  datetime     
 Declare @F_Shift_In_Time Datetime     
 Declare @F_Shift_End_Time datetime     
 Declare @S_Shift_in_Time datetime     
 Declare @S_shift_end_Time datetime     
 Declare @T_Shift_In_Time datetime     
 Declare @T_Shift_End_Time datetime 
 
 Declare @Shift_st_Time_P  Datetime     
 Declare @Shift_End_Time_P  datetime     
 Declare @F_Shift_In_Time_P Datetime     
 Declare @F_Shift_End_Time_P datetime     
 Declare @S_Shift_in_Time_P datetime     
 Declare @S_shift_end_Time_P datetime     
 Declare @T_Shift_In_Time_P datetime     
 Declare @T_Shift_End_Time_P datetime  
 Declare @For_Date_P Datetime    
  
  
 declare @IO_Tran_ID   numeric     
 declare @Last_Entry numeric(18,0)
 Declare @minutdiff numeric(22,0)
 declare @Enroll_no numeric
 set @Enroll_no = 0
 
 --Added by Hardik 15/06/2016
 Declare @In_Out_Flag_SP tinyint
 Set @In_Out_Flag_SP = 0
 SELECT @In_Out_Flag_SP = ISNULL(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) where Setting_Name='In and Out Punch depends on Device In-Out Flag' and Cmp_ID = @Cmp_ID
 
  --Mukti(01092017)
 DECLARE @Approval_Required INT = 0
 select @Approval_Required=isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@CMP_ID and Setting_Name='Required Mobile In Out Approval'  
 
 DECLARE @CmpID numeric(18,0)

--Conditions added by Sumit for Month Lock and Date Check 15022016
select @BranchName = Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=isnull(@Branch_ID,0)
if (isnull(@BranchName,'') ='')
	Begin
		set @BranchName='All'
	End
declare @Sal_St_Date as datetime
declare @Sal_End_Date as datetime
Declare @manual_salary_period tinyint


select @Sal_St_Date=sal_st_date,@manual_salary_period=isnull(GS2.Manual_Salary_Period,0) from T0040_GENERAL_SETTING GS2 WITH (NOLOCK) ,
	(select MAX(for_date) as For_Date from T0040_GENERAL_SETTING WITH (NOLOCK) 
			where Cmp_ID=@Cmp_ID and Branch_ID=isnull(@Branch_ID,0)) GS
	where GS2.For_Date=gs.For_Date and GS2.Branch_ID=isnull(@Branch_ID,0) and Cmp_ID=@Cmp_ID
	
if (isnull(@Sal_St_Date,'')='')
	Begin
		set @Sal_St_Date = cast('01/' + cast(dbo.F_GET_MONTH_NAME(Month(DATEADD(MM,1,@From_Date))) as nvarchar) + '/' + cast(YEAR(@From_Date) as nvarchar) as datetime)
		set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Sal_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Sal_St_Date) )as varchar(10)) as smalldatetime)
		set @Sal_End_Date=dateadd(d,-1,dateadd(m,1,@Sal_St_Date))  		
	End
Else if day(@Sal_St_Date) =1
	Begin
		set @Sal_St_Date =  @From_Date
		set @Sal_End_Date= @To_Date
	End	
Else
If @manual_salary_period = 0 
		Begin
			set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)
			set @Sal_End_Date=dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		End
	Else
		begin
			select @Sal_St_Date=from_date,@Sal_End_Date=end_date 
			from salary_period where month= month(@To_Date) and YEAR=year(@To_Date)
		end  	
	
 if exists(select 1 from T0250_MONTHLY_LOCK_INFORMATION ML WITH (NOLOCK) where Cmp_ID=@Cmp_ID and (Branch_ID =0 or Branch_ID=isnull(@Branch_ID,0)) and ((ML.Month=Month(@From_Date) And ML.Year=Year(@From_Date)) or (ML.Month=Month(@To_Date) ANd ML.Year=Year(@To_Date)))) 
	Begin		
		if (@From_Date between @Sal_St_Date and @Sal_End_Date) OR (@To_Date between @Sal_St_Date and @Sal_End_Date)
			Begin			
				RAISERROR('@@ This Month is Lock @@',16,2)
				RETURN -1
			End
	End --Conditions Ended by Sumit for Month Lock and Date Check 15022016
 
	 ------------Add By Jignesh 06-Sep-2017 (Check SALARY For Regularization Data)-----
	 Delete From #EMP_CONS
	 Where EMP_ID In 
	 (
		SELECT Emp_id from T0200_MONTHLY_SALARY WITH (NOLOCK)
		--Where (Month_St_Date between @Sal_St_Date and @Sal_End_Date) 
		--OR (Month_End_Date between @Sal_St_Date and @Sal_End_Date)
		--Where (Month_St_Date between @From_Date and @To_Date) 
		--OR (Month_End_Date between @From_Date and @To_Date)
		Where (Isnull(@EMP_ID,0) = 0 OR Emp_ID= @EMP_ID)
		AND((ISNULL(Cutoff_Date,Month_St_Date) between @From_Date and @To_Date) 
		OR (ISNULL(Cutoff_Date,Month_End_Date) between @From_Date and @To_Date))
		
	  )
	  ---------End By Jignesh 06-Sep-2017 -----

IF NOT EXISTS (SELECT 1 FROM sys.objects 
		WHERE object_id = OBJECT_ID(N'[dbo].[T0150_emp_inout_Record_Before_Delete]'	) AND type in (N'U'))
		BEGIN
			SELECT * Into T0150_emp_inout_Record_Before_Delete  from T0150_emp_inout_Record WITH (NOLOCK) Where 0=1
		END

IF NOT EXISTS (select 1 from INFORMATION_SCHEMA.COLUMNS 
					WHERE TABLE_NAME ='T0150_emp_inout_Record_Before_Delete'
					And COLUMN_NAME like '%User_ID%' )
		BEGIN
		ALTER TABLE dbo.T0150_emp_inout_Record_Before_Delete ADD
				[User_ID] Int NULL	
		END	

--------- jignesh --- 01-Nov-2017------------
declare @RecCount as int
select @RecCount=COUNT(1) from T0150_emp_inout_Record_Before_Delete WITH (NOLOCK)
	if @RecCount>40000
	begin
		declare @Max_Date datetime
		select top 10000 @Max_Date = For_Date from T0150_emp_inout_Record_Before_Delete WITH (NOLOCK) order by For_Date
		delete T0150_emp_inout_Record_Before_Delete Where for_date <= @Max_Date
		Return
	end
--------- End --- 01-Nov-2017------------



 if @Check_Regularization_Flag = 0
	 begin
	 
 		---- Modify by jignesh 06-Sep-2017 -----
 		
 		--delete from T0150_emp_inout_Record where for_date >= @from_Date and for_date <= @to_date 
 		--and  Chk_By_Superior <> 1 and  emp_id in (select Emp_id from #EMP_CONS)
 		IF @Return_Record= 0		
 		Begin
			SET @From_Date = @From_Date-1
		End
 		
 			---------- Query 1 Add by jignesh 06-Sep-2017--------------------
 	   INSERT INTO T0150_emp_inout_Record_Before_Delete
 	  	 ( [IO_Tran_Id],[Emp_ID],[Cmp_ID],[For_Date],[In_Time],[Out_Time],[Duration]
      ,[Reason],[Ip_Address],[In_Date_Time],[Out_Date_Time],[Skip_Count],[Late_Calc_Not_App]
      ,[Chk_By_Superior],[Sup_Comment],[Half_Full_day],[Is_Cancel_Late_In] ,[Is_Cancel_Early_Out]
      ,[Is_Default_In] ,[Is_Default_Out],[Cmp_prp_in_flag],[Cmp_prp_out_flag] ,[is_Cmp_purpose]
      ,[App_Date] ,[Apr_Date],[System_date],[Other_Reason],[ManualEntryFlag],[User_ID])
		
 	   SELECT [IO_Tran_Id],[Emp_ID],[Cmp_ID],[For_Date],[In_Time],[Out_Time],[Duration]
      ,[Reason],[Ip_Address],[In_Date_Time],[Out_Date_Time],[Skip_Count],[Late_Calc_Not_App]
      ,[Chk_By_Superior],[Sup_Comment],[Half_Full_day],[Is_Cancel_Late_In] ,[Is_Cancel_Early_Out]
      ,[Is_Default_In] ,[Is_Default_Out],[Cmp_prp_in_flag],[Cmp_prp_out_flag] ,[is_Cmp_purpose]
      ,[App_Date] ,[Apr_Date],GETDATE() as System_date,[Other_Reason],[ManualEntryFlag],@User_ID
 		from T0150_emp_inout_Record AS In_Out WITH (NOLOCK)
	 	WHERE for_date >= @from_Date and for_date <= @to_date 
		AND  (isnull(Chk_By_Superior,0) =0  Or isnull(Chk_By_Superior,0) =1)
		AND isnull(Reason,'') = '' 
		AND isnull(ManualEntryFlag,'N') ='N' 
		AND  emp_id in (select Emp_id from #EMP_CONS)
		
		AND NOT EXISTS
		(
			SELECT IO_Tran_ID,Emp_ID ,IO_DateTime from (
			SELECT IO_Tran_ID,Emp_ID,in_time as IO_DateTime ,ip_address FROM T0150_emp_inout_Record_Before_Delete AS In_Out_BE WITH (NOLOCK)
			UNION all
			SELECT IO_Tran_ID,Emp_ID ,Out_time as IO_DateTime,ip_address FROM T0150_emp_inout_Record_Before_Delete AS In_Out_BE WITH (NOLOCK)
		) as Emp_Inout 
		
			WHERE In_Out.emp_id=Emp_Inout.emp_id 
			----And ((In_Out.In_Time =Emp_Inout.IO_DateTime) OR (In_Out.Out_Time =Emp_Inout.IO_DateTime))
			
			And (				
					(
					CAST((cast( In_Out.In_Time as varchar(11)) + ' ' + dbo.F_GET_AMPM( In_Out.In_Time)) as datetime)
					=CAST((cast(Emp_Inout.IO_DateTime as varchar(11)) + ' ' + dbo.F_GET_AMPM( Emp_Inout.IO_DateTime)) as datetime)
					)
					OR
					(
					CAST((cast( In_Out.Out_Time as varchar(11)) + ' ' + dbo.F_GET_AMPM( In_Out.Out_Time)) as datetime)
					=CAST((cast(Emp_Inout.IO_DateTime as varchar(11)) + ' ' + dbo.F_GET_AMPM( Emp_Inout.IO_DateTime)) as datetime)
					)
					
				)
				
        )	
        AND NOT EXISTS(SELECT 1 FROM T0150_emp_inout_Record_Before_Delete D WITH (NOLOCK) WHERE D.IO_Tran_Id = In_Out.IO_Tran_Id)
        AND NOT EXISTS
		(SELECT 
		 1 From 
		 (
				SELECT Distinct Emp_id ,For_Date  From T0150_emp_inout_Record WITH (NOLOCK) 
				WHERE (isnull(Reason,'') <> '' OR isnull(ManualEntryFlag,'N') <> 'N' )
				)As IO_DATA
	   
				WHERE  IO_DATA.For_Date=Cast(Cast(In_Out.for_date as varchar(11)) as DateTime) 
				AND IO_DATA.Emp_Id=In_Out.Emp_ID 
			) 
		------------End Query 1------------------
		
		----------Query 2 Add by jignesh 06-Sep-2017--------------------
	 	DELETE from T0150_emp_inout_Record 
	 	WHERE for_date >= @from_Date and for_date <= @to_date 
		AND  (isnull(Chk_By_Superior,0) =0  Or isnull(Chk_By_Superior,0) =1)
		AND isnull(Reason,'') = '' 
		AND isnull(ManualEntryFlag,'N') ='N' 
		AND emp_id in (select Emp_id from #EMP_CONS)	
		AND NOT EXISTS
		(SELECT 
		 * From 
		 (
				SELECT Distinct Emp_id ,For_Date  From T0150_emp_inout_Record WITH (NOLOCK) 
				WHERE (isnull(Reason,'') <> '' OR isnull(ManualEntryFlag,'N') <> 'N' )
				)As IO_DATA
	   
				WHERE  IO_DATA.For_Date=Cast(Cast(T0150_emp_inout_Record.for_date as varchar(11)) as DateTime) 
				AND IO_DATA.Emp_Id=T0150_emp_inout_Record.Emp_ID 
			) 
		------------End Query 2------------------
		
		------- End  jignesh 06-Sep-2017  -----	
			
	 end
 else
	 begin	
		
		 ---------- Query 1 Add by jignesh 06-Sep-2017--------------------
 	   INSERT INTO T0150_emp_inout_Record_Before_Delete
 	  	 ( [IO_Tran_Id],[Emp_ID],[Cmp_ID],[For_Date],[In_Time],[Out_Time],[Duration]
      ,[Reason],[Ip_Address],[In_Date_Time],[Out_Date_Time],[Skip_Count],[Late_Calc_Not_App]
      ,[Chk_By_Superior],[Sup_Comment],[Half_Full_day],[Is_Cancel_Late_In] ,[Is_Cancel_Early_Out]
      ,[Is_Default_In] ,[Is_Default_Out],[Cmp_prp_in_flag],[Cmp_prp_out_flag] ,[is_Cmp_purpose]
      ,[App_Date] ,[Apr_Date],[System_date],[Other_Reason],[ManualEntryFlag],[User_ID])
		
 	   SELECT [IO_Tran_Id],[Emp_ID],[Cmp_ID],[For_Date],[In_Time],[Out_Time],[Duration]
      ,[Reason],[Ip_Address],[In_Date_Time],[Out_Date_Time],[Skip_Count],[Late_Calc_Not_App]
      ,[Chk_By_Superior],[Sup_Comment],[Half_Full_day],[Is_Cancel_Late_In] ,[Is_Cancel_Early_Out]
      ,[Is_Default_In] ,[Is_Default_Out],[Cmp_prp_in_flag],[Cmp_prp_out_flag] ,[is_Cmp_purpose]
      ,[App_Date] ,[Apr_Date],GETDATE() as System_date,[Other_Reason],[ManualEntryFlag],@User_ID
 		from T0150_emp_inout_Record AS In_Out WITH (NOLOCK)
 		
	 	where for_date >= @from_Date and for_date <= @to_date 
	 	and  emp_id in (select Emp_id from #EMP_CONS)
	 	
		AND NOT EXISTS
		(	
			SELECT IO_Tran_ID,Emp_ID ,IO_DateTime from (
			SELECT IO_Tran_ID,Emp_ID,in_time as IO_DateTime ,ip_address FROM T0150_emp_inout_Record_Before_Delete AS In_Out_BE WITH (NOLOCK)
			UNION all
			SELECT IO_Tran_ID,Emp_ID ,Out_time as IO_DateTime,ip_address FROM T0150_emp_inout_Record_Before_Delete AS In_Out_BE WITH (NOLOCK)
		) as Emp_Inout 
		
			WHERE In_Out.emp_id=Emp_Inout.emp_id 
			----And ((In_Out.In_Time =Emp_Inout.IO_DateTime) OR (In_Out.Out_Time =Emp_Inout.IO_DateTime))
			
			And (				
					(
					CAST((cast( In_Out.In_Time as varchar(11)) + ' ' + dbo.F_GET_AMPM( In_Out.In_Time)) as datetime)
					=CAST((cast(Emp_Inout.IO_DateTime as varchar(11)) + ' ' + dbo.F_GET_AMPM( Emp_Inout.IO_DateTime)) as datetime)
					)
					OR
					(
					CAST((cast( In_Out.Out_Time as varchar(11)) + ' ' + dbo.F_GET_AMPM( In_Out.Out_Time)) as datetime)
					=CAST((cast(Emp_Inout.IO_DateTime as varchar(11)) + ' ' + dbo.F_GET_AMPM( Emp_Inout.IO_DateTime)) as datetime)
					)
					
				)

        )	
		------------End Query 1------------------
	 
		delete from T0150_emp_inout_Record where for_date >= @from_Date and for_date <= @to_date and emp_id in (select Emp_id from #EMP_CONS)
	 end
	 
	 ----------------Add by jignesh 26-09-2017-----------------
	 
	 IF NOT EXISTS (SELECT 1 FROM sys.objects 
		WHERE object_id = OBJECT_ID(N'[dbo].[T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete]'	) AND type in (N'U'))
		SELECT * Into T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete  from T0150_EMP_Gate_Pass_INOUT_RECORD  WITH (NOLOCK) Where 0=1
	
	 IF NOT EXISTS (select 1 from INFORMATION_SCHEMA.COLUMNS 
					WHERE TABLE_NAME ='T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete'
					And COLUMN_NAME like '%System_date%' )
		BEGIN
		ALTER TABLE dbo.T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete ADD
				System_date datetime NULL
		END
	
	 IF NOT EXISTS (select 1 from INFORMATION_SCHEMA.COLUMNS 
					WHERE TABLE_NAME ='T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete'
					And COLUMN_NAME like '%User_ID%' )
		BEGIN
		ALTER TABLE dbo.T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete ADD
				[User_ID] Int NULL	
		END	
						
	
	INSERT INTO T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete
	  ([Tran_Id] ,[cmp_Id] ,[emp_id] ,[For_date] ,[Out_Time]
      ,[In_Time],[Hours] ,[Reason_id] ,[Exempted]
      ,[IP_Address],[Is_Approved],[Is_Default]
      ,[Shift_St_Time],[Shift_End_Time],[App_ID],[System_date],[User_ID])
      
	SELECT [Tran_Id]
      ,[cmp_Id] ,[emp_id] ,[For_date] ,[Out_Time]
      ,[In_Time],[Hours] ,[Reason_id] ,[Exempted]
      ,[IP_Address],[Is_Approved],[Is_Default]
      ,[Shift_St_Time],[Shift_End_Time],[App_ID],GETDATE(),@User_ID
	  FROM [T0150_EMP_Gate_Pass_INOUT_RECORD] as EMP_Gate_Pass WITH (NOLOCK)
		
		WHERE for_date >= @from_Date and for_date <= @to_date 
		and  Is_approved <> 1 
		and  emp_id in (select Emp_id from #EMP_CONS)

		AND NOT EXISTS
		(
			SELECT [Tran_Id],Emp_ID ,IO_DateTime from (
			SELECT [Tran_Id],Emp_ID,in_time as IO_DateTime ,ip_address FROM T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete AS EMP_Gate_Pass_BE WITH (NOLOCK)
			UNION all
			SELECT [Tran_Id],Emp_ID ,Out_time as IO_DateTime,ip_address FROM T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete AS EMP_Gate_Pass_BE WITH (NOLOCK)
		) as Emp_Inout 
		
			WHERE EMP_Gate_Pass.emp_id=Emp_Inout.emp_id 
			And (
					--(EMP_Gate_Pass.In_Time =Emp_Inout.IO_DateTime) 
					--OR	(EMP_Gate_Pass.Out_Time =Emp_Inout.IO_DateTime)
					(
					CAST((cast( EMP_Gate_Pass.In_Time as varchar(11)) + ' ' + dbo.F_GET_AMPM( EMP_Gate_Pass.In_Time)) as datetime)
					=CAST((cast(Emp_Inout.IO_DateTime as varchar(11)) + ' ' + dbo.F_GET_AMPM( Emp_Inout.IO_DateTime)) as datetime)
					)
					OR
					(
					CAST((cast( EMP_Gate_Pass.Out_Time as varchar(11)) + ' ' + dbo.F_GET_AMPM( EMP_Gate_Pass.Out_Time)) as datetime)
					=CAST((cast(Emp_Inout.IO_DateTime as varchar(11)) + ' ' + dbo.F_GET_AMPM( Emp_Inout.IO_DateTime)) as datetime)
					)
					
				)
        )	
        
	 ----------------Add by jignesh 26-09-2017-----------------
		delete from T0150_EMP_Gate_Pass_INOUT_RECORD 
		where for_date >= @from_Date and for_date <= @to_date 
		and  Is_approved <> 1 
		and  emp_id in (select Emp_id from #EMP_CONS)


	DECLARE @SYNC_METHOD NVARCHAR(512)
	SET @SYNC_METHOD = 'SP_EMP_INOUT_SYNCHRONIZATION @EMP_ID=@EMP_ID, @CMP_ID=@CMP_ID, @IO_DATETIME=@IO_DATETIME, @IP_ADDRESS=@IP_ADDRESS,@In_Out_flag=0,@Flag=1'
	IF EXISTS(SELECT 1 FROM T0000_SYNC_METHOD WITH (NOLOCK))
		SELECT	TOP 1 @SYNC_METHOD = METHOD_NAME + ' @EMP_ID=@EMP_ID, @CMP_ID=@CMP_ID, @IO_DATETIME=@IO_DATETIME, @IP_ADDRESS=@IP_ADDRESS,@In_Out_flag=0,@Flag=1'
		FROM	T0000_SYNC_METHOD WITH (NOLOCK)


----- Added by Prakash Patel for device and mobile attendance syncronization ---------------
--- New Cursor for Mobile and Device Entry --
	DECLARE curDeviceEmp CURSOR FOR
	
	SELECT * FROM (
	
	SELECT EC.Emp_ID,DID.IO_DateTime,ISNULL(DID.IP_Address,'') as IP_Address,DID.Cmp_ID,
	(CASE WHEN  ISNULL(DID.In_Out_flag,'') = '' THEN -1 
			--when isnull(I.Flag,'') = '' then  -1
			when I.Flag = 'All' then -1
			when I.Flag = 'In' then 0
			when I.Flag = 'Out' then 1
		 ELSE DID.In_Out_Flag END) AS 'In_Out_flag'

	FROM T9999_DEVICE_INOUT_DETAIL DID WITH (NOLOCK)
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON DID.Enroll_No = EM.Enroll_No
	INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.Emp_ID
	left join T0040_IP_MASTER I WITH (NOLOCK) on DID.IP_Address = I.IP_ADDRESS
	WHERE DID.IO_DateTime >= @from_Date And DID.IO_DateTime <= Getdate()
	
	UNION ALL 
			
	SELECT EM.Emp_ID,DID.IO_DateTime,DID.IMEI_No AS 'IP_Address',DID.Cmp_ID,
	(CASE WHEN ISNULL(DID.In_Out_flag,'') = 'I' THEN 0 ELSE 1 END) AS 'In_Out_flag'
	FROM T9999_MOBILE_INOUT_DETAIL DID WITH (NOLOCK)
	INNER JOIN #EMP_CONS EM ON DID.Emp_ID = EM.Emp_ID
	WHERE DID.IO_DateTime >= @from_Date And DID.IO_DateTime <= Getdate()
	And Isnull(DID.Approval_Status,0)= Case When @Approval_Required = 1 then 1 Else Isnull(DID.Approval_Status,0) END
	AND DID.IMEI_No <> 'PAYROLL' -- Added By Sajid 13-02-2025
	----ORDER BY DID.IO_Datetime

	-- Added By Sajid 13-02-2025
	UNION ALL 			
	SELECT EM.Emp_ID,DID.IO_DateTime,DID.IMEI_No AS 'IP_Address',DID.Cmp_ID,
	(CASE WHEN ISNULL(DID.In_Out_flag,'') = 'I' THEN 0 ELSE 1 END) AS 'In_Out_flag'
	FROM T9999_MOBILE_INOUT_DETAIL DID WITH (NOLOCK)
	INNER JOIN #EMP_CONS EM ON DID.Emp_ID = EM.Emp_ID
	WHERE DID.IO_DateTime >= @from_Date And DID.IO_DateTime <= Getdate()
	AND DID.IMEI_No ='PAYROLL' -- Added By Sajid 13-02-2025
	) AS DID
	
	Where NOT EXISTS
    (SELECT 
     1 From 
     (
			SELECT Distinct Emp_id ,For_Date    from T0150_emp_inout_Record  WITH (NOLOCK)
			where For_Date >= @from_Date and For_Date <= @to_date  
			AND (isnull(Reason,'') <> '' OR isnull(ManualEntryFlag,'N') <> 'N' )
			)As IO_DATA
   
			WHERE  IO_DATA.For_Date=Cast(Cast(DID.IO_DateTime as varchar(11)) as DateTime) 
			AND IO_DATA.Emp_Id=DID.Emp_ID 
        )
	
	ORDER BY DID.IO_Datetime


	OPEN curDeviceEmp
	
	FETCH NEXT FROM curDeviceEmp into @Emp_ID,@IO_DATETIME,@IP_ADDRESS,@CmpID,@In_Out_flag
	WHILE @@fetch_status = 0
		BEGIN
			
		SET @IO_DATETIME = cast(@IO_DATETIME as varchar(11)) + ' ' + dbo.F_GET_AMPM(@IO_DATETIME)
						
			
			IF  SUBSTRING(@IP_ADDRESS,1,6) <> 'Mobile'
				BEGIN		
					if @In_Out_flag =-1
						begin
							goto NxtLine
						end 
											
					If @In_Out_Flag_SP = 1 --Added by Hardik 15/06/2016
						exec SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,@in_out_flag,0 --------------Sp will Execute for HNG Halol 17022016----------------------------------
					ELSE if @In_Out_Flag_SP = 2
						exec SP_EMP_INOUT_SYNCHRONIZATION_12AM_SHIFT_TIME @Emp_ID, @Cmp_ID,@IO_DateTime,@IP_Address ,@in_out_flag,0 --- Added for Aculife 
					Else	
						BEGIN
							NxtLine:	
							exec sp_executesql @SYNC_METHOD, N'@EMP_ID NUMERIC, @CMP_ID NUMERIC, @IO_DATETIME DATETIME, @IP_ADDRESS VARCHAR(50)',@EMP_ID, @CMP_ID, @IO_DATETIME, @IP_ADDRESS
						END
						--Exec SP_EMP_INOUT_SYNCHRONIZATION @EMP_ID, @CMP_ID, @IO_DATETIME, @IP_ADDRESS,0,1
				END
			ELSE
				BEGIN
					EXEC SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @EMP_ID,@CmpID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,0
				END
			
			
			set @data_count = @data_count + 1
			---------- Add by jignesh 25-Sep-2017----------
			--if @Return_Record= 0
			--BEGIN
			--	Update T9999_DEVICE_INOUT_DETAIL SET Is_verify = 1 
			--	Where Enroll_No in (Select  Enroll_No From T0080_EMP_MASTER Where Emp_ID =@EMP_ID ) 
			--	And  Cast(cast(IO_DATETIME as varchar(11)) + ' ' + dbo.F_GET_AMPM(IO_DATETIME) AS datetime)	= @IO_DATETIME
				
			--	Update T9999_MOBILE_INOUT_DETAIL SET Is_verify = 1 
			--	Where Emp_ID =@EMP_ID  
			--	And  Cast(cast(IO_DATETIME as varchar(11)) + ' ' + dbo.F_GET_AMPM(IO_DATETIME) AS datetime)	= @IO_DATETIME
			--END		
			---------- END by jignesh 25-Sep-2017----------
			
			FETCH NEXT FROM curDeviceEmp into @Emp_ID,@IO_DATETIME,@IP_ADDRESS,@CmpID,@In_Out_flag
		END 
	CLOSE curDeviceEmp
	DEALLOCATE curDeviceEmp	
	set @OldValue = 'New Value' 
						+ '#' + 'Branch Name :' + ISNULL(@BranchName,'')
						+ '#' + 'From Date :' + CONVERT(nvarchar(100),ISNULL(@From_Date,getdate()))
						+ '#' + 'To Date :' + CONVERT(nvarchar(100),ISNULL(@To_Date,getdate()))
						+ '#' + 'Check Regularization Flag :' + cast(ISNULL(@Check_Regularization_Flag,0) as nvarchar(11))
						+ '#' + 'User ID :' + cast(ISNULL(@User_Id,0) as nvarchar(50))
						+ '#' + 'Employee Count :' + cast(ISNULL(@data_count,0) as nvarchar(100))																			
	exec P9999_Audit_Trail @Cmp_ID,'I','In Out Re-Synchronized',@Oldvalue,0,@User_Id,@IPAddress,1
	
----------------- Cursor End -----------------------

if @Return_Record= 1
	begin
		select @data_count 					
	end
	
	
-- Declare curEmp cursor for	                  
--	select EM.Emp_ID,EM.Enroll_no from @Emp_Cons ES inner join t0080_emp_master EM on Es.Emp_id = Em.emp_id 
--	Open curEmp                      
--	Fetch next from curEmp into @EMP_ID,@Enroll_no
	
	
-- While @@fetch_status = 0
--	Begin
 
-- Declare curDeviceEmp cursor for	                  
--		select IO_DateTime,IP_Address,Case When In_Out_flag = '' then 0 else In_Out_Flag End 
--		from T9999_DEVICE_INOUT_DETAIL  where enroll_no =@Enroll_no and io_datetime>=@from_Date order by Enroll_No,IO_DateTime
--	Open curDeviceEmp                      
--	Fetch next from curDeviceEmp into @IO_DATETIME,@IP_ADDRESS,@In_Out_flag
	
--	While @@fetch_status = 0
--	Begin
 
--	Set @IO_DATETIME = cast(@IO_DATETIME as varchar(11)) + ' ' + dbo.F_GET_AMPM(@IO_DATETIME)
 
--		Exec [dbo].[SP_EMP_INOUT_SYNCHRONIZATION] @EMP_ID, @CMP_ID, @IO_DATETIME, @IP_ADDRESS,@In_Out_flag,1
 
---- set @For_Date = cast(@IO_DATETIME as varchar(11))    
---- set @varFor_Date = cast(@IO_DATETIME as varchar(11)) 
---- set @For_Date_P = Dateadd(d,-1,@For_Date)

---- Declare @Max_Date datetime
---- --changes done by Falak on 04-jan-2011 
---- -- for blocking of updating the entry of inout records
---- set @Max_Date = null
------ select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record where emp_ID=@emp_ID

----  if @Flag = 0
----	begin
----		select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record where emp_ID=@emp_ID and For_Date < @to_date
----	end
----else
----	begin
----		select @In_Time = max(In_time)  from 
----		T0150_emp_inout_Record where  Cmp_ID = @CMP_ID  And emp_ID=@emp_ID And cast(In_time as varchar(11)) = cast(@IO_DATETIME as varchar(11))
----		select @Out_Time = max(Out_Time) from 
----		T0150_emp_inout_Record where  Cmp_ID = @CMP_ID  And emp_ID=@emp_ID And cast(Out_Time as varchar(11)) = cast(@IO_DATETIME as varchar(11))
----	end
	
 
---- if isnull(@ToDate,'01-jan-1900')='01-jan-1900'
---- begin 
----	select @Max_Date = max(for_date) from T0150_EMP_INOUT_RECORD where Emp_ID = @EMP_ID 
---- end
---- else
---- Begin
---- 	select @Max_Date = max(for_date) from T0150_EMP_INOUT_RECORD where Emp_ID = @EMP_ID  and for_date < @ToDate
---- End 
--------  select @In_Time = max(In_time) , @Out_Time =max(Out_Time) from T0150_emp_inout_Record where emp_ID=@emp_ID  

----	Declare @InOut_duration_Gap numeric    --Added by Mihir 06/03/2012
----	select @InOut_duration_Gap = ISNULL(Inout_Duration,300) from T0010_COMPANY_MASTER where Cmp_Id = @CMP_ID   --Added by Mihir 06/03/2012
	  
----if isnull(@In_Out_flag,0) = 0
----	begin
		
----			if @Flag = 0
----			begin	
----				If @IO_DATETIME < @Max_Date 
----				begin		
----					goto ABC;
----				end	  
----			end
				
----				 if Exists(select IO_Tran_ID from t0150_emp_inout_record where 
----				 Emp_Id=@Emp_Id And(In_time = @IO_DATETIME OR Out_Time = @IO_DATETIME ))
----				Begin		
----					goto ABC;
----				End 
							
----			--declare @minInTime datetime
----			--declare @maxOutTime datetime


----			--select @minInTime=min(In_Time),@maxOutTime=max(Out_Time) from t0150_emp_inout_record where Emp_Id=@Emp_Id And(day(For_Date) = day(@IO_DATETIME) and month(For_Date) = month(@IO_DATETIME) and year(For_Date) = year(@IO_DATETIME) )


----			--if Exists(select IO_Tran_ID from t0150_emp_inout_record where Emp_Id=@Emp_Id And day(For_Date) = day(@IO_DATETIME) and month(For_Date) = month(@IO_DATETIME) and year(For_Date) = year(@IO_DATETIME) and In_Time is not NULL and Out_Time is not NULL) OR (@minInTime is not NULL and @maxOutTime is not NULL)
----			--Begin			
----			--	Return
----			--End 
			
----			 if not @In_time is null and @In_Time > isnull(@Out_Time,'01-01-1900') and datediff(s,@In_Time,@IO_DATETIME) < @InOut_duration_Gap and datediff(s,@In_Time,@IO_DATETIME) >0    --@InOut_duration_Gap Added by Mihir 06/03/2012
----			  begin   
----			  --print 'y' 
----			   Update T0150_emp_inout_Record     
----			   set  In_Time = @IO_DATETIME    
----				 ,Duration = dbo.F_Return_Hours (datediff(s,@IO_DATETIME,Out_Time))      
----			   where In_Time = @In_Time and Emp_ID=@emp_ID    
----			   goto ABC;     
----			  end    
----			 else if not @Out_Time is null and @Out_Time > isnull(@In_Time,'01-01-1900')   and datediff(s,@Out_Time,@IO_DATETIME) < @InOut_duration_Gap and datediff(s,@Out_Time,@IO_DATETIME) >0    
----			  begin    
----			  --print 'N'
----			   Update T0150_emp_inout_Record     
----			   set  Out_Time = @IO_DATETIME    
----				 ,Duration = dbo.F_Return_Hours (datediff(s,In_Time,@IO_DATETIME))      
----			   where Out_Time = @Out_Time and Emp_ID=@emp_ID    
----			   goto ABC;     
----			  end    

----			---- Added by rohit on 31122013 for Auto Shift
			
----			  declare @in_time_temp as datetime
----			  declare @out_time_temp as datetime
----			  declare @Pre_IO_Date as datetime
----			  declare @Pre_IO_Flag as varchar
			
----			select TOP 1 @in_time_temp=in_time,@out_time_temp=out_time from T0150_EMP_INOUT_RECORD WHERE Emp_Id=@Emp_Id AND cmp_id =@cmp_id AND For_Date < @IO_DATETIME ORDER BY For_Date DESC
			
----			if isnull(@out_time,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000'
----			begin
----				set @Pre_IO_Date =@in_time_temp
----				set @Pre_IO_Flag='I'
----			end
----			else
----			BEGIN
----				set @Pre_IO_Date =@out_time_temp
----				set @Pre_IO_Flag='O'
----			END
			
----				Declare @Shift_St_Time1 as varchar(10)
----				Declare @Shift_End_Time1 as varchar(10)
				
----				EXEC Get_Emp_Curr_Shift_New @emp_id,@cmp_id,@IO_DATETIME,@Pre_IO_Flag,@Pre_IO_Date,@Shift_St_Time1 output ,@Shift_End_Time1 output
		

----			if not @Shift_St_Time1 is null and @Shift_St_Time1 <> ''
----				Begin
----					set @F_Shift_In_Time = @Shift_St_Time1 
----					set @F_Shift_End_Time = @Shift_End_Time1
----				End
						

----			if @Shift_St_Time1 is null OR @Shift_St_Time1 = ''
----			begin  			
----			  exec SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date,null,@F_Shift_In_Time output ,@F_Shift_End_Time output,@S_Shift_in_Time output ,@S_shift_end_Time output,@T_Shift_In_Time output ,@T_Shift_End_Time output , @Shift_st_Time output ,@Shift_end_Time output
----			  exec SP_SHIFT_DETAIL_GET @Emp_ID,@Cmp_ID,@For_Date_P,null,@F_Shift_In_Time_P output ,@F_Shift_End_Time_P output,@S_Shift_in_Time_P output ,@S_shift_end_Time_P output,@T_Shift_In_Time_P output ,@T_Shift_End_Time_P output , @Shift_st_Time_P output ,@Shift_end_Time_P output
----			End			   
----			 --Ended by rohit on 31-dec-2013 for auto shift				   
			
			
----			  if @S_Shift_in_Time ='1900-01-01 00:00:00.000'    
----			   set @S_Shift_in_Time = null    
----			  if @S_Shift_End_Time ='1900-01-01 00:00:00.000'    
----			   set @S_Shift_End_Time = null    
				  
----			  if @T_Shift_In_Time ='1900-01-01 00:00:00.000'    
----			   set @T_Shift_In_Time = null    
				
----			  if @T_Shift_End_Time ='1900-01-01 00:00:00.000'    
----			   set @T_Shift_End_Time = null    
			   
----			   if @S_Shift_in_Time_P ='1900-01-01 00:00:00.000'    
----			   set @S_Shift_in_Time_P = null    
----			  if @S_Shift_End_Time_P ='1900-01-01 00:00:00.000'    
----			   set @S_Shift_End_Time_P = null    
				  
----			  if @T_Shift_In_Time_P ='1900-01-01 00:00:00.000'    
----			   set @T_Shift_In_Time_P = null    
				
----			  if @T_Shift_End_Time_P ='1900-01-01 00:00:00.000'    
----			   set @T_Shift_End_Time_P = null    
					  
----			  set @F_Shift_In_Time =  @varFor_Date + ' ' + @F_Shift_In_Time    
----			  set @F_Shift_End_Time = @varFor_Date + ' ' + @F_Shift_End_Time    
----			  set @S_Shift_in_Time = @varFor_Date + ' ' + @S_Shift_in_Time    
----			  set @S_shift_end_Time = @varFor_Date + ' ' + @S_shift_end_Time    
----			  set @T_Shift_In_Time = @varFor_Date + ' ' + @T_Shift_In_Time     
----			  set @T_Shift_End_Time = @varFor_Date + ' ' + @T_Shift_End_Time    
----			  set @Shift_end_Time = @varFor_Date + ' ' + @Shift_end_Time    
----			  set @Shift_st_Time = @varFor_Date + ' ' + @Shift_st_Time 
			  
			   
----				select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record   
				

					
----				   if Exists (select Max(In_time)  from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID And Out_Time is null And In_time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
----								Begin
									
----									Declare @Diff numeric(22,0)
----									set @Diff = isnull(Datediff(s,@F_Shift_In_Time,@IO_DATETIME),0)
									
----									if @Diff >=-10800
----										Begin				
										
----											select @In_Time=Max(In_time) from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME     and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))
											
----											if @In_Time is not null  
----												Begin									
													
----													Declare @varFor_Date_P varchar(22)    
													
----													set @varFor_Date_P = cast(@In_Time as varchar(11)) 
													
----													set @F_Shift_In_Time_P =  @varFor_Date_P + ' ' + @F_Shift_In_Time_P  
----													set @minutdiff = isnull(Datediff(s,@F_Shift_In_Time_P,@IO_DATETIME),0)
													
----														if @minutdiff > =75600
----															Begin
----																INSERT INTO T0150_EMP_INOUT_RECORD    
----																(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)    
----																VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0)			
----																 set @data_count = @data_count + 1
----																 goto ABC;						
----															End	
----												End
----										End					
								  
----								End
									
----				   if Exists (select Max(In_time)  from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
----						  Begin 
						  
----							--Condition added by Hardik on 05/04/2014 for below case going wrong
----							/* Sample case
----								exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 10:00AM', '192.168.1.1',0, 0
----								exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 12:01PM', '192.168.1.1',0, 0
----								exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '01-apr-2014 06:59PM', '192.168.1.1',0, 0
----								exec [SP_EMP_INOUT_SYNCHRONIZATION] 1996 , 9,  '02-apr-2014 10:01AM', '192.168.1.1',0, 0
----							*/
----							If @F_Shift_In_Time > @F_Shift_End_Time
----								Begin
----									select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME     and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date)))
----								End
----							Else
----								Begin
----									select @In_Time=Max(In_time)  from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME     and  For_Date=@For_Date
----								End
													
----						   if @In_Time is null  
----							Begin  
							
----							--select Shift_ID from T0100_Emp_Shift_Detail where Emp_ID=@Emp_ID and For_Date in(select max(for_date) from T0100_Emp_Shift_Detail where Emp_ID=@Emp_ID and For_Date <= @For_Date) And Shift_type <> 1	
							
----							INSERT INTO T0150_EMP_INOUT_RECORD    
----							(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)    
----							VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0)			
----							set @data_count = @data_count + 1
----							 goto ABC;
----							End  
----						   else  
----							Begin 
								
----							 declare @Sec_Diff numeric(22,0) 
----							 set @Sec_Diff = isnull(Datediff(s,@In_Time,@IO_DATETIME),0)
----								--if @Sec_Diff <= 126000
----								if @Sec_Diff <= 57600
								
----									Begin

----										Update T0150_EMP_INOUT_RECORD  
----										set  Out_Time = @IO_DATETIME  ,IP_Address=@Ip_Address
----										where Emp_ID =@Emp_ID and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))) and in_Time  = @In_Time 
							 
----										Update T0150_emp_inout_Record     
----										set  Duration = dbo.F_Return_Hours (datediff(s,In_time,Out_Time))      
----										where Emp_ID =@Emp_ID and (For_Date =@For_Date OR (For_Date=dateadd(d,-1,@For_Date))) and not in_time  is null and not out_Time is null   
----										goto ABC;
----									End
									
----								INSERT INTO T0150_EMP_INOUT_RECORD    
----							(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)    
----							VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0)				
----							  set @data_count = @data_count + 1
----							  goto ABC;
----							End  
----						  End 
						  
----				   if Not Exists (select Max(In_time)  from T0150_EMP_INOUT_RECORD where emp_ID=@emp_ID  And Out_Time is null And In_time <  @IO_DATETIME and  ((For_Date=@For_Date)  OR (For_Date=dateadd(d,-1,@For_Date))))  
----						Begin
----								 INSERT INTO T0150_EMP_INOUT_RECORD    
----							(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App)    
----							VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0)			
----						set @data_count = @data_count + 1
----						End
----				end
----else
----	begin
		
----		if @In_Out_flag = 2 
----			begin
				
			
				
----				select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record 
				
----				 INSERT INTO T0150_EMP_INOUT_RECORD    
----				(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,Cmp_prp_out_flag,is_Cmp_purpose)    
----				VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,null,@IO_DATETIME,'','',@Ip_Address,null,null, 0, 0,@In_Out_flag,1)			
			
----					set @data_count = @data_count + 1			
				
----			end
		
----		if @In_Out_flag = 3
----			begin
			
		
----				select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from T0150_emp_inout_Record 
				
----				-- INSERT INTO T0150_EMP_INOUT_RECORD    
----				--(IO_Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Duration, Reason, Ip_Address, In_Date_Time, Out_Date_Time, Skip_Count, Late_Calc_Not_App,Cmp_prp_in_flag,is_Cmp_purpose)    
----				--VALUES     (@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IO_DATETIME,null,'','',@Ip_Address,null,null, 0, 0,@In_Out_flag,1)			
				
				
----				Update T0150_emp_inout_Record     
----			   set  In_Time = @IO_DATETIME    
----					,Cmp_prp_in_flag = @In_Out_flag	
----				 ,Duration = dbo.F_Return_Hours (datediff(s,@IO_DATETIME,Out_Time))      
----			   where Emp_ID=@emp_ID and is_Cmp_purpose = 1 and Cmp_prp_in_flag = 0 and Cmp_prp_out_flag > 0 and For_Date = @For_Date
			   
		
			
----			end
		
--	--end


-- --ABC:
--		set @data_count = @data_count + 1

--		fetch next from curDeviceEmp into @IO_DATETIME,@IP_ADDRESS,@In_Out_flag
--	End                 
--	close curDeviceEmp                    
--	deallocate curDeviceEmp
	
--		-- For Mobile Data Sync  Start  Added by Prakash Patel 15102015 --
--		DECLARE MOBILE_IO_CURSOR CURSOR FOR
	
--		SELECT IO_DateTime,IMEI_No,Cmp_ID,(CASE WHEN In_Out_flag = 'I' THEN 0 ELSE 1 END) AS 'In_Out_flag'
--		FROM T9999_MOBILE_INOUT_DETAIL WHERE Emp_ID = @EMP_ID AND io_datetime>=@from_Date ORDER BY IO_Datetime 
			
--		OPEN MOBILE_IO_CURSOR
--		FETCH NEXT FROM MOBILE_IO_CURSOR INTO @IO_DATETIME,@IP_ADDRESS,@CmpID,@In_Out_flag
--		WHILE @@fetch_status = 0
--			BEGIN
--				SET @IO_DATETIME = cast(@IO_DATETIME as varchar(11)) + ' ' + dbo.F_GET_AMPM(@IO_DATETIME)
	 
--				EXEC SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @EMP_ID,@CmpID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,0
	 
--				SET @data_count = @data_count + 1

--				FETCH NEXT FROM MOBILE_IO_CURSOR INTO @IO_DATETIME,@IP_ADDRESS,@CmpID,@In_Out_flag
--			END
--		CLOSE MOBILE_IO_CURSOR                     
--		DEALLOCATE MOBILE_IO_CURSOR 
--	-- For Mobile Data Sync  END  Added by Prakash Patel 15102015 --
 
 
--	fetch next from curEmp into @EMP_ID,@Enroll_no
--	End                 
--	close curEmp                    
--	deallocate curEmp
	
	
RETURN 




