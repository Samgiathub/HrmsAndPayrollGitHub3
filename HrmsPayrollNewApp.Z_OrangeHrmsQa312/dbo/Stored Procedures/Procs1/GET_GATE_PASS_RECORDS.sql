




-- =============================================
-- Author:		<Gadriwala Muslim> 
-- Create date: <29/12/2014>
-- Description:	 <Getting IN-OUT Records from Gate-Pass Device which Pending>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---		
-- =============================================
CREATE PROCEDURE [dbo].[GET_GATE_PASS_RECORDS]
 @cmp_ID numeric(18,0)
,@emp_ID numeric(18,0)
,@From_Date	 datetime
,@To_Date	 datetime
,@Branch_ID numeric(18,0) 
,@Status varchar(5) = 'P'	
,@Constraint varchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		--, isnull(dbo.F_Return_HHMM (In_Time),'') as In_Time,
		--		isnull(dbo.F_Return_HHMM (Out_Time),'') as Out_Time,
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		Declare @Out_Time datetime
		Declare @In_Time datetime
		Declare @Reason_Name as Varchar(25)
		--Declare @From_Date as datetime
		--Declare @To_date as datetime
		
		--set @From_Date = dbo.GET_MONTH_ST_DATE(@Month,@Year)
		--set @To_date = dbo.GET_MONTH_END_DATE(@Month,@Year)
		
		set @Reason_Name = ''	
		--select @Shift_End_Time = Shift_End_Time	 from T0100_emp_shift_Detail es inner join 
		-- ( select max(for_Date) For_date ,Emp_ID from T0100_emp_shift_Detail 
		--	Where Emp_ID =@Emp_ID and (Month(For_Date) <= @Month and YEAR(For_Date) <= @Year) group by Emp_ID )q on es.emp_ID =q.emp_ID and es.for_Date =q.for_Date inner join 
		--		T0040_shift_master sm on es.Shift_ID =sm.shift_ID 		 
	
			select Top 1 @Reason_Name = Reason_Name from T0040_Reason_Master WITH (NOLOCK)
			 where Type = 'GatePass' and Gate_Pass_Type = 'Personal' and Isactive = 1
			 
	     	If @Reason_Name is null
	     		begin
	     			set @Reason_Name = ''
	     		end	
	     		
	     If @Branch_ID = 0 
			set @Branch_ID = null
		If @emp_ID = 0
			set @emp_ID = null	
	    		
	     		
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else if @Emp_ID > 0
		begin
			Insert Into @Emp_Cons values (@Emp_ID)
		end
	else 
		begin
			Insert Into @Emp_Cons
			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
			Where Cmp_ID = @Cmp_ID 
			--and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @To_date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date) 	
		End
		
			Create table #Emp_Shift
			(
			   Emp_Id numeric(18,0),
			   For_date datetime,
			   Shift_St_Time varchar(10),
			   Shift_End_Time varchar(10),
			   Is_Night_Shift tinyint
			)
		
			declare @For_date datetime
			
			--- Commented by Hardik 07/02/2015 as it is take more time to execute..
			
			--exec getAllDaysBetweenTwoDate @From_date,@To_Date
		    
			--declare DateCur cursor for select test1 from test1 
		 
			-- Open DateCur
			--	Fetch next from DateCur into @For_Date
			--	 while @@fetch_status = 0
			--		begin	
						
			--					Insert into #Emp_Shift (Emp_ID,For_Date)		
									
			--					select EC.Emp_ID,@For_Date from @Emp_Cons EC inner join
			--					T0150_EMP_Gate_Pass_INOUT_RECORD EG on EC.Emp_ID = EG.Emp_ID
			--					where EG.For_Date >= @From_date and EG.For_Date <= @To_Date   
									
			--			Fetch next from DateCur  into @For_Date
			--		end
			--close DateCur
			--Deallocate DateCur	


			-- Added by Hardik 07/02/2015
			Insert into #Emp_Shift (Emp_ID,For_Date)		
			select EC.Emp_ID,For_date from @Emp_Cons EC inner join
			T0150_EMP_Gate_Pass_INOUT_RECORD EG WITH (NOLOCK) on EC.Emp_ID = EG.Emp_ID
			where EG.For_Date >= @From_date and EG.For_Date <= @To_Date   
			
			UNION	--Ankit 28052016
			
			SELECT EC.Emp_ID,For_date FROM @Emp_Cons EC INNER JOIN
				T0120_GATE_PASS_APPROVAL GP WITH (NOLOCK)ON EC.Emp_ID = GP.Emp_ID
			WHERE GP.For_Date >= @From_date AND GP.For_Date <= @To_Date  AND GP.Actual_Out_Time IS NULL


			Declare @Shift_St_Time varchar(10)
			Declare @Shift_End_Time varchar(10) 
			Declare @Is_Night_Shift tinyint
			
		Declare ShiftCur Cursor for select emp_ID,For_date from #Emp_Shift
		 Open ShiftCur
			Fetch next From ShiftCur into @emp_ID,@For_date
			   while @@fetch_Status = 0
			     begin
							set @Shift_St_Time = ''
							set @Shift_End_Time = ''	
							
							select @Shift_St_Time = isnull(shift_st_Time,''), 
								   @Shift_End_Time = isnull(Shift_End_Time,'') 
							from T0150_EMP_Gate_Pass_INOUT_RECORD WITH (NOLOCK)
							where emp_id = @emp_ID and  for_date = @For_date and Is_Approved = 1
					  
						   If ( @Shift_St_Time = '' or  @Shift_End_Time = '')							
							exec SP_CURR_T0100_EMP_SHIFT_GET @emp_Id,@Cmp_ID,@For_Date,@Shift_St_Time output ,@Shift_End_Time output
							
							if @Shift_St_Time > @Shift_End_Time
								set @Is_Night_Shift = 1
							else
								set @Is_Night_Shift = 0
										
							Update  #Emp_Shift set 
									Shift_st_Time = @Shift_St_Time, 
									Shift_End_Time = @Shift_End_Time ,
									Is_Night_Shift = @Is_Night_Shift
									where Emp_ID = @emp_ID and For_Date = @For_date
					
					Fetch next From ShiftCur into @emp_ID,@For_date
			     end
		close ShiftCur
	    Deallocate ShiftCur     
				
		If @Status = 'P' 
				begin

					select distinct  Tran_ID,EI.Emp_Id,Alpha_Emp_Code,Emp_Full_Name,EI.For_Date,isnull(dbo.F_Return_HHMM(EI.Out_Time),'') as Out_Time,
						case when isnull(EI.In_Time,'') = '' then
									case when Is_Night_Shift = 0 then
											case when cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
												isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
											else
												isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))),'')
											end
									else
										case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(EI.OUT_Time) as datetime)) as Float) * 24.0 < 10 then
												isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
										else
												case when dbo.F_Return_HHMM(EI.OUT_Time) > dbo.F_Return_HHMM(ES.Shift_End_Time) then
													isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))),'')
												else
													isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
												end
										end			
									end 
							else 	
								isnull(dbo.F_Return_HHMM(EI.In_Time),'')
								
							end as In_Time
						,
						--case when Hours = '' or Hours = '00:00'  then 
								
								case when Is_Night_Shift = 0 then
									case when isnull(dbo.F_Return_HHMM(EI.OUT_Time),'') <> '' And isnull(dbo.F_Return_HHMM(EI.In_Time),'') <> '' then
										dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(EI.In_Time),'')  as datetime)))
									when cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
										dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))
									else
										dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))))
									end
								else
							   CASE 
									-- If OUT_Time is greater than In_Time, it means the shift crossed midnight
									WHEN CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME) > CAST(ISNULL(dbo.F_Return_HHMM(EI.In_Time), '') AS DATETIME) THEN
									-- Add 1 day to In_Time, since it's on the next day (midnight crossover)
									dbo.F_Return_Hours(DATEDIFF(s, CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME), DATEADD(d, 1, CAST(ISNULL(dbo.F_Return_HHMM(EI.In_Time), '') AS DATETIME))))
									ELSE
										-- If OUT_Time is less than or equal to In_Time, calculate the difference normally
									dbo.F_Return_Hours(DATEDIFF(s, CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME), CAST(ISNULL(dbo.F_Return_HHMM(EI.In_Time), '') AS DATETIME)))
										--ronakb171224  Bug #31617
										--case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(EI.OUT_Time) as datetime)) as Float) * 24.0 < 10 then
										--	dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),Dateadd(d,1,cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime))))																							
										--else
										--	case when 	cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime) > cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
										--		dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))))								
										--	else
										--		dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))																							
										--	end
											--ronakb171224 Bug #31617
										end
																
								end as Hours
						--	else
						--		Hours
						--	End as Hours
						,isnull(Reason_Name,@Reason_Name) as Reason_Name
						,Exempted,case when isnull(EI.In_Time,'') = '' then  1 else 0 end as Is_Default_Punch 
						,Is_Night_Shift,ES.Shift_St_Time + ' - ' +  ES.Shift_End_Time as Shift_Time,ES.Shift_St_Time,ES.Shift_End_Time,EI.is_Approved
						,EI.App_ID
				from T0150_EMP_Gate_Pass_INOUT_RECORD EI WITH (NOLOCK) Inner join
						T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = EI.Emp_ID Inner join
						#Emp_Shift ES on ES.Emp_Id = EI.emp_id  and ES.For_date = EI.For_date Left Outer join 
						--T0040_Reason_Master RM on RM.Res_Id = EI.Reason_id      ''commented by jimit 28112016 due to reason Id is 0 for some employee (RK)
						(SELECT RM.REASON_NAME,GPAA.EMP_ID,GPAA.APP_ID 
						 FROM	T0100_GATE_PASS_APPLICATION GPAA WITH (NOLOCK) INNER JOIN
								T0120_GATE_PASS_APPROVAL GPA WITH (NOLOCK) ON GPA.APP_ID = GPAA.APP_ID AND GPA.REASON_ID = GPAA.REASON_ID INNER JOIN
								T0040_REASON_MASTER RM WITH (NOLOCK) ON RM.RES_ID = GPA.REASON_ID)Q ON Q.APP_ID = EI.APP_ID 
								
								
				where	EI.For_date >= @From_Date and  EI.For_Date <= @To_date
						and EI.Cmp_ID = @cmp_ID
						and EI.is_Approved = 0 
						
				UNION
					
				select distinct 0 AS Tran_ID,GP.Emp_Id,Alpha_Emp_Code,Emp_Full_Name,GP.For_Date,
							isnull(dbo.F_Return_HHMM(GP.From_Time),'') as Out_Time,
							case when isnull(GP.To_Time,'') = '' then
								case when Is_Night_Shift = 0 then
										case when cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
											isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
										else
											isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime))),'')
										end
								else
									case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(GP.From_Time) as datetime)) as Float) * 24.0 < 10 then
											isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
									else
											case when dbo.F_Return_HHMM(GP.From_Time) > dbo.F_Return_HHMM(ES.Shift_End_Time) then
												isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime))),'')
											else
												isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
											end
									end			
								end 
							else 	
								isnull(dbo.F_Return_HHMM(GP.To_Time),'')
							end as In_Time
							,
							case when Is_Night_Shift = 0 then
								case when isnull(dbo.F_Return_HHMM(GP.From_Time),'') <> '' And isnull(dbo.F_Return_HHMM(GP.To_Time),'') <> '' then
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(GP.To_Time),'')  as datetime)))
								when cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))
								else
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime))))
								end
							else
								case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(GP.From_Time) as datetime)) as Float) * 24.0 < 10 then
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),Dateadd(d,1,cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime))))																							
								else
									case when 	cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime) > cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
										dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime))))								
									else
										dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))																							
									end
								end
							end as Hours
							,isnull(Reason_Name,@Reason_Name) as Reason_Name
							,0 as Exempted,/*case when isnull(GP.To_Time,'') = '' then  1 else 0 end as*/ 2 as Is_Default_Punch 
							,Is_Night_Shift,ES.Shift_St_Time + ' - ' +  ES.Shift_End_Time as Shift_Time,ES.Shift_St_Time,ES.Shift_End_Time,0 /*EI.is_Approved*/
							,GP.App_ID
					from T0120_GATE_PASS_APPROVAL GP WITH (NOLOCK) Inner join
						T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = GP.Emp_ID Inner join
						#Emp_Shift ES on ES.Emp_Id = GP.emp_id  and ES.For_date = GP.For_date Left Outer join 
						T0040_Reason_Master RM WITH (NOLOCK) on RM.Res_Id = GP.Reason_id 
					where  GP.For_date >= @From_Date and  GP.For_Date <= @To_date
						and GP.Cmp_ID = @cmp_ID and GP.Actual_Out_Time IS NULL and Gp.Apr_Status = 'A'
					
					
					order by EM.Alpha_Emp_Code,EI.For_date		
		 		end
		 	
	else if @Status = 'Reg'
		begin
			
				select distinct  Tran_ID,EI.Emp_Id,Alpha_Emp_Code,Emp_Full_Name,EI.For_Date,isnull(dbo.F_Return_HHMM(EI.Out_Time),'') as Out_Time,
				case when isnull(EI.In_Time,'') = '' then
							case when Is_Night_Shift = 0 then
									case when cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
										isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
									else
										isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))),'')
									end
							else
								case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(EI.OUT_Time) as datetime)) as Float) * 24.0 < 10 then
										isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
								else
										case when dbo.F_Return_HHMM(EI.OUT_Time) > dbo.F_Return_HHMM(ES.Shift_End_Time) then
											isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))),'')
										else
											isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
										end
								end			
							end 
					else 	
						isnull(dbo.F_Return_HHMM(EI.In_Time),'')
						
					end as In_Time
				,
				--case when Hours = '' or Hours = '00:00'  then 
				----Ronakb041224----
						CASE 
    WHEN Is_Night_Shift = 0 THEN

        -- Day shift case
        CASE 
            WHEN ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') <> '' AND ISNULL(dbo.F_Return_HHMM(EI.In_Time), '') <> '' THEN
                dbo.F_Return_Hours(DATEDIFF(s, CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME), CAST(ISNULL(dbo.F_Return_HHMM(EI.In_Time), '') AS DATETIME)))
            WHEN CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME) <= CAST(ISNULL(dbo.F_Return_HHMM(ES.Shift_End_Time), '') AS DATETIME) THEN
                dbo.F_Return_Hours(DATEDIFF(s, CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME), CAST(ISNULL(dbo.F_Return_HHMM(ES.Shift_End_Time), '') AS DATETIME)))
            ELSE
                dbo.F_Return_Hours(DATEDIFF(s, CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME), DATEADD(MI, 10, CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME))))
        END
    ELSE
	
        -- Night shift case
       CASE 
    -- If OUT_Time is greater than In_Time, it means the shift crossed midnight
    WHEN CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME) > CAST(ISNULL(dbo.F_Return_HHMM(EI.In_Time), '') AS DATETIME) THEN
        -- Add 1 day to In_Time, since it's on the next day (midnight crossover)
        dbo.F_Return_Hours(DATEDIFF(s, CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME), DATEADD(d, 1, CAST(ISNULL(dbo.F_Return_HHMM(EI.In_Time), '') AS DATETIME))))
    ELSE
        -- If OUT_Time is less than or equal to In_Time, calculate the difference normally
        dbo.F_Return_Hours(DATEDIFF(s, CAST(ISNULL(dbo.F_Return_HHMM(EI.OUT_Time), '') AS DATETIME), CAST(ISNULL(dbo.F_Return_HHMM(EI.In_Time), '') AS DATETIME)))
