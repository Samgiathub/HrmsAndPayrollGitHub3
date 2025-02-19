CREATE VIEW [dbo].[V0040_Reason_Master]  
AS  
SELECT     Res_Id, ISNULL(Reason_Name, '') AS Reason_Name, ISNULL(Isactive, 0) AS Isactive,   
                      CASE WHEN Type = 'R' THEN 'Attendance Regularization' WHEN Type = 'OT' THEN 'OT' WHEN Type = 'GatePass' THEN 'Gate Pass' WHEN Type = 'Advance' THEN 'Advance'  
                         
        WHEN Type = 'Increment' THEN 'Increment' WHEN Type = 'Appraisal' THEN 'Appraisal' WHEN Type = 'MA' THEN 'Mobile Attendance' WHEN Type = 'Exit' THEN 'Exit'   
        WHEN Type = 'Travel' THEN 'Travel'  
        when type = 'Left' then 'Left' when type = 'Canteen' then 'Canteen' END AS Type, ISNULL(Gate_Pass_Type, '') AS Gate_Pass_Type  
	,Is_Mandatory,CASE WHEN dbo.T0040_Reason_Master.IsActive=1 THEN 'awards_link' WHEN dbo.T0040_Reason_Master.IsActive=0 THEN 'awards_link clsinactive' ELSE 'awards_link clsinactive' END as Status_Color  
	FROM         dbo.T0040_Reason_Master WITH (NOLOCK)  
  
  
  
  
