
CREATE PROCEDURE [dbo].[Get_Griev_Dashboard_Details]
	@Cmp_ID Numeric(18,0),
	@ChartType varchar(50),
	@isFilter int =0,
	@Date1 datetime =null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

-- Created by ronakk 16052022
   
   Declare @FROM_DATE Datetime
   Declare @TO_DATE Datetime
   DECLARE @TEMP_FROM_DATE DATETIME
   
   Declare @Temp_DT As DATETIME

	Set @Temp_DT = DATEADD(MONTH,-1,GETDATE())
   
   if @ChartType = 'header'
		Begin

					-- For Header Part

					 select 
					 COUNT((Case When GA.IsForwarded = 0 or  GA.IsForwarded = 1 THEN 1 END)) as pending,
					 COUNT((Case When GA.IsForwarded = 2 THEN 1 END)) as allocated,
					 COUNT((Case When GA.IsForwarded = 3 THEN 1 END)) as rejected,
					 COUNT((Case When GA.IsForwarded = 4 THEN 1 END)) as inhearing,
					 COUNT((Case When GA.IsForwarded = 5 THEN 1 END)) as closed,
					 COUNT((Case When GA.IsForwarded = 6 THEN 1 END)) as schnxthearing,
					 COUNT((Case When GA.IsForwarded = 7 THEN 1 END)) as transfered,
					 COUNT(1) as totalGriev
					from T0080_Griev_Application GA
					left join T0030_Griev_Status_Common GSC on GSC.S_ID = GA.IsForwarded
					where GA.Cmp_ID=@Cmp_ID

		End
	Else If @ChartType = 'pie'
		Begin

		       --For monthly summery in pai chart


			   
		   if @isFilter=0
		   begin

			

			  
				SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))
				SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@Temp_DT),YEAR(@Temp_DT))

		   end
		   else
		   Begin
				

				 SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(@Date1),YEAR(@Date1))
		         SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@Date1),YEAR(@Date1))



		   End




   

		     SELECT 
			  COUNT(Isnull(GA.GA_ID,0)) as Ticket_Count
			 ,(Case 
					When GA.IsForwarded = 0  then 'Pending' 
					else GSC.S_Name
				
			END) as Griev_Status
			  ,CAST(DATENAME(MONTH,@FROM_DATE) AS VARCHAR(3)) + '-' + CAST(YEAR(@FROM_DATE) AS VARCHAR(4)) AS MONTH_NAME
			FROM T0080_Griev_Application GA WITH (NOLOCK)
			left join T0030_Griev_Status_Common GSC on GSC.S_ID = GA.IsForwarded
			Where  GA.Cmp_ID=120 and CreatedDate >= @FROM_DATE and CreatedDate <= @TO_DATE
			GROUP BY GA.IsForwarded,GSC.S_Name



		End

	Else If @ChartType = 'pie1'
	Begin

	       --For whole summery in pai chart
	     SELECT 
		  COUNT(Isnull(GA.GA_ID,0)) as Ticket_Count
		 ,(Case 
				When GA.IsForwarded = 0  then 'Pending' 
				else GSC.S_Name
			
		END) as Griev_Status
		FROM T0080_Griev_Application GA WITH (NOLOCK)
		left join T0030_Griev_Status_Common GSC on GSC.S_ID = GA.IsForwarded
		Where  GA.Cmp_ID=120 
		GROUP BY GA.IsForwarded,GSC.S_Name

	End


	Else If @ChartType = 'pie2'
	Begin

	       --For Yearly summery in pai chart



		   if @isFilter=0
		   begin

			

			  SELECT
				@FROM_DATE= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) ,
				@TO_DATE= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1) 

		   end
		   else
		   Begin
				
					 SELECT
					@FROM_DATE= DATEADD(yy, DATEDIFF(yy, 0, @Date1), 0) ,
					@TO_DATE= DATEADD(yy, DATEDIFF(yy, 0, @Date1) + 1, -1) 
				

		   End


	    	


		     SELECT 
			  COUNT(Isnull(GA.GA_ID,0)) as Ticket_Count
			 ,(Case 
					When GA.IsForwarded = 0  then 'Pending' 
					else GSC.S_Name
				
			END) as Griev_Status
			,CAST(YEAR(@FROM_DATE) AS VARCHAR(4)) AS YearName
			FROM T0080_Griev_Application GA WITH (NOLOCK)
			left join T0030_Griev_Status_Common GSC on GSC.S_ID = GA.IsForwarded
			Where  GA.Cmp_ID=120 and CreatedDate >= @FROM_DATE and CreatedDate <= @TO_DATE
			GROUP BY GA.IsForwarded,GSC.S_Name



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
						FROM T0090_Ticket_Application WITH (NOLOCK)
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
					Where Ticket_Gen_Date >= @FROM_DATE AND Ticket_Gen_Date <= @TO_DATE AND TA.CMP_ID = @CMP_ID
					GROUP BY Month(TA.Ticket_Gen_Date),Year(TA.Ticket_Gen_Date),TA.Is_Candidate
				) AS T1
			ON T1.ticketMonth = TS.Ticket_Month AND T1.ticketYear = TS.Ticket_Year AND T1.Is_Candidate = TS.Ticket_Mod_ID
					
			Select * From #TEMP_TICKET_MOD
		End
	Else if @ChartType = 'Total Grievance'
		Begin
		  
		       -- for total records of grievance 
		      

				select ROW_NUMBER() OVER(ORDER BY GA_ID ASC) AS RowID,
				App_No,ReceiveDate,[From] Applicant,Name_From,R_From,
				Griev_Against,Name_Against,SubjectLine,ApplicationStatus 
				from V0080_Griev_App_Admin_Side
		        Where Cmp_ID = @Cmp_ID

		End
	Else if @ChartType = 'Pending'
		Begin

		       select ROW_NUMBER() OVER(ORDER BY GA_ID ASC) AS RowID,
				App_No,ReceiveDate,[From] Applicant,Name_From,R_From,
				Griev_Against,Name_Against,SubjectLine,ApplicationStatus 
				from V0080_Griev_App_Admin_Side
		        Where Cmp_ID = @Cmp_ID and ApplicationStatus='Pending'


		End
	Else if @ChartType = 'Allocated'
		Begin
		  
					 select ROW_NUMBER() OVER(ORDER BY GA_ID ASC) AS RowID,
				     App_No,ReceiveDate,[From] Applicant,Name_From,R_From,
				     Griev_Against,Name_Against,SubjectLine,ApplicationStatus 
				     from V0080_Griev_App_Admin_Side
				     Where Cmp_ID = @Cmp_ID and ApplicationStatus='Allocated'


		End
	Else if @ChartType = 'In Hearing'
		Begin
		   
		             select ROW_NUMBER() OVER(ORDER BY GA_ID ASC) AS RowID,
				     App_No,ReceiveDate,[From] Applicant,Name_From,R_From,
				     Griev_Against,Name_Against,SubjectLine,ApplicationStatus 
				     from V0080_Griev_App_Admin_Side
				     Where Cmp_ID = @Cmp_ID and ApplicationStatus='In Hearing'


		End

	Else if @ChartType = 'Scheduled Next Hearing'
	Begin
	   
	             select ROW_NUMBER() OVER(ORDER BY GA_ID ASC) AS RowID,
			     App_No,ReceiveDate,[From] Applicant,Name_From,R_From,
			     Griev_Against,Name_Against,SubjectLine,ApplicationStatus 
			     from V0080_Griev_App_Admin_Side
			     Where Cmp_ID = @Cmp_ID and ApplicationStatus='Scheduled Next Hearing'


	End
	Else if @ChartType = 'Transferred'
	Begin
	   
	             select ROW_NUMBER() OVER(ORDER BY GA_ID ASC) AS RowID,
			     App_No,ReceiveDate,[From] Applicant,Name_From,R_From,
			     Griev_Against,Name_Against,SubjectLine,ApplicationStatus 
			     from V0080_Griev_App_Admin_Side
			     Where Cmp_ID = @Cmp_ID and ApplicationStatus='Transferred'


	End
	Else if @ChartType = 'Rejected'
	Begin
	   
	             select ROW_NUMBER() OVER(ORDER BY GA_ID ASC) AS RowID,
			     App_No,ReceiveDate,[From] Applicant,Name_From,R_From,
			     Griev_Against,Name_Against,SubjectLine,ApplicationStatus 
			     from V0080_Griev_App_Admin_Side
			     Where Cmp_ID = @Cmp_ID and ApplicationStatus='Rejected'


	End
    Else if @ChartType = 'Closed'
	Begin
	   
	             select ROW_NUMBER() OVER(ORDER BY GA_ID ASC) AS RowID,
			     App_No,ReceiveDate,[From] Applicant,Name_From,R_From,
			     Griev_Against,Name_Against,SubjectLine,ApplicationStatus 
			     from V0080_Griev_App_Admin_Side
			     Where Cmp_ID = @Cmp_ID and ApplicationStatus='Closed'


	End

END

