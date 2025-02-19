
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_RPT_EMP_IN_OUT_MUSTER_GET_WITH_DURATION_Daily]
	 @Cmp_ID 		numeric
	,@From_Date		datetime='01-jan-2014' 
	,@To_Date 		datetime='31-jan-2014'
	,@Branch_ID		numeric 
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_For	varchar(10)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	SET @From_Date = CAST(GETDATE()-1 AS varchar(11))
	SET @To_Date = CAST(GETDATE()-1 AS varchar(11))
     
 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
	
	Declare @Total_Second as numeric(18,2) -- Added by Mihir A. 17/05/2012
	
	--Declare @Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into @Emp_Cons(Emp_ID)
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
	--		Insert Into @Emp_Cons(Emp_ID)

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date )
	--	end
	
	--Commented Above Old Code and New Code of Cons Added By Ramiz on 17/10/2018
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )    
   
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint 

	declare @For_Date datetime 
	Declare @Date_Diff numeric 
	Declare @New_To_Date datetime 
	
	
	set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	set @Date_Diff = 35 - ( @Date_Diff)
	set @New_To_Date = @To_Date --dateadd(d,@date_diff,@To_Date)
	
	if	exists (select * from [tempdb].dbo.sysobjects where name like '#Att_Muster' )		
			begin
				drop table #Att_Muster
			end
		
		
	 CREATE TABLE #Att_Muster 
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			Leave_Count	numeric(5,1),
			WO_COHO		varchar(4),
			Status_1_1	varchar(22),
			Status_2_1	varchar(22),
			Status_3_1	varchar(22),
			Status_4_1	varchar(22),
			Second_5_1  numeric(18,0),
			Second_6_1  numeric(18,0),
			Status_7_1	varchar(22),
			Status_1_2	varchar(22),
			Status_2_2	varchar(22),
			Status_3_2	varchar(22),
			Status_4_2	varchar(22),
			Second_5_2  numeric(18,0),
			Second_6_2  numeric(18,0),
			Status_7_2	varchar(22),
			Status_1_3	varchar(22),
			Status_2_3	varchar(22),
			Status_3_3	varchar(22),
			Status_4_3	varchar(22),
			Second_5_3  numeric(18,0),
			Second_6_3  numeric(18,0),
			Status_7_3	varchar(22),
			Status_1_4	varchar(22),
			Status_2_4	varchar(22),
			Status_3_4	varchar(22),
			Status_4_4	varchar(22),
			Second_5_4  numeric(18,0),
			Second_6_4  numeric(18,0),
			Status_7_4	varchar(22),
			Status_1_5	varchar(22),
			Status_2_5	varchar(22),
			Status_3_5	varchar(22),
			Status_4_5	varchar(22),
			Second_5_5  numeric(18,0),
			Second_6_5  numeric(18,0),
			Status_7_5	varchar(22),
			Status_1_6	varchar(22),
			Status_2_6	varchar(22),
			Status_3_6	varchar(22),
			Status_4_6	varchar(22),
			Second_5_6  numeric(18,0),
			Second_6_6  numeric(18,0),
			Status_7_6	varchar(22),
			Status_1_7	varchar(22),
			Status_2_7	varchar(22),
			Status_3_7	varchar(22),
			Status_4_7	varchar(22),
			Second_5_7  numeric(18,0),
			Second_6_7  numeric(18,0),
			Status_7_7	varchar(22),
			Status_1_8	varchar(22),
			Status_2_8	varchar(22),
			Status_3_8	varchar(22),
			Status_4_8	varchar(22),
			Second_5_8  numeric(18,0),
			Second_6_8  numeric(18,0),
			Status_7_8	varchar(22),
			Status_1_9	varchar(22),
			Status_2_9	varchar(22),
			Status_3_9	varchar(22),
			Status_4_9	varchar(22),
			Second_5_9  numeric(18,0),
			Second_6_9  numeric(18,0),
			Status_7_9	varchar(22),
			Status_1_10	varchar(22),
			Status_2_10	varchar(22),
			Status_3_10	varchar(22),
			Status_4_10	varchar(22),
			Second_5_10  numeric(18,0),
			Second_6_10  numeric(18,0),
			Status_7_10	varchar(22),
			Status_1_11	varchar(22),
			Status_2_11	varchar(22),
			Status_3_11	varchar(22),
			Status_4_11	varchar(22),
			Second_5_11  numeric(18,0),
			Second_6_11  numeric(18,0),
			Status_7_11	varchar(22),
			Status_1_12	varchar(22),
			Status_2_12	varchar(22),
			Status_3_12	varchar(22),
			Status_4_12	varchar(22),
			Second_5_12  numeric(18,0),
			Second_6_12  numeric(18,0),
			Status_7_12	varchar(22),
			Status_1_13	varchar(22),
			Status_2_13	varchar(22),
			Status_3_13	varchar(22),
			Status_4_13	varchar(22),
			Second_5_13  numeric(18,0),
			Second_6_13  numeric(18,0),
			Status_7_13	varchar(22),
			Status_1_14	varchar(22),
			Status_2_14	varchar(22),
			Status_3_14	varchar(22),
			Status_4_14	varchar(22),
			Second_5_14  numeric(18,0),
			Second_6_14  numeric(18,0),
			Status_7_14	varchar(22),
			Status_1_15	varchar(22),
			Status_2_15	varchar(22),
			Status_3_15	varchar(22),
			Status_4_15	varchar(22),
			Second_5_15  numeric(18,0),
			Second_6_15  numeric(18,0),
			Status_7_15	varchar(22),
			Status_1_16	varchar(22),
			Status_2_16	varchar(22),
			Status_3_16	varchar(22),
			Status_4_16	varchar(22),
			Second_5_16  numeric(18,0),
			Second_6_16  numeric(18,0),
			Status_7_16	varchar(22),
			Status_1_17	varchar(22),
			Status_2_17	varchar(22),
			Status_3_17	varchar(22),
			Status_4_17	varchar(22),
			Second_5_17  numeric(18,0),
			Second_6_17  numeric(18,0),
			Status_7_17	varchar(22),
			Status_1_18	varchar(22),
			Status_2_18	varchar(22),
			Status_3_18	varchar(22),
			Status_4_18	varchar(22),
			Second_5_18  numeric(18,0),
			Second_6_18  numeric(18,0),
			Status_7_18	varchar(22),
			Status_1_19	varchar(22),
			Status_2_19	varchar(22),
			Status_3_19	varchar(22),
			Status_4_19	varchar(22),
			Second_5_19  numeric(18,0),
			Second_6_19  numeric(18,0),
			Status_7_19	varchar(22),
			Status_1_20	varchar(22),
			Status_2_20	varchar(22),
			Status_3_20	varchar(22),
			Status_4_20	varchar(22),
			Second_5_20  numeric(18,0),
			Second_6_20  numeric(18,0),
			Status_7_20	varchar(22),
			Status_1_21	varchar(22),
			Status_2_21	varchar(22),
			Status_3_21	varchar(22),
			Status_4_21	varchar(22),
			Second_5_21  numeric(18,0),
			Second_6_21  numeric(18,0),
			Status_7_21	varchar(22),
			Status_1_22	varchar(22),
			Status_2_22	varchar(22),
			Status_3_22	varchar(22),
			Status_4_22	varchar(22),
			Second_5_22  numeric(18,0),
			Second_6_22  numeric(18,0),
			Status_7_22	varchar(22),
			Status_1_23	varchar(22),
			Status_2_23	varchar(22),
			Status_3_23	varchar(22),
			Status_4_23	varchar(22),
			Second_5_23  numeric(18,0),
			Second_6_23  numeric(18,0),
			Status_7_23	varchar(22),
			Status_1_24	varchar(22),
			Status_2_24	varchar(22),
			Status_3_24	varchar(22),
			Status_4_24	varchar(22),
			Second_5_24  numeric(18,0),
			Second_6_24  numeric(18,0),
			Status_7_24	varchar(22),
			Status_1_25	varchar(22),
			Status_2_25	varchar(22),
			Status_3_25	varchar(22),
			Status_4_25	varchar(22),
			Second_5_25  numeric(18,0),
			Second_6_25  numeric(18,0),
			Status_7_25	varchar(22),
			Status_1_26	varchar(22),
			Status_2_26	varchar(22),
			Status_3_26	varchar(22),
			Status_4_26	varchar(22),
			Second_5_26  numeric(18,0),
			Second_6_26  numeric(18,0),
			Status_7_26	varchar(22),
			Status_1_27	varchar(22),
			Status_2_27	varchar(22),
			Status_3_27	varchar(22),
			Status_4_27	varchar(22),
			Second_5_27  numeric(18,0),
			Second_6_27  numeric(18,0),
			Status_7_27	varchar(22),
			Status_1_28	varchar(22),
			Status_2_28	varchar(22),
			Status_3_28	varchar(22),
			Status_4_28	varchar(22),
			Second_5_28  numeric(18,0),
			Second_6_28  numeric(18,0),
			Status_7_28	varchar(22),
			Status_1_29	varchar(22),
			Status_2_29	varchar(22),
			Status_3_29	varchar(22),
			Status_4_29	varchar(22),
			Second_5_29  numeric(18,0),
			Second_6_29  numeric(18,0),
			Status_7_29	varchar(22),
			Status_1_30	varchar(22),
			Status_2_30	varchar(22),
			Status_3_30	varchar(22),
			Status_4_30	varchar(22),
			Second_5_30  numeric(18,0),
			Second_6_30  numeric(18,0),
			Status_7_30	varchar(22),
			Status_1_31	varchar(22),
			Status_2_31	varchar(22),
			Status_3_31	varchar(22),
			Status_4_31	varchar(22),
			Second_5_31  numeric(18,0),
			Second_6_31  numeric(18,0),
			Status_7_31	varchar(22),
			Total_Duration varchar(22)
	  )


	CREATE table #Emp_Holiday
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			H_Day		numeric(3,1),
			is_Half_day tinyint
	  )	  

	CREATE table #Emp_Weekoff
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			W_Day		numeric(3,1)
	  )	  
	  
	Declare @Is_Cancel_Holiday  numeric(1,0)
	Declare @Is_Cancel_Weekoff	numeric(1,0)	
	Declare @strHoliday_Date As Varchar(max)
	Declare @StrWeekoff_Date  varchar(max)

	Set @StrHoliday_Date = ''      
	set @StrWeekoff_Date = ''


	insert into #Att_Muster (Emp_ID,Cmp_ID,For_Date)
	select 	Emp_ID ,@Cmp_ID ,@From_date from #Emp_Cons
	
	Declare @Emp_Id_Cur As Numeric(18,0)
	Declare @Branch_Id_Cur As Numeric(18,0)
	
	Declare @Temp_Date datetime
	Declare @count numeric 
	Declare @OutRuchi AS DateTime
	Declare @tmp_InTime DateTime
	Declare @tmp_OutTime DateTime

	declare @Shift_St_Time as varchar(10)      
	declare @Shift_End_Time as varchar(10)      
	declare @Shift_Id as Numeric
	declare @Shift_Dur as varchar(10)
	Declare @Shift_End_DateTime as datetime      
	Declare @Shift_ST_DateTime as datetime			
	declare @Shift_St_Sec as numeric       
	declare @Shift_En_sec as numeric    
	Declare @Temp_Date1 as datetime 
	Declare @Night_Shift as tinyint        

	declare @status_1 varchar(100)
	declare @status_2 varchar(100)
	declare @status_3 varchar(100)
	declare @status_4 varchar(100)
	declare @status_5 varchar(100)
	declare @status_6 varchar(100)
	declare @status_7 varchar(100)
	declare @strQry nvarchar(max)	
		
	Set @Emp_Id_Cur=0
	
	DECLARE Att_Cursor CURSOR FOR 
		SELECT Emp_Id , BRANCH_ID FROM #Emp_Cons
	OPEN Att_Cursor
	FETCH NEXT FROM Att_Cursor INTO @Emp_Id_Cur , @Branch_Id_Cur
	WHILE @@fetch_status = 0
	BEGIN 
		
			--SELECT @Branch_ID = I.Branch_ID FROM T0095_Increment I inner join 
			--	( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment
			--	where Increment_Effective_date <= @To_Date
			--	and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id_Cur
			--	group by emp_ID  ) Qry on
			--	I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			--where Qry.Emp_ID = @Emp_Id_Cur

			SELECT @Is_Cancel_Holiday = isnull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = isnull(Is_Cancel_Weekoff,0)
			FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE cmp_ID = @cmp_ID	and Branch_ID = @Branch_Id_Cur
			and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_Id_Cur and Cmp_ID = @Cmp_ID)


			EXEC dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_Id_Cur,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,0,0,1       
			EXEC dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_Id_Cur,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,0,0,1,@Branch_Id_Cur,@StrWeekoff_Date  	 


		Set @Night_Shift = 0
		set @Temp_Date = @From_Date 
		set @count = 1 
		
		while @Temp_Date <=@To_Date 
			Begin			
				
								
				set @status_1 = 'Status_1_'+ cast(@count as varchar(2))
				set @status_2 = 'Status_2_'+ cast(@count as varchar(2)) 
				set @status_3 = 'Status_3_'+ cast(@count as varchar(2)) 
				set @status_4 = 'Status_4_'+ cast(@count as varchar(2)) 
				set @status_5 = 'Second_5_'+ cast(@count as varchar(2)) 
				set @status_6 = 'Second_6_'+ cast(@count as varchar(2)) 
				set @status_7 = 'Status_7_'+ cast(@count as varchar(2)) 
				
				If @Night_Shift = 0 
					Begin
						set @strQry = 'Update #Att_Muster Set ' + @Status_1 + ' = dbo.F_Return_HHMM(In_time) 
												From #Att_Muster AM inner join 
												( select min(In_Time) In_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
													Where Cmp_ID = ' + cast(@cmp_ID as varchar(10)) + ' and For_Date >= ''' + cast(@Temp_Date as varchar(11)) + ''' and For_Date <= ''' + cast(@Temp_Date as varchar(11)) + '''
													group by Emp_ID ,for_date 
												)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(11))
						--select @strQry
						exec(@strQry)

						Select @tmp_InTime=In_time From #Att_Muster AM inner join 
								( select min(In_Time) In_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
									Where Cmp_ID = @cmp_ID and For_Date>=@Temp_Date and For_Date <=@Temp_Date
									group by Emp_ID ,for_date 
								)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id=@Emp_Id_Cur 

						Select @OutRuchi=Q.Out_Time from #Att_Muster AM Inner Join(select Max(Out_Time)Out_Time,Emp_Id from T0150_EMP_INOUT_RECORD WITH (NOLOCK)			
									Where Cmp_ID = @cmp_ID and For_Date>=@Temp_Date and For_Date <=@Temp_Date And Emp_Id=@Emp_Id_Cur 
									group by Emp_ID ,for_date)q on AM.EMp_Id=Q.Emp_Id

						IF @OutRuchi is NULL
							 Begin								
								-- Update #Att_Muster Set Status_2_1 = 'NULL'
								Print 'NULL'
							End
						Else
							Begin
								If Exists(Select In_Time From #Att_Muster AM  Inner Join(Select IN_Time,Emp_Id From T0150_Emp_Inout_Record WITH (NOLOCK) Where IN_Time>@OutRuchi And For_Date>=@Temp_Date and For_Date <=@Temp_Date And Cmp_Id=@Cmp_Id and Emp_Id=@Emp_Id_Cur group By Emp_ID ,for_date,In_Time) EIR ON Am.Emp_Id=EIR.Emp_Id)
										Begin
												set @strQry =  'Update #Att_Muster
																Set ' + @status_2 + ' = dbo.F_Return_HHMM(OUT_Time)
																From #Att_Muster AM inner join 
																(select Max(IN_Time) OUT_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
																	Where Cmp_ID = ' + Cast(@cmp_ID As varchar(10)) + ' and For_Date >= ''' + cast(@Temp_Date as varchar(11)) + ''' and For_Date <= ''' + cast(@Temp_Date as varchar(11)) + '''
																	group by Emp_ID ,for_date 
																)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
												Exec (@strQry)
												
												select @tmp_OutTime=OUT_Time From #Att_Muster AM inner join 
												(select Max(IN_Time) OUT_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
													Where Cmp_ID = @cmp_ID and For_Date>=@Temp_Date and For_Date <=@Temp_Date
													group by Emp_ID ,for_date 
												)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id=@Emp_Id_Cur 								
										End
									Else	
										Begin
												set @strQry =  'Update #Att_Muster
																Set ' + @status_2 + ' = dbo.F_Return_HHMM(OUT_Time)
																From #Att_Muster AM inner join 
																(select Max(Out_Time) OUT_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
																	Where Cmp_ID = ' + Cast(@cmp_ID As varchar(10)) + ' and For_Date >= ''' + cast(@Temp_Date as varchar(11)) + ''' and For_Date <= ''' + cast(@Temp_Date as varchar(11)) + '''
																	group by Emp_ID ,for_date 
																)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
												Exec (@strQry)
											
											select @tmp_OutTime=OUT_Time From #Att_Muster AM inner join 
											(select Max(Out_Time) OUT_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
												Where Cmp_ID = @cmp_ID and For_Date>=@Temp_Date and For_Date <=@Temp_Date
												group by Emp_ID ,for_date 
											)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id=@Emp_Id_Cur 								
										End
																
							End

							--- Added by Hardik 15/03/2012
							If exists (Select 1 from #Emp_Weekoff EW Where EW.Emp_Id = @Emp_Id_Cur And EW.For_Date = @Temp_Date And W_Day > 0)
								Begin
									set @strQry =  'Update #Att_Muster
									set WO_COHO = ''WO'', ' + @status_3 + ' = ''WO'' 
									Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
									
									Exec (@StrQry)
								End
							--- Added by Hardik 15/03/2012	
							If exists (Select 1 from #Emp_Holiday EH Where EH.Emp_Id = @Emp_Id_Cur And EH.For_Date = @Temp_Date)
								Begin
									set @strQry =  'Update #Att_Muster
									set WO_COHO = ''HO'', ' + @status_3 + ' = ''HO'' 
									Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
									
									Exec (@StrQry)
								End

							Set @strQry = 'Update #Att_Muster
											set ' + @status_3 + ' = Leave_code,
											Leave_Count = Leave_Used
											from #Att_Muster AM inner join T0140_LEAVE_TRANSACTION LT ON AM.EMP_ID = LT.EMP_ID Inner join
											T0040_leave_master lm on lt.leavE_ID = lm.leave_ID 
											AND ''' + cast(@Temp_date as varchar(11)) + ''' = LT.FOR_DATE
											and Day(LT.FOR_DATE)=Day(''' + cast(@Temp_date as varchar(11)) + ''') 
											where LT.Leave_Used  >0 And Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(11))
							Exec (@strqry)

							
							-- ADDED BY MIHIR A. 17052012
							If @OutRuchi is not null
							Begin
								Set @strQry = 'Update #Att_Muster
												set ' + @status_5 + ' = isnull(ROUND(cast((datediff(SECOND,''' + CONVERT(VARCHAR(26), @tmp_InTime, 109) + ''',''' + CONVERT(VARCHAR(26), @tmp_OutTime, 109) + ''')) as numeric(18,2)),2),0)
												where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
								Exec (@strQry)
								
								Set @strQry = 'Update #Att_Muster
												set ' + @status_4 + ' = dbo.F_Return_Hours(' + @status_5 + ') 
												where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
								Exec (@strQry)
								
								set @strQry =  'Update #Att_Muster
																Set ' + @status_6 + ' = Duration1
																From #Att_Muster AM inner join 
																(select sum(dbo.F_Return_Sec(duration)) Duration1,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
																	Where Cmp_ID = ' + Cast(@cmp_ID As varchar(10)) + ' and For_Date >= ''' + cast(@Temp_Date as varchar(11)) + ''' and For_Date <= ''' + cast(@Temp_Date as varchar(11)) + '''
																	group by Emp_ID ,for_date 
																)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
												
												Exec (@strQry)
									set @strQry =  'Update #Att_Muster
																Set ' + @status_7 + ' = dbo.f_return_hours(cast(Duration1 as numeric))
																From #Att_Muster AM inner join 
																(select sum(dbo.F_Return_Sec(duration)) Duration1,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
																	Where Cmp_ID = ' + Cast(@cmp_ID As varchar(10)) + ' and For_Date >= ''' + cast(@Temp_Date as varchar(11)) + ''' and For_Date <= ''' + cast(@Temp_Date as varchar(11)) + '''
																	group by Emp_ID ,for_date 
																)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
												
												Exec (@strQry)
							End
							-- End of ADDED BY MIHIR A. 17052012


								set @strQry =  'Update #Att_Muster
									set WO_COHO = ''AB'', ' + @status_3 + ' = ''AB'' 
									Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10)) +
									' And ' + @Status_1 + ' Is Null' + ' And ' + @Status_2 + ' Is Null' +
									' And ' + @Status_3 + ' Is Null' + ' And ' + @Status_4 + ' = ''00:00''' +
									' And ' + @status_5 + ' Is Null'
									
								Exec (@strqry)

							
							set @tmp_InTime = null
							set @tmp_OutTime = null
						End			
					Else  --- For Night Shift
					Begin
						set @strQry = 'Update #Att_Muster Set ' + @Status_1 + ' = dbo.F_Return_HHMM(In_time) 
												From #Att_Muster AM inner join 
												( select min(In_Time) In_Time ,Emp_Id,''' + cast(@Shift_St_Datetime as varchar(11)) + ''' as For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
													Where Cmp_ID = ' + cast(@cmp_ID as varchar(10)) + ' and In_Time >= Dateadd(hh,-5, ''' + cast(@Shift_St_Datetime as varchar(20)) + ''') and Out_Time <= Dateadd(hh,5,''' + cast(@Shift_End_DateTime as varchar(20)) + ''') 
													group by Emp_ID 
												)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(11))
						--select @strQry
						exec(@strQry)

						Select @tmp_InTime=In_time From #Att_Muster AM inner join 
						( select min(In_Time) In_Time ,Emp_Id,cast(@Shift_St_Datetime as varchar(11))For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
							Where Cmp_ID = @cmp_ID and In_Time>=Dateadd(hh,-5,@Shift_St_Datetime) and Out_Time <=Dateadd(hh,5,@Shift_End_DateTime)
							group by Emp_ID 
						)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id=@Emp_Id_Cur


						Select @OutRuchi=Q.Out_Time from #Att_Muster AM Inner Join(select Max(Out_Time)Out_Time,Emp_Id from T0150_EMP_INOUT_RECORD WITH (NOLOCK)				
									Where Cmp_ID = @cmp_ID and In_Time>=Dateadd(hh,-5,@Shift_St_Datetime) and Out_Time <=Dateadd(hh,5,@Shift_End_DateTime) And Emp_Id=@Emp_Id_Cur 
									group by Emp_ID)q on AM.EMp_Id=Q.Emp_Id

						IF @OutRuchi is NULL
							 Begin								
								-- Update #Att_Muster Set Status_2_1 = 'NULL'
								Print 'NULL'
							End
						Else
							Begin
								If Exists(Select In_Time From #Att_Muster AM  Inner Join(Select IN_Time,Emp_Id From T0150_Emp_Inout_Record WITH (NOLOCK) Where IN_Time>@OutRuchi And For_Date>=@Temp_Date and In_Time <=Dateadd(hh,-5,@Shift_St_Datetime)And Cmp_Id=@Cmp_Id and Emp_Id=@Emp_Id_Cur group By Emp_ID ,for_date,In_Time) EIR ON Am.Emp_Id=EIR.Emp_Id)
										Begin
												set @strQry =  'Update #Att_Muster Set ' + @status_2 + ' = dbo.F_Return_HHMM(In_time) 
																From #Att_Muster AM inner join 
																( select max(In_Time) In_Time ,Emp_Id,''' + cast(@Shift_St_Datetime as varchar(11)) + ''' as For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
																	Where Cmp_ID = ' + cast(@cmp_ID as varchar(10)) + ' and In_Time >= Dateadd(hh,-5, ''' + cast(@Shift_St_Datetime as varchar(20)) + ''') and Out_Time <= Dateadd(hh,5,''' + cast(@Shift_End_DateTime as varchar(20)) + ''') 
																	group by Emp_ID 
																)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(11))

												Exec (@strQry)
												
												select @tmp_OutTime=OUT_Time From #Att_Muster AM inner join 
													(select Max(IN_Time) OUT_Time ,Emp_Id,cast(@Shift_St_Datetime as varchar(11)) For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
														Where Cmp_ID = @cmp_ID and In_Time>=Dateadd(hh,-5,@Shift_St_Datetime) and Out_Time <=Dateadd(hh,5,@Shift_End_DateTime)
														group by Emp_ID 
													)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id=@Emp_Id_Cur 	
										End
									Else	
										Begin
												set @strQry =  'Update #Att_Muster Set ' + @status_2 + ' = dbo.F_Return_HHMM(Out_time) 
																From #Att_Muster AM inner join 
																( select max(Out_Time) Out_Time ,Emp_Id,''' + cast(@Shift_St_Datetime as varchar(11)) + ''' as For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
																	Where Cmp_ID = ' + cast(@cmp_ID as varchar(10)) + ' and In_Time >= Dateadd(hh,-5, ''' + cast(@Shift_St_Datetime as varchar(20)) + ''') and Out_Time <= Dateadd(hh,5,''' + cast(@Shift_End_DateTime as varchar(20)) + ''') 
																	group by Emp_ID 
																)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(11))
												Exec (@strQry)
											
												select @tmp_OutTime=OUT_Time From #Att_Muster AM inner join 
												(select Max(Out_Time) OUT_Time ,Emp_Id,cast(@Shift_St_Datetime as varchar(11))For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
													Where Cmp_ID = @cmp_ID and In_Time>=Dateadd(hh,-5,@Shift_St_Datetime) and Out_Time <=Dateadd(hh,5,@Shift_End_DateTime)
													group by Emp_ID
												)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id=@Emp_Id_Cur 						
										End									
							End

							
							--- Added by Hardik 15/03/2012
							If exists (Select 1 from #Emp_Weekoff EW Where EW.Emp_Id = @Emp_Id_Cur And EW.For_Date = @Temp_Date And W_Day > 0)
								Begin
									set @strQry =  'Update #Att_Muster
									set WO_COHO = ''WO'', ' + @status_3 + ' = ''WO'' 
									Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
									
									Exec (@StrQry)
								End
							--- Added by Hardik 15/03/2012	
							If exists (Select 1 from #Emp_Holiday EH Where EH.Emp_Id = @Emp_Id_Cur And EH.For_Date = @Temp_Date)
								Begin
									set @strQry =  'Update #Att_Muster
									set WO_COHO = ''HO'', ' + @status_3 + ' = ''HO'' 
									Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
									
									Exec (@StrQry)
								End

							Set @strQry = 'Update #Att_Muster
											set ' + @status_3 + ' = Leave_code,
											Leave_Count = Leave_Used
											from #Att_Muster AM inner join T0140_LEAVE_TRANSACTION LT ON AM.EMP_ID = LT.EMP_ID Inner join
											T0040_leave_master lm on lt.leavE_ID = lm.leave_ID 
											AND ''' + cast(@Temp_date as varchar(11)) + ''' = LT.FOR_DATE
											and Day(LT.FOR_DATE)=Day(''' + cast(@Temp_date as varchar(11)) + ''') 
											where LT.Leave_Used  >0 And Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(11))
							Exec (@strqry)

							
							-- ADDED BY MIHIR A. 17052012
							If @OutRuchi is not null
							Begin
								Set @strQry = 'Update #Att_Muster
												set ' + @status_5 + ' = isnull(ROUND(cast((datediff(SECOND,''' + CONVERT(VARCHAR(26), @tmp_InTime, 109) + ''',''' + CONVERT(VARCHAR(26), @tmp_OutTime, 109) + ''')) as numeric(18,2)),2),0)
												where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
								Exec (@strQry)
								
								
								Set @strQry = 'Update #Att_Muster
												set ' + @status_4 + ' = dbo.F_Return_Hours(' + @status_5 + ') 
												where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
								Exec (@strQry)
								
									set @strQry =  'Update #Att_Muster
																Set ' + @status_6 + ' = Duration1 
																From #Att_Muster AM inner join 
																(select sum(dbo.F_Return_Sec(duration)) Duration1,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
																	Where Cmp_ID = ' + Cast(@cmp_ID As varchar(10)) + ' and For_Date >= ''' + cast(@Temp_Date as varchar(11)) + ''' and For_Date <= ''' + cast(@Temp_Date as varchar(11)) + '''
																	group by Emp_ID ,for_date 
																)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
												
												Exec (@strQry)
								
								set @strQry =  'Update #Att_Muster
																Set ' + @status_7 + ' = dbo.f_return_hours(cast(Duration1 as numeric))
																From #Att_Muster AM inner join 
																(select sum(dbo.F_Return_Sec(duration)) Duration1,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
																	Where Cmp_ID = ' + Cast(@cmp_ID As varchar(10)) + ' and For_Date >= ''' + cast(@Temp_Date as varchar(11)) + ''' and For_Date <= ''' + cast(@Temp_Date as varchar(11)) + '''
																	group by Emp_ID ,for_date 
																)q on Am.Emp_ID =q.emp_ID Where Am.Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10))
												
												Exec (@strQry)
								
							End
							-- End of ADDED BY MIHIR A. 17052012

								set @strQry =  'Update #Att_Muster
									set WO_COHO = ''AB'', ' + @status_3 + ' = ''AB'' 
									Where Emp_Id = ' + cast(@Emp_Id_Cur as varchar(10)) +
									' And ' + @Status_1 + ' Is Null' + ' And ' + @Status_2 + ' Is Null' +
									' And ' + @Status_3 + ' Is Null' + ' And ' + @Status_4 + ' = ''00:00''' +
									' And ' + @status_5 + ' Is Null'
									
								Exec (@strqry)

							
							set @tmp_InTime = null
							set @tmp_OutTime = null
						End		----- End for Night Shift	
														
	 																	
				set @Temp_Date = dateadd(d,1,@Temp_date)
				set @count = @count + 1  
			End
	Fetch Next From Att_Cursor INTO @Emp_Id_Cur , @Branch_Id_Cur
	End
	Close Att_Cursor
	Deallocate Att_Cursor

	--Added By Ramiz on 17/10/2018
	UPDATE AM
	SET AM.Total_Duration = dbo.F_Return_Hours(isnull(Second_5_1,0) +ISNULL(Second_5_2,0) +ISNULL(Second_5_3,0) +ISNULL(Second_5_4,0) +ISNULL(Second_5_5,0) +ISNULL(Second_5_6,0) +ISNULL(Second_5_7,0) +ISNULL(Second_5_8,0) +ISNULL(Second_5_9,0) +ISNULL(Second_5_10,0) +ISNULL(Second_5_11,0) +ISNULL(Second_5_12,0) +ISNULL(Second_5_13,0) +ISNULL(Second_5_14,0) +ISNULL(Second_5_15,0) +ISNULL(Second_5_16,0) +ISNULL(Second_5_17,0) +ISNULL(Second_5_18,0) +ISNULL(Second_5_19,0) +ISNULL(Second_5_20,0) +ISNULL(Second_5_21,0) +ISNULL(Second_5_22,0) +ISNULL(Second_5_23,0) +ISNULL(Second_5_24,0) +ISNULL(Second_5_25,0) +ISNULL(Second_5_26,0) +ISNULL(Second_5_27,0) +ISNULL(Second_5_28,0) +ISNULL(Second_5_29,0) +isnull(Second_5_30,0) +isnull(Second_5_31,0)) 	
	FROM #Att_Muster AM
	
	SELECT * FROM #ATT_MUSTER ORDER BY EMP_ID
	
	--This Cursor is Commented By Ramiz and Replaced by Update Query on 17/10/2018
	/*
	-- Added by Mihir A. 18/05/2012	
	Declare @Emp_Id_Cur_1 As Numeric(18,0)
	Set @Emp_Id_Cur_1=0
	
	Declare Att_Cursor_Duration Cursor For 
		Select Emp_Id From #Att_Muster 
	Open Att_Cursor_Duration
	Fetch Next From Att_Cursor_Duration INTO @Emp_Id_Cur_1
	while @@fetch_status = 0
	Begin 
	
		select @Total_Second = (isnull(Second_5_1,0) +ISNULL(Second_5_2,0) +ISNULL(Second_5_3,0) +ISNULL(Second_5_4,0) +ISNULL(Second_5_5,0) +ISNULL(Second_5_6,0) +ISNULL(Second_5_7,0) +ISNULL(Second_5_8,0) +ISNULL(Second_5_9,0) +ISNULL(Second_5_10,0) +ISNULL(Second_5_11,0) +ISNULL(Second_5_12,0) +ISNULL(Second_5_13,0) +ISNULL(Second_5_14,0) +ISNULL(Second_5_15,0) +ISNULL(Second_5_16,0) +ISNULL(Second_5_17,0) +ISNULL(Second_5_18,0) +ISNULL(Second_5_19,0) +ISNULL(Second_5_20,0) +ISNULL(Second_5_21,0) +ISNULL(Second_5_22,0) +ISNULL(Second_5_23,0) +ISNULL(Second_5_24,0) +ISNULL(Second_5_25,0) +ISNULL(Second_5_26,0) +ISNULL(Second_5_27,0) +ISNULL(Second_5_28,0) +ISNULL(Second_5_29,0) +isnull(Second_5_30,0) +isnull(Second_5_31,0)) 
		from #Att_Muster where Emp_Id =@Emp_Id_Cur_1
		
		update #Att_Muster
		set Total_Duration = dbo.F_Return_Hours(@Total_Second)	 
		where Emp_Id =@Emp_Id_Cur_1	
	
	Fetch Next From Att_Cursor_Duration INTO @Emp_Id_Cur_1
	End
	Close Att_Cursor_Duration
	Deallocate Att_Cursor_Duration
	--End of Added by Mihir A. 18/05/2012
	
	select * from #Att_Muster order by Emp_id
	
*/




