


CREATE VIEW [dbo].[V0100_Break_Time_Branch_Department_Wise]
AS
SELECT		LTB.Break_Id, LTB.Cmp_ID,LTB.Emp_ID,LTB.Effective_Date,
			LTB.[TYPE],LTB.Break_Start_Time,LTB.Break_End_Time,LTB.Break_Duration,
			BM.Branch_Name,Dm.Dept_Name,Bm.Branch_ID,Dm.Dept_Id    
FROM		dbo.T0100_Break_Time AS LTB WITH (NOLOCK) Inner JOin			 
			T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON BM.Branch_ID = LTB.Branch_ID Inner JOin	
			T0040_Department_MASTER DM WITH (NOLOCK)  ON Dm.Dept_Id = LTB.Dept_ID

