CREATE procedure [dbo].[SP_Mittsure_RestAPI]
@Pk_PID numeric(18, 0),
@Emp_ID varchar(100),
@Fk_Staff_ID numeric(18, 0),
@Staff_Name varchar(100),
@Start_date_time datetime,
@Start_Lat nvarchar(100),
@Start_Log nvarchar(100),
@End_date_time datetime,
@End_Lat nvarchar(100),
@End_Log nvarchar(100),
@Is_Sync bit
AS  
BEGIN
	Insert into
	Mittsure_Json_Master
	(Pk_PID, Emp_ID, Fk_Staff_ID, Staff_Name, Start_date_time, Start_Lat, Start_Log, End_date_time, End_Lat, End_Log, Is_Sync)
	values
	(@Pk_PID, @Emp_ID, @Fk_Staff_ID, @Staff_Name, @Start_date_time, @Start_Lat, @Start_Log, @End_date_time, @End_Lat, @End_Log, @Is_Sync)
END



