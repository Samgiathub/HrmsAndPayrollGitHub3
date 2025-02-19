




CREATE VIEW [dbo].[V0095_EMP_SCHEME]
AS
SELECT     TOP (100) PERCENT ISNULL(CONVERT(NVARCHAR, ES.Effective_Date, 103), '-') AS Effective_Date, ISNULL(CONVERT(NVARCHAR, ES.Scheme_ID), '-') AS Scheme_ID, 
                      ES.Cmp_ID, EMP.Emp_Full_Name, EMP.Alpha_Emp_Code, ISNULL(SM.Scheme_Name, '-') AS Scheme_Name, ISNULL(SM.Scheme_Type, '-') AS Scheme_Type, 
                      INC.Branch_ID, INC.Grd_ID, INC.Desig_Id, ISNULL(INC.Dept_ID, 0) AS Dept_ID, ISNULL(ES.Tran_ID, 0) AS Tran_Id, EMP.Emp_ID,
                      INC.Vertical_ID,INC.SubVertical_ID,   --Added By Jaina 16-09-2015
					  INC.Cat_ID,INC.SalDate_id as SalCycleID,INC.Segment_ID,INC.subBranch_ID,INC.Band_Id,INC.Type_ID --Added By Ronakk 10022022

FROM         dbo.T0095_EMP_SCHEME AS ES WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EMP WITH (NOLOCK)  ON EMP.Emp_ID = ES.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_Scheme_Master AS SM WITH (NOLOCK)  ON SM.Scheme_Id = ES.Scheme_ID INNER JOIN
                      dbo.T0095_INCREMENT AS INC WITH (NOLOCK)  ON INC.Increment_ID = EMP.Increment_ID
WHERE     (EMP.Emp_Left = 'N') and isnull(ES.IsMakerChecker,0) <> 1
ORDER BY EMP.Alpha_Emp_Code, Effective_Date




