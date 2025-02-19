CREATE PROCEDURE [dbo].[Get_Email_Address_Medical_Officer]
	@CMP_ID numeric(18,0)

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN		

CREATE TABLE #tempdetails
(
	 Emp_id numeric(18,0)
	,Login_id numeric(18,0)
	,Login_Name varchar(100)
	--added by aswini 12122024
	,Email_id nvarchar(2000)
	,Designation varchar(2000)
	,Branch_id_multi nvarchar(4000)
	--commented by aswini
	--,Email_id nvarchar(1000)
	--,Designation varchar(1000)
	--,Branch_id_multi nvarchar
)
	
	Insert into #tempdetails
	SELECT	Emp_id,Login_ID,Login_Name,Email_ID_IT AS Email_id,'Medical Officer' AS Designation ,Branch_id_multi 
	FROM	T0011_LOGIN L WITH (NOLOCK)  
	WHERE	IS_Medical = 1 and Emp_ID > 0 and L.Cmp_ID =@cmp_id 
	
	Select Emp_id,Login_id,Login_Name,Email_id,Designation,Branch_id_multi from #tempdetails

	drop table #tempdetails
END


