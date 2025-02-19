--exec  Get_Emp_Doc_Ver 119 ,'10/01/2020','10/31/2020'
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Emp_Doc_Ver]
	@cmp_ID numeric(18,0),
	@From_date datetime,
	@To_Date datetime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Select  Row_id,D.Emp_ID as Emp_Id, E.Alpha_Emp_Code as Emp_Code, E.Emp_Full_Name as Emp_Full_Name
	,dm.Doc_Name as Document_Name,Doc_Path,d.Doc_Comments
	,DocUpload_DateTime,Verify 
	from T0090_EMP_DOC_DETAIL D WITH (NOLOCK) inner join T0080_EMP_MASTER E WITH (NOLOCK) on d.Emp_ID = E.Emp_ID
	left join T0040_DOCUMENT_MASTER dm WITH (NOLOCK) on dm.Doc_ID=d.Doc_ID
	where d.Doc_Comments = 'Bulk Doc'
	And (DocUpload_DateTime between @From_date and @To_Date) and d.Cmp_ID = @cmp_ID and Verify is null
	order by Emp_id
END

