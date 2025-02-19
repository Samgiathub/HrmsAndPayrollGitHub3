



-- =============================================
-- Author:		<Alpesh>
-- ALTER date: <29-Jun-2011>
-- Description:	<To get direct and indirect downline means Tree Structure>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_DIRECT_INDIRECT_DOWNLINE]
@Cmp_ID numeric(18,0),  
@Emp_ID numeric(18,0) 	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	-----Direct Downline----
	select emp_id,emp_full_name,Alpha_Emp_Code from V0080_Employee_Master where emp_id in (select emp_id from t0080_emp_master WITH (NOLOCK) where emp_superior=@Emp_ID and Cmp_ID=@Cmp_ID and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120))))
		
	
	
	-----Indirect Downline----
 --   ;with tem(emp_id,emp_full_name,Alpha_Emp_Code,superior)
	--as
	--(
	--	select emp_id,emp_full_name,Alpha_Emp_Code,emp_superior from V0080_Employee_Master where emp_id=@Emp_ID  and Cmp_ID=@Cmp_ID and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120)))
	--	union all
	--	select v.Emp_ID,v.Emp_Full_Name,v.Alpha_Emp_Code,v.emp_superior from V0080_Employee_Master v inner join tem on v.emp_superior=tem.emp_id where Cmp_ID=@Cmp_ID and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120))) 
		
	--)select * from tem where emp_id<>@Emp_ID and superior<>@Emp_ID option(maxrecursion 32767)

	select emp_id,emp_full_name,Alpha_Emp_Code from V0080_Employee_Master where Cmp_ID = 0 and Emp_ID = 0 -- temp only for getting table at form level - mitesh on 21/02/2012

	select emp_id,emp_full_name,Alpha_Emp_Code from V0080_Employee_Master where emp_id in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @Emp_ID and Reporting_Method = 'InDirect') and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120)))
	
	
END



