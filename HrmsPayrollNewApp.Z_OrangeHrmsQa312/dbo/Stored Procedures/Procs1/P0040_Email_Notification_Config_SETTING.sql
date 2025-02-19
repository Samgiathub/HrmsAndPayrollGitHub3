  
  
-- =============================================  
-- Author:  <Author,,Tejas>  
-- Create date: <Create Date,,>  
-- Description: <Create for Dropdown wise show data,,>  
---11/01/2024 (CREATE BY Tejas) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P0040_Email_Notification_Config_SETTING]  
 @Cmp_ID Numeric(18,0)  
AS  
BEGIN  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
 --/*  
    -- Insert statements for procedure here  
 --; with Setting_List as ( SELECT ROW_NUMBER() OVER(PARTITION BY Group_BY ORDER BY Group_BY,Caption) As RowID, *   
 --FROM T0040_CAPTION_SETTING  WHERE Cmp_Id = @Cmp_ID and Is_Hidden = 0)--Added by Mukti(02012018)Is_Hidden=0  
    
 --select case when rowID = 1 then Group_BY else '' end as Group_BY,Tran_Id,SL.Cmp_ID,Caption,Alias,SortingNo,Remarks,SL.Module_Name,  
 --(Case When rowID = 1 Then 'True' Else 'False' End) As IsGroup  
 --from Setting_List SL  
 --Inner Join (  
 --  Select isnull(module_status,0) as module_status,Cmp_id From T0011_module_detail Where Cmp_id = @Cmp_ID And Module_Name = 'HRMS'  
 -- ) as Qry  
 -- ON SL.Cmp_Id = Qry.Cmp_id  
 --where SL.Cmp_ID = @Cmp_ID and Module_Name <> (Case When module_status = 1 then '' else 'HRMS' End)   
 --*/  
   
 /* NOW AS WE ARE WORKING ON MULTIPLE MODULE , THIS QUERY IS CHANGED BY RAMIZ (23/04/2018). */  
  
; WITH Setting_List AS 
		(	SELECT ROW_NUMBER() OVER(PARTITION BY Module_Name ORDER BY Module_Name) As RowID, * 
			FROM T0040_Email_Notification_Config  WITH (NOLOCK)
			WHERE Cmp_Id = @Cmp_ID and Email_NTF_ID <> 0 and (Module_name in ('MOBILE','Appraisal2','HRMS','Payroll','Timesheet','Grievance') OR Module_Name IS NULL)
			--Added by Mukti(02012018)Is_Hidden=0
		 )
	SELECT	CASE WHEN rowID = 1 THEN isnull(Module_Name,'Extra') ELSE '' END AS Group_BY,Email_Type_Name,Email_NTF_DEF_ID,Email_NTF_SENT,Email_NTF_ID,To_Manager,To_Hr,
	To_Account,Other_Email,Is_Manager_CC,Is_HR_CC,Is_Account_CC,Other_Email_Bcc,
			CASE WHEN rowID = 1 THEN 'True' ELSE 'False' END As IsGroup
	FROM Setting_List SL
	WHERE SL.Cmp_ID = @Cmp_ID
   
END  
  