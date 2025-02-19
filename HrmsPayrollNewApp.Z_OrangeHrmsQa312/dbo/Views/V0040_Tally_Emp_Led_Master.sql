





CREATE VIEW [dbo].[V0040_Tally_Emp_Led_Master]
AS
SELECT     Tally_Led_ID, Cmp_Id, Tally_Led_Name, Parent_Tally_Led_Name
FROM         dbo.T0040_Tally_Led_Master WITH (NOLOCK)
WHERE     (Parent_Tally_Led_Name NOT IN ('Bank Accounts', 'Cash-in-hand'))




