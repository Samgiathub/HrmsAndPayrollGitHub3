



-- Created By rohit for ALTER new Guest user in Company on 21122012
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Create_Guestuser]
	  @Cmp_Id numeric,	
	  @User_Name varchar(50)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

begin

declare @max_id as numeric
declare @login_id as numeric
declare @domain as varchar(50)

select @domain = ISNULL(Domain_Name,'0') from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id

if isnull(@domain,'0') <> '0' 
begin

select @max_id = ISNULL(MAX(Login_id),0)+1 from T0011_LOGIN WITH (NOLOCK)
	INSERT INTO T0011_LOGIN(Login_ID, Cmp_ID, Login_Name, Login_Password,Emp_ID,Branch_ID,Login_Rights_ID,Is_Default,IS_HR,Is_Accou,Email_ID,Email_ID_Accou,Is_Active)
			 VALUES(@max_id ,@Cmp_Id,@User_Name + @domain,'VuMs/PGYS74=',NULL,NULL,NULL,1,0,0,'','',1)
			 
	
	set @login_id = @max_id
	
	DECLARE @PRIV_ID AS NUMERIC		 
	select @priv_id = Privilege_ID from T0020_PRIVILEGE_MASTER WITH (NOLOCK) where Privilege_Name='admin' and Cmp_Id=1

	select @max_id = ISNULL(MAX(Trans_id),0)+1 from T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)

	INSERT INTO T0090_EMP_PRIVILEGE_DETAILS(Trans_Id, Cmp_Id, Login_Id, Privilege_Id,From_Date)
			 VALUES(@max_id ,1,@login_id,@priv_id, CONVERT(varchar(10),GETDATE(),101))	
			 
end
else
begin
return -1
end

end

