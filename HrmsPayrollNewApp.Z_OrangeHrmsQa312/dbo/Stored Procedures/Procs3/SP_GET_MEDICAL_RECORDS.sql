CREATE PROCEDURE [DBO].[SP_GET_MEDICAL_RECORDS]
	@Cmp_ID		Numeric(18,5),
	@Emp_ID		Numeric(18,5),
	@IncidentID Numeric(18,0),
	@Constrains Nvarchar(max),
	@Type numeric(18,0)= 0,
	@OrderBy	varchar(100)=''
AS 
BEGIN

	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON


	create table #MedicalRecords
	(
		App_id numeric(18,0),
		App_date datetime,
		Cmp_Id numeric(18,0),
		Emp_Full_Name varchar(100),
		Incident_Name varchar(100) 
	)


			Insert into #MedicalRecords
			select ma.App_Id,ma.App_Date,ma.Cmp_Id,isnull(Em.Emp_Full_Name,'') as Emp_Full_Name,
			isnull(IM.Incident_Name,'') as Incident_Name from T0500_Medical_Application ma 
			inner join T0040_INCIDENT_MASTER im on im.Incident_Id = ma.Incident_Id 
			inner join T0080_EMP_MASTER EM on Em.Emp_id = Ma.Emp_id


			declare @queryExe as nvarchar(max)

			If @Type = 0
			Begin
				set @queryExe ='select * from ##MedicalRecords where ' + @Constrains + ' ' + @OrderBy 
				exec (@queryExe)
			End

			drop table #MedicalRecords

END