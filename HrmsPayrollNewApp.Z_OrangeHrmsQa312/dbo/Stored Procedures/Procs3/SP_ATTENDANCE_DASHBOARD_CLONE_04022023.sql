
CREATE PROCEDURE [dbo].[SP_ATTENDANCE_DASHBOARD_CLONE_04022023]   
 -- Add the parameters for the stored procedure here  
  @CMP_ID   NUMERIC,  
  @FROM_DATE  DATETIME,  
  @TO_DATE   DATETIME,  
  @EMP_ID   NUMERIC,  
  @CONSTRAINT  VARCHAR(MAX),  
  @REPORT_FOR VARCHAR(50) = ''  
AS  

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 	


 DECLARE @Leave_Count NUMERIC(9,3)  
  
   CREATE table #ATT_MUSTER_EXCEL   
 (   
  EMP_ID  NUMERIC ,   
  CMP_ID  NUMERIC,  
  FOR_DATE DATETIME,  
  STATUS  VARCHAR(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  LEAVE_COUNT NUMERIC(5,2),  
  WO_HO  VARCHAR(3) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  STATUS_2 VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  ROW_ID  NUMERIC ,  
  WO_HO_DAY NUMERIC(3,2) DEFAULT 0,  
  P_DAYS  NUMERIC(5,2) DEFAULT 0,  
  A_DAYS  NUMERIC(5,2) DEFAULT 0 ,  
  JOIN_DATE DATETIME DEFAULT NULL,  
  LEFT_DATE DATETIME DEFAULT NULL,  
  GATE_PASS_DAYS NUMERIC(18,2) DEFAULT 0,  -- ADDED BY GADRIWALA MUSLIM 07042015  
  LATE_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0, -- ADDED BY GADRIWALA MUSLIM 07042015  
  EARLY_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0, -- ADDED BY GADRIWALA MUSLIM 07042015  
  EMP_CODE    VARCHAR(50) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  EMP_FULL_NAME  VARCHAR(300) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  BRANCH_ADDRESS VARCHAR(300) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  COMP_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  BRANCH_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  DEPT_NAME  VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  GRD_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  DESIG_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,  
  P_FROM_DATE  DATETIME,  
  P_TO_DATE DATETIME,  
  BRANCH_ID NUMERIC(18,0),  
  DESIG_DIS_NO NUMERIC(18,2) DEFAULT 0,          ---ADDED JIMIT 31082015   
  SUBBRANCH_NAME VARCHAR(200) DEFAULT '' COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS , 
 Shift_id Numeric(18,0)  
 )  
     
 CREATE TABLE #Data           
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
    IO_Tran_Id    numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)  
    OUT_Time datetime,  
    Shift_End_Time datetime,   --Ankit 16112013  
    OT_End_Time numeric default 0, --Ankit 16112013  
    Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014  
    Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014  
    GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014  
   )          
      
 CREATE NONCLUSTERED INDEX IX_DATA ON DBO.#ATT_MUSTER_EXCEL  
  ( EMP_ID,EMP_CODE,ROW_ID )   
  



-----------Added by ronakk 05082022 ------------------
Declare @Branch_ID as int  = 0
Declare @Sal_St_Date	Datetime
Declare @Sal_end_Date   Datetime 
Declare @OutOf_Days		NUMERIC  
declare @manual_salary_period as numeric(18,0)

			IF @Branch_ID = 0  
				SET @Branch_ID = null
				
			IF @Emp_ID = 0  
				SET @Emp_ID = null
				
				
			IF @Branch_ID is null
				begin
					select @Branch_ID  = Branch_ID 
					from dbo.T0095_Increment EI WITH (NOLOCK)
					where Increment_ID in (select max(Increment_ID) as Increment_ID from dbo.T0095_Increment WITH (NOLOCK)  where Increment_Effective_date <= @To_Date  
					and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID) 
					and Emp_ID = @Emp_ID
				End

			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End 
				
				
			if isnull(@Sal_St_Date,'') = ''    
				  begin    
					   set @From_Date  = @From_Date     
					   set @To_Date = @To_Date    
					   set @OutOf_Days = @OutOf_Days			  			   
				  end  
				     
			 else if day(@Sal_St_Date) =1
				  begin    
					   set @From_Date  = @From_Date     
					   set @To_Date = @To_Date    
					   set @OutOf_Days = @OutOf_Days    	         			   
				  end
				  		  
			else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
				  begin   
					if @manual_salary_period = 0 
					   begin
					   
							set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
							set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					   
							Set @From_Date = @Sal_St_Date
							Set @To_Date = @Sal_End_Date 			        
					   end 
					else
						begin
							select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
							Set @From_Date = @Sal_St_Date
							Set @To_Date = @Sal_End_Date 				    				    
						end   
				  end
				  



