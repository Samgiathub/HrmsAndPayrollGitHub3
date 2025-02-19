
        
        
        
create PROCEDURE [dbo].[SP_RPT_EMP_RECORD_GET_working16112021]        
  @Cmp_ID  numeric        
 ,@From_Date  datetime        
 ,@To_Date  datetime         
 --,@Branch_ID numeric   = 0 --  Comment by nilesh on 06092014        
 --,@Grd_ID  numeric = 0  --  Comment by nilesh on 06092014        
 --,@Dept_ID  numeric  = 0   --  Comment by nilesh on 06092014         
 --,@Desig_ID numeric = 0 --  Comment by nilesh on 06092014         
 ,@Branch_ID  varchar(Max) --  Added by nilesh patel on 06092014        
 --,@Cat_ID  numeric  = 0        
 ,@Cat_ID  varchar(Max)        
 ,@Grd_ID  varchar(Max) --  Added by nilesh patel on 06092014        
 --,@Type_ID  numeric  = 0          
 ,@Type_ID  varchar(Max)         
 ,@Dept_ID  varchar(Max) --  Added by nilesh patel on 06092014        
 ,@Desig_ID  varchar(Max) --  Added by nilesh patel on 06092014        
 ,@Emp_ID  numeric  = 0        
 ,@Constraint varchar(max) = ''        
 ,@New_Join_emp numeric = 0         
 ,@Left_Emp  Numeric = 0        
 ,@Salary_Cycle_id numeric = NULL        
 --,@Salary_Cycle_id  varchar(Max)        
 --,@Segment_Id  numeric = 0   -- Added By Gadriwala Muslim 24072013        
 ,@Segment_Id  varchar(Max) = ''         
 --,@Vertical_Id numeric = 0   -- Added By Gadriwala Muslim 24072013        
 ,@Vertical_Id varchar(Max) = ''          
 --,@SubVertical_Id numeric = 0  -- Added By Gadriwala Muslim 24072013         
 ,@SubVertical_Id varchar(Max) = ''         
 --,@SubBranch_Id numeric = 0   -- Added By Gadriwala Muslim 01082013         
 ,@SubBranch_Id varchar(Max) = ''        
 ,@Report_Type varchar(50) = ''   -- Added By Jignesh Patel 13-Dec-2013         
 ,@PrintEmpName varchar(500) = ''   --Added By Jaina 16-10-2015        
 ,@reportPath    varchar(max) =''   --Added by rohit 19022016        
 ,@Payment_Mode varchar(20) = ''  --added jimit 02062016         
 ,@For_Attendance tinyint = 0   --Added By Jaina 07-09-2016        
 ,@Is_Active tinyint = 0        
 ,@Type varchar(50)=''        
AS        
 SET NOCOUNT ON         
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
 SET ARITHABORT ON        
    -- Comment by nilesh patel on 06092014 -- Start        
 /* if @Salary_Cycle_id = 0        
  set @Salary_Cycle_id =NULL        
        
 if @Branch_ID = 0        
  set @Branch_ID = null        
 if @Cat_ID = 0        
  set @Cat_ID = null        
           
 if @Type_ID = 0        
  set @Type_ID = null        
 if @Dept_ID = 0        
  set @Dept_ID = null        
 if @Grd_ID = 0        
  set @Grd_ID = null        
 if @Emp_ID = 0        
  set @Emp_ID = null        
          
 If @Desig_ID = 0        
  set @Desig_ID = null        
         
 If @Segment_Id = 0   -- Added By Gadriwala Muslim 24072013        
 set @Segment_Id = null        
 If @Vertical_Id = 0   -- Added By Gadriwala Muslim 24072013        
 set @Vertical_Id = null        
 If @SubVertical_Id = 0  -- Added By Gadriwala Muslim 24072013        
 set @SubVertical_Id = null         
 If @SubBranch_Id = 0  -- Added By Gadriwala Muslim 01082013        
 set @SubBranch_Id = null  */         
         
 -- Comment by nilesh patel on 06092014 -- End        
        
  SET @Is_Active = (CASE @Is_Active WHEN 0 THEN 2 WHEN 1 THEN 1 ELSE 0 END)             
        
  DECLARE @Show_Left_Employee_for_Salary AS TINYINT        
          
  SET @Show_Left_Employee_for_Salary = 0        
          
  SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0)         
  FROM T0040_SETTING WITH (NOLOCK)        
  WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'        
        
  --Added By Jaina 07-09-2016 Start        
  DECLARE @Hide_Attendance_For_Fix_Salary TINYINT          
          
  SET @Hide_Attendance_For_Fix_Salary = 0        
          
  IF @For_Attendance  = 1        
  BEGIN        
 SELECT @Hide_Attendance_For_Fix_Salary = ISNULL(Setting_Value,0)         
 FROM T0040_SETTING WITH (NOLOCK)        
 WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Hide Attendance For Fix Salary Employee'        
  END        
  --Added By Jaina 07-09-2016 End          
        
 CREATE TABLE #Emp_Cons         
 (              
   Emp_ID NUMERIC ,             
   Branch_ID NUMERIC,        
   Increment_ID NUMERIC            
 )        
 CREATE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);        
   
