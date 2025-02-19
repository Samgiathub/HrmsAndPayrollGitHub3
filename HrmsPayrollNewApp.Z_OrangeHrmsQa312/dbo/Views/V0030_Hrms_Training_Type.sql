





CREATE VIEW [dbo].[V0030_Hrms_Training_Type]
AS
SELECT   Training_Type_ID,Cmp_Id, Training_TypeName,isnull(Type_OJT,0) as Type_OJT, isnull(Type_Induction,0)as Type_Induction, (Case When Induction_Traning_Dept = 1 Then 'HR' When Induction_Traning_Dept = 2 Then 'Functional' Else '-' END) as Induction_Traning_Dept
FROM dbo.T0030_Hrms_Training_Type WITH (NOLOCK)



