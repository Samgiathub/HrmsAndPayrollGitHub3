




CREATE VIEW [dbo].[V0160_OT_Approve_Backup_Yogesh_19082022]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0160_OT_APPROVAL.Tran_ID, dbo.T0160_OT_APPROVAL.Emp_ID, 
                      dbo.T0160_OT_APPROVAL.Cmp_ID, dbo.T0160_OT_APPROVAL.For_Date, dbo.T0160_OT_APPROVAL.Working_Sec, dbo.T0160_OT_APPROVAL.OT_Sec, 
                      dbo.T0160_OT_APPROVAL.Is_Approved, dbo.T0160_OT_APPROVAL.Approved_OT_Sec, dbo.T0160_OT_APPROVAL.Comments, 
                      dbo.T0160_OT_APPROVAL.Login_ID, dbo.T0160_OT_APPROVAL.System_Date, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0160_OT_APPROVAL.Approved_OT_Hours, 
                      dbo.T0080_EMP_MASTER.Emp_Superior, dbo.T0160_OT_APPROVAL.P_Days_Count, ISNULL(dbo.T0160_OT_APPROVAL.Is_Month_Wise, 0) 
                      AS Is_Month_Wise, ISNULL(dbo.T0160_OT_APPROVAL.Weekoff_OT_Sec, 0.00) AS Weekoff_OT_Sec, 
                      ISNULL(dbo.T0160_OT_APPROVAL.Approved_WO_OT_Sec, 0.00) AS Approved_WO_OT_Sec, 
                      ISNULL(dbo.T0160_OT_APPROVAL.Approved_WO_OT_Hours, '0.00') AS Approved_WO_OT_Hours, 
                      ISNULL(dbo.T0160_OT_APPROVAL.Holiday_OT_Sec, 0.00) AS Holiday_OT_Sec, ISNULL(dbo.T0160_OT_APPROVAL.Approved_HO_OT_Sec, 0.00) 
                      AS Approved_HO_OT_Sec, ISNULL(dbo.T0160_OT_APPROVAL.Approved_HO_OT_Hours, '0.00') AS Approved_HO_OT_Hours, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0160_OT_APPROVAL.Remark,
                      dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID,dbo.T0095_INCREMENT.Dept_ID   -- Added By Jaina 30-09-2015
                      ,dbo.T0030_BRANCH_MASTER.Branch_Name,dbo.T0040_DEPARTMENT_MASTER.Dept_Name , dbo.T0040_DESIGNATION_MASTER.Desig_Name , T0040_GRADE_MASTER.Grd_Name
                      ,dbo.T0040_TYPE_MASTER.Type_Name , T0040_Vertical_Segment.Vertical_Name , T0050_SubVertical.SubVertical_Name
                      ,isnull(BS.Segment_name,'') as Segment_name
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK)
			INNER JOIN dbo.T0160_OT_APPROVAL WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0160_OT_APPROVAL.Emp_ID
			Inner Join T0095_INCREMENT WITH (NOLOCK) On T0080_EMP_MASTER.Emp_ID = T0095_INCREMENT.Emp_ID
			CROSS APPLY (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						FROM	T0095_INCREMENT I2 WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 WITH (NOLOCK) 
											WHERE	I3.Increment_Effective_Date <= T0160_OT_APPROVAL.For_Date
											GROUP BY I3.Emp_ID
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						GROUP BY I2.Emp_ID HAVING T0095_Increment.Emp_ID=I2.Emp_ID AND T0095_Increment.Increment_ID=	MAX(I2.Increment_ID)
						) I2
			INNER JOIN dbo.T0040_GRADE_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID						
			INNER JOIN dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID
			INNER JOIN dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.DESIG_ID = T0040_DESIGNATION_MASTER.DESIG_ID
			LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.DEPT_ID = T0040_DEPARTMENT_MASTER.DEPT_ID
			LEFT OUTER JOIN dbo.T0040_TYPE_MASTER WITH (NOLOCK) on T0095_INCREMENT.Type_ID = T0040_TYPE_MASTER.Type_ID
			LEFT OUTER JOIN dbo.T0040_Vertical_Segment WITH (NOLOCK) ON dbo.T0095_INCREMENT.Vertical_ID = T0040_Vertical_Segment.Vertical_ID
			LEFT OUTER JOIN dbo.T0050_SubVertical WITH (NOLOCK) on T0095_INCREMENT.SubVertical_ID = T0050_SubVertical.SubVertical_ID
			left outer join T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=T0095_INCREMENT.Segment_ID




