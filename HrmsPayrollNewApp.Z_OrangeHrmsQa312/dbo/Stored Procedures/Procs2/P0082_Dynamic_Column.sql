
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0082_Dynamic_Column]
 @Emp_id 		numeric
 ,@Cmp_id        Numeric
 ,@table		NVARCHAR(257) = 'Employee Master'
  as

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


 Begin
 
	--if not exists(select 1 from  T0081_CUSTOMIZED_COLUMN where Cmp_Id =@Cmp_id and Table_Name =@table)
	--begin
	--	RAISERROR ('@@ Customized Column is Not Created. @@' , 16, 2) 
	--	Return
	--end

select cc.Tran_Id as mst_tran_id,cc.Column_Name,cc.Table_Name,cc.Active,cc.Cmp_Id,ec.tran_id as tran_id,
	  isnull(EC.value,'') as value ,EC.emp_id   
	  ,CC.Ess_Editable,CC.Ess_Visible   --Added by Jaina 21-04-2018
from T0081_CUSTOMIZED_COLUMN as CC WITH (NOLOCK)
	 left join (
				select * 
				from T0082_Emp_Column WITH (NOLOCK)
				where emp_id=@Emp_id
				) As EC on CC.Tran_Id =Ec.mst_tran_Id  and cc.Cmp_Id =Ec.cmp_Id
where cc.Cmp_Id =@Cmp_id and cc.Table_Name =@table and isnull(cc.Active,0) = 1
 	
 end
