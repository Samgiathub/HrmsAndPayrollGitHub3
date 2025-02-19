
-- =============================================
-- Author:		Nilesh Patel	
-- Create date: 13-Feb-2018	
-- Description:	Sales Hierarchy Bussiness Segment Wise
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Sales_Downline_Hierarchy]
	@Emp_ID Numeric,
	@Cmp_ID Numeric,
	@Segment_ID Numeric,
	@Flag_ID Numeric
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	if @Emp_ID = 266
		Begin
			SET @Emp_ID = 135 -- For Mr.Jigesh for Checking purpose 
		End

	If @Flag_ID = 1
		Begin
			;WITH Q(CMP_ID,EMP_ID, R_EMP_ID, R_LEVEL,Alpha_Emp_Code,Emp_Full_NAME) AS
			(
				SELECT	EM.CMP_ID,EM.Emp_ID,CAST(0 AS NUMERIC) as R_Emp_ID, CAST(1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM T0080_EMP_MASTER EM WITH (NOLOCK)
					WHERE	EM.Emp_ID = @Emp_ID --AND(EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
				UNION ALL
				SELECT	RD.CMP_ID,RD.Emp_ID,RD.R_Emp_ID, CAST(Q.R_LEVEL + 1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM	T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
						INNER JOIN V0090_EMP_REP_DETAIL_MAX EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE AND RD.Row_ID = EMP_SUP.Row_ID
						INNER JOIN Q ON RD.R_Emp_ID=Q.Emp_ID	
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = RD.Emp_ID
					--WHERE (EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
			)

			Select EM.Emp_ID as Emp_ID ,EM.Alpha_Emp_Code + '-' +  EM.Emp_Full_Name  as Emp_Name
				FROM Q INNER JOIN 
						(Select I.Emp_ID,I.Segment_ID From T0095_Increment I WITH (NOLOCK) Inner Join
								 (
									select Max(TI.Increment_ID) as Increment_Id,TI.Emp_ID
										from t0095_increment TI WITH (NOLOCK) inner join
										(
											Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
												from T0095_Increment WITH (NOLOCK)
											Where Increment_effective_Date <= GETDATE() And Cmp_ID = @Cmp_ID
											GROUP BY Emp_ID 
										) new_inc on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date and TI.Emp_ID = new_inc.Emp_ID
									Where TI.Increment_effective_Date <= GETDATE()
									GROUP BY TI.Emp_ID
								)  as Qry ON I.Increment_ID = Qry.Increment_Id AND I.Emp_ID = Qry.Emp_ID
						) as Qry1 ON Q.Emp_ID = Qry1.Emp_ID
					Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON Q.Emp_ID =EM.Emp_ID
			Where Qry1.Segment_ID = @Segment_ID

		End
	Else if @Flag_ID = 2
		Begin
			;WITH Q(CMP_ID,EMP_ID, R_EMP_ID, R_LEVEL,Alpha_Emp_Code,Emp_Full_NAME) AS
			(
				SELECT	EM.CMP_ID,EM.Emp_ID,CAST(0 AS NUMERIC) as R_Emp_ID, CAST(1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM T0080_EMP_MASTER EM WITH (NOLOCK)
					WHERE	EM.Emp_ID = @Emp_ID --AND(EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
				UNION ALL
				SELECT	RD.CMP_ID,RD.Emp_ID,RD.R_Emp_ID, CAST(Q.R_LEVEL + 1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM	T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
						INNER JOIN V0090_EMP_REP_DETAIL_MAX EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE AND RD.Row_ID = EMP_SUP.Row_ID
						INNER JOIN Q ON RD.R_Emp_ID=Q.Emp_ID	
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = RD.Emp_ID
					--WHERE (EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
			)

			Select EM.Emp_ID as Emp_ID ,EM.Alpha_Emp_Code + '-' +  EM.Emp_Full_Name  as Emp_Name
				FROM Q INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON Q.Emp_ID =EM.Emp_ID
		End
END