------------End By ronakk 05082022 -------------------




 EXEC SP_RPT_EMP_ATTENDANCE_MUSTER_GET @CMP_ID,@FROM_DATE,@TO_DATE,0,0,0,0,0,0,@EMP_ID,@CONSTRAINT,'','EXCEL',@Opt_Para=1  
  

	SELECT	DISTINCT GS.Branch_ID,INC_HOLIDAY,INC_WEEKOFF
	INTO	#GENERAL_SETTING
	FROM	T0040_GENERAL_SETTING GS WITH (NOLOCK)
			INNER JOIN(
							SELECT	MAX(GS1.FOR_DATE) AS FOR_DATE,GS1.Branch_ID
							FROM	DBO.T0040_GENERAL_SETTING GS1 WITH (NOLOCK)
									INNER JOIN #ATT_MUSTER_EXCEL EC ON GS1.Branch_ID=EC.Branch_ID
							WHERE	GS1.FOR_DATE < = @TO_DATE AND GS1.CMP_ID = @CMP_ID 
							GROUP BY GS1.Branch_ID 
						) GS1 ON GS1.Branch_ID = GS.Branch_ID AND GS.FOR_DATE = GS1.FOR_DATE


		
		Select  em.EMP_CODE,EM.EMP_FULL_NAME,Sm.Shift_Name,isnull(COUNT(EM.P_DAYS),0) as Present
		from #ATT_MUSTER_EXCEL EM
		inner join T0040_SHIFT_MASTER  SM on EM.Shift_id = SM.Shift_ID
		where EM.Status in ('P','HO','HF') or STATUS_2 = 'P' --EM.STATUS = 'P' 
		group by em.EMP_CODE,EM.EMP_FULL_NAME,Sm.Shift_Name


	

		--select * from V100_EMP_SHIFT_DETAIL where Cmp_ID=119 --emp_id = 24105
		--order by For_Date desc
		--inner join T0100_EMP_SHIFT_DETAIL ESD on ESD.Emp_ID = EM.EMP_ID --and ESD.For_Date = EM.FOR_DATE and ESD.Cmp_ID = EM.CMP_ID
		--left outer join T0040_SHIFT_MASTER SM on SM.Shift_ID = ESD.Shift_ID and SM.Cmp_ID = ESD.CMP_ID
		--left outer join T0080_EMP_MASTER EMP on EMP.Emp_ID = EM.EMP_ID

		--SELECT Emp_id,CMP_ID,P_DAYS  FROM #ATT_MUSTER_EXCEL AME

		--SELECT Alpha_Emp_Code,EM.Emp_Full_Name,Shift_Name,AME.STATUS  
		--FROM #ATT_MUSTER_EXCEL AME
		--inner join T0080_EMP_MASTER EM on EM.Emp_ID = AME.EMP_ID
		--inner join T0100_EMP_SHIFT_DETAIL SMD on SMD.Emp_ID = AME.EMP_ID and SMD.Cmp_ID = EM.Cmp_ID --and SMD.For_Date = AME.FOR_DATE
		--left outer join T0040_SHIFT_MASTER SM on Sm.Shift_ID = SMd.Shift_ID
		--inner join T0100_EMP_SHIFT_DETAIL ESD on ESD.Emp_ID = AME.EMP_ID and ESD.Cmp_ID = AME.CMP_ID and ESD.For_Date = AME.FOR_DATE


  END
 