--Exec  SP_Mobile_HRMS_WebService_Travel_picCount 21164,121,1,1,1,1
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Travel_picCount]
	 @Emp_ID numeric(18,0)
	,@Cmp_ID numeric(18,0) 
	,@start_Journey varchar(5) 
	,@Reach_Destination varchar(5)
	,@t_Event varchar(5)
	,@End_Journey varchar(5)
	,@Result VARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

				create table #Temp
				(
					Cmpid int, 
					empid int, 
					S_journey varchar(5), 
					Reach_Destination varchar(5), 
					t_event varchar(5),
					E_journey varchar(5)
				)

		
			INSERT INTO #Temp(
						Cmpid,
						empid,
						S_journey,
						Reach_Destination,
						t_event,
						E_journey
					)
					VALUES
					(
						@Cmp_ID,
						@EMP_ID,
						@start_Journey,
						@Reach_Destination,
						@t_Event,
						@End_Journey
					)

	select @Result = Isnull(cast(S_journey as int),0) + IsNull(cast(Reach_Destination as int),0) + IsNull(cast(t_event as int),0)+ IsNull(cast(E_journey as int),0) from #Temp

	select @Result as Result
END
