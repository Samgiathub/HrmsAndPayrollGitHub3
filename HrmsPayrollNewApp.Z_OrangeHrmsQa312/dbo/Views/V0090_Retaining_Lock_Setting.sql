
CREATE VIEW [dbo].[V0090_Retaining_Lock_Setting]
AS
SELECT     Tran_Id, Cmp_Id, Financial_Year, From_Date, To_Date, Emp_Enable_Days
FROM         dbo.T0090_Retaining_Lock_Setting WITH (NOLOCK)


