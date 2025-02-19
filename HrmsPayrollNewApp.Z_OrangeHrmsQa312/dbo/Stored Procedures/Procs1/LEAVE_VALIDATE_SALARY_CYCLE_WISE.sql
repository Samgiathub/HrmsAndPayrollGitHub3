/* Created by Sumit on 08122016 for Leave Validation to check to date month is not changin */
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[LEAVE_VALIDATE_SALARY_CYCLE_WISE]
	@CMP_ID		NUMERIC ,
	@EMP_ID		NUMERIC ,
	@FROM_DATE  DATETIME,
	@TO_DATE    DATETIME
	

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	Declare @BRANCH_ID numeric(18,0)
	DECLARE @SAL_START_DATE DATETIME
	DECLARE @SAL_END_DATE DATETIME
	declare @Month numeric
	declare @year numeric
	declare @Manual_Salary as tinyint
	set @Manual_Salary=0;	
	set @Month=MONTH(@FROM_DATE);
	set @year= YEAR(@FROM_DATE);--YEAR(@FROM_DATE)-1;
	

	SELECT @Branch_ID =I.Branch_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
					(
						select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(
								Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date and Emp_ID=@Emp_ID Group by emp_ID
						)		new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date and TI.Emp_ID=@Emp_ID group by ti.emp_id
					) Qry on I.Increment_Id = Qry.Increment_Id
					
	SELECT	@SAL_START_DATE = GS.Sal_St_Date,@Manual_Salary=ISNULL(GS.Manual_Salary_Period,0) 
			FROM T0040_GENERAL_SETTING GS WITH (NOLOCK) INNER JOIN
								( 
									SELECT MAX(For_Date) AS For_Date,Branch_ID FROM T0040_GENERAL_SETTING WITH (NOLOCK)
									WHERE  Cmp_ID = @cmp_ID AND Branch_ID = isnull(@BRANCH_ID,Branch_ID) 
									GROUP BY Branch_ID
								) Qry ON Qry.Branch_ID = GS.Branch_ID AND GS.For_Date = Qry.For_Date
							WHERE Cmp_ID = @cmp_ID AND GS.Branch_ID = isnull(@BRANCH_ID,GS.Branch_ID)
	
	--SELECT @SAL_START_DATE =  SAL_ST_DATE,@Manual_Salary=ISNULL(Manual_Salary_Period,0) FROM T0040_GENERAL_SETTING 
	--					      WHERE CMP_ID=@CMP_ID AND BRANCH_ID=@BRANCH_ID 
	--					      AND FOR_DATE = (
	--											SELECT MAX(FOR_DATE) FROM T0040_GENERAL_SETTING 
	--											WHERE CMP_ID=@CMP_ID AND BRANCH_ID=@BRANCH_ID
											 --)
										 
	
	SELECT @SAL_START_DATE	= SALARY_ST_DATE FROM DBO.T0040_SALARY_CYCLE_MASTER SCM WITH (NOLOCK)
							  INNER JOIN T0095_EMP_SALARY_CYCLE ESC WITH (NOLOCK) ON SCM.TRAN_ID = ESC.SALDATE_ID AND SCM.CMP_ID=ESC.CMP_ID
							  WHERE EMP_ID=@EMP_ID AND SCM.CMP_ID=@CMP_ID
	
	
	if (@Manual_Salary=1)
		Begin
			select @SAL_START_DATE = from_date,@SAL_END_DATE=end_date from Salary_Period where MONTH(from_date)=@Month and year(from_date)=@year;
		End
	
	
	if (@SAL_START_DATE is null)
		Begin			
			set @SAL_START_DATE ='1900-01-01';
		End	
		
	
	--if (@SAL_START_DATE is not null) --Because Not to Check if Salary Cycle start from 01.
	--	Begin
			if (DAY(@FROM_DATE) < DAY(@SAL_START_DATE))
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
					set @SAL_START_DATE =CAST(CAST(@Month AS VARCHAR(20)) + '-' + CAST(DAY(@SAL_START_DATE) AS VARCHAR(20)) + '-' + CAST(@year AS VARCHAR(20)) AS DATETIME)
				End
			Else
				Begin	
					set @SAL_START_DATE =CAST(CAST(MONTH(@FROM_DATE) AS VARCHAR(20)) + '-' + CAST(DAY(@SAL_START_DATE) AS VARCHAR(20)) + '-' + CAST(YEAR(@FROM_DATE) AS VARCHAR(20)) AS DATETIME)
				End
					
			set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@SAL_START_DATE)) 			
			
			if (@TO_DATE not between @SAL_START_DATE and @Sal_End_Date and DAY(@SAL_END_DATE) <> DAY(@TO_DATE))
				Begin
					--select @SAL_END_DATE as ErrorDate
					Select TOP 0 @SAL_END_DATE as ErrorDate
				End
			 
			--if ((DAY(@SAL_END_DATE) between DAY(@FROM_DATE) and DAY(@TO_DATE)) and DAY(@FROM_DATE) <> DAY(@TO_DATE) or (DAY(@FROM_DATE) = DAY(@SAL_END_DATE) and DAY(@TO_DATE) <> DAY(@SAL_END_DATE)))
			----if ((@SAL_END_DATE between @FROM_DATE and @TO_DATE) and DAY(@FROM_DATE) <> DAY(@TO_DATE) or (DAY(@FROM_DATE) = DAY(@SAL_END_DATE) and DAY(@TO_DATE) <> DAY(@SAL_END_DATE)))
			--	Begin
					
			--		if (DAY(@SAL_END_DATE) <> DAY(@TO_DATE))
			--			Begin
			--				select @SAL_END_DATE
			--			End	
			--	End
			
			--if (@TO_DATE > @Sal_End_Date and @FROM_DATE <= @SAL_END_DATE or (DAY(@SAL_END_DATE) > DAY(@TO_DATE) and day(@FROM_DATE) <= day(@SAL_END_DATE) and @SAL_END_DATE <= @FROM_DATE) or DAY(@FROM_DATE) = DAY(@SAL_END_DATE))--BETWEEN DAY(@FROMDATE) AND DAY(@TODATE))
			--	Begin
			--		if (DAY(@FROM_DATE) = DAY(@SAL_END_DATE) and DAY(@TO_DATE) <> DAY(@SAL_END_DATE))
			--			Begin
			--				select @SAL_END_DATE
			--			End	
			--	End	
		--End	
				
	RETURN



