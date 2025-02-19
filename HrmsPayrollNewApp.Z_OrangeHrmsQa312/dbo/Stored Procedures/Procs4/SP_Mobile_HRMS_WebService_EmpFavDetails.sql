
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_EmpFavDetails]
	@Emp_ID numeric(18,0)=0,
	@Cmp_ID numeric(18,0)=0,
	@Emp_Code Varchar(50) = '',
	@EmpFavSportId nvarchar(500)='',
	@EmpFavSportName nvarchar(1000)='',
	@EmpHobbyID nvarchar(500)='',
	@EmpHobbyName nvarchar(1000)='',
	@EmpFavFood nvarchar(200)='',
	@EmpFavRestro nvarchar(200)='',
	@EmpFavTrvDest nvarchar(200)='',
	@EmpFavFest nvarchar(200)='',
	@EmpFavSportPerson nvarchar(200)='',
	@EmpFavSinger nvarchar(200)='',
	@Type char(1)='',
	@Result varchar(50) OUTPUT
	
	
AS
SET NOCOUNT ON		
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON



	if not exists(select 1 from T0010_COMPANY_MASTER where  Cmp_ID =@Cmp_ID)
	Begin

	       SET @Result = 'Company Not Exists'
		   Select @Result 
		   Return
	
	End


	if not exists(select 1 from T0080_EMP_MASTER where Emp_ID=@Emp_ID and Cmp_ID =@Cmp_ID)
	Begin

	       SET @Result = 'Employee Not Exists'
		   Select @Result 
		   Return
	
	End




IF @Type = 'U' -- For Update Employee Favourite Details
	BEGIN
		
		UPDATE T0080_EMP_MASTER SET 
		Emp_Fav_Sport_id =@EmpFavSportId 
	   ,Emp_Fav_Sport_Name = @EmpFavSportName
	   ,Emp_Hobby_id = @EmpHobbyID
	   ,Emp_Hobby_Name = @EmpHobbyName
	   ,Emp_Fav_Food = @EmpFavFood
	   ,Emp_Fav_Restro = @EmpFavRestro
	   ,Emp_Fav_Trv_Destination = @EmpFavTrvDest
	   ,Emp_Fav_Festival = @EmpFavFest
	   ,Emp_Fav_SportPerson = @EmpFavSportPerson
	   ,Emp_Fav_Singer = @EmpFavSinger
		WHERE Emp_ID = @Emp_ID and Cmp_ID =@Cmp_ID
		
		SET @Result = 'Employee Update Successfully'
		Select @Result 
END
Else if @Type = 'F'
Begin

	select  isnull(Emp_ID,0) Emp_ID ,isnull(Alpha_Emp_Code,'') Alpha_Emp_Code,isnull(Emp_Fav_Sport_id,'') Emp_Fav_Sport_id,
	isnull(Emp_Fav_Sport_Name,'') Emp_Fav_Sport_Name ,isnull(Emp_Hobby_id,'') Emp_Hobby_id,isnull(Emp_Hobby_Name,'') Emp_Hobby_Name,
	isnull(Emp_Fav_Food,'') Emp_Fav_Food ,isnull(Emp_Fav_Restro,'') Emp_Fav_Restro,isnull(Emp_Fav_Trv_Destination,'') Emp_Fav_Trv_Destination,
	isnull(Emp_Fav_Festival,'') Emp_Fav_Festival,isnull(Emp_Fav_SportPerson,'') Emp_Fav_SportPerson,isnull(Emp_Fav_Singer,'') Emp_Fav_Singer
	from T0080_EMP_MASTER where Emp_ID=@Emp_ID  and  Cmp_ID=@Cmp_ID

End
