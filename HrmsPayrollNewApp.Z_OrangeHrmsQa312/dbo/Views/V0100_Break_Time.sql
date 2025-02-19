




CREATE VIEW [dbo].[V0100_Break_Time]
AS
SELECT     LTB.Break_Id, LTB.Cmp_ID,LTB.Emp_ID,LTB.Effective_Date,EM.Emp_Full_Name, EM.Emp_First_Name, 
           EM.Emp_code,EM.Alpha_Emp_Code,B1.Vertical_ID,B1.SubVertical_ID,B1.Dept_ID,B1.Branch_ID,B1.Grd_ID,B1.Type_ID,B1.Desig_Id,B1.Segment_ID,
		   B1.Cat_ID,B1.subBranch_ID,LTB.[TYPE],LTB.Break_Start_Time,LTB.Break_End_Time,LTB.Break_Duration     
FROM       dbo.T0100_Break_Time AS LTB WITH (NOLOCK) LEFT OUTER JOIN
           dbo.T0080_EMP_MASTER AS EM  WITH (NOLOCK) ON LTB.Emp_ID = EM.Emp_ID INNER JOIN 
		   T0095_INCREMENT I_Q  WITH (NOLOCK) ON EM.Emp_ID = I_Q.Emp_ID INNER JOIN 	
		   (
				SELECT	I.Branch_ID, I.CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID,I.Grd_ID,I.Type_ID,I.Desig_Id,I.Segment_ID,I.Cat_ID,
						I.subBranch_ID,I.Increment_ID
				FROM	T0095_INCREMENT I  WITH (NOLOCK) INNER JOIN 
						 (
							SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
							FROM		T0095_INCREMENT I2  WITH (NOLOCK) 	INNER JOIN
									(
										SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
										FROM	T0095_INCREMENT I3 WITH (NOLOCK)  INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON EM.Emp_ID = I3.EMp_ID									
										WHERE	I3.Increment_Effective_Date <= (Case WHEN EM.Date_Of_Join >= GETDATE() then EM.Date_Of_Join Else GETDATE() END)													
										GROUP BY I3.Emp_ID
									) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID		
							GROUP BY I2.Emp_ID
						) B ON I.Emp_ID=B.Emp_ID AND I.Increment_ID=B.INCREMENT_ID	
			) AS B1 ON I_Q.Increment_ID = B1.Increment_ID AND B1.CMP_ID=I_Q.CMP_ID 
				 
