
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_CALCULATE_PRESENT_DAYS_REPORT]      
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
 ,@constraint   varchar(max)      
 ,@Return_Record_set numeric =1       
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  
         
Declare @Count   numeric       
Declare @Tmp_Date datetime       
      
set @Tmp_Date = @From_Date      

 Declare @Data table       
   (       
   Emp_Id   numeric ,       
   For_date datetime,     
   WWORKING_HOURS VARCHAR(10),
   OT_HOURS VARCHAR(10),
   EMP_FULL_NAME VARCHAR(100),
   PRESENT_DAYS  numeric(12,1) default 0
  )            
      
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
   Emp_OT_min_Limit numeric(18,2),      
   Emp_OT_max_Limit numeric(18,2),      
   P_days  numeric(12,1) default 0,      
   OT_Sec  numeric(22,2) default 0      
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
     ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)    
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
       
       
       
 select eir.Emp_ID ,for_Date,isnull(datediff(s,in_time,out_time),0) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit)      
 from T0150_emp_inout_Record  EIR WITH (NOLOCK) Inner join @Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join      
  ( select I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit from T0095_Increment  I WITH (NOLOCK) inner join       
  (select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment WITH (NOLOCK)      
   where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and       
     I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID      
 Where cmp_Id= @Cmp_ID      
 and for_Date >=@From_Date and For_Date <=@To_Date      
 
 
      
 	--Add by Nimesh 20 May, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint

  
	SET @Tmp_Date =@From_Date      
	WHILE @Tmp_Date <=@To_Date BEGIN      
		--Updating Default Shift From latest employee shift detail
		UPDATE	#Data      
		SET		Shift_ID   = Q1.Shift_ID,        
				Shift_Type = q1.Shift_type      
		FROM	#Data d inner Join      
				(SELECT		sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail   sd WITH (NOLOCK) inner join      
				(select		MAX(for_Date) for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail WITH (NOLOCK)      
					WHERE	Cmp_Id =@Cmp_ID and shift_Type = 0 and for_Date <=@Tmp_Date group by Emp_ID ,Shift_Id)q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID       
		WHERE	D.For_Date = @tmp_Date       
		

		--Added by Nimesh 22 April, 2015
		--Updating Shift ID From Rotation
		UPDATE	#Data 
		SET		SHIFT_ID=SM.SHIFT_ID,Shift_Type=0
		FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
		WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND
				Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
					FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
						 R_Effective_Date<=@Tmp_Date) AND 
				For_date=@Tmp_Date

		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
		--And Rotation should be assigned to that particular employee
		UPDATE	#Data 
		SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
		FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
				FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
		WHERE	ESD.Emp_ID IN (Select R.R_EmpID FROM #Rotation R
					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
					GROUP BY R.R_EmpID) 
				AND D.For_date=@Tmp_Date

		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
		--And Rotation should not be assigned to that particular employee
		UPDATE	#Data 
		SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
		FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
				FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
		WHERE	IsNull(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (Select R.R_EmpID FROM #Rotation R
					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
					GROUP BY R.R_EmpID) 
				AND D.For_date=@Tmp_Date
		--End Nimesh


		SET		@Tmp_Date = DATEADD(d,1,@tmp_date)      
	END        
      
   /*Commented by Nimesh 20 May, 2015
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

      
 Declare Cur_shift cursor for       
  select sd.Shift_ID ,From_Hour,To_Hour,Minimum_hour,Calculate_days,OT_applicable,Fix_OT_Hours       
    ,Shift_Dur       
  from T0050_shift_detail sd WITH (NOLOCK) inner join       
    T0040_shift_master sm WITH (NOLOCK) on sd.shift_ID= sm.Shift_ID inner join       
     (select distinct Shift_ID from #Data ) q on sm.shift_Id=  q.shift_ID      
  order by sd.shift_Id,From_Hour      
 open cur_shift      
 fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur       
 While @@Fetch_Status=0      
  begin      
   select @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur)      
      
   Update #Data      
   set P_Days = @Calculate_Days      
   Where Duration_in_sec >=( @From_hour * 3600) and Duration_in_sec <= ( @To_Hour * 3600 )      
      and Shift_ID= @shift_ID       
            
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
   fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur       
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


       
   INSERT INTO @Data     
   select OA.EMP_ID,OA.FOR_DATE,CONVERT(decimal(10,2), Duration_in_Sec/3600) as Working_Hour
 ,CONVERT(decimal(10,2), OT_SEc/3600) as OT_Hour,e.EMP_FULL_NAME  from #Data   OA  
 inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID    
     
Where OT_Sec > 0          
     order by For_Date  
        

				update #Data 
				set OT_Sec = 0
				from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID 

      

				update #Data 
				set OT_Sec = isnull(Approved_OT_Sec,0)  * 3600
				from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date 
				
				INSERT INTO @Data
				
				select OA.Emp_ID,Max(For_Date)For_Date,dbo.F_Return_Hours(CONVERT(decimal(10,2), sum(Duration_in_Sec))) 	 as Working_Hour ,dbo.F_Return_Hours(CONVERT(decimal(10,2), sum(OT_SEc))) as OT_Hour ,'TOTAL',sum(P_days) as Present_Days
				From #Data  OA 
				inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID
				inner join  T0040_shift_master SM WITH (NOLOCK) On OA.Shift_ID=SM.Shift_ID inner join   
				T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join  
				 
  
				(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join     
				(select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)   
					where Increment_Effective_date <= @To_Date    
						and Cmp_ID = @Cmp_ID    
						group by emp_ID  ) Qry on    
				I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q     
				on E.Emp_ID = I_Q.Emp_ID  inner join    
				T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
				T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
				T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
				T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN     
				T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID     
    Group by  OA.Emp_Id,E.Emp_Full_Name,E.Emp_Code,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender


SELECT OA.*,E.Emp_Code,OA.EMP_FULL_NAME,SM.Shift_Name,CM.Cmp_Name,CM.Cmp_Address,Branch_Address,Dept_Name,Comp_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender
FROM @Data  OA     
inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID
				inner join  T0040_shift_master SM WITH (NOLOCK) On e.Shift_ID=SM.Shift_ID inner join   
				T0010_company_master CM WITH (NOLOCK) On E.CMP_ID =CM.CMP_ID inner join  
				 
  
				(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join     
				(select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)   
					where Increment_Effective_date <= @To_Date    
						and Cmp_ID = @Cmp_ID    
						group by emp_ID  ) Qry on    
				I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q     
				on E.Emp_ID = I_Q.Emp_ID  inner join    
				T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
				T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
				T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
				T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN     
				T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
				ORDER BY OA.EMP_ID,OA.FOR_DATE,OA.PRESENT_DAYS
RETURN      
      
      
      

