




CREATE VIEW [dbo].[V0050_EMP_PAY_SCALE_DETAIL]
AS
	SELECT	ROW_NUMBER() OVER (PARTITION BY PSD.Cmp_ID,PSD.Emp_ID ORDER BY PSD.Effective_Date DESC,PSD.Tran_ID DESC) AS ROW_NO, 
			PSD.Cmp_ID,PSD.Tran_ID,PSD.Emp_ID,PSD.Effective_Date,PSD.Pay_Scale_ID,PS.Pay_Scale_Name, PS.Pay_Scale_Detail,
			E.Alpha_Emp_Code,E.Emp_Full_Name,BM.Branch_Name,
			INC.Branch_ID,INC.Vertical_ID,INC.SubVertical_ID,INC.Dept_ID,INC.Grd_ID --add INC.Grd_ID by chetan 180517    ---Added By Jaina 24-09-2015
	FROM	T0050_EMP_PAY_SCALE_DETAIL PSD WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON PSD.Emp_ID=E.Emp_ID AND PSD.Cmp_ID=E.Cmp_ID
			INNER JOIN  T0040_PAY_SCALE_MASTER PS WITH (NOLOCK)  ON PSD.Cmp_ID=PS.Cmp_ID AND PS.Pay_Scale_ID=PSD.Pay_Scale_ID
			INNER JOIN  (SELECT I.Emp_ID,I.Cmp_ID,I.Branch_ID,I.Increment_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID,I.Grd_ID FROM T0095_INCREMENT I WITH (NOLOCK)    --Change By Jaina 24-09-2015
						 WHERE	I.Increment_ID=(SELECT	TOP 1 I1.Increment_ID 
												FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
												WHERE	I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
												ORDER BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
												)
						) INC ON E.Cmp_ID=INC.Cmp_ID AND E.Emp_ID=INC.Emp_ID
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON INC.Cmp_ID=BM.Cmp_ID AND INC.Branch_ID=BM.Branch_ID
		



