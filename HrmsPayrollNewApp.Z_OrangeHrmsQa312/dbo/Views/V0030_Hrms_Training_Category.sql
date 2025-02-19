




CREATE VIEW [dbo].[V0030_Hrms_Training_Category]
AS
SELECT     dbo.T0030_Hrms_Training_Category.Training_Category_ID, dbo.T0030_Hrms_Training_Category.Cmp_Id, 
                      dbo.T0030_Hrms_Training_Category.Training_Category_Name, dbo.T0030_Hrms_Training_Category.Parent_categoryId, 
                      T0030_Hrms_Training_Category_1.Training_Category_Name AS Parent_Category
FROM         dbo.T0030_Hrms_Training_Category WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0030_Hrms_Training_Category AS T0030_Hrms_Training_Category_1 WITH (NOLOCK)  ON 
                      dbo.T0030_Hrms_Training_Category.Parent_categoryId = T0030_Hrms_Training_Category_1.Training_Category_ID



