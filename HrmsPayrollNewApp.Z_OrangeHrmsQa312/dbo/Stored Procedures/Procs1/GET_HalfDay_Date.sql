


CREATE  PROCEDURE [dbo].[GET_HalfDay_Date]

@Company_Id			numeric 
,@Emp_Id			numeric
,@From_Date			DateTime
,@To_Date			Datetime
,@Half_Day			numeric(18,1) output
,@HalfDay_Date		varchar(max) output
	
AS
	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	declare @For_Date as datetime
	declare @TempFor_Date as datetime
	declare @Week_day as varchar(10)
	
	set @HalfDay_Date = ''
	set @TempFor_Date = @From_Date
	set @Week_day = ''
	
	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
	BEGIN
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
		
		--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure		
		Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Company_Id, @Emp_Id, @To_Date, ''
	END	
	
	
	DECLARE @Shift_ID numeric(18,0)
	WHILE @TempFor_Date <= @To_Date 
		BEGIN


			/*Commented By Nimesh 2015
			Set @Week_day = ''
			select @Week_day=sm.Week_Day from T0040_SHIFT_MASTER SM inner join 
				T0100_EMP_SHIFT_DETAIL EM on SM.Shift_ID = Em.Shift_ID 
			where EM.Emp_ID = @Emp_Id and sm.Is_Half_Day = 1 
				and for_date = (Select max(for_date) from T0100_EMP_SHIFT_DETAIL where for_date <= @TempFor_Date and Emp_ID = @Emp_Id)
							
			if @Week_day <> ''
				BEGIN					
					if(LOWER(@Week_day) = lower(DATENAME(dw,@TempFor_Date)))
						begin
							Set @HalfDay_Date = @HalfDay_Date + ' ; ' + cast(@TempFor_Date as varchar(11))						
						end				
				END
			*/
			
			SET @Shift_ID = NULL;
			
			SELECT	@Shift_ID = R.R_ShiftID FROM  #Rotation R
			WHERE	R.R_DayName='Day' + CAST(DATEPART(d,@TempFor_Date) As Varchar) AND R.R_EmpID=@Emp_Id 
					AND R.R_Effective_Date=(
											Select	MAX(R_Effective_Date) 
											FROM	#Rotation R1
											WHERE	R1.R_Effective_Date <= @To_Date
											)
					
			IF (@Shift_ID IS NULL)
				SELECT	@Shift_ID=Em.Shift_ID from T0100_EMP_SHIFT_DETAIL EM WITH (NOLOCK)
				WHERE	EM.Emp_ID = @Emp_Id AND For_Date=@TempFor_Date AND
						EM.Cmp_ID=@Company_Id AND ISNULL(EM.Shift_Type,0)=1
			ELSE BEGIN
				DECLARE @TEMP_SHIFT_ID NUMERIC(18,0)
				SELECT	@TEMP_SHIFT_ID=Em.Shift_ID from T0100_EMP_SHIFT_DETAIL EM  WITH (NOLOCK)
				WHERE	EM.Emp_ID = @Emp_Id AND For_Date=@TempFor_Date AND
						EM.Cmp_ID=@Company_Id 
						
				IF (@TEMP_SHIFT_ID IS NOT NULL)
					SET @Shift_ID=@TEMP_SHIFT_ID;			
			END	
			
			
			IF (@Shift_ID IS NULL) BEGIN
				SELECT	@Shift_ID=Em.Shift_ID from T0100_EMP_SHIFT_DETAIL EM  WITH (NOLOCK)
				WHERE	EM.Emp_ID = @Emp_Id AND EM.Cmp_ID=@Company_Id 
						AND For_Date = (
											SELECT	MAX(for_date) 
											FROM	T0100_EMP_SHIFT_DETAIL EM1 WITH (NOLOCK)
											WHERE	EM1.For_Date<=@TempFor_Date 
													AND EM1.Emp_ID = EM.Emp_ID AND EM1.Cmp_ID=EM.Cmp_ID
										) 
			END
					
			Set @Week_day = ''
			select @Week_day=sm.Week_Day from T0040_SHIFT_MASTER SM  WITH (NOLOCK)
			where SM.Is_Half_Day = 1 AND SM.Cmp_ID=@Company_Id AND SM.Shift_ID=@Shift_ID;
							
			IF @Week_day <> '' BEGIN					
				IF(LOWER(@Week_day) = lower(DATENAME(dw,@TempFor_Date))) BEGIN
					SET @HalfDay_Date = @HalfDay_Date + ' ; ' + CAST(@TempFor_Date as varchar(11))						
				END				
			END
			
			SET @TempFor_Date = DATEADD(dd,1,@TempFor_Date)
		END
			


RETURN




