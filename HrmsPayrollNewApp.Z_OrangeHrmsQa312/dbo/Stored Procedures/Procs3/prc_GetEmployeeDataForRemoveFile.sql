-- exec [prc_GetEmployeeDataForRemoveFile]  
-- drop proc [prc_GetEmployeeDataForRemoveFile]
CREATE PROCEDURE [dbo].[prc_GetEmployeeDataForRemoveFile]  
 @rCmp_ID numeric,
 @rMonth varchar(20),
 @rYear varchar(20),
 @Flag varchar(20)
as

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


begin

	select Result = '<td><input type="checkbox" attrid="'+ convert(varchar,E.Emp_ID) +'" /></td>
	<td>' + isnull(Alpha_Emp_Code,'') + '</td><td>' + ISNULL(E.Emp_Full_Name,'') + '</td>'
	from T9999_Bank_Transfer_Export E WITH (NOLOCK) inner join T0080_EMP_MASTER M WITH (NOLOCK) on E.Emp_ID = M.Emp_ID where Regerate_Flag = 'I' and E.Cmp_Id= @rCmp_ID
	and Month = @rMonth and Year = @rYear and Flag = @Flag

	
end