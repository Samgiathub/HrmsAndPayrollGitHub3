
Create VIEW [dbo].[V0060_HRMS_EmployeeReward_Image]
AS
SELECT     dbo.T0060_HRMS_EmployeeReward.EmpReward_Id, dbo.T0060_HRMS_EmployeeReward.Cmp_Id, dbo.T0060_HRMS_EmployeeReward.From_Date, 
                      dbo.T0060_HRMS_EmployeeReward.To_Date, dbo.T0060_HRMS_EmployeeReward.Employee_Id, dbo.T0060_HRMS_EmployeeReward.Type, 
                      dbo.T0060_HRMS_EmployeeReward.EmpReward_Rating, dbo.T0060_HRMS_EmployeeReward.Awards_Id, dbo.T0040_HRMS_AwardMaster.Award_Name, 
                      RewardValues_Id, comments, dbo.T0060_HRMS_EmployeeReward.Reward_Attachment,
                      CASE WHEN T0060_HRMS_EmployeeReward.RewardValues_Id IS NOT NULL THEN
                          (SELECT     R.RewardValues_Name + ','
                            FROM          T0040_Hrms_RewardValues R WITH (NOLOCK)
                            WHERE      R.RewardValues_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0060_HRMS_EmployeeReward.RewardValues_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) 
                      ELSE 'ALL'
                      END AS RewardValues, 
                      CASE WHEN T0060_HRMS_EmployeeReward.Employee_Id IS NOT NULL 
                      THEN
                          (SELECT     (('#img src="../App_File/EMPIMAGES/' +  Case when  isnull(E.Image_Name,'') = '' then case when E.Gender = 'M' then 'Emp_default.png' else 'Emp_Default_Female.png' END else E.Image_Name END + '" width=25px height=25px style="border-radius:10px" "$') + ' ' + E.Alpha_Emp_Code + '-' + E.Emp_Full_Name) + ','
                            FROM          T0080_EMP_MASTER E WITH (NOLOCK)
                            WHERE      E.Emp_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0060_HRMS_EmployeeReward.Employee_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) 
                     ELSE 'ALL' END AS Employee
FROM         dbo.T0060_HRMS_EmployeeReward WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_HRMS_AwardMaster WITH (NOLOCK) ON dbo.T0060_HRMS_EmployeeReward.Awards_Id = dbo.T0040_HRMS_AwardMaster.Awards_Id

