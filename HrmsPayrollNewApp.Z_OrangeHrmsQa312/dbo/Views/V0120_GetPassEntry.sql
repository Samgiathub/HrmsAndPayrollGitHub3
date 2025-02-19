


CREATE VIEW [dbo].[V0120_GetPassEntry]
AS
SELECT     dbo.T0130_LEAVE_APPROVAL_DETAIL.From_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.To_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Assign_As, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Period, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Approval_ID, dbo.T0120_LEAVE_APPROVAL.Approval_Status, 
                      T0080_EMP_MASTER_1.Emp_First_Name, 
                      dbo.T0120_LEAVE_APPROVAL.Approval_Date, 
                      dbo.T0100_LEAVE_APPLICATION.Application_Code, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.Cmp_ID, dbo.T0100_LEAVE_APPLICATION.Application_Date, dbo.T0040_LEAVE_MASTER.Leave_Name, 
                      dbo.T0040_LEAVE_MASTER.Leave_Paid_Unpaid, dbo.T0040_LEAVE_MASTER.Leave_Min, dbo.T0040_LEAVE_MASTER.Leave_Max, 
                      dbo.T0040_LEAVE_MASTER.Leave_Status, dbo.T0040_LEAVE_MASTER.Leave_Applicable, dbo.T0040_LEAVE_MASTER.Leave_Notice_Period, 
                      isnull(dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID,0) as Leave_Application_ID ,
                       dbo.T0040_LEAVE_MASTER.Leave_ID, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Reason, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.Row_ID, T0080_EMP_MASTER_1.Emp_Full_Name, dbo.T0095_INCREMENT.Grd_ID, dbo.T0095_INCREMENT.Dept_ID, 
                      T0080_EMP_MASTER_1.Date_Of_Join, T0080_EMP_MASTER_1.Emp_code, T0080_EMP_MASTER_1.Other_Email, T0080_EMP_MASTER_1.Mobile_No, 
                      T0080_EMP_MASTER_1.Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name AS S_emp_Full_Name, dbo.T0080_EMP_MASTER.Other_Email AS S_Other_Email, 
                      dbo.T0120_LEAVE_APPROVAL.S_Emp_ID, dbo.T0120_LEAVE_APPROVAL.Approval_Comments, dbo.T0095_INCREMENT.Branch_ID, dbo.T0095_INCREMENT.Desig_Id, 
                      dbo.T0040_LEAVE_MASTER.Leave_Type, T0080_EMP_MASTER_1.Alpha_Emp_Code, ISNULL(dbo.T0130_LEAVE_APPROVAL_DETAIL.M_Cancel_WO_HO, 0) 
                      AS M_Cancel_WO_HO, dbo.T0130_LEAVE_APPROVAL_DETAIL.Half_Leave_Date
                      --,T0110_LEAVE_APPLICATION_DETAIL.leave_Out_time,
                      --T0110_LEAVE_APPLICATION_DETAIL.leave_In_time,
                      
                      --,case when T0110_LEAVE_APPLICATION_DETAIL.leave_Out_time = '01-jan-1900' then '' else isnull(CONVERT(varchar(15),T0110_LEAVE_APPLICATION_DETAIL.leave_Out_time ,108),'') end as leave_Out_time 
                      --,case when T0110_LEAVE_APPLICATION_DETAIL.leave_In_time='01-jan-1900' then '' else isnull(CONVERT(varchar(15),(T0110_LEAVE_APPLICATION_DETAIL.leave_In_time ),108),'') end as leave_In_time, 
                      
                      ,case when T0110_LEAVE_APPLICATION_DETAIL.leave_Out_time = '01-jan-1900' then '' else isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), T0110_LEAVE_APPLICATION_DETAIL.leave_Out_time, 100), 7)),'') end as leave_Out_time 
                      ,case when T0110_LEAVE_APPLICATION_DETAIL.leave_In_time='01-jan-1900' then '' else isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), T0110_LEAVE_APPLICATION_DETAIL.leave_In_time, 100), 7)),'') end as leave_In_time, 
                      
                      --isnull(cast(T0110_LEAVE_APPLICATION_DETAIL.Leave_Actual_out_time as varchar),'') as Leave_Actual_out_time ,
                      --isnull(cast(T0110_LEAVE_APPLICATION_DETAIL.Leave_Actual_In_time as varchar),'') as Leave_Actual_In_time 
                      --isnull(CONVERT(varchar(15),(T0110_LEAVE_APPLICATION_DETAIL.Leave_Actual_out_time ),108),'') as Leave_Actual_out_time ,
                      --isnull(CONVERT(varchar(15),(T0110_LEAVE_APPLICATION_DETAIL.Leave_Actual_In_time ),108),'') as Leave_Actual_In_time 
                      
                      isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), T0110_LEAVE_APPLICATION_DETAIL.Leave_Actual_out_time, 100), 7)),'') as Leave_Actual_out_time ,
                      isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), T0110_LEAVE_APPLICATION_DETAIL.Leave_Actual_In_time , 100), 7)),'') as Leave_Actual_In_time 
                      
                     , '../App_File/Empimages/' + (case when isnull(T0080_EMP_MASTER_1.Image_Name,'0.jpg')='0.jpg' then 'default.jpg' when T0080_EMP_MASTER_1.Image_Name ='' then 'default.jpg' else T0080_EMP_MASTER_1.Image_Name end ) as Photo
                     ,T0110_LEAVE_APPLICATION_DETAIL.Leave_Actual_out_time as Leave_Actual_out_Date
                      ,T0110_LEAVE_APPLICATION_DETAIL.Leave_Actual_In_time as Leave_Actual_In_Date
                      ,dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID  -- Added By Jaina 22-09-2015
