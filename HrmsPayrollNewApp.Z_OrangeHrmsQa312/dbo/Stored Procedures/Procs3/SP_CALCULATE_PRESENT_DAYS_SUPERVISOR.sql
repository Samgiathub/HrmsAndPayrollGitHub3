
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_PRESENT_DAYS_SUPERVISOR]  
  @Cmp_ID    numeric  
 ,@From_Date   datetime  
 ,@To_Date    datetime   
 ,@Branch_ID   numeric  
 ,@Cat_ID    numeric   
 ,@Grd_ID    numeric  
 ,@Type_ID    numeric  
 ,@Dept_ID    numeric  
 ,@Desig_ID    numeric  
 ,@Emp_ID    numeric  
,@R_Emp_Id   numeric
 ,@constraint   varchar(5000)  
 ,@Return_Record_set numeric =1  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
     
Declare @Count   numeric   
Declare @Tmp_Date datetime   
  
set @Tmp_Date = @From_Date  
  
if @Return_Record_set = 1 or @Return_Record_set = 2 or @Return_Record_set =3    
 Begin  
  CREATE table #Data   
   (   
   Emp_Id   numeric ,   
   For_date datetime,  
   Duration_in_sec numeric,  
   Shift_ID numeric ,  
   Shift_Type numeric ,  
   Emp_OT  numeric ,  
   Emp_OT_min_Limit numeric,  
   Emp_OT_max_Limit numeric,  
   P_days  numeric(12,1) default 0,  
   OT_Sec  numeric default 0  
   )  
 end  
  
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
    
 Declare @Emp_Cons Table  
 (  
  Emp_ID numeric  
 )  
   
 if @Constraint <> ''  
  begin  
   Insert Into @Emp_Cons(Emp_ID)  
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')   
  end  
 else  
  begin  
   Insert Into @Emp_Cons(Emp_ID)  
  
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join   
     ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment  WITH (NOLOCK)
     where Increment_Effective_date <= @To_Date  
     and Cmp_ID = @Cmp_ID  
     group by emp_ID  ) Qry on  
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date   
         
   Where Cmp_ID = @Cmp_ID   
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))  
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)  
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)  
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))  
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))  
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
  end  
 Insert into #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit)  
 select eir.Emp_ID ,for_Date,sum(isnull(datediff(s,in_time,out_time),0)) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit)  
 from T0150_emp_inout_Record  EIR WITH (NOLOCK) Inner join @Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join  
  ( select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I WITH (NOLOCK) inner join   
  (select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment WITH (NOLOCK)  
   where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and   
     I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID  left outer join t0090_emp_reporting_detail as erd WITH (NOLOCK) on eir.emp_id= erd.emp_id
 Where eir.cmp_Id= @Cmp_ID 
 and for_Date >=@From_Date and For_Date <=@To_Date  and  erd.R_emp_ID = @R_Emp_Id 
 group by eir.Emp_ID  ,eir.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit  
   
 	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint

 
 set @Tmp_Date =@From_Date  
  
 while @Tmp_Date <=@To_Date  
  begin  
		--Modified by Nimesh 21 May 2015
		UPDATE	#Data  
		SET		Shift_ID   = Q1.Shift_ID,    
				Shift_Type = q1.Shift_type  
		FROM	#Data d inner Join  
				(SELECT		sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail   sd WITH (NOLOCK) inner join  
				(SELECT		MaX(for_Date) for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail WITH (NOLOCK) 
					WHERE	Cmp_Id =@Cmp_ID and shift_Type = 0 and for_Date <=@Tmp_Date 
					GROUP BY Emp_ID ,Shift_Id)q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID   
		WHERE	D.For_Date = @tmp_Date   

		/*Commented by Nimesh 21 May, 2015
   Update #Data  
   set Shift_ID   = Q1.Shift_ID,    
       Shift_Type = q1.Shift_type  
   from #Data d inner Join  
   ( select sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail   sd inner join  
    ( select MaX(for_Date) for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail  
    where Cmp_Id =@Cmp_ID and shift_Type = 1 and for_Date =@Tmp_Date group by Emp_ID ,Shift_Id)q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID   
   Where D.For_Date = @tmp_Date   
		*/
		
		--Added by Nimesh 21 May, 2015
		--Updating Shift ID From Rotation
		UPDATE	#Data 
		SET		SHIFT_ID=SM.SHIFT_ID,Shift_Type=0
		FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
		WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND
				Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
					FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
						 R_Effective_Date<=@Tmp_Date) AND 
				For_date=@Tmp_Date

		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=0 
		--And Rotation should be assigned to that particular employee
		UPDATE	#Data 
		SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
		FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
				FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
		WHERE	ESD.Emp_ID IN (Select R.R_EmpID FROM #Rotation R
					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
					GROUP BY R.R_EmpID) AND D.For_date=@Tmp_Date

		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
		--And Rotation should not be assigned to that particular employee
		UPDATE	#Data 
		SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
		FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
				FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
		WHERE	IsNull(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (Select R.R_EmpID FROM #Rotation R
					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
					GROUP BY R.R_EmpID) AND D.For_date=@Tmp_Date
		--End Nimesh
  
   set @Tmp_Date = dateadd(d,1,@tmp_date)  
  end   
  /*Commented by Nimesh 21 May 2015
 Update #Data  
   set Shift_ID   = Q1.Shift_ID,    
       Shift_Type = q1.Shift_type  
   from #Data d inner Join  
   ( select sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail   sd   
    Where Cmp_ID =@Cmp_ID and Shift_Type =1 and For_Date >=@From_Date and For_Date <=@To_Date )q1 on  
    D.emp_ID = q1.For_Date And d.For_Date =Q1.For_Date  
   */
 Declare @Shift_ID  numeric   
 Declare @From_Hour  numeric(12,3)  
 Declare @To_Hour  numeric(12,3)  
 Declare @Minimum_hour numeric(12,3)  
 Declare @Calculate_days numeric(12,1)  
 Declare @OT_applicable numeric(1)  
 Declare @Fix_OT_Hours numeric(12,3)  
 Declare @Shift_Dur  varchar(10)  
 Declare @Shift_Dur_sec numeric   
 Declare @Fix_W_Hours  numeric(5,2)  
   
   
 Declare Cur_shift cursor for   
  select sd.Shift_ID ,From_Hour,To_Hour,Minimum_hour,Calculate_days,OT_applicable,Fix_OT_Hours   
    ,Shift_Dur ,isnull(Fix_W_Hours,0) as  Fix_W_Hours  
  from T0050_shift_detail sd WITH (NOLOCK) inner join   
    T0040_shift_master sm WITH (NOLOCK) on sd.shift_ID= sm.Shift_ID inner join   
     (select distinct Shift_ID from #Data ) q on sm.shift_Id=  q.shift_ID  
  order by sd.shift_Id,From_Hour  
 open cur_shift  
 fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours   
 While @@Fetch_Status=0  
  begin  
     
    
   select @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur)  
  
   if @Fix_W_Hours > 0   
    begin   
     Update #Data  
     set P_Days = @Calculate_Days, Duration_in_sec = @Fix_W_Hours * 3600  
     Where Duration_in_sec >=( @From_hour * 3600) and Duration_in_sec <= ( @To_Hour * 3600 )  
        and Shift_ID= @shift_ID   
    end  
   else  
    begin  
     Update #Data  
     set P_Days = @Calculate_Days  
     Where Duration_in_sec >=( @From_hour * 3600) and Duration_in_sec <= ( @To_Hour * 3600 )  
        and Shift_ID= @shift_ID   
    end  
        
        
   If @OT_Applicable =1   
    begin  
     if @Fix_OT_Hours > 0   
      begin  
       Update #Data  
       set P_Days = @Calculate_Days,  
        OT_Sec = @Fix_OT_Hours * 3600   
       Where Duration_in_sec >=@From_hour * 3600 and Duration_in_sec <=@To_Hour * 3600   
       and Emp_OT= 1 and Shift_ID= @shift_ID   
      end  
     else if @Minimum_Hour > 0   
      begin  
       Update #Data  
       set P_Days = @Calculate_Days,  
        OT_Sec = Duration_in_sec - @Minimum_Hour * 3600   
       Where Duration_in_sec >=@From_hour * 3600 and Duration_in_sec <=@To_Hour * 3600   
       and Emp_OT= 1 and Shift_ID= @shift_ID   
      end  
     else if @Minimum_Hour = 0   
      begin  
       Update #Data  
       set P_Days = @Calculate_Days,  
        OT_Sec = Duration_in_sec - @Shift_Dur_sec  ,  
        Duration_in_sec= @Shift_Dur_sec  
       Where Duration_in_sec >=@From_hour * 3600 and Duration_in_sec <=@To_Hour * 3600   
       and Emp_OT= 1 and Duration_in_sec > @Shift_Dur_sec  
       and Shift_ID= @shift_ID   
      end        
    end  
   fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours   
  end  
 close cur_Shift  
 Deallocate Cur_Shift   
   
   
 update #Data   
 set OT_Sec = isnull(Approved_OT_Sec,0)  * 3600  
 from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date   
   
     
 Update #Data  
 set OT_Sec = 0   
 where Emp_OT_Min_Limit >= OT_sec and OT_sec >0  
  
 Update #Data  
 set OT_Sec = Emp_OT_Max_Limit  
 where OT_sec  > Emp_OT_Max_Limit  and Emp_OT_Max_Limit > 0 and OT_sec >0  
   
   
   
 if @Return_Record_set =2   
  begin  
    
   select *,CONVERT(decimal(10,2), Duration_in_Sec/3600) as Working_Hour ,CONVERT(decimal(10,2), OT_SEc/3600) as OT_Hour  from #Data   OA  
     inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID   
     inner join T0040_shift_master SM WITH (NOLOCK) on OA.Shift_ID=SM.Shift_ID   
   Where OT_Sec > 0  
     order by For_Date  
     
  end  
    
 else if @Return_Record_set =1   
  begin  
   select *, CONVERT(decimal(10,2), Duration_in_Sec/3600)   as Working_Hour ,CONVERT(decimal(10,2), OT_SEc/3600) as OT_Hour from #Data  OA  
     
      inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
   --order by emp_ID,For_Date  
  end  
 else if @Return_Record_set =3  
  begin  
    update #Data   
    set OT_Sec = 0  
    from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID   
  
    update #Data   
    set OT_Sec = isnull(Approved_OT_Sec,0)  * 3600  
    from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date   
  
    select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, CONVERT(decimal(10,2), sum(Duration_in_Sec)/3600)   as Working_Hour ,CONVERT(decimal(10,2), sum(OT_SEc)/3600) as OT_Hour   
       
    From #Data  OA inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
    Group by OA.emp_ID,E.Emp_Full_Name  
  end    
 else if @Return_Record_set = 4  
  begin  
    update #Data  Set OT_Sec = 0 From #Data    
      
    update #Data   
    set OT_Sec = isnull(Approved_OT_Sec,0)  * 3600  
    from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date   
      
  end  
     
 RETURN  
  
  
  

