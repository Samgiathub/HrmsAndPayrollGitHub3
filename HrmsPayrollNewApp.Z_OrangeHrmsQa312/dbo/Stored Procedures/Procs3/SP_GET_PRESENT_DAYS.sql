
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_PRESENT_DAYS]
 @emp_Id as numeric
,@Cmp_ID as numeric
,@From_Date DATETIME
,@To_Date DATETIME
,@Present_Days		  NUMERIC(12,2) output   
,@Absent_Days		  NUMERIC(12,2) output   
,@Holiday_Days		  NUMERIC(12,2)   output 
,@Weekoff_Days		  NUMERIC(12,2)  output  
,@Is_Cutoff_Salary tinyint = 0  --Added by Hardik 02/02/2016
,@Start_Date DateTime = NULL
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if Isnull(@Is_Cutoff_Salary,0) = 1 --Added by Hardik 02/02/2016
		Begin

			 CREATE TABLE #Att_Muster_Excel 
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
					Gate_Pass_Days numeric(18,2) default 0,  -- Added by Gadriwala Muslim 07042015
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
			
		  
			exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID=@cmp_id,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint=@Emp_Id,@Report_For='',@Export_Type='Excel'
			
			
			Select @Present_Days = Sum(P_days),@Absent_Days = Sum(A_days) from #Att_Muster_Excel where Emp_Id =@Emp_Id And For_Date Between @From_Date And @To_Date

			-- Added by Hardik 30/12/2020 for Aprican Client
			Select @Weekoff_Days = Status from #Att_Muster_Excel where Emp_Id =@Emp_Id And Row_Id = 35
			
			SELECT @Holiday_Days = Holiday--,@Weekoff_Days=Weeklyoff
			FROM T0170_EMP_ATTENDANCE_IMPORT  WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_ID 	and 
				[Month]= month(@To_Date) And 
				[Year]= Year(@To_Date) and 
				Emp_ID = @emp_id

			drop table #Att_Muster_Excel
		END
	
	ELSE
		BEGIN
			DECLARE @FH VARCHAR(1024)
			DECLARE @SH VARCHAR(1024)

			SELECT	@FH = SUBSTRING(Att_Detail, 0, CHARINDEX('/', Att_Detail)),
					@SH = SUBSTRING(Att_Detail, CHARINDEX('/', Att_Detail)+1, LEN(Att_Detail))
			FROM	T0170_EMP_ATTENDANCE_IMPORT  WITH (NOLOCK)
			WHERE	Cmp_ID = @Cmp_ID 	and 
					[Month]= month(@To_Date) And 
					[Year]= Year(@To_Date) and 
					Emp_ID = @emp_id

			SELECT	T1.ID, IsNull(T1.DATA,'') FH, IsNull(T2.DATA,'') AS SH, DateAdd(DD, T1.Id-1, @Start_Date) As For_Date, 
					CAST(0.00 AS Numeric(9,2))  As P_Days, CAST(0.00 AS Numeric(9,2)) As A_Days, CAST(0.00 AS Numeric(9,2)) As Leave_Count, 
					CAST(0.00 AS Numeric(9,2)) As W_Days, CAST(0.00 AS Numeric(9,2)) As H_Days
			INTO	#Attendance
			FROM	dbo.Split(@FH,'#') T1 
					LEFT OUTER JOIN dbo.Split(@SH, '#') T2 ON T1.Id=T2.Id

			
			UPDATE	A
			SET		P_Days = CASE WHEN FH = 'P' THEN 0.5 ELSE 0 END,
					W_Days = CASE WHEN FH = 'W' THEN 0.5 ELSE 0 END,
					H_Days = CASE WHEN FH = 'HO' or FH = 'OHO'  THEN 0.5 ELSE 0 END,
					A_Days = CASE WHEN FH = 'A' THEN 0.5 ELSE 0 END,
					Leave_Count = CASE WHEN FH NOT IN ('HO', 'W', 'P', 'A','OHO') THEN 0.5 ELSE 0 END					
			FROM	#Attendance A
			
				

			UPDATE	A
			SET		P_Days = P_Days  + CASE WHEN SH = 'P' THEN 0.5 WHEN SH = '' AND FH = 'P' THEN P_Days ELSE 0 END,
					W_Days = W_Days + CASE WHEN SH = 'W' THEN 0.5 WHEN SH = '' AND FH = 'W' THEN W_Days ELSE 0 END,
					H_Days = H_Days + CASE WHEN SH = 'HO' or SH = 'OHO'  THEN 0.5 WHEN SH = '' AND (FH = 'HO' or FH = 'OHO') THEN H_Days ELSE 0 END,
					A_Days = A_Days + CASE WHEN SH = 'A' THEN 0.5 WHEN SH = ''  AND FH = 'A' THEN A_Days ELSE 0 END,
					Leave_Count = Leave_Count + CASE WHEN SH NOT IN ('HO', 'W', 'P', 'A', '','OHO')  THEN 0.5 WHEN SH = '' AND  FH NOT IN ('HO', 'W', 'P', 'A', '','OHO') THEN Leave_Count ELSE 0 END
			FROM	#Attendance A

		
			SELECT	@Present_Days = Sum(P_Days),
					@Absent_Days = Sum(A_Days),
					@Holiday_Days = Sum(H_Days),
					@Weekoff_Days = Sum(W_Days) 
			FROM	#Attendance A
			WHERE	A.For_Date BETWEEN @From_Date AND @To_Date

			return
			/*

			SELECT @Present_Days = PresentDays,@Absent_Days=[Absent],
				@Holiday_Days = Holiday,@Weekoff_Days=Weeklyoff
			FROM T0170_EMP_ATTENDANCE_IMPORT 
			WHERE Cmp_ID = @Cmp_ID 	and 
				[Month]= month(@From_Date) And 
				[Year]= Year(@From_Date) and 
				Emp_ID = @emp_id
			*/
		END	

return


