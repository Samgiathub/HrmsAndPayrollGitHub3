

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Employee_Retirement_Records]
	@Cmp_Id numeric(18,0),
	@Type tinyint = 0,
	@Days numeric(18,0),
	@StrWhere varchar(max) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
	DECLARE @Start_Date datetime
	DECLARE @End_Date datetime
	Declare @SqlQuery varchar(max)

	
	SET @Start_Date = GETDATE()
	SET @End_Date = DATEADD(dd,@Days,@Start_Date)
	
	IF OBJECT_ID('tempdb..#EMP_RETIREMENT') IS  NULL 
	BEGIN
			  --DROP TABLE #EMP_RETIREMENT
	--END
		CREATE TABLE #EMP_RETIREMENT
		(
			Cmp_Id numeric(18,0),
			Emp_ID numeric(18,0),
			Branch_ID numeric(18,0),
			Alpha_Emp_Code varchar(250),
			Emp_Full_Name varchar(500),
			Branch_Name varchar(500),
			Date_Of_Join datetime,
			Date_of_Retirement datetime,
			Desig_ID numeric(18,0),
			Desig_Name varchar(500),
			Emp_Superior numeric(18,0)
			
		
		)
	END
	set @SqlQuery = 'SELECT i.Cmp_id,i.Emp_ID,e.Branch_ID,Alpha_Emp_Code,Emp_Full_Name,B.Branch_Name,E.Date_Of_Join,E.Date_of_Retirement,I.Desig_ID,D.Desig_Name,E.Emp_Superior
		FROM    T0080_EMP_MASTER AS e WITH (NOLOCK) INNER JOIN
			T0095_INCREMENT I WITH (NOLOCK) ON e.Emp_ID = I.Emp_ID INNER JOIN 
				 (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
				  FROM	T0095_INCREMENT I2 WITH (NOLOCK) 
						INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
									FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = I3.EMp_ID
									--WHERE	I3.Increment_Effective_Date <= GETDATE() --Comment by Nilesh patel on 19042017 For future date edit
									WHERE	I3.Increment_Effective_Date <= (Case WHEN EM.Date_Of_Join >= GETDATE() then EM.Date_Of_Join Else GETDATE() END)
									GROUP BY I3.Emp_ID
									) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
				 
				  GROUP BY I2.Emp_ID
				) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID INNER JOIN
		T0030_BRANCH_MASTER B WITH (NOLOCK) ON I.Branch_ID = B.Branch_ID INNER JOIN
		T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = I.Desig_Id
		WHERE E.Emp_Left <> ''Y'' AND E.Cmp_Id = ' +  cast(@Cmp_id as varchar(10)) + ' AND Date_of_Retirement IS NOT NULL 
		and E.Date_of_Retirement <= '''+ CAST(@End_Date AS varchar(11)) +''''+ @StrWhere
	
	--and E.Date_of_Retirement BETWEEN '''+ cast(@Start_Date AS varchar(11)) +''' and '''+ CAST(@End_Date AS varchar(11)) +''''+ @StrWhere
	--IF @Type = 2
	--	exec (@SqlQuery)
	--ELSE
		insert INTO #Emp_Retirement
		exec (@SqlQuery)
		
	IF @Type = 1	
		SELECT COUNT(*)AS Retirement FROM #Emp_Retirement
	ELSE IF @Type = 0
		SELECT * FROM #Emp_Retirement
END

