


 
  
CREATE  VIEW [dbo].[Get_TaskDetails] AS  
SELECT  TTM.Task_ID,TTM.Task_Name,TTM.Task_Code,TTM.Task_Description,ISNULL(TTM.Task_Priority,'Select Task Priority')AS 'Task_Priority',TTM.Cmp_Id,
ISNULL(TTM.Task_Type_ID,0) as 'Task_Type_ID',TTM.Project_ID,CONVERT(varchar(20),ISNULL(TTM.Due_Date,''),103) as 'Due_Date',
CONVERT(varchar(20),ISNULL(TTM.Deadline_Date,''),103) as 'Deadline_Date',TTM.Duration,TTM.Completed, TTM.IsReOpen,
ISNULL(TTM.Project_Status_ID,0)as 'Project_Status_ID',ISNULL(TTM.Milestone_ID,0) as 'Milestone_ID',TTD.Assign_To,TTM.All_Employee_Task,TTM.All_Project_Task,
ISNULL(TTM.Estimate_Cost,0) as 'Estimate_Cost',ISNULL(TTM.Estimate_Duration,0) as 'Estimate_Duration',ISNULL(TTM.Task_Attachment,'') as 'Task_Attachment', 
TTD.Task_Detail_ID,Emp_ID,(ISNULL(Emp_First_Name,'')+''+ISNULL(Emp_Last_Name,''))AS 'EmployeeName',
DM.Desig_Name,BM.Branch_Name
FROM T0040_Task_Master TTM WITH (NOLOCK)   
LEFT  JOIN T0050_Task_Detail TTD WITH (NOLOCK) ON TTM.Task_ID = TTD.Task_ID   
LEFT JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TTD.Assign_To = EM.Emp_ID    
LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EM.Branch_ID = BM.Branch_ID   
LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON EM.Desig_Id = DM.Desig_ID

