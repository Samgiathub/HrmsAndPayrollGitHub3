

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Request_Details]
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@Request_ID Numeric(18,0),
	@Shift_Date Datetime 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	Declare @Shift_ID Numeric(18,0)
	Set @Shift_ID = 0
	
	if @Shift_Date = '01/01/1900'
		Set @Shift_Date = GETDATE()
	
	if @Request_ID = 3 
		Begin
			Set @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, @emp_Id,@Shift_Date); 
		End
    SELECT T0080_EMP_MASTER.Emp_ID,Cmp_ID,Branch_ID,(Case when @Request_ID = 3 then @Shift_ID ELSE Shift_ID End) as Shift_ID,Date_Of_Birth,Marital_Status,Street_1,City,
	State,Zip_code,Tehsil,District,Thana_Id,Present_Street,Present_City,Present_State,Present_Post_Box,Tehsil_Wok,District_Wok,Thana_Id_Wok 
	,Ifsc_Code,qry_1.Bank_ID,qry_1.Inc_Bank_AC_No,qry_1.Bank_Branch_Name,Pan_No,Aadhar_Card_No
	---------------------------Added by ronakk 24062022 --------------------------------------------
	,isnull(Emp_Fav_Sport_id,'') as Emp_Fav_Sport_id
	,isnull(Emp_Fav_Sport_Name,'') as Emp_Fav_Sport_Name
	,isnull(Emp_Hobby_id,'') as Emp_Hobby_id
	,isnull(Emp_Hobby_Name,'') as Emp_Hobby_Name
	,isnull(Emp_Fav_Food,'') as Emp_Fav_Food
	,isnull(Emp_Fav_Restro,'') as Emp_Fav_Restro
	,isnull(Emp_Fav_Trv_Destination,'') as Emp_Fav_Trv_Destination
	,isnull(Emp_Fav_Festival,'') as Emp_Fav_Festival
	,isnull(Emp_Fav_SportPerson,'') as Emp_Fav_SportPerson
	,isnull(Emp_Fav_Singer,'') as Emp_Fav_Singer
	------------------------------------------------------------------------------------------------
	FROM T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN
		(SELECT I.Emp_ID,I.Increment_ID,I.Bank_ID,I.Inc_Bank_AC_No,I.Bank_Branch_Name FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
		(SELECT MAX(Increment_Effective_Date) as Effecitve_Date,Emp_ID
			From T0095_INCREMENT WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Increment_Effective_Date <= GETDATE()
			GROUP By Emp_ID) as qry 
			on  I.Increment_Effective_Date = qry.Effecitve_Date and I.Emp_ID = qry.Emp_ID
		) as qry_1
	On T0080_EMP_MASTER.Emp_ID = qry_1.Emp_ID
	where Cmp_ID = @Cmp_ID and T0080_EMP_MASTER.Emp_ID = @Emp_ID
END

