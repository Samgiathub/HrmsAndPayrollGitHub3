



create VIEW [dbo].[V0140_Travel_Expense_Master_backup_06012021]
AS
select distinct
 TEP.Expense_Type_ID,Expense_Type_name,Expense_Type_Group,Grade_Wise_ExAmount,is_overlimit
  --,isnull(ETM.City_Cat_Flag,0) as Grade_Id_Multi,
  ,case when isnull(ETM.City_Cat_Flag,0) =0 then 'No' Else 'Yes' End as Grade_Id_Multi
  ,TEP.Cmp_ID
 from T0040_Expense_Type_Master TEP WITH (NOLOCK)
 left join T0050_EXPENSE_TYPE_MAX_LIMIT ETM WITH (NOLOCK)
 on TEP.Expense_Type_ID=ETM.Expense_Type_ID and TEP.CMP_ID=ETM.Cmp_ID
                      



