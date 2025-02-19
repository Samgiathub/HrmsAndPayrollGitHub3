


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Ticket_Summary]
	@Cmp_ID Numeric(18,0),
	@ChartType varchar(50),
	@privilage_id int = null 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   
   Declare @FROM_DATE Datetime
   Declare @TO_DATE Datetime
   DECLARE @TEMP_FROM_DATE DATETIME
  
   CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	)	
	
	 Declare @Temp_DT As DATETIME
	Set @Temp_DT = DATEADD(MONTH,-1,GETDATE()) -- Added By Niraj (05012022)
  

	SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))
		   SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))



	--EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID,@From_Date,@To_Date,@Branch_Id,0,0,0,@Department_ID,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0   
			
	--EXEC SP_RPT_FILL_EMP_CONS @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
	
	--Added by ronakk 19122023
	Declare @BranchMulti nvarchar(max)
	Declare @VerticalMulti nvarchar(max)
	Declare @SubvertMulti nvarchar(max)
	Declare @DeptMulti nvarchar(max)

	select @BranchMulti = Branch_Id_Multi
		  ,@VerticalMulti = Vertical_ID_Multi
		  ,@SubvertMulti = SubVertical_ID_Multi
		  ,@DeptMulti = Department_Id_Multi
   
   from T0020_PRIVILEGE_MASTER where Privilege_ID = @privilage_id

	--End by ronakk 19122023

	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@BranchMulti,0,0,0,@DeptMulti,0,0,'',0,0,0,@VerticalMulti,@SubvertMulti,0,0,0,0,'0',0,0,0   

  
   IF @ChartType = 'header'
		Begin
		
				SELECT 
						 COUNT((Case When Ticket_Status = 'O' THEN 1 END)) as openticket,
					   COUNT((Case When Ticket_Status = 'C' THEN 1 END)) as closeticket,
					   COUNT((Case When Ticket_Status = 'H' THEN 1 END)) as holdticket,
					   COUNT(1) as totalticket
				   FROM T0090_Ticket_Application TA WITH (NOLOCK)
					INNER JOIN #EMP_CONS EM ON EM.EMP_ID= TA.Emp_ID
				   Where TA.Cmp_ID = @Cmp_ID --and Branch_ID in (Select Cast(Data As Numeric) As ID FROM dbo.Split(@Cmp_Field,'#') T Where T.Data <> '')
		End
	Else If @ChartType = 'pie'
		Begin
   
		   SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))
		   --SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(mm,-3,GETDATE())),YEAR(GETDATE()))
		   SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))
		   
		   SELECT 
				   COUNT(Isnull(LA.Ticket_App_ID,0)) as Ticket_Count,
				   (Case 
						When LA.Ticket_Status = 'C' then 'Closed' 
						When LA.Ticket_Status = 'O' then 'Open'
						When LA.Ticket_Status = 'H' then 'On Hold'
				   END) as Ticket_Status,
				   CAST(DATENAME(MONTH,@FROM_DATE) AS VARCHAR(3)) + '-' + CAST(YEAR(@FROM_DATE) AS VARCHAR(4)) AS MONTH_NAME
			FROM T0090_Ticket_Application LA WITH (NOLOCK)
			INNER JOIN #EMP_CONS EM ON EM.EMP_ID= LA.Emp_ID
			Where Cmp_ID = @Cmp_ID and Ticket_Gen_Date >= @FROM_DATE and Ticket_Gen_Date <= @TO_DATE 
			GROUP BY Ticket_Status
		End
	Else if @ChartType = 'BarDept'
		Begin
			
			
			
			SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(mm,-3,@Temp_DT)),YEAR(@Temp_DT))
			SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))
	 
			IF OBJECT_ID('TEMPDB..#TEMP_TICKET_DEPT') IS NOT NULL
				BEGIN
					DROP TABLE #TEMP_TICKET_DEPT
				END

	 
			 CREATE TABLE #TEMP_TICKET_DEPT
			 (
				 MONTH_NAME Varchar(100),
				 Ticket_Month Numeric(5,0),
				 Ticket_Year Numeric(5,0),
				 Ticket_Dept_ID Numeric(5,0),
				 Ticket_Name Varchar(50),
				 Ticket_Count Numeric(18,0)
			 )
	 
			 SET @TEMP_FROM_DATE = @FROM_DATE
				WHILE @TO_DATE >= @TEMP_FROM_DATE
					BEGIN
						INSERT INTO #TEMP_TICKET_DEPT
						SELECT  DISTINCT
						CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)) + '-' + CAST(YEAR(@TEMP_FROM_DATE) AS VARCHAR(4)),
						MONTH(@TEMP_FROM_DATE),
						YEAR(@TEMP_FROM_DATE),
						Ticket_Dept_ID,
						Ticket_Dept_Name,
						0
						FROM T0040_Ticket_Type_Master WITH (NOLOCK)
						WHERE CMP_ID = @CMP_ID
						
						SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
					END
	
			UPDATE TS
				SET TS.Ticket_Count = ticketCount
			FROM #TEMP_TICKET_DEPT TS INNER JOIN
				(
					SELECT COUNT(TA.Ticket_App_ID) as ticketCount, 
						   Month(Ticket_Gen_Date) as ticketMonth,
						   Year(Ticket_Gen_Date) as ticketYear,
						   TM.Ticket_Dept_ID as Ticket_Dept_ID
					From T0090_Ticket_Application TA WITH (NOLOCK)
					INNER JOIN #EMP_CONS EM ON EM.EMP_ID= TA.Emp_ID
					Inner JOIN T0040_Ticket_Type_Master TM WITH (NOLOCK)
					ON TA.Ticket_Dept_ID = TM.Ticket_Dept_ID and TA.Ticket_Type_ID = TM.Ticket_Type_ID
					Where Ticket_Gen_Date >= @FROM_DATE AND Ticket_Gen_Date <= @TO_DATE AND TA.CMP_ID = @CMP_ID
					GROUP BY Month(TA.Ticket_Gen_Date),Year(TA.Ticket_Gen_Date),TM.Ticket_Dept_ID
				) AS T1
			ON T1.ticketMonth = TS.Ticket_Month AND T1.ticketYear = TS.Ticket_Year AND T1.Ticket_Dept_ID = TS.Ticket_Dept_ID
			
			SELECT * FROM #TEMP_TICKET_DEPT
		End
	Else if @ChartType = 'BarMod'
		Begin
			SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(mm,-3,@Temp_DT)),YEAR(@Temp_DT))
			SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))
			
			IF OBJECT_ID('TEMPDB..#TEMP_TICKET_MOD') IS NOT NULL
				BEGIN
					DROP TABLE #TEMP_TICKET_MOD
				END
			
			CREATE TABLE #TEMP_TICKET_MOD
			 (
				 MONTH_NAME Varchar(100),
				 Ticket_Month Numeric(5,0),
				 Ticket_Year Numeric(5,0),
				 Ticket_Mod_ID Numeric(5,0),
				 Ticket_Name Varchar(50),
				 Ticket_Count Numeric(18,0)
			 )
	 
			 SET @TEMP_FROM_DATE = @FROM_DATE
				WHILE @TO_DATE >= @TEMP_FROM_DATE
					BEGIN
						INSERT INTO #TEMP_TICKET_MOD
						SELECT  DISTINCT
						CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)) + '-' + CAST(YEAR(@TEMP_FROM_DATE) AS VARCHAR(4)),
						MONTH(@TEMP_FROM_DATE),
						YEAR(@TEMP_FROM_DATE),
						isnull(Is_Candidate,0),
						(Case When isnull(Is_Candidate,0) = 1 THEN 'Candidate' ELSE 'Employee' END),
						0
						FROM T0090_Ticket_Application TA WITH (NOLOCK)
						INNER JOIN #EMP_CONS EM ON EM.EMP_ID= TA.Emp_ID
						WHERE CMP_ID = @CMP_ID
						
						SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
					END
					
			UPDATE TS
				SET TS.Ticket_Count = ticketCount
			FROM #TEMP_TICKET_MOD TS INNER JOIN
				(
					SELECT COUNT(TA.Ticket_App_ID) as ticketCount, 
						   Month(Ticket_Gen_Date) as ticketMonth,
						   Year(Ticket_Gen_Date) as ticketYear,
						   Isnull(TA.Is_Candidate,0) as Is_Candidate
					From T0090_Ticket_Application TA WITH (NOLOCK)
					INNER JOIN #EMP_CONS EM ON EM.EMP_ID= TA.Emp_ID
					Where Ticket_Gen_Date >= @FROM_DATE AND Ticket_Gen_Date <= @TO_DATE AND TA.CMP_ID = @CMP_ID
					GROUP BY Month(TA.Ticket_Gen_Date),Year(TA.Ticket_Gen_Date),TA.Is_Candidate
				) AS T1
			ON T1.ticketMonth = TS.Ticket_Month AND T1.ticketYear = TS.Ticket_Year AND T1.Is_Candidate = TS.Ticket_Mod_ID
					
			Select * From #TEMP_TICKET_MOD
		End

		--Added by ronakk 20082022
		Else if @ChartType = 'barStatus'
		Begin
			
			Set @Temp_DT = GETDATE()
			
			
			SET @FROM_DATE = concat(YEAR( DATEADD(mm,-11,GETDATE())) ,' - ',month( DATEADD(mm,-11,GETDATE())),' - 01')
			SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))

			--SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(mm,-8,@Temp_DT)),YEAR(@Temp_DT))
			--SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))
	 
			IF OBJECT_ID('TEMPDB..#TEMP_TICKET_Status') IS NOT NULL
				BEGIN
					DROP TABLE #TEMP_TICKET_Status
				END

	 
			 CREATE TABLE #TEMP_TICKET_Status
			 (
				 MONTH_NAME Varchar(100),
				 Ticket_Month Numeric(5,0),
				 Ticket_Year Numeric(5,0),
				 Ticket_Dept_ID Varchar(50),
				 Ticket_Name Varchar(50),
				 Ticket_Count Numeric(18,0)
			 )
	 
			 SET @TEMP_FROM_DATE = @FROM_DATE
				WHILE @TO_DATE >= @TEMP_FROM_DATE
					BEGIN
						INSERT INTO #TEMP_TICKET_Status
						SELECT  DISTINCT
						CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)) + '-' + CAST(YEAR(@TEMP_FROM_DATE) AS VARCHAR(4)),
						MONTH(@TEMP_FROM_DATE),
						YEAR(@TEMP_FROM_DATE),
						Ticket_Status,
						Case When Ticket_Status = 'O' Then 'Open' 
						When Ticket_Status = 'H' Then 'On Hold'
						When Ticket_Status = 'C' Then 'Closed'
						END as Ticket_Status_Label,
						0
						FROM T0090_Ticket_Application TA WITH (NOLOCK)
						INNER JOIN #EMP_CONS EM ON EM.EMP_ID= TA.Emp_ID
						WHERE CMP_ID = @CMP_ID

						SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
					END
	
			UPDATE TS
				SET TS.Ticket_Count = TCOUNT
			FROM #TEMP_TICKET_Status TS INNER JOIN
				( 
					
						SELECT COUNT(TA.Ticket_App_ID) as ticketCount, 
							   Month(Ticket_Gen_Date) as ticketMonth,
							   Year(Ticket_Gen_Date) as ticketYear,
							   Ticket_Status,
						       count(Ticket_Status) TCOUNT
						From T0090_Ticket_Application TA WITH (NOLOCK)
						INNER JOIN #EMP_CONS EM ON EM.EMP_ID= TA.Emp_ID
						Where Ticket_Gen_Date >= @FROM_DATE AND Ticket_Gen_Date <= @TO_DATE AND TA.CMP_ID = @CMP_ID 
						GROUP BY Month(TA.Ticket_Gen_Date),Year(TA.Ticket_Gen_Date),Ticket_Status
				) AS T1
			ON T1.ticketMonth = TS.Ticket_Month AND T1.ticketYear = TS.Ticket_Year AND T1.Ticket_Status = TS.Ticket_Dept_ID
			
			SELECT * FROM #TEMP_TICKET_Status
		End
	--End by ronakk 20082022

	Else if @ChartType = 'Total Ticket'
		Begin
		   SELECT 
			   ROW_NUMBER() OVER(ORDER BY TA.Emp_ID ASC) AS RowID,
			  (Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Resume_Code ELSE  EM.Alpha_Emp_Code END) as Alpha_Emp_Code,
			  (Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Emp_First_Name + ' ' + RM.Emp_Last_Name ELSE  EM.Emp_Full_Name END) as Emp_Full_Name,
			  TM.Ticket_Type,
			  TM.Ticket_Dept_Name,
			  TA.Ticket_Gen_Date,
			  TA.Ticket_Description,
			  --TA.Ticket_Status 
			  (Case When TA.Ticket_Status = 'O' Then 'Open' 
				   When TA.Ticket_Status = 'H' Then 'On Hold'
				   When TA.Ticket_Status = 'C' Then 'Close'
			   END) as Ticket_Status,
			   Isnull(T_Apr.Ticket_Solution,'') as Ticket_Solution,
			   Isnull(T_Apr.Feedback_Rating, 0) as Feedback_Rating,
			   Isnull(T_Apr.Feedback_Date, GETDATE()) as Feedback_Date,
			   Isnull(T_Apr.Feedback_Suggestion, '') as Feedback_Suggestion
		   FROM T0090_Ticket_Application TA WITH (NOLOCK)
		   INNER JOIN #EMP_CONS EC ON EC.EMP_ID= TA.Emp_ID 
		   Inner JOIN T0040_Ticket_Type_Master TM WITH (NOLOCK)
		   ON TA.Ticket_Dept_ID = TM.Ticket_Dept_ID and TA.Ticket_Type_ID = TM.Ticket_Type_ID
		   LEFT JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = TA.Emp_ID and Isnull(TA.Is_Candidate,0) <> 1 and EC.BRANCH_ID = EM.Branch_ID
		   LEFT OUTER JOIN T0055_Resume_Master RM WITH (NOLOCK) ON RM.Resume_Id = TA.Emp_ID and Isnull(TA.Is_Candidate,0) = 1
		   LEFT OUTER JOIN T0100_Ticket_Approval T_Apr WITH (NOLOCK) ON TA.Ticket_App_ID = T_Apr.Ticket_App_ID
		   Where TA.Cmp_ID = @Cmp_ID 
		   order by TA.Ticket_Gen_Date desc
		End
	Else if @ChartType = 'Open Ticket'
		Begin
		   SELECT 
			   ROW_NUMBER() OVER(ORDER BY TA.Emp_ID ASC) AS RowID,
			  (Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Resume_Code ELSE  EM.Alpha_Emp_Code END) as Alpha_Emp_Code,
			  (Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Emp_First_Name + ' ' + RM.Emp_Last_Name ELSE  EM.Emp_Full_Name END) as Emp_Full_Name,
			  TM.Ticket_Type,
			  TM.Ticket_Dept_Name,
			  TA.Ticket_Gen_Date,
			  TA.Ticket_Description,
			  (Case When TA.Ticket_Status = 'O' Then 'Open' 
				   When TA.Ticket_Status = 'H' Then 'On Hold'
				   When TA.Ticket_Status = 'C' Then 'Close'
			   END) as Ticket_Status,
			   Isnull(T_Apr.Ticket_Solution,'') as Ticket_Solution,
			   Isnull(T_Apr.Feedback_Rating, 0) as Feedback_Rating,
			   Isnull(T_Apr.Feedback_Date, GETDATE()) as Feedback_Date,
			   Isnull(T_Apr.Feedback_Suggestion, '') as Feedback_Suggestion
		   FROM T0090_Ticket_Application TA WITH (NOLOCK)
		   INNER JOIN #EMP_CONS EC ON EC.EMP_ID= TA.Emp_ID
		   Inner JOIN T0040_Ticket_Type_Master TM  WITH (NOLOCK)
		   ON TA.Ticket_Dept_ID = TM.Ticket_Dept_ID and TA.Ticket_Type_ID = TM.Ticket_Type_ID
		   LEFT Outer JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = TA.Emp_ID and Isnull(TA.Is_Candidate,0) <> 1
		   LEFT OUTER JOIN T0055_Resume_Master RM WITH (NOLOCK) ON RM.Resume_Id = TA.Emp_ID and Isnull(TA.Is_Candidate,0) = 1
		   LEFT OUTER JOIN T0100_Ticket_Approval T_Apr WITH (NOLOCK) ON TA.Ticket_App_ID = T_Apr.Ticket_App_ID
		   Where TA.Cmp_ID = @Cmp_ID and TA.Ticket_Status = 'O'
		   order by TA.Ticket_Gen_Date desc
		End
	Else if @ChartType = 'On Hold Ticket'
		Begin
		   SELECT 
			    ROW_NUMBER() OVER(ORDER BY TA.Emp_ID ASC) AS RowID,
			  (Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Resume_Code ELSE  EM.Alpha_Emp_Code END) as Alpha_Emp_Code,
			  (Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Emp_First_Name + ' ' + RM.Emp_Last_Name ELSE  EM.Emp_Full_Name END) as Emp_Full_Name,
			  TM.Ticket_Type,
			  TM.Ticket_Dept_Name,
			  TA.Ticket_Gen_Date,
			  TA.Ticket_Description,
			  (Case When TA.Ticket_Status = 'O' Then 'Open' 
				   When TA.Ticket_Status = 'H' Then 'On Hold'
				   When TA.Ticket_Status = 'C' Then 'Close'
			   END) as Ticket_Status,
			   Isnull(T_Apr.Ticket_Solution,'') as Ticket_Solution,
			   Isnull(T_Apr.Feedback_Rating, 0) as Feedback_Rating,
			   Isnull(T_Apr.Feedback_Date, GETDATE()) as Feedback_Date,
			   Isnull(T_Apr.Feedback_Suggestion, '') as Feedback_Suggestion
		   FROM T0090_Ticket_Application TA WITH (NOLOCK)
		   INNER JOIN #EMP_CONS EC ON EC.EMP_ID= TA.Emp_ID
		   Inner JOIN T0040_Ticket_Type_Master TM WITH (NOLOCK)
		   ON TA.Ticket_Dept_ID = TM.Ticket_Dept_ID and TA.Ticket_Type_ID = TM.Ticket_Type_ID
		   LEFT Outer JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = TA.Emp_ID and Isnull(TA.Is_Candidate,0) <> 1
		   LEFT OUTER JOIN T0055_Resume_Master RM WITH (NOLOCK) ON RM.Resume_Id = TA.Emp_ID and Isnull(TA.Is_Candidate,0) = 1
		   LEFT OUTER JOIN T0100_Ticket_Approval T_Apr WITH (NOLOCK) ON TA.Ticket_App_ID = T_Apr.Ticket_App_ID
		   Where TA.Cmp_ID = @Cmp_ID and TA.Ticket_Status = 'H'
		   order by TA.Ticket_Gen_Date desc
		End
	Else if @ChartType = 'Close Ticket'
		Begin
		   SELECT 
			   ROW_NUMBER() OVER(ORDER BY TA.Emp_ID ASC) AS RowID,
			  (Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Resume_Code ELSE  EM.Alpha_Emp_Code END) as Alpha_Emp_Code,
			  (Case WHen isnull(TA.Is_Candidate,0) = 1 THEN RM.Emp_First_Name + ' ' + RM.Emp_Last_Name ELSE  EM.Emp_Full_Name END) as Emp_Full_Name,
			  TM.Ticket_Type,
			  TM.Ticket_Dept_Name,
			  TA.Ticket_Gen_Date,
			  T_Apr.Ticket_Apr_Date as Ticket_Closed_Date,
			  TA.Ticket_Description,
			  (Case When TA.Ticket_Status = 'O' Then 'Open' 
				   When TA.Ticket_Status = 'H' Then 'On Hold'
				   When TA.Ticket_Status = 'C' Then 'Close'
			   END) as Ticket_Status,
			   Isnull(T_Apr.Ticket_Solution,'') as Ticket_Solution,
			   Isnull(T_Apr.Feedback_Rating, 0) as Feedback_Rating,
			   Isnull(T_Apr.Feedback_Date, GETDATE()) as Feedback_Date,
			   Isnull(T_Apr.Feedback_Suggestion, '') as Feedback_Suggestion
		   FROM T0090_Ticket_Application TA WITH (NOLOCK)
		   INNER JOIN #EMP_CONS EC ON EC.EMP_ID= TA.Emp_ID
		   Inner JOIN T0040_Ticket_Type_Master TM  WITH (NOLOCK)
		   ON TA.Ticket_Dept_ID = TM.Ticket_Dept_ID and TA.Ticket_Type_ID = TM.Ticket_Type_ID
		   LEFT Outer JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = TA.Emp_ID and Isnull(TA.Is_Candidate,0) <> 1
		   LEFT OUTER JOIN T0055_Resume_Master RM WITH (NOLOCK) ON RM.Resume_Id = TA.Emp_ID and Isnull(TA.Is_Candidate,0) = 1
		   LEFT OUTER JOIN T0100_Ticket_Approval T_Apr WITH (NOLOCK) ON TA.Ticket_App_ID = T_Apr.Ticket_App_ID
		   Where TA.Cmp_ID = @Cmp_ID and TA.Ticket_Status = 'C'
		   order by Ticket_Closed_Date desc
		End
END

