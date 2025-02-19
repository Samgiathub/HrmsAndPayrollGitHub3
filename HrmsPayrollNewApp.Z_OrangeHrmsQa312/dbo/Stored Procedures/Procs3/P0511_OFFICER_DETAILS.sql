CREATE PROCEDURE [dbo].[P0511_OFFICER_DETAILS]
@Cmp_id numeric(18,0),
@Officer_Name varchar(50),
@Officer_Branch varchar(100),
@Officer_Department varchar(50),
@Emailid varchar(100),
@Contact varchar(50),
@Address varchar(500)

as 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


begin 

	Insert into T0511_OFFICER_DETAILS (cmp_id,Officer_Name,Officer_Branch,Officer_Department,Emailid,Contact,Address)
	Values(@Cmp_id,@Officer_Name,@Officer_Branch,@Officer_Department,@Emailid,@Contact,@Address)

End