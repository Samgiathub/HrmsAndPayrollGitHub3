

 

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 19042018
-- Description:	For check Employee Regional Head
---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
-- =============================================
CREATE FUNCTION [dbo].[fn_getRegionalHead]
(	
	@Cmp_ID Numeric,
	@Constraint Varchar(max),
	@To_Date Datetime
)
RETURNS @EmpReginalHead TABLE 
(	
	Emp_ID	 [NUMERIC] NOT NULL,
	Regional_Head Varchar(200)
) 
AS
Begin


	Declare @Emp_ID Numeric
	Set @Emp_ID = 0
	Declare @Emp_Name Varchar(200)
	Set @Emp_Name = ''
	Declare @Alpha_Emp_Code Varchar(200)
	Set @Alpha_Emp_Code = ''



	Declare Cur_Emp Cursor For
	Select EM.Emp_ID,EM.Emp_Full_Name,EM.Alpha_Emp_Code From
					T0080_EMP_MASTER EM  WITH (NOLOCK) Inner Join (Select I.Emp_ID,I.Segment_ID From T0095_Increment I WITH (NOLOCK) Inner Join
							 (
								select Max(TI.Increment_ID) as Increment_Id,TI.Emp_ID
									from t0095_increment TI WITH (NOLOCK) inner join
									(
										Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
											from T0095_Increment WITH (NOLOCK)
										Where Increment_effective_Date <= @To_Date --And Cmp_ID = 2
										GROUP BY Emp_ID 
									) new_inc on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date and TI.Emp_ID = new_inc.Emp_ID
								Where TI.Increment_effective_Date <= @To_Date
								GROUP BY TI.Emp_ID
							)  as Qry ON I.Increment_ID = Qry.Increment_Id AND I.Emp_ID = Qry.Emp_ID
					) as Qry1
					ON Qry1.Emp_ID =EM.Emp_ID
		Where Qry1.Segment_ID = 3 
	Open Cur_Emp
	fetch next from Cur_Emp into @Emp_ID,@Emp_Name,@Alpha_Emp_Code
	while @@FETCH_STATUS = 0
		Begin
		
			;WITH Q(CMP_ID,EMP_ID, R_EMP_ID, R_LEVEL,Alpha_Emp_Code,Emp_Full_NAME) AS
			(
				SELECT	EM.CMP_ID,EM.Emp_ID,CAST(0 AS NUMERIC) as R_Emp_ID, CAST(1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM T0080_EMP_MASTER EM WITH (NOLOCK)
					WHERE	EM.Emp_ID = @Emp_ID AND(EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
				UNION ALL
				SELECT	RD.CMP_ID,RD.Emp_ID,RD.R_Emp_ID, CAST(Q.R_LEVEL + 1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM	T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
						INNER JOIN V0090_EMP_REP_DETAIL_MAX EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE AND RD.Row_ID = EMP_SUP.Row_ID
						INNER JOIN Q ON RD.R_Emp_ID=Q.Emp_ID	
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = RD.Emp_ID
					WHERE (EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
			)

			Insert into @EmpReginalHead
				Select Q.EMP_ID,@Alpha_Emp_Code + ' - ' + @Emp_Name From Q 
				Inner Join (Select data As EmpID From dbo.Split(@Constraint,'#') Where Data <> '') as Qry
				ON Q.EMP_ID = Qry.EmpID
				where R_Emp_ID <> 0

			fetch next from Cur_Emp into @Emp_ID,@Emp_Name,@Alpha_Emp_Code
		End
	Close Cur_Emp
	deallocate Cur_Emp


	RETURN;

End

