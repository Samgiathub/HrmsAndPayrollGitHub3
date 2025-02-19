


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <29/01/2015,,>
-- Description:	<Medical Checkup Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Medical_Checkup_Records]
 @cmp_ID numeric(18,0),
 @Emp_ID numeric(18,0),
 @for_date datetime,
 @New_Records tinyint = 1
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If @New_Records = 0 
		begin
		 	
			  select  ROW_NUMBER() over (Order by Medical_ID asc) as SR_NO,*
			   From  (
			   
				 select  EMC.Tran_ID as Medical_Tran_ID,EMC.Medical_ID as Medical_ID,IM.Ins_Name as Parameter
				,EMC.Description as Diagnosis
				from T0090_Emp_Medical_Checkup EMC WITH (NOLOCK)
				inner join T0040_INSURANCE_MASTER IM WITH (NOLOCK) on EMC.Medical_ID = IM.Ins_Tran_ID and IM.Type = 'Medical'
							where EMC.Cmp_ID = @cmp_ID and Emp_ID = @Emp_ID and For_date = @For_Date
				Union  
				select 0 as Medical_Tran_ID,Ins_Tran_ID as Medical_ID,Ins_Name as Parameter, '' as Diagnosis from dbo.T0040_INSURANCE_MASTER IM WITH (NOLOCK)
							Left outer join ( select Medical_ID as Old_Medical_Id from T0090_Emp_Medical_Checkup  WITH (NOLOCK)
							where  cmp_Id =@cmp_ID and Emp_Id = @emp_ID and For_Date = @for_date)qry on Qry.Old_Medical_Id = IM.Ins_Tran_ID
							where Cmp_ID = @cmp_ID and Type = 'Medical' and isnull(Old_Medical_Id,0) = 0
				 )a	
		end
	else
		begin
				select ROW_NUMBER() over (Order by Ins_Tran_ID asc) as SR_NO , 
						0 as Medical_Tran_ID,
						IM.Ins_Tran_ID as Medical_ID,
						Ins_Name as Parameter, 
						'' as Diagnosis 
						from dbo.T0040_INSURANCE_MASTER IM WITH (NOLOCK)
						where Cmp_ID = @cmp_ID and Type = 'Medical' 
		end		
--	SELECT *, ROW_NUMBER() OVER(ORDER BY Id) ROW_NUM
--  FROM (
--        select Id, VersionNumber from documents where id=5 
--        Union all  
--        select Id, VersionNumber from versions where id=5
--       ) a
--order by VersionNumber desc
END