FROM         dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON T0080_EMP_MASTER_1.Increment_ID = dbo.T0095_INCREMENT.Increment_ID INNER JOIN
                      dbo.T0120_LEAVE_APPROVAL WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0120_LEAVE_APPROVAL.S_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND 
                      dbo.T0120_LEAVE_APPROVAL.S_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0100_LEAVE_APPLICATION WITH (NOLOCK)  ON dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID = dbo.T0100_LEAVE_APPLICATION.Leave_Application_ID ON 
                      T0080_EMP_MASTER_1.Emp_ID = dbo.T0120_LEAVE_APPROVAL.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)  ON dbo.T0040_LEAVE_MASTER.Leave_ID = dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_ID ON 
                      dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID = dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Approval_ID
                      left join T0110_LEAVE_APPLICATION_DETAIL WITH (NOLOCK)  on T0110_LEAVE_APPLICATION_DETAIL.Leave_Application_ID = T0100_LEAVE_APPLICATION.Leave_Application_ID

union all

SELECT 
lad.From_Date,lad.To_Date, lad.Leave_Assign_As,lad.Leave_Period, 0 as Leave_Approval_ID, LA.Application_Status as Approval_Status, 
E1.Emp_First_Name, 
                      LA.Application_Date as Approval_Date, 
                      LA.Application_Code as Application_Code,
                       lad.Cmp_ID, LA.Application_Date, LM.Leave_Name, 
                      LM.Leave_Paid_Unpaid, LM.Leave_Min, LM.Leave_Max, 
                      LM.Leave_Status, LM.Leave_Applicable, LM.Leave_Notice_Period, 
                      isnull(LA.Leave_Application_ID,0) as Leave_Application_ID ,
                       LM.Leave_ID, lad.Leave_Reason, 
                      lad.Row_ID, E1.Emp_Full_Name, dbo.T0095_INCREMENT.Grd_ID, dbo.T0095_INCREMENT.Dept_ID, 
                      E1.Date_Of_Join, E1.Emp_code, E1.Other_Email, E1.Mobile_No, 
                      E1.Emp_ID, E.Emp_Full_Name AS S_emp_Full_Name, E1.Other_Email AS S_Other_Email, 
                      LA.S_Emp_ID, LA.application_comments as Approval_Comments, dbo.T0095_INCREMENT.Branch_ID, dbo.T0095_INCREMENT.Desig_Id, 
                      lm.Leave_Type, E1.Alpha_Emp_Code, 0 as M_Cancel_WO_HO, 
                      lad.Half_Leave_Date
                      --,lad.leave_Out_time,
                      --lad.leave_In_time,
                      --,isnull(CONVERT(varchar(15),CAST(lad.leave_Out_time AS TIME),100),'') as leave_Out_time ,
                      --isnull(CONVERT(varchar(15),CAST(lad.leave_In_time AS TIME),100),'') as leave_In_time ,
                      --,case when lad.leave_Out_time = '01-jan-1900' then '' else isnull(CONVERT(varchar(15),(lad.leave_Out_time ),108),'') end as leave_Out_time 
                      --,case when lad.leave_In_time='01-jan-1900' then '' else isnull(CONVERT(varchar(15),(lad.leave_In_time ),108),'') end as leave_In_time, 
                      
                        ,case when lad.leave_Out_time = '01-jan-1900' then '' else isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), lad.leave_Out_time, 100), 7)),'') end as leave_Out_time 
                      ,case when lad.leave_In_time='01-jan-1900' then '' else isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), lad.leave_In_time , 100), 7)),'') end as leave_In_time, 
                      
                      -- isnull(CONVERT(varchar(15),(lad.Leave_Actual_out_time ),108),'') as Leave_Actual_out_time ,
                      --isnull(CONVERT(varchar(15),(lad.Leave_Actual_In_time ),108),'') as Leave_Actual_In_time 
                      
                      isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), lad.Leave_Actual_out_time, 100), 7)),'') as Leave_Actual_out_time ,
                      isnull(LTRIM(RIGHT(CONVERT(VARCHAR(20), lad.Leave_Actual_In_time, 100), 7)),'') as Leave_Actual_In_time 
                      
                     , '../App_File/Empimages/' + (case when isnull(E1.Image_Name,'0.jpg')='0.jpg' then 'default.jpg' when E1.Image_Name ='' then 'default.jpg' else E1.Image_Name end ) as Photo
						,lad.Leave_Actual_out_time as Leave_Actual_out_Date
                      ,lad.Leave_Actual_in_time as Leave_Actual_In_Date
                      ,dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID  -- Added By Jaina 22-09-2015
FROM         dbo.T0100_LEAVE_APPLICATION AS LA WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E1 WITH (NOLOCK)  INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON E1.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID ON LA.Emp_ID = E1.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON LA.S_Emp_ID = e.Emp_ID RIGHT OUTER JOIN
                      dbo.T0040_LEAVE_MASTER AS lm WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0110_LEAVE_APPLICATION_DETAIL AS lad WITH (NOLOCK)  ON lm.Leave_ID = lad.Leave_ID ON LA.Leave_Application_ID = lad.Leave_Application_ID
where la.Application_Status ='P'