-- Added by nilesh patel on 06092014        
IF @Left_Emp = 1 OR @New_Join_emp > 0        
Begin 
	 EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0     
END
ELSE        
BEGIN
	 EXEC SP_EMP_SALARY_Constraint @Cmp_ID, @From_Date,@To_Date,0,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID ,@Desig_ID,@Emp_ID,@Salary_Cycle_id ,@Branch_ID,@Segment_ID,@Vertical_Id,@SubVertical_Id,@subBranch_Id,@Constraint 
	--exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@From_Date,@Branch_ID,'',@Grd_ID,'',@Dept_ID,@Desig_ID,0,'',0,0,'','','','',0,0,0,'0',0,0 --Change By Jaina 1-10-2015   
END
        
    
        
 -- Ankit 09092014 for Same Date Increment        
 -- EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id ,@New_Join_emp,@Left_Emp        
          
-- if @Constraint <> ''        
--  begin        
--   Insert Into #Emp_Cons        
--   Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#')         
--  end        
-- else if @New_Join_emp = 1         
--  begin        
        
--   Insert Into #Emp_Cons              
--   Select distinct emp_id,branch_id,Increment_ID From V_Emp_Cons         
--   Where Cmp_id=@Cmp_ID         
--    and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))              
--    and Branch_ID = isnull(@Branch_ID ,Branch_ID)              
--    and Grd_ID = isnull(@Grd_ID ,Grd_ID)              
--    and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))              
--    and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))              
--    and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))          
--    and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))  -- Added By Gadriwala Muslim 24072013        
--    and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))  -- Added By Gadriwala Muslim 24072013        
--    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013        
--    and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013        
--    and Emp_ID = isnull(@Emp_ID ,Emp_ID)          
--    and Increment_Effective_Date <= @To_Date         
--    and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date        
--   Order by Emp_ID        
              
---- Commented and Added by rohit on 17122013 for polycab issue employee transfer        
--   --Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment        
--   -- Where  Increment_effective_Date <= @to_date Group by emp_ID)        
        
--    Delete From #Emp_Cons Where Increment_ID Not In        
--    (select TI.Increment_ID from t0095_increment TI INNER JOIN        
--    (Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment        
--    Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc        
--    on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID        
--    Where Increment_effective_Date <= @to_date)        
        
---- Ended by rohit on 17122013         
          
--   --Insert Into #Emp_Cons        
--   --select I.Emp_Id from dbo.T0095_Increment I INNER JOIN dbo.T0080_Emp_Master e on i.Emp_ID = E.Emp_ID INNER JOIN         
--   --  ( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment        
--   --  where Increment_Effective_date <= @To_Date        
--   --  and Cmp_ID = @Cmp_ID        
--   --  group by emp_ID  ) Qry on        
--   --  I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date        
--   --Where I.Cmp_ID = @Cmp_ID         
--   --and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))        
--   --and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)        
--   --and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)        
--   --and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))        
--   --and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))        
--   --and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))        
--   --and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)         
--   --and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date        
--  end        
-- else if @Left_Emp = 1         
--  begin        
        
--   Insert Into #Emp_Cons              
--   Select distinct emp_id,branch_id,Increment_ID         
--   From V_Emp_Cons Where Cmp_id=@Cmp_ID         
--    and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))              
--    and Branch_ID = isnull(@Branch_ID ,Branch_ID)              
--    and Grd_ID = isnull(@Grd_ID ,Grd_ID)              
--    and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))              
--    and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))              
--    and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))          
--    and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))    -- Added By Gadriwala Muslim 24072013        
--    and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))   -- Added By Gadriwala Muslim 24072013         
--    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013        
--    and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013        
--    and Emp_ID = isnull(@Emp_ID ,Emp_ID)          
--    and Increment_Effective_Date <= @To_Date         
--    and Left_date >=@From_Date and Left_Date <=@to_Date        
--   Order by Emp_ID        
              
---- Commented and Added by rohit on 17122013 for polycab issue employee transfer        
--   --Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment        
--   -- Where  Increment_effective_Date <= @to_date Group by emp_ID)        
        
