
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Emp_Curr_Shift_New]
	 @Emp_Id as numeric
	,@Company_Id as numeric
	,@For_Date as datetime
	,@PRE_FLAG AS VARCHAR(10)
	,@pre_date as datetime
	,@St_Time_1 as varchar(10) = null output
	,@End_Time_1 as varchar(10) = null output
	,@Shift_Dur as varchar(10) = null output
	,@Lunch_Dur as varchar(10) = null output
	,@Break1_Dur as varchar(10)= null output
	,@Break2_Dur as varchar(10) = null output
	,@Min_Shift_Dur as varchar(10) = null output
	,@Break1_St_Time as varchar(10) = null output
	,@Break1_End_Time as varchar(10) = null output
	,@Shift_ID as numeric = null output
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		DECLARE @isAutoShift As tinyint
		declare @beforeshift as varchar(10)
		declare @aftershift as varchar(10)
		declare @Auto_Shift_Group as varchar(50)
		Declare @inflag as tinyint			
		Declare @outflag as tinyint
		declare @beforeshift_sec as numeric
		declare @aftershift_sec as numeric
		DECLARE @Shift_Id1 AS NUMERIC
		declare @St_Time as varchar(10)
		declare @End_Time as varchar(10)

		DECLARE @H_Shift_Start VARCHAR(10)
		DECLARE @H_Shift_End VARCHAR(10)
		DECLARE @Is_Half_Day TinyInt
		DECLARE @H_Day_Name  Varchar(32)
		DECLARE @H_Duration Varchar(10)
		DECLARE @AUTO_SHIFT_GRPID AS TINYINT

		Set @isAutoShift=0
		SET @aftershift =''
		SET @beforeshift=''
		set @inflag=0
		set @outflag=0
		Set @Auto_Shift_Group=''
		set @St_Time_1 =''
		Set @End_time_1=''
		
		DECLARE @IO_DateTime DateTime
		SET @IO_DateTIme = @For_Date
		

		set @beforeshift_sec = 14400 -- for 4 hours
		set @aftershift_sec = 14400
		
		set @beforeshift_sec=-@beforeshift_sec
		
		SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@company_Id, @emp_Id, @For_Date);
		
		IF Not EXISTS (SELECT 1 FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @company_Id AND shift_id=@shift_id AND Inc_Auto_Shift=1)
			Begin
			
			 select @St_Time_1 = shift_St_Time,
					@End_Time_1 = shift_End_Time,
					@Shift_Dur = Shift_Dur,
					@H_Shift_Start = Half_St_Time,
					@H_Shift_End = Half_End_Time,
					@Is_Half_Day = Is_Half_Day,
					@H_Duration = Half_Dur,
					@H_Day_Name = Week_Day
			FROM 	T0040_shift_master sm WITH (NOLOCK)
			WHERE 	Shift_ID=@Shift_ID				
			End
		else
			Begin
				set @Outflag = 0
				set @inflag=0
				set @isAutoShift=1
				
						
				if isnull(@pre_date,'')=''
					set @pre_date = @For_Date 
				
				              declare CurAutoShift cursor for
								select Top 1 Shift_Id,Shift_St_Time,Shift_End_Time from T0040_SHIFT_MASTER WITH (NOLOCK) where cmp_id=@Company_Id and inc_Auto_Shift=1 
								open CurAutoShift
								Fetch next from CurAutoShift into @Shift_Id,@St_Time,@End_Time
								while @@fetch_status = 0
									Begin			
										
								
										if @PRE_FLAG ='O'
											Begin
												SET @FOR_DATE = CONVERT(DATETIME, CONVERT(VARCHAR(10), @FOR_DATE, 103), 103)
												SET @PRE_DATE = CONVERT(DATETIME, CONVERT(VARCHAR(10), @PRE_DATE, 103), 103)
												SELECT 	TOP 1 @Shift_Id1 =  Shift_ID ,
														@St_Time_1 = Shift_St_Time , 
														@End_Time_1 = Shift_End_Time,
														@Shift_Dur = Shift_Dur,
														@H_Shift_Start = Half_St_Time,
														@H_Shift_End = Half_End_Time,
														@Is_Half_Day = Is_Half_Day,
														@H_Duration = Half_Dur,
														@H_Day_Name = Week_Day
							                    FROM 	(SELECT Cast(@FOR_DATE + Shift_St_Time As DateTime) As S_DateTime, *
															 FROM	T0040_SHIFT_MASTER WITH (NOLOCK)
															 WHERE	Cmp_ID = @company_id
															 UNION ALL									
															 SELECT Cast(@PRE_DATE + Shift_St_Time As DateTime) As S_DateTime, *
															 FROM	T0040_SHIFT_MASTER WITH (NOLOCK)
															 WHERE	Cmp_ID = @company_id
															) T
												ORDER BY Abs(DateDiff(s, @IO_DateTIme, S_DateTime) )
										
										
										
											 End
										Else
											Begin
											 	select	top 1 @Shift_Id1 =  Shift_ID ,
														@St_Time_1 = Shift_St_Time , 
														@End_Time_1 = Shift_End_Time,
														@Shift_Dur = Shift_Dur,
														@H_Shift_Start = Half_St_Time,
														@H_Shift_End = Half_End_Time,
														@Is_Half_Day = Is_Half_Day,
														@H_Duration = Half_Dur,
														@H_Day_Name = Week_Day
						                    	from	T0040_SHIFT_MASTER WITH (NOLOCK)
						                    	where	Cmp_ID = @company_id
						                    	order by ABS(datediff(s,@pre_date,cast(CONVERT(VARCHAR(11),  Case When DATEPART(hh,Shift_St_Time)=0 And DATEPART(hh,@pre_date) <> 0 THEN  DATEADD(dd,1,@pre_date) ELSE @pre_date END, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)))			
										
											
											End

										
								fetch next from CurAutoShift into @Shift_Id,@St_Time,@End_Time
								End
					Close CurAutoShift
					Deallocate CurAutoShift
					
				set @shift_id =	@Shift_Id1
				
				

			End
	
		IF DATENAME(WEEKDAY, @For_Date) = @H_Day_Name AND @Is_Half_Day=1 AND @H_Shift_Start IS NOT NULL
			BEGIN
				SET @St_Time_1 = @H_Shift_Start
				SET @End_Time_1 = @H_Shift_End
				SET @Shift_Dur = @H_Duration
			END
	RETURN

