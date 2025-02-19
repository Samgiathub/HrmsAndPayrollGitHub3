



CREATE VIEW [dbo].[V0080_Canteen_Application_2]
AS
SELECT        CA.App_Id, ISNULL(CA.App_No, 'CN' + CAST(CA.App_Id AS nvarchar)) AS App_No, CA.Receive_Date, CA.Emp_Name, 
				CA.Emp_Id, CA.Desig_Id, CA.Dept_Id, ISNULL(CA.Cnt_Id, 0) AS Food, ISNULL(CA.Duration, 0) AS Duration,
				ISNULL(CA.From_Date, 0) AS From_Date, ISNULL(CA.To_Date, 0) AS To_Date, ISNULL(CA.Canteen_Name, 0) AS Canteen_Name,
				CA.[Description],CA.App_Type as App_Type,Isnull(CA.Guest_Type_Id,0) as Guest_Type_Id,Isnull(CA.Guest_Name,'') as Guest_Name,ISNULL(CA.Guest_Count,0) as Guest_Count

FROM            dbo.T0080_CANTEEN_APPLICATION as CA 
				--INNER JOIN T0040_Reason_Master as RM on RM.Res_Id = CA.Guest_Type_Id