END
END AS Hours

						--case when Is_Night_Shift = 0 then
						--	case when isnull(dbo.F_Return_HHMM(EI.OUT_Time),'') <> '' And isnull(dbo.F_Return_HHMM(EI.In_Time),'') <> '' then
						--		dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(EI.In_Time),'')  as datetime)))
						--	when cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
						--		dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))
						--	else
						--		dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))))
						--	end
						--else
						--		case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(EI.OUT_Time) as datetime)) as Float) * 24.0 < 10 then
						--			dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),Dateadd(d,1,cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime))))																							
						--		else
						--			case when 	cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime) > cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
						--				dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))))								
						--			else
						--				dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))																							
						--			end
						--		end
														
						--end as Hours
					--else
					--	Hours
					--End as Hours
				,isnull(Reason_Name,@Reason_Name) as Reason_Name
				,Exempted,case when isnull(EI.In_Time,'') = '' then  1 else 0 end as Is_Default_Punch 
				,Is_Night_Shift,ES.Shift_St_Time + ' - ' +  ES.Shift_End_Time as Shift_Time,ES.Shift_St_Time,ES.Shift_End_Time,EI.is_Approved
				,EI.App_ID
				from T0150_EMP_Gate_Pass_INOUT_RECORD EI WITH (NOLOCK) Inner join
				T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = EI.Emp_ID Inner join
				#Emp_Shift ES on ES.Emp_Id = EI.emp_id  and ES.For_date = EI.For_date Left Outer join 
				T0040_Reason_Master RM WITH (NOLOCK) on RM.Res_Id = EI.Reason_id
				where  EI.For_date >= @From_Date and  EI.For_Date <= @To_date
				and EI.Cmp_ID = @cmp_ID
				and EI.is_Approved = 1 
				order by EM.Alpha_Emp_Code,EI.For_date
		end
	else
		begin
			
				select distinct  Tran_ID,EI.Emp_Id,Alpha_Emp_Code,Emp_Full_Name,EI.For_Date,isnull(dbo.F_Return_HHMM(EI.Out_Time),'') as Out_Time,
					case when isnull(EI.In_Time,'') = '' then
								case when Is_Night_Shift = 0 then
										case when cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
											isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
										else
											isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))),'')
										end
								else
									case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(EI.OUT_Time) as datetime)) as Float) * 24.0 < 10 then
											isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
									else
											case when dbo.F_Return_HHMM(EI.OUT_Time) > dbo.F_Return_HHMM(ES.Shift_End_Time) then
												isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))),'')
											else
												isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
											end
									end			
								end 
						else 	
							isnull(dbo.F_Return_HHMM(EI.In_Time),'')
							
						end as In_Time
					,
					--case when Hours = '' or Hours = '00:00'  then 
							
							case when Is_Night_Shift = 0 then
								case when isnull(dbo.F_Return_HHMM(EI.OUT_Time),'') <> '' And isnull(dbo.F_Return_HHMM(EI.In_Time),'') <> '' then
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(EI.In_Time),'')  as datetime)))
								when cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))
								else
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))))
								end
							else
									case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(EI.OUT_Time) as datetime)) as Float) * 24.0 < 10 then
										dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),Dateadd(d,1,cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime))))																							
									else
										case when 	cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime) > cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
											dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime))))								
										else
											dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(EI.OUT_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))																							
										end
									end
															
							end as Hours
						--else
						--	Hours
						--End as Hours
					,isnull(Reason_Name,@Reason_Name) as Reason_Name
					,Exempted,case when isnull(EI.In_Time,'') = '' then  1 else 0 end as Is_Default_Punch 
					,Is_Night_Shift,ES.Shift_St_Time + ' - ' +  ES.Shift_End_Time as Shift_Time,ES.Shift_St_Time,ES.Shift_End_Time,EI.is_Approved
					,EI.App_ID
				from T0150_EMP_Gate_Pass_INOUT_RECORD EI WITH (NOLOCK) Inner join
					T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = EI.Emp_ID Inner join
					#Emp_Shift ES on ES.Emp_Id = EI.emp_id  and ES.For_date = EI.For_date Left Outer join 
					T0040_Reason_Master RM WITH (NOLOCK) on RM.Res_Id = EI.Reason_id
				where  EI.For_date >= @From_Date and  EI.For_Date <= @To_date and EI.Cmp_ID = @cmp_ID
				
				UNION	--Ankit 31052016
					
				select distinct 0 AS Tran_ID,GP.Emp_Id,Alpha_Emp_Code,Emp_Full_Name,GP.For_Date,
							isnull(dbo.F_Return_HHMM(GP.From_Time),'') as Out_Time,
							case when isnull(GP.To_Time,'') = '' then
								case when Is_Night_Shift = 0 then
										case when cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
											isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
										else
											isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime))),'')
										end
								else
									case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(GP.From_Time) as datetime)) as Float) * 24.0 < 10 then
											isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
									else
											case when dbo.F_Return_HHMM(GP.From_Time) > dbo.F_Return_HHMM(ES.Shift_End_Time) then
												isnull(dbo.F_Return_HHMM(Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime))),'')
											else
												isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'') 
											end
									end			
								end 
							else 	
								isnull(dbo.F_Return_HHMM(GP.To_Time),'')
							end as In_Time
							,
							case when Is_Night_Shift = 0 then
								case when isnull(dbo.F_Return_HHMM(GP.From_Time),'') <> '' And isnull(dbo.F_Return_HHMM(GP.To_Time),'') <> '' then
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(GP.To_Time),'')  as datetime)))
								when cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime) <= cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))
								else
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime))))
								end
							else
								case when Cast((cast('23:59' as datetime) - cast(dbo.F_Return_HHMM(GP.From_Time) as datetime)) as Float) * 24.0 < 10 then
									dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),Dateadd(d,1,cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime))))																							
								else
									case when 	cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime) > cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime) then
										dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),Dateadd(MI,10,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime))))								
									else
										dbo.F_Return_Hours(Datediff(s,cast(isnull(dbo.F_Return_HHMM(GP.From_Time),'')  as datetime),cast(isnull(dbo.F_Return_HHMM(ES.Shift_End_Time),'')  as datetime)))																							
									end
								end
							end as Hours
							,isnull(Reason_Name,@Reason_Name) as Reason_Name
							,0 as Exempted,/*case when isnull(GP.To_Time,'') = '' then  1 else 0 end as*/ 2 as Is_Default_Punch 
							,Is_Night_Shift,ES.Shift_St_Time + ' - ' +  ES.Shift_End_Time as Shift_Time,ES.Shift_St_Time,ES.Shift_End_Time,0 /*EI.is_Approved*/
							,GP.App_ID
					from T0120_GATE_PASS_APPROVAL GP WITH (NOLOCK) Inner join
						T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = GP.Emp_ID Inner join
						#Emp_Shift ES on ES.Emp_Id = GP.emp_id  and ES.For_date = GP.For_date Left Outer join 
						T0040_Reason_Master RM WITH (NOLOCK) on RM.Res_Id = GP.Reason_id 
					where  GP.For_date >= @From_Date and  GP.For_Date <= @To_date
						and GP.Cmp_ID = @cmp_ID and GP.Actual_Out_Time IS NULL and Gp.Apr_Status = 'A'
					
				
				order by EM.Alpha_Emp_Code,EI.For_date
		end

	
		
END

