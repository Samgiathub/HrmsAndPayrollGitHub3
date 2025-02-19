
CREATE VIEW [dbo].[V0100_Employee_Icard_Detail]
AS
					SELECT   dbo.T0100_ICard_Issue_Detail.Tran_ID, dbo.T0100_ICard_Issue_Detail.Cmp_ID, dbo.T0100_ICard_Issue_Detail.Effective_Date
					, dbo.T0100_ICard_Issue_Detail.[Expiry_Date] ,
                      dbo.T0100_ICard_Issue_Detail.Reason as Comments, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Second_Name, dbo.T0080_EMP_MASTER.Emp_Last_Name
                      ,dbo.T0100_ICard_Issue_Detail.Emp_ID,dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, B.Vertical_ID,B.SubVertical_ID,B.Dept_ID,B.Branch_ID                        
                      ,dbo.T0100_ICard_Issue_Detail.Is_Recovered,dbo.T0100_ICard_Issue_Detail.Reason
                      ,B.Grd_ID,B.Type_ID,B.Desig_Id,B.Segment_ID,
                      (case when dbo.T0100_ICard_Issue_Detail.Is_Recovered = 1 then 'Yes' else 'No' ENd) as IsRecovered
                      ,Return_Date,(case when Emp_Left = 'Y' then 1 else 0 end) as Left_Emp,
                      Issue_Date,B.Cat_ID,B.subBranch_ID,dbo.T0080_EMP_MASTER.Blood_Group,dbo.T0080_EMP_MASTER.Father_name,dbo.T0080_EMP_MASTER.Date_Of_Birth
					  ,dbo.T0080_EMP_MASTER.Emp_Category,dbo.T0080_EMP_MASTER.SkillType_ID,dbo.T0100_ICard_Issue_Detail.Issue_By
					  FROM dbo.T0100_ICard_Issue_Detail WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_ICard_Issue_Detail.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN 
                      (
						SELECT	 EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID,I.Grd_ID,I.Type_ID,I.Desig_Id,I.Segment_ID,I.Cat_ID
								,I.subBranch_ID
						FROM	T0095_INCREMENT I WITH (NOLOCK) 
						WHERE	I.INCREMENT_ID = (
													SELECT	TOP 1 INCREMENT_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
													WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
													ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
												)
					  ) AS B ON B.EMP_ID = dbo.T0080_EMP_MASTER.EMP_ID AND B.CMP_ID=dbo.T0080_EMP_MASTER.CMP_ID 

