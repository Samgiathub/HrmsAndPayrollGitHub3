


 


CREATE VIEW [dbo].[V0100_WO_Application]
AS
--SELECT     dbo.T0100_WO_Application_Main.WO_Application_Id, dbo.T0100_WO_Application_Main.Cmp_Id, dbo.T0100_WO_Application_Main.Emp_Id, B.Branch_ID, 
--                      dbo.T0100_WO_Application_Main.S_Emp_Id, CONVERT(VARCHAR(30), dbo.T0100_WO_Application_Main.Application_Date, 103) AS Application_Date, 
--                      dbo.T0100_WO_Application_Main.Application_Status, dbo.T0100_WO_Application_Main.Login_Id, dbo.T0100_WO_Application_Main.Month, 
--                      dbo.T0100_WO_Application_Main.Year, CASE WHEN ISNULL(Application_Status, 'P') 
--                      = 'P' THEN '<span style="color: Red;">Pending</span>' ELSE '<span style="color: Green;">Approved</span>' END AS Status, 
--                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, B.Vertical_ID, B.SubVertical_ID, B.Dept_ID, 
--                      CASE WHEN dbo.T0100_WO_Application_Main.Month = 1 THEN 'January' WHEN dbo.T0100_WO_Application_Main.Month = 2 THEN 'February' WHEN dbo.T0100_WO_Application_Main.Month
--                       = 3 THEN 'March' WHEN dbo.T0100_WO_Application_Main.Month = 4 THEN 'April' WHEN dbo.T0100_WO_Application_Main.Month = 5 THEN 'May' WHEN dbo.T0100_WO_Application_Main.Month
--                       = 6 THEN 'June' WHEN dbo.T0100_WO_Application_Main.Month = 7 THEN 'July' WHEN dbo.T0100_WO_Application_Main.Month = 8 THEN 'August' WHEN dbo.T0100_WO_Application_Main.Month
--                       = 9 THEN 'September' WHEN dbo.T0100_WO_Application_Main.Month = 10 THEN 'October' WHEN dbo.T0100_WO_Application_Main.Month = 11 THEN 'November' ELSE
--                       'December' END AS Month_Name, dbo.T0080_EMP_MASTER.Emp_First_Name
--					  ,WA.WO_Date,WA.New_WO_Date                       
--FROM         dbo.T0100_WO_Application_Main INNER JOIN
--					T0110_WO_Application WA ON WA.WO_Application_Id = T0100_WO_Application_Main.WO_Application_Id INNER JOIN
--                      dbo.T0080_EMP_MASTER ON dbo.T0100_WO_Application_Main.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
--                          (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID
--                            FROM          dbo.T0095_INCREMENT AS I
--                            WHERE      (Increment_ID =
--                                                       (SELECT     TOP (1) Increment_ID
--                                                         FROM          dbo.T0095_INCREMENT AS I1
--                                                         WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)
--                                                         ORDER BY Increment_Effective_Date DESC, Increment_ID DESC))) AS B ON B.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND 
--                      B.Cmp_ID = dbo.T0080_EMP_MASTER.Cmp_ID


SELECT   DISTINCT   dbo.T0110_WO_Application.WO_Application_Id, dbo.T0110_WO_Application.Cmp_Id, dbo.T0110_WO_Application.Emp_Id, B.Branch_ID, 
                      CONVERT(VARCHAR(30), dbo.T0110_WO_Application.Application_Date, 103) AS Application_Date, 
                      dbo.T0110_WO_Application.Status as Application_Status, dbo.T0110_WO_Application.Login_Id, dbo.T0110_WO_Application.Month, 
                      dbo.T0110_WO_Application.Year, CASE WHEN ISNULL(T0110_WO_Application.status, 'P') 
                      = 'P' THEN '<span style="color: Red;">Pending</span>' ELSE '<span style="color: Green;">Approved</span>' END AS Status, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, B.Vertical_ID, B.SubVertical_ID, B.Dept_ID, 
                      CASE WHEN dbo.T0110_WO_Application.Month = 1 THEN 'January' WHEN dbo.T0110_WO_Application.Month = 2 THEN 'February' WHEN dbo.T0110_WO_Application.Month
                       = 3 THEN 'March' WHEN dbo.T0110_WO_Application.Month = 4 THEN 'April' WHEN dbo.T0110_WO_Application.Month = 5 THEN 'May' WHEN dbo.T0110_WO_Application.Month
                       = 6 THEN 'June' WHEN dbo.T0110_WO_Application.Month = 7 THEN 'July' WHEN dbo.T0110_WO_Application.Month = 8 THEN 'August' WHEN dbo.T0110_WO_Application.Month
                       = 9 THEN 'September' WHEN dbo.T0110_WO_Application.Month = 10 THEN 'October' WHEN dbo.T0110_WO_Application.Month = 11 THEN 'November' ELSE
                       'December' END AS Month_Name, dbo.T0080_EMP_MASTER.Emp_First_Name
                       ,T0110_WO_Application.WO_Date,
                       case when isnull(WA.New_WO_Date,T0110_WO_Application.New_WO_Date) = T0110_WO_Application.New_WO_Date THEN T0110_WO_Application.New_WO_Date ELSE WA.New_WO_Date END AS New_WO_Date,
                       case when isnull(WA.New_WO_Day,T0110_WO_Application.New_WO_Day) = T0110_WO_Application.New_WO_Day THEN T0110_WO_Application.New_WO_Day ELSE WA.New_WO_Day END AS New_WO_Day,
                        T0110_WO_Application.WO_Day
                       ,WA.WO_Approval_Id,T0110_WO_Application.Sup_Emp_Id
FROM         dbo.T0110_WO_Application WITH (NOLOCK) left OUTER JOIN
			T0120_WO_Approval WA WITH (NOLOCK)  ON WA.WO_Application_Id = dbo.T0110_WO_Application.WO_Application_Id	INNER JOIN		
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0110_WO_Application.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                          (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID
                            FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK) 
                            WHERE      (Increment_ID =
                                                       (SELECT     TOP (1) Increment_ID
                                                         FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK) 
                                                         WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)
                                                         ORDER BY Increment_Effective_Date DESC, Increment_ID DESC))) AS B ON B.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND 
                      B.Cmp_ID = dbo.T0080_EMP_MASTER.Cmp_ID




