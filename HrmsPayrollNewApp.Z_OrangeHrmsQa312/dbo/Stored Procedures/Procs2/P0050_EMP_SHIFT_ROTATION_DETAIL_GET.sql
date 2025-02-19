

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 10-Aug-2015
-- Description:	To retrieving employee information
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_EMP_SHIFT_ROTATION_DETAIL_GET] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID numeric, 
	@Branch_ID numeric = 0,
	
	@Grd_ID numeric = 0,
	@DEPT_ID numeric = 0,
	@DESIG_ID numeric = 0,
	@Emp_ID numeric = 0,
	@Effective_Date DateTime,
	@Tran_ID numeric = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
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
		SELECT	E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,ROT.Rotation_Name,ROT.Rotation_ID,ROT.Effective_Date,ROT.Tran_ID
				,INC.Branch_ID,INC.Vertical_ID,INC.SubVertical_ID,INC.Dept_ID   -- Added By Jaina 24-09-2015
		FROM	T0080_EMP_MASTER E WITH (NOLOCK)
				INNER JOIN  (SELECT I.Emp_ID,I.Cmp_ID,I.Branch_ID,I.Increment_ID,I.Dept_ID,I.Desig_Id,I.Grd_ID,I.Vertical_ID,I.SubVertical_ID FROM T0095_INCREMENT I WITH (NOLOCK)   --Change By Jaina 24-09-2015
								 WHERE	I.Increment_ID=(SELECT	TOP 1 I1.Increment_ID 
														FROM	T0095_INCREMENT I1 WITH (NOLOCK)
														WHERE	I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
														ORDER BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
														)
								) INC ON E.Cmp_ID=INC.Cmp_ID AND E.Emp_ID=INC.Emp_ID
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON INC.Cmp_ID=BM.Cmp_ID AND  INC.Branch_ID = BM.Branch_ID
				--in (cast(@Branch_ID as varchar(30)))
				--= BM.Branch_ID
				--in (select cast(Data as Int) from dbo.Split(@Branch_ID, ','))
				--
				--LEFT OUTER JOIN T0030_BRANCH_MASTER BMM WITH (NOLOCK) ON INC.Cmp_ID=BMM.Cmp_ID AND INC.Branch_ID in (select cast(Data as Int) from dbo.Split(@PBranch_ID, ',')) --(Isnull(@PBranch_ID,'') ) --added by aswini
				--LEFT OUTER JOIN T0040_Vertical_Segment VT WITH (NOLOCK) ON INC.Cmp_ID=VT.Cmp_ID AND INC.Vertical_ID in (select cast(Data as Int) from dbo.Split(@PVertical, ','))-- (Isnull(@PVertical,'')) --added by aswini
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DEPT WITH (NOLOCK) ON INC.Cmp_ID=DEPT.Cmp_ID AND INC.Dept_ID=DEPT.Dept_ID
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON INC.Cmp_ID=DESIG.Cmp_ID AND INC.Desig_Id=DESIG.Desig_Id
				INNER JOIN T0040_GRADE_MASTER GRD WITH (NOLOCK) ON INC.Cmp_ID=GRD.Cmp_ID AND INC.Grd_ID=GRD.Grd_ID		
				LEFT OUTER JOIN (
									SELECT	ER.Rotation_ID, R.Rotation_Name, ER.Emp_ID, ER.Cmp_ID, ER.Effective_Date, ER.Tran_ID
									FROM	T0050_SHIFT_ROTATION_MASTER R WITH (NOLOCK) INNER JOIN T0050_EMP_MONTHLY_SHIFT_ROTATION ER WITH (NOLOCK)
											ON R.Cmp_ID=ER.Cmp_ID AND R.Tran_ID=ER.Rotation_ID 
									WHERE	ER.Tran_ID=(
															SELECT	TOP 1 TRAN_ID
															FROM	T0050_EMP_MONTHLY_SHIFT_ROTATION ER1 WITH (NOLOCK)
															WHERE	ER1.Cmp_ID=ER.Cmp_ID AND ER1.Emp_ID=ER.Emp_ID 
																	AND ER1.Effective_Date <=@Effective_Date
															ORDER BY ER1.Effective_Date DESC, ER1.Tran_ID DESC
														) 
								) ROT ON ROT.Cmp_ID=E.Cmp_ID  AND ROT.Emp_ID = E.Emp_ID
		WHERE	E.Cmp_ID=@Cmp_ID AND ISNULL(E.Emp_ID, 0) = COALESCE(@EMP_ID, E.Emp_ID, 0)
				AND ISNULL(INC.Branch_ID, 0) = COALESCE(@BRANCH_ID, INC.Branch_ID, 0)
				AND ISNULL(INC.Grd_ID, 0) = COALESCE(@Grd_ID, INC.Grd_ID, 0)
				AND ISNULL(INC.Dept_ID, 0) = COALESCE(@Dept_ID, INC.Dept_ID, 0)
				AND ISNULL(INC.Desig_Id, 0) = COALESCE(@Desig_Id, INC.Desig_Id, 0)	
				and  (E.Emp_Left <> 'Y')    ----added by aswini 09/01/2024
		ORDER BY E.Alpha_Emp_Code
	END
	--else IF  ISNULL(@Tran_ID,0) = 0 and @PBranch_id<>'' and @Pvertical <>''
 --   BEGIN
	--	SELECT	E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,ROT.Rotation_Name,ROT.Rotation_ID,ROT.Effective_Date,ROT.Tran_ID
	--			,INC.Branch_ID,INC.Vertical_ID,INC.SubVertical_ID,INC.Dept_ID   -- Added By Jaina 24-09-2015
	--	FROM	T0080_EMP_MASTER E WITH (NOLOCK)
	--			INNER JOIN  (SELECT I.Emp_ID,I.Cmp_ID,I.Branch_ID,I.Increment_ID,I.Dept_ID,I.Desig_Id,I.Grd_ID,I.Vertical_ID,I.SubVertical_ID FROM T0095_INCREMENT I WITH (NOLOCK)   --Change By Jaina 24-09-2015
	--							 WHERE	I.Increment_ID=(SELECT	TOP 1 I1.Increment_ID 
	--													FROM	T0095_INCREMENT I1 WITH (NOLOCK)
	--													WHERE	I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
	--													ORDER BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
	--													)
	--							) INC ON E.Cmp_ID=INC.Cmp_ID AND E.Emp_ID=INC.Emp_ID
	--			--INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON INC.Cmp_ID=BM.Cmp_ID AND  INC.Branch_ID = BM.Branch_ID
	--			--in (cast(@Branch_ID as varchar(30)))
	--			--= BM.Branch_ID
	--			--in (select cast(Data as Int) from dbo.Split(@Branch_ID, ','))
	--			--
	--			LEFT OUTER JOIN T0030_BRANCH_MASTER BMM WITH (NOLOCK) ON INC.Cmp_ID=BMM.Cmp_ID AND INC.Branch_ID in (select cast(Data as Int) from dbo.Split(@PBranch_ID, ',')) --(Isnull(@PBranch_ID,'') ) --added by aswini
	--			LEFT OUTER JOIN T0040_Vertical_Segment VT WITH (NOLOCK) ON INC.Cmp_ID=VT.Cmp_ID AND INC.Vertical_ID in (select cast(Data as Int) from dbo.Split(@PVertical, ','))-- (Isnull(@PVertical,'')) --added by aswini
	--			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DEPT WITH (NOLOCK) ON INC.Cmp_ID=DEPT.Cmp_ID AND INC.Dept_ID=DEPT.Dept_ID
	--			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON INC.Cmp_ID=DESIG.Cmp_ID AND INC.Desig_Id=DESIG.Desig_Id
	--			INNER JOIN T0040_GRADE_MASTER GRD WITH (NOLOCK) ON INC.Cmp_ID=GRD.Cmp_ID AND INC.Grd_ID=GRD.Grd_ID		
	--			LEFT OUTER JOIN (
	--								SELECT	ER.Rotation_ID, R.Rotation_Name, ER.Emp_ID, ER.Cmp_ID, ER.Effective_Date, ER.Tran_ID
	--								FROM	T0050_SHIFT_ROTATION_MASTER R WITH (NOLOCK) INNER JOIN T0050_EMP_MONTHLY_SHIFT_ROTATION ER WITH (NOLOCK)
	--										ON R.Cmp_ID=ER.Cmp_ID AND R.Tran_ID=ER.Rotation_ID 
	--								WHERE	ER.Tran_ID=(
	--														SELECT	TOP 1 TRAN_ID
	--														FROM	T0050_EMP_MONTHLY_SHIFT_ROTATION ER1 WITH (NOLOCK)
	--														WHERE	ER1.Cmp_ID=ER.Cmp_ID AND ER1.Emp_ID=ER.Emp_ID 
	--																AND ER1.Effective_Date <=@Effective_Date
	--														ORDER BY ER1.Effective_Date DESC, ER1.Tran_ID DESC
	--													) 
	--							) ROT ON ROT.Cmp_ID=E.Cmp_ID  AND ROT.Emp_ID = E.Emp_ID
	--	WHERE	E.Cmp_ID=@Cmp_ID AND ISNULL(E.Emp_ID, 0) = COALESCE(@EMP_ID, E.Emp_ID, 0)
	--			AND ISNULL(INC.Branch_ID, 0) = COALESCE(@BRANCH_ID, INC.Branch_ID, 0)
	--			AND ISNULL(INC.Grd_ID, 0) = COALESCE(@Grd_ID, INC.Grd_ID, 0)
	--			AND ISNULL(INC.Dept_ID, 0) = COALESCE(@Dept_ID, INC.Dept_ID, 0)
	--			AND ISNULL(INC.Desig_Id, 0) = COALESCE(@Desig_Id, INC.Desig_Id, 0)		
	--	ORDER BY E.Alpha_Emp_Code
	--END
	--ELSE
	--BEGIN
	--	SELECT	E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,P.Rotation_Name,P.Rotation_ID,P.Effective_Date,P.Tran_ID
	--	FROM	T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN V0050_Emp_Monthly_Shift_Rotation P ON E.Cmp_ID=P.Cmp_ID AND E.Emp_ID=P.Emp_ID 
	--	WHERE	P.Tran_ID = @TRAN_ID
		
	--END
	    
END