--  Delete From #Emp_Cons Where Increment_ID Not In        
--    (select TI.Increment_ID from t0095_increment TI INNER JOIN        
--    (Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment        
--    Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc        
--    on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID        
--    Where Increment_effective_Date <= @to_date)        
---- Commented and Added by rohit on 17122013         
        
--   --Insert Into #Emp_Cons        
        
--   --select I.Emp_Id from dbo.T0095_Increment I INNER JOIN T0100_lefT_emp Le on i.emp_Id = le.emp_ID INNER JOIN         
--   --  ( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment        
--   --  where Increment_Effective_date <= @To_Date        
--   --  and Cmp_ID = @Cmp_ID        
--   --  group by emp_ID  ) Qry on        
--   --  I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date        
--   --Where I.Cmp_ID = @Cmp_ID         
--   --and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
--   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
--   --and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
--   --and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
--   --and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
--   --and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))        
--   --and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)         
--   --and Left_date >=@From_Date and Left_Date <=@to_Date        
--  end          
-- else         
--  begin        
        
--   -- below condition changed by mitesh on 05072013        
--   Insert Into #Emp_Cons              
--        select distinct emp_id,V_Emp_Cons.branch_id,Increment_ID from V_Emp_Cons        
--    INNER JOIN T0040_GENERAL_SETTING g on V_Emp_Cons.branch_id=g.branch_id --Ankit 05032014        
--          LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC        
--       INNER JOIN         
--       (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date        
--       GROUP BY emp_id) Qry        
--       on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC        
--         ON QrySC.eid = V_Emp_Cons.Emp_ID        
--    where         
--       V_Emp_Cons.cmp_id=@Cmp_ID         
--         and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))              
--      and V_Emp_Cons.Branch_ID = isnull(@Branch_ID ,V_Emp_Cons.Branch_ID)              
--      and Grd_ID = isnull(@Grd_ID ,Grd_ID)         
--      and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))              
--      and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))              
--      and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))         
--      and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))          
--      and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       -- Added By Gadriwala Muslim 24072013        
--      and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))  -- Added By Gadriwala Muslim 24072013        
--      and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  -- Added By Gadriwala Muslim 24072013        
--      and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013        
--      and Emp_ID = isnull(@Emp_ID ,Emp_ID)           
--         and Increment_Effective_Date <= @To_Date         
--         and         
--                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )              
--      or ( @To_Date  >= join_Date  and @To_Date <= left_date )              
--      or (Left_date is null and @To_Date >= Join_Date)              
--      or (@To_Date >= left_date  and  @From_Date <= left_date )        
--      --OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)        
--      OR 1=(CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (left_date >= case when (isnull(Sal_St_Date,'')) = ''  then @From_Date  when day(Sal_St_Date) = 1  then @From_Date  else  (cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)) end AND left_date <= case when (isnull(Sal_St_Date,'')) = ''  then @to_date when day(sal_st_date)=1 then @to_date else  dateadd(d,-1,dateadd(m,1,(cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)))) end))  THEN 1 ELSE 0 END) --Ankit 05032014        
--      )         
--      order by Emp_ID        
              
           
        
--    -- Commented and Added by rohit on 17122013 for polycab issue employee transfer        
--   --delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment        
--   -- where  Increment_effective_Date <= @to_date        
--   -- group by emp_ID)        
        
--  Delete From #Emp_Cons Where Increment_ID Not In        
--    (select TI.Increment_ID from t0095_increment TI INNER JOIN        
--    (Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment        
--    Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc        
--    on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID        
--    Where Increment_effective_Date <= @to_date)        
---- Commented and Added by rohit on 17122013         
            
            
--   --Insert Into #Emp_Cons              
--     --   select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons where         
--     --   cmp_id=@Cmp_ID         
--     --    and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))              
--     --and Branch_ID = isnull(@Branch_ID ,Branch_ID)              
--     --and Grd_ID = isnull(@Grd_ID ,Grd_ID)              
--     --and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))              
--     --and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))              
--     --and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))         
--     --and Emp_ID = isnull(@Emp_ID ,Emp_ID)           
--     --   and Increment_Effective_Date <= @To_Date         
--     --   and         
--     --                 ( (@From_Date  >= join_Date  and  @From_Date <= left_date )              
--     -- or ( @To_Date  >= join_Date  and @To_Date <= left_date )              
--     -- or (Left_date is null and @To_Date >= Join_Date)              
--     -- or (@To_Date >= left_date  and  @From_Date <= left_date )        
--     -- OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)        
--     -- )         
--     -- order by Emp_ID        
              
--   --delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment        
--   -- where  Increment_effective_Date <= @to_date        
--   -- group by emp_ID)        
          
