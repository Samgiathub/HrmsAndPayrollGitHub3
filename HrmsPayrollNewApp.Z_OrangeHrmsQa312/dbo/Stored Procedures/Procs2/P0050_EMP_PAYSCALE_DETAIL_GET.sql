

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 10-Aug-2015
-- Description:	To retrieving employee information
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_EMP_PAYSCALE_DETAIL_GET] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID numeric, 
	@Branch_ID numeric = 0,
	@Grd_ID numeric = 0,
	@DEPT_ID numeric = 0,
	@DESIG_ID numeric = 0,
	@Emp_ID numeric = 0,
	@Tran_ID numeric = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	IF @Branch_ID = 0 
		SET @Branch_ID = NULL;
	IF @Grd_ID = 0 
		SET @Grd_ID = NULL;
	IF @DEPT_ID = 0 
		SET @DEPT_ID = NULL;
	IF @DESIG_ID = 0 
		SET @DESIG_ID = NULL;
	IF @Emp_ID = 0 
		SET @Emp_ID = NULL;
		
    
    IF ISNULL(@Tran_ID,0) = 0 
    BEGIN
		SELECT	E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,IsNull(P.Pay_Scale_Name,'') As Pay_Scale_Name,P.Pay_Scale_Detail,P.Pay_Scale_ID,P.Effective_Date,P.Tran_ID
				,INC.Branch_ID,INC.Vertical_ID,INC.SubVertical_ID,INC.Dept_ID   -- Added By Jaina 24-09-2015
		FROM	T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN V0050_EMP_PAY_SCALE_DETAIL P ON E.Cmp_ID=P.Cmp_ID AND E.Emp_ID=P.Emp_ID AND P.ROW_NO=1
				INNER JOIN  (SELECT I.Emp_ID,I.Cmp_ID,I.Branch_ID,I.Increment_ID,I.Dept_ID,I.Desig_Id,I.Grd_ID,I.Vertical_ID,I.SubVertical_ID FROM T0095_INCREMENT I   WITH (NOLOCK)  --Change By Jaina 24-09-2015
								 WHERE	I.Increment_ID=(SELECT	TOP 1 I1.Increment_ID 
														FROM	T0095_INCREMENT I1 WITH (NOLOCK)
														WHERE	I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
														ORDER BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
														)
								) INC ON E.Cmp_ID=INC.Cmp_ID AND E.Emp_ID=INC.Emp_ID
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON INC.Cmp_ID=BM.Cmp_ID AND INC.Branch_ID=BM.Branch_ID
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DEPT WITH (NOLOCK) ON INC.Cmp_ID=DEPT.Cmp_ID AND INC.Dept_ID=DEPT.Dept_ID
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON INC.Cmp_ID=DESIG.Cmp_ID AND INC.Desig_Id=DESIG.Desig_Id
				INNER JOIN T0040_GRADE_MASTER GRD WITH (NOLOCK) ON INC.Cmp_ID=GRD.Cmp_ID AND INC.Grd_ID=GRD.Grd_ID		
		WHERE	E.Cmp_ID=@Cmp_ID AND ISNULL(E.Emp_ID, 0) = COALESCE(@EMP_ID, E.Emp_ID, 0)
				AND ISNULL(INC.Branch_ID, 0) = COALESCE(@BRANCH_ID, INC.Branch_ID, 0)
				AND ISNULL(INC.Grd_ID, 0) = COALESCE(@Grd_ID, INC.Grd_ID, 0)
				AND ISNULL(INC.Dept_ID, 0) = COALESCE(@Dept_ID, INC.Dept_ID, 0)
				AND ISNULL(INC.Desig_Id, 0) = COALESCE(@Desig_Id, INC.Desig_Id, 0)		
		ORDER BY E.Alpha_Emp_Code
	END
	ELSE
	BEGIN
		
		SELECT	E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,IsNull(P.Pay_Scale_Name,'') As Pay_Scale_Name,P.Pay_Scale_Detail,P.Pay_Scale_ID,P.Effective_Date,P.Tran_ID
				,INC.Branch_ID,INC.Vertical_ID,INC.SubVertical_ID,INC.Dept_ID   --Added By Jaina 3-11-2015
		FROM	T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN V0050_EMP_PAY_SCALE_DETAIL P ON E.Cmp_ID=P.Cmp_ID AND E.Emp_ID=P.Emp_ID 
				--Added By Jaina 3-11-2015
				INNER JOIN  (SELECT I.Emp_ID,I.Cmp_ID,I.Branch_ID,I.Increment_ID,I.Dept_ID,I.Desig_Id,I.Grd_ID,I.Vertical_ID,I.SubVertical_ID FROM T0095_INCREMENT I  WITH (NOLOCK)  --Change By Jaina 24-09-2015
								 WHERE	I.Increment_ID=(SELECT	TOP 1 I1.Increment_ID 
														FROM	T0095_INCREMENT I1 WITH (NOLOCK)
														WHERE	I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
														ORDER BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
														)
								) INC ON E.Cmp_ID=INC.Cmp_ID AND E.Emp_ID=INC.Emp_ID
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON INC.Cmp_ID=BM.Cmp_ID AND INC.Branch_ID=BM.Branch_ID
		WHERE	P.Tran_ID = @TRAN_ID
		
	END
	    
END