--  end        
        
   
 IF @Report_Type =''        
  BEGIN       
 
   IF @Type=''        
   BEGIN     
    
	--SELECT  E.Cmp_ID,I_Q.Emp_Id,I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.Type_ID,I_Q.Bank_ID,I_Q.Inc_Bank_AC_No,I_Q.Payment_Mode,I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.Emp_Fix_Salary
	--,E.Emp_Last_Name,E.Emp_Second_Name, E.Present_Street As Street_1,E.City,E.State,E.Worker_Adult_No,E.Father_Name, E.Emp_Code,E.Alpha_Emp_Code,        
 --     CASE WHEN S.Setting_Value = 1 then   
 --      isnull(E.Initial,'')+' '+E.Emp_First_Name + ' '+ isnull(E.Emp_Second_Name,'') + ' '+ isnull(E.Emp_Last_Name,'')         
 --     ELSE        
 --      E.Emp_First_Name + ' '+ isnull(E.Emp_Second_Name,'') + ' ' + isnull(E.Emp_Last_Name,'')        
 --     End AS Emp_Full_Name,        
 --     Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason        
 --     ,Dm.Dept_Name,Dgm.Desig_Name,Etm.Type_Name,Gm.Grd_Name,BM.Branch_Name,E.Date_of_Join,E.Date_Of_Birth,E.Emp_Mark_Of_Identification,E.Gender,@From_Date as From_Date ,@To_Date as To_Date        
 --     ,Cm.Cmp_Name,Cmp_Address,E.Present_Street,E.Present_State,E.Present_City,E.Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(E.Date_of_bIRTH,getdate()),GETDATE()) AS AGE,        
 --     Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no--,I_Q.Bank_ID,I_Q.Inc_Bank_AC_No        
 --     ,E.Enroll_No 
 --     ,CASE WHEN Is_Terminate = 1 THEN 'Terminated'         
 --        WHEN Is_Death = 1 THEN 'Death'         
 --        WHEN isnull(Is_Retire,0) = 1 THEN 'Retirement'         
 --        WHEN Is_Absconded = 1 THEN 'Absconded'        
 --      ELSE 'Resignation'  END AS Reason_Type
 --     ,DGM.Desig_Dis_No       
 --     ,I_Q.Vertical_ID,I_Q.SubVertical_ID   
 --     ,E.Emp_First_Name   
 --     ,E.Initial 
 --     ,Reason_Name 
 --     ,E.Work_Email        
 --   FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN dbo.T0100_Left_Emp l WITH (NOLOCK) ON E.Emp_ID =  l.Emp_ID INNER JOIN        
 --   ( SELECT distinct I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Qry.Bank_ID,Qry.Inc_Bank_AC_No,I.Payment_Mode,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary         
 --     FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN         
 --     ( SELECT max(T0095_Increment.Increment_Effective_Date) AS Increment_Effective_Date ,
	--	 max(T0095_Increment.Increment_ID)as Increment_ID,max(T0095_Increment.Bank_ID)as Bank_ID,
	--	max(T0095_Increment.Inc_Bank_AC_No)as Inc_Bank_AC_No,
	--	 T0095_Increment.Emp_ID         
 --      FROM dbo.T0095_Increment WITH (NOLOCK) INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON T0095_Increment.Emp_ID = EC.Emp_ID        
 --      WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID        
 --      GROUP BY T0095_Increment.emp_ID          
 --     ) Qry on        
 --     I.Emp_ID = Qry.Emp_ID AND I.Increment_Effective_Date = Qry.Increment_Effective_Date  ) I_Q  ON E.Emp_ID = I_Q.Emp_ID and E.Cmp_ID = @Cmp_ID INNER JOIN        
 --     dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN        
 --     dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN        
 --     dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN        
 --     dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN         
 --     dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN        
 --     dbo.T0050_SubBranch SBM WITH (NOLOCK) ON BM.BRANCH_ID = SBM.SubBranch_ID And BM.Cmp_ID = SBM.Cmp_ID INNER JOIN        
 --     dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID INNER JOIN         
 --     #Emp_Cons EC WITH (NOLOCK) ON E.Emp_ID = EC.Emp_ID INNER JOIN        
 --     T0040_SETTING S WITH (NOLOCK) ON E.Cmp_ID = S.Cmp_ID AND S.Setting_Name='Add initial in employee full name' INNER JOIN         
 --     T0011_Login LO WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id LEFT OUTER JOIN        
 --     T0040_Reason_Master Rm WITH (NOLOCK) ON rm.Res_Id = l.Res_Id         
 --   WHERE E.Cmp_ID = @Cmp_Id         
 --   AND E.Date_Of_Join <= ISNULL(e.Emp_Left_Date , @To_Date)        
 --   AND I_Q.Payment_Mode = (CASE WHEN (@Payment_Mode = '--Select--' or @Payment_Mode = '')        
 --           THEN I_Q.Payment_Mode        
 --           ELSE @Payment_Mode        
 --         END)        
 --   AND (CASE WHEN @Hide_Attendance_For_Fix_Salary = 1 AND I_Q.Emp_Fix_Salary = 1 THEN 1 ELSE 0 END) = 0  --Added By Jaina 07-09-2016                           
 --   AND 1 = (CASE WHEN @Is_Active <> 2 and LO.is_Active = @Is_Active         
 --        THEN 1         
 --        WHEN @Is_Active = 2         
 --        THEN 1         
 --        ELSE 0 END)        
 --   ORDER BY         
 --      CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 THEN        
 --         Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)        
 --        ELSE        
 --         Left(e.Alpha_Emp_Code + Replicate('',21), 20)        
 --        END   
 
 

		SELECT e.Emp_ID, e.Alpha_Emp_Code+'-'+REPLACE(e.Emp_Full_Name,char(39),'') as Emp_Full_Name	
			,RE.Cmp_ID,ER.R_Emp_Id,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID,
			IER.branch_id as Sup_branch_id,IER.Dept_ID as Sup_dept_id,IER.Grd_ID as Sup_Grd_ID
			,IER.DESIG_ID as Sup_DESIG_ID,
			IE.Bank_ID,IE.Inc_Bank_AC_No
			,IE.Payment_Mode
			,IE.Vertical_ID,IE.SubVertical_ID,IE.Emp_Fix_Salary,e.Emp_Last_Name,e.Emp_Second_Name, e.Street_1, e.City, e.State, e.Worker_Adult_No, e.Father_Name, e.Emp_Code, e.Alpha_Emp_Code, e.Emp_Full_Name
			, Left_Date, BME.Comp_Name, BME.Branch_Address, Left_Reason, DME.Dept_Name, DGE.Desig_Name, ETM.Type_Name, GM.Grd_Name, BME.Branch_Name, e.Date_of_Join
			, e.Date_Of_Birth, e.Emp_Mark_Of_Identification, e.Gender, @From_Date as From_Date ,@To_Date as To_Date, Cmp_Name, Cmp_Address, e.Present_Street, e.Present_State
			, e.Present_City, e.Present_Post_Box, left_reason, DATEDIFF(YY,ISNULL(E.Date_of_bIRTH,getdate()),GETDATE()) AS AGE, Nature_of_Business, Cmp_City, Cmp_State_Name, Cmp_PinCode, e.mobile_no, e.Enroll_No, CASE WHEN Is_Terminate = 1 THEN 'Terminated'         
				WHEN Is_Death = 1 THEN 'Death'         
				WHEN isnull(Is_Retire,0) = 1 THEN 'Retirement'         
				WHEN Is_Absconded = 1 THEN 'Absconded'        
				ELSE 'Resignation'  END AS Reason_Type
			, DGE.Desig_Dis_No, e.Vertical_ID, e.SubVertical_ID, e.Emp_First_Name, e.Initial, Reason_Name, e.Work_Email
			FROM T0080_EMP_MASTER E INNER JOIN    
			#Emp_Cons EC ON E.Emp_ID=EC.Emp_ID LEFT OUTER JOIN 
			dbo.T0100_Left_Emp l WITH (NOLOCK) ON E.Emp_ID =  l.Emp_ID left  OUTER JOIN   
			T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID INNER JOIN    
			(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID    
			from T0090_EMP_REPORTING_DETAIL inner JOIN    
			(select max(Effect_Date)Effect_Date,Emp_ID    
			from T0090_EMP_REPORTING_DETAIL    
			where  Effect_Date <= getdate()    
			GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID    
			 
			GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID INNER JOIN    
			T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID Inner JOIN    
			(
				SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,Cat_ID
				,Bank_ID,Inc_Bank_AC_No,I.Payment_Mode,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary   
				FROM T0095_INCREMENT I INNER JOIN    
					(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
					FROM T0095_INCREMENT Inner JOIN    
						(    
							SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
								FROM T0095_INCREMENT  GROUP BY EMP_ID    
						) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
					   
					GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			)IE 
			on ie.Emp_ID = e.Emp_ID 
			inner JOIN    
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
			FROM T0095_INCREMENT I INNER JOIN    
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
			FROM T0095_INCREMENT Inner JOIN    
			(    
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
			FROM T0095_INCREMENT    
			
			GROUP BY EMP_ID    
			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
			
			GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			)IER on IER.Emp_ID = RE.Emp_ID left JOIN    
			T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left JOIN   
			T0040_TYPE_MASTER ETM WITH (NOLOCK) ON Ie.Type_ID = ETM.Type_ID LEFT OUTER JOIN   
			T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN  
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON IE.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
			dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN
			 T0040_Reason_Master Rm WITH (NOLOCK) ON rm.Res_Id = l.Res_Id    LEFT OUTER JOIN
			T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN    
			T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN    
			T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN    
			T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID    
			
   END        
   ELSE        
    IF @Type='Unifrom Cost'        
    BEGIN        
    
     SELECT I_Q.* ,E.Emp_Last_Name,E.Emp_Second_Name, E.Present_Street As Street_1,E.City,E.State,E.Worker_Adult_No,E.Father_Name, E.Emp_Code,E.Alpha_Emp_Code,        
        CASE WHEN S.Setting_Value = 1 then   --Added By Hardik 04/02/2016        
         isnull(E.Initial,'')+' '+E.Emp_First_Name + ' '+ isnull(E.Emp_Second_Name,'') + ' '+ isnull(E.Emp_Last_Name,'')         
        ELSE        
         E.Emp_First_Name + ' '+ isnull(E.Emp_Second_Name,'') + ' ' + isnull(E.Emp_Last_Name,'')        
        End AS Emp_Full_Name,         
        Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason        
        ,Dm.Dept_Name,Dgm.Desig_Name,Etm.Type_Name,Gm.Grd_Name,BM.Branch_Name,E.Date_of_Join,E.Date_Of_Birth,E.Emp_Mark_Of_Identification,E.Gender,@From_Date as From_Date ,@To_Date as To_Date        
        ,Cm.Cmp_Name,Cmp_Address,E.Present_Street,E.Present_State,E.Present_City,E.Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(E.Date_of_bIRTH,getdate()),GETDATE()) AS AGE,        
        Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no--,I_Q.Bank_ID,I_Q.Inc_Bank_AC_No        
        ,E.Enroll_No    --Added By Nimesh 17-07-2015 (To sort by enroll no)        
        ,CASE WHEN Is_Terminate = 1 THEN 'Terminated'         
           WHEN Is_Death = 1 THEN 'Death'         
           WHEN isnull(Is_Retire,0) = 1 THEN 'Retirement'         
           WHEN Is_Absconded = 1 THEN 'Absconded'        
         ELSE 'Resignation'  End AS Reason_Type  --Added By Ramiz on 18/08/2015        
        ,DGM.Desig_Dis_No        --added jimit 21082015        
        ,I_Q.Vertical_ID,I_Q.SubVertical_ID   --Added By Jaina 5-10-2015        
        ,E.Emp_First_Name   --added jimit 09022016        
        ,E.Initial --added by chetan 280817        
        ,Reason_Name --Added By Jimit 25122018        
        ,E.Work_Email        
      FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN dbo.T0100_Left_Emp l WITH (NOLOCK) ON E.Emp_ID =  l.Emp_ID INNER JOIN        
      ( SELECT distinct I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Bank_ID,Inc_Bank_AC_No,I.Payment_Mode,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary         
        FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN         
        ( SELECT max(T0095_Increment.Increment_Effective_Date) AS Increment_ID , T0095_Increment.Emp_ID         
         FROM dbo.T0095_Increment WITH (NOLOCK) INNER JOIN         
              #Emp_Cons EC ON T0095_Increment.Emp_ID = EC.Emp_ID        
         WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID        
        GROUP BY T0095_Increment.emp_ID  ) Qry ON        
        I.Emp_ID = Qry.Emp_ID and I.Increment_Effective_Date = Qry.Increment_ID  ) I_Q ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN        
        dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN        
        dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN        
        dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN        
        dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN         
        dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  INNER JOIN         
        dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID INNER JOIN        
        #Emp_Cons EC WITH (NOLOCK) ON E.Emp_ID = EC.Emp_ID INNER JOIN        
        T0040_SETTING S WITH (NOLOCK) ON E.Cmp_ID = S.Cmp_ID And S.Setting_Name='Add initial in employee full name' --Added Condition by Hardik 04/02/2016                    
        INNER JOIN T0011_Login LO WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id   LEFT OUTER JOIN        
        T0040_Reason_Master Rm WITH (NOLOCK) ON rm.Res_Id = l.Res_Id --Added By Jimit 25122018        
        INNER JOIN T0110_Uniform_Dispatch_Detail UDD WITH (NOLOCK) ON UDD.Emp_ID=EC.Emp_ID         
     WHERE E.Cmp_ID = @Cmp_Id AND (UDD.Dispatch_Date >= @From_Date and UDD.Dispatch_Date <= @To_Date)        
     AND E.Date_Of_Join <= ISNULL(e.Emp_Left_Date , @To_Date) --Added By Ramiz on 20/06/2018        
     AND I_Q.Payment_Mode = (CASE WHEN (@Payment_Mode = '--Select--' or @Payment_Mode = '')        
             THEN I_Q.Payment_Mode        
             ELSE @Payment_Mode        
             END)        
     AND (CASE WHEN @Hide_Attendance_For_Fix_Salary = 1 AND I_Q.Emp_Fix_Salary = 1 THEN 1 ELSE 0 END) = 0  --Added By Jaina 07-09-2016                           
     AND 1 = (CASE WHEN @Is_Active <> 2 and LO.is_Active = @Is_Active THEN 1 WHEN @Is_Active = 2 THEN 1 ELSE 0 END)        
     --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)         
      ORDER BY         
         CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 THEN        
            Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)        
           ELSE        
            Left(e.Alpha_Emp_Code + Replicate('',21), 20)        
           END         
    END        
          
  END        
 ELSE             
  IF @Report_Type = 'ID Card' or @Report_Type='QR Code'        
   BEGIN        
                     
    SELECT I_Q.* ,E.Emp_Last_Name,E.Emp_Second_Name,E.Present_Street AS Street_1,E.City,E.State,        
     E.Zip_Code, CASE WHEN @PrintEmpName = '1'         
          THEN  isnull(E.Initial,'')+' '+E.Emp_First_Name + ' '+ isnull(E.Emp_Second_Name,'')  + ' '+ isnull(E.Emp_Last_Name,'')         
          ELSE        
          E.Emp_First_Name + ' '+ isnull(E.Emp_Second_Name,'') + ' '+ isnull(E.Emp_Last_Name,'')        
          End as Emp_Full_Name,    --Added By Jaina 19-10-2015 End        
    E.Worker_Adult_No,E.Father_Name, E.Enroll_no as Emp_Code,E.Home_Tel_No,isnull(Vertical_Code,'')as Vertical_Code,isnull(Vertical_name,'')as Vertical_name,  
 isnull(Vertical_description,'') as Vertical_description,isnull(SubVertical_Code,'') as SubVertical_Code,isnull(SubVertical_name,'')as SubVertical_name,  
 isnull(SubVertical_description,'') as SubVertical_description,isnull(SubBranch_Description,'') as SubBranch_Description,  
 E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason,Dept_Name,Desig_Name,Type_Name,Grd_Name,  
 Branch_Name,E.Date_of_Join,E.Date_Of_Birth,e.Emp_Mark_Of_Identification,e.Gender,@From_Date as From_Date ,@To_Date as To_Date,Cmp_Name,Cmp_Address,        
    e.Present_Street,        
    e.Present_State,        
    e.Present_City,        
    e.Present_Post_Box,        
    l.left_reason,DATEDIFF(YY,ISNULL(E.Date_of_bIRTH,getdate()),GETDATE()) AS AGE,        
    Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no,E.Image_Name,isnull(e.Blood_Group,'-') as Blood_Group,        
    CAST ( 0 AS VARBINARY(max)) AS Emp_Image        
    ,E.SSN_No --Added by Nimesh 18-Jun-2015 (for PF No)        
    ,ETM.[Type_Name]     ---added jimit 09072015        
    ,Cm.cmp_logo         ---added jimit 12082015        
    ,DGM.Desig_Dis_No,E.Emp_First_Name --added jimit 09022016        
    ,E.Tally_Led_Name        
    ,CAST(@reportPath as varchar(max)) + '\report_image\Rp_' + cast (isnull(E.Tally_Led_ID,0) as varchar) + '.png' as rp_Image        
    ,E.Home_Tel_no as Emergency_No1,E.Mobile_No as Emergency_No2,CM.Cmp_Phone,S.State_Name,cm.CIT_City, --added jimit 29022016        
    Emergency_Contact.Home_Mobile_No        
    ,E.Initial--added by chetan 280817        
    ,E.Tehsil_Wok,CM.Cmp_Email,CM.Cmp_Web        
    ,CAST(0 AS VARBINARY(MAX)) AS Emp_Signature,E.Signature_Image_Name  --added by chetan 08012018        
    ,CAST(0 AS varbinary(max)) As Authorized_Sign, AUS.Signature_Image_Name As Authorized_Sign_ImgName  --Added by Jaina 16-04-2018        
    ,E.UAN_No,E.SIN_No        
    ,BS.Segment_Name        
    ,E.Old_Ref_No        
    ,E.Enroll_No        
    ,E.Work_Email, Manager.R_Emp_ID, EM1.Emp_Full_Name As Manager_Name,CAST(0 AS VARBINARY(MAX)) AS Emp_QR_Code        
    ,E.Street_1 AS PermanentAddress, CM.Cmp_TAN_No as Cmp_RegistrationNo,DGM.Desig_Code,DM.Dept_Code,EM.Home_Mobile_No        
    FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN dbo.T0100_Left_Emp l ON E.Emp_ID =  l.Emp_ID INNER JOIN        
     ( SELECT distinct I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,        
      Type_ID,Vertical_id,SubVertical_id,I.subBranch_ID,I.Segment_ID FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN         
       (   SELECT max(Increment_Effective_Date) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment        
        WHERE Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID        
                
        GROUP BY emp_ID  ) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_Effective_Date = Qry.Increment_ID         
        ) I_Q ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN        
       dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN        
       dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN        
       dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN        
       dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN         
       dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  INNER JOIN         
       dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID INNER JOIN        
	   dbo.T0090_EMP_EMERGENCY_CONTACT_DETAIL EM WITH (NOLOCK) ON E.Emp_ID = EM.Emp_ID INNER JOIN  
       #Emp_Cons EC WITH (NOLOCK) on E.Emp_ID = EC.Emp_ID        
               
       LEFT OUTER JOIN T0040_Vertical_Segment AS VT WITH (NOLOCK) ON VT.Vertical_id = I_Q.Vertical_id        
       LEFT OUTER JOIN T0050_SubVertical AS SVT WITH (NOLOCK)  ON SVT.SubVertical_id = I_Q.SubVertical_id        
       LEFT OUTER JOIN dbo.T0050_SubBranch AS SBM WITH (NOLOCK) ON SBM.BRANCH_ID = BM.BRANCH_ID and sbm.SubBranch_ID = I_Q.subBranch_ID         
       --LEFT JOIN (Select top 1 ECD.Home_Mobile_No,ECD.Home_Tel_No,Cmp_ID,ECD.Emp_ID from T0090_EMP_EMERGENCY_CONTACT_DETAIL ECD INNER JOIN        
       -- #Emp_Cons EC1 On EC1.Emp_ID = ECD.Emp_ID        
       -- where Cmp_ID = @Cmp_Id) ECD On Ecd.Emp_ID = E.Emp_ID and ecd.Cmp_ID = E.Cmp_ID        
         LEFT JOIN        
        T0020_STATE_MASTER S WITH (NOLOCK) ON S.Cmp_ID = Cm.Cmp_Id and s.State_ID = Cm.State_ID LEFT OUTER JOIN        
        (SELECT Min(EMCD.Row_ID) AS Row_Id, EMCD.Emp_ID,EMCD.Home_Mobile_No         
        FROM T0090_EMP_EMERGENCY_CONTACT_DETAIL EMCD WITH (NOLOCK) INNER JOIN         
         (SELECT Min(EMCD.Row_ID) AS Row_Id, EC.Emp_ID        
          FROM T0090_EMP_EMERGENCY_CONTACT_DETAIL EMCD WITH (NOLOCK) INNER JOIN         
          #Emp_Cons EC WITH (NOLOCK) ON EMCD.Emp_ID = EC.Emp_ID GROUP BY EC.Emp_ID) Qry ON EMCD.Row_ID=Qry.Row_Id And EMCD.Emp_ID=Qry.Emp_ID        
        WHERE Cmp_ID=@Cmp_Id GROUP BY EMCD.Emp_ID,EMCD.Home_Mobile_No) Emergency_Contact ON E.Emp_ID= Emergency_Contact.Emp_ID        
        LEFT OUTER JOIN (select top 1 max(AU.Effective_Date)as Effective_date,AU.Emp_ID,AU.Branch_ID,E_Sign.Signature_Image_Name --Added by Jaina 16-04-2018        
             FROM T0095_Authorized_Signature AU WITH (NOLOCK)        
               INNER JOIN #Emp_Cons EC1 WITH (NOLOCK) ON EC1.Branch_ID = AU.Branch_ID        
               INNER JOIN T0080_EMP_MASTER E_Sign WITH (NOLOCK) ON E_Sign.Emp_ID = AU.Emp_ID                        
             GROUP BY AU.Branch_ID,AU.Emp_ID,E_Sign.Signature_Image_Name        
             )as  AUS on AUS.Branch_Id = I_Q.Branch_Id        
       LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) on I_Q.Segment_ID = BS.Segment_ID        
       LEFT OUTER JOIN dbo.fn_getReportingManager(@Cmp_Id,0,@To_Date) Manager On EC.Emp_ID = Manager.Emp_ID        
       LEFT OUTER JOIN T0080_EMP_MASTER EM1 WITH (NOLOCK) ON Manager.R_Emp_ID = EM1.Emp_ID        
    WHERE E.Cmp_ID = @Cmp_Id        
    --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)         
    ORDER BY CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 THEN Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)        
    WHEN IsNumeric(e.Alpha_Emp_Code) = 0 THEN Left(e.Alpha_Emp_Code + Replicate('',21), 20)        
     ELSE e.Alpha_Emp_Code        
    END        
            
           
   END        
           
          
 RETURN 
