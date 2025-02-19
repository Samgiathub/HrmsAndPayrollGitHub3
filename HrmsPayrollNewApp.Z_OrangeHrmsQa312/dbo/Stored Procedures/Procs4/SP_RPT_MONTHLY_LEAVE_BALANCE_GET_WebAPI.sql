    
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[SP_RPT_MONTHLY_LEAVE_BALANCE_GET_WebAPI]    
  @Cmp_ID  NUMERIC    
 ,@From_Date  DateTime    
 ,@To_Date  DateTime    
 ,@Branch_ID  NUMERIC     
 ,@Cat_ID  NUMERIC    
 ,@Grd_ID  NUMERIC    
 ,@Type_ID  NUMERIC     
 ,@Dept_Id  NUMERIC    
 ,@Desig_Id  NUMERIC    
 ,@Emp_ID  NUMERIC    
 ,@Leave_ID  varchar(max) --Commented AND change by Sumit 30092015    
 ,@Constraint varchar(MAX)    
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
 DECLARE @Closing AS NUMERIC(18,1)    
 DECLARE @Opening AS NUMERIC(18,1)    
 DECLARE @Earn AS NUMERIC(18,1)    
 DECLARE @Adj_LMark AS NUMERIC(18,1)    
 DECLARE @Adj_Absent AS NUMERIC(18,1)     
 DECLARE @Total_Adj AS NUMERIC(18,1)    
     
 CREATE TABLE #Emp_Leave_Bal     
 (    
  Cmp_ID   NUMERIC,    
  Emp_ID   NUMERIC,    
  For_Date  DateTime,    
  Leave_Opening NUMERIC(18,2),    
  Leave_Credit NUMERIC(18,2),    
  Leave_Used  NUMERIC(18,2),    
  Leave_Closing NUMERIC(18,2),    
  Leave_ID  NUMERIC,    
  Leave_Type     Varchar(30)    
 )     
    
      
 IF @Branch_ID = 0    
  SET @Branch_ID = NULL    
 IF @Cat_ID = 0    
  SET @Cat_ID  = NULL    
 IF @Type_ID = 0    
  SET @Type_ID = NULL    
 IF @Dept_ID = 0    
  SET @Dept_ID = NULL    
 IF @Grd_ID = 0    
  SET @Grd_ID = NULL    
 IF @Desig_ID = 0    
  SET @Desig_ID = NULL    
 IF @Emp_ID = 0    
  SET @Emp_ID = NULL    
      
      
      
 CREATE TABLE #Emp_Cons    
 (    
  Emp_ID   NUMERIC,    
  Increment_ID NUMERIC,    
  Branch_ID  NUMERIC    
 )    
     
 CREATE TABLE #Leave_ID     
 (    
  Leave_ID NUMERIC,    
  Leave_Type VARCHAR(30) --added By Jimit 05012018     
 )    
 if @Leave_ID<>''    
  Begin    
      
      
   insert into #Leave_ID    
   select cast(data  as numeric),'' from dbo.Split (@Leave_ID,'#')    
       
   update #Leave_ID     
   set Leave_Type = Leave_Bal.Leave_Type    
   From #Leave_ID  LB Inner join      
   (    
    SELECT Leave_type,Leave_ID    
    FROM t0040_LEAVE_MASTER WITH (NOLOCK)    
    WHERE cmp_Id = @Cmp_Id and     
      @To_Date <= (case when Leave_Status = 0 then InActive_Effective_Date else @To_date End)  --Added By Jimit 03082018 only showing Active Leave and for In Active Leave consider Effective Date    
   )Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID      
     
        
      
  End    
 Else    
  Begin    
 INSERT INTO #Leave_ID    
   select Leave_ID,Leave_Type from T0040_LEAVE_MASTER WITH (NOLOCK)    
 WHERE Cmp_ID=@Cmp_ID AND Display_leave_balance=1  --commented jimit 14062016  -- uncomment by Jaina 20-12-2018    
    and @To_Date <= (case when Leave_Status = 0 then InActive_Effective_Date else @To_date End)  --Added By Jimit 03082018 only showing Active Leave and for In Active Leave consider Effective Date       
 ORDER BY Leave_Sorting_No    
     
  End     
      
      
     
 IF @CONSTRAINT  <> ''    
  INSERT INTO #EMP_CONS    
  SELECT E.EMP_ID, I.INCREMENT_ID, I.BRANCH_ID    
  FROM T0095_INCREMENT I WITH (NOLOCK)    
    INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID    
    INNER JOIN (SELECT CAST(DATA AS NUMERIC) AS EMP_ID FROM dbo.Split(@Constraint, '#') T Where Data <> '') T ON E.Emp_ID=T.Emp_ID    
    INNER JOIN (SELECT I1.EMP_ID, MAX(I1.INCREMENT_ID) AS INCREMENT_ID    
       FROM T0095_INCREMENT I1 WITH (NOLOCK)    
         INNER JOIN (SELECT I2.EMP_ID,MAX(I2.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE    
            FROM T0095_INCREMENT I2 WITH (NOLOCK)    
            WHERE I2.INCREMENT_EFFECTIVE_DATE <= @TO_DATE    
            GROUP BY I2.EMP_ID) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE = I2.INCREMENT_EFFECTIVE_DATE    
       GROUP BY I1.EMP_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID    
  WHERE Date_Of_Join < @To_Date AND IsNull(Emp_Left_Date, @To_Date) > @From_Date    
 ELSE    
  INSERT INTO #EMP_CONS    
  SELECT E.EMP_ID, I.INCREMENT_ID, I.BRANCH_ID    
  FROM T0095_INCREMENT I WITH (NOLOCK)    
    INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID        INNER JOIN (SELECT I1.EMP_ID, MAX(I1.INCREMENT_ID) AS INCREMENT_ID    
       FROM T0095_INCREMENT I1 WITH (NOLOCK)    
         INNER JOIN (SELECT I2.EMP_ID,MAX(I2.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE    
            FROM T0095_INCREMENT I2 WITH (NOLOCK)    
            WHERE I2.INCREMENT_EFFECTIVE_DATE <= @TO_DATE    
            GROUP BY I2.EMP_ID) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE = I2.INCREMENT_EFFECTIVE_DATE    
       GROUP BY I1.EMP_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID    
  WHERE Date_Of_Join < @To_Date AND IsNull(Emp_Left_Date, @To_Date) > @From_Date    
    AND I.Cmp_ID = @Cmp_ID AND IsNull(I.Cat_ID,0) = IsNull(@Cat_ID ,IsNull(I.Cat_ID,0))     
    AND I.Branch_ID = IsNull(@Branch_ID ,I.Branch_ID)    
    AND I.Grd_ID = IsNull(@Grd_ID ,I.Grd_ID)    
    AND IsNull(I.Dept_ID,0) = IsNull(@Dept_ID ,IsNull(I.Dept_ID,0))    
    AND IsNull(I.Type_ID,0) = IsNull(@Type_ID ,IsNull(I.Type_ID,0))    
    AND IsNull(I.Desig_ID,0) = IsNull(@Desig_ID ,IsNull(I.Desig_ID,0))    
    AND I.Emp_ID = IsNull(@Emp_ID ,I.Emp_ID)     
      
 INSERT INTO #Emp_Leave_Bal       
 SELECT @Cmp_ID , E.Emp_Id,@From_Date,0,0,0,0,LI.Leave_ID,LI.Leave_Type     
 FROM #EMP_CONS E    
   CROSS JOIN #Leave_ID LI     
       
 -- Added by rohit on 14062016    
 DECLARE @Leave_Bal_Display_FixOpening AS NUMERIC  /*TMS - For Electrothem requirement  (Email Dated :  Apr 12, 2016) --Ankit 12042016 */    
 SELECT @Leave_Bal_Display_FixOpening = Leave_Balance_Display_FixOpening FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE Cmp_Id = @cmp_Id    
  
     
 IF @Leave_Bal_Display_FixOpening = 1 AND EXISTS( SELECT 1 FROM T0011_module_detail WITH (NOLOCK) WHERE module_name = 'Payroll' AND Cmp_id = @Cmp_ID AND module_status = 0 )    
  BEGIN    
   DECLARE @For_Date_temp DateTime    
   SET @For_Date_temp = '01-Jan-' + CAST( YEAR(@From_Date) AS VARCHAR(4)) + ''    
       
    
       
       
    
   update #Emp_Leave_Bal     
   set  Leave_Opening = LT.Leave_Opening    
   From #Emp_Leave_Bal  LB     
     INNER JOIN T0140_LEAVE_TRANSACTION LT ON LB.Emp_ID=LT.Emp_ID AND LB.Leave_ID=LT.Leave_ID    
     INNER JOIN (    
        SELECT EMP_ID, LEAVE_ID, MAX(FOR_DATE) AS FOR_DATE    
        FROM (    
          SELECT LT1.EMP_ID, LT1.LEAVE_ID, MAX(LT1.FOR_DATE) FOR_DATE    
          FROM T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)    
          WHERE LT1.For_Date = @From_Date    
          GROUP BY LT1.EMP_ID, LT1.LEAVE_ID    
          UNION ALL    
          SELECT LT1.EMP_ID, LT1.LEAVE_ID, MAX(LT1.FOR_DATE) FOR_DATE    
          FROM T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)    
          WHERE LT1.For_Date < @From_Date    
          GROUP BY LT1.EMP_ID, LT1.LEAVE_ID    
          ) T    
        GROUP BY EMP_ID, LEAVE_ID    
        ) LT1 ON LT.Emp_ID=LT1.Emp_ID AND LT.For_Date=LT1.FOR_DATE AND LT.Leave_ID=LT1.Leave_ID    
    
         
       
   update #Emp_Leave_Bal     
   set Leave_Credit = Q.Leave_Credit    
   ,leave_used = Q.Leave_used    
   From #Emp_Leave_Bal  LB Inner join      
   ( SELECT Leave_ID, Emp_ID,SUM(IsNull(Leave_Used,0) + IsNull(Leave_Adj_L_Mark,0) ) AS Leave_Used,SUM(Leave_Credit) AS Leave_Credit    
   FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)    
   WHERE (For_Date <= @To_Date) AND YEAR(For_Date) = YEAR(@To_Date)    
   AND (Leave_ID IN (select Leave_ID from #Leave_ID) )    
   GROUP BY Emp_ID, Leave_ID    
   )Q on lb.LEave_ID = Q.LEave_ID AND Lb.emp_ID = Q.Emp_ID    
       
       
    
   update #Emp_Leave_Bal     
   set Leave_Closing = Leave_Credit - Leave_Used    
   From #Emp_Leave_Bal     
       
    
  END      
 ELSE    
  BEGIN    
        
   --update #Emp_Leave_Bal     
   --set Leave_Opening = Leave_Bal.Leave_Closing    
   --From #Emp_Leave_Bal  LB Inner join      
   --( select lt.* From T0140_leave_Transaction LT inner join     
   -- ( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction where For_date <= @From_Date AND Cmp_ID = @Cmp_ID    
   -- AND LEave_ID in (select Leave_ID from #Leave_ID) --= @Leave_ID     
   -- Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID AND lt.For_Date = Q.For_Date AND lt.Leave_ID = Q.LEave_ID    
   -- )Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID AND LB.Emp_ID = leave_Bal.Emp_ID     
    
   --update #Emp_Leave_Bal     
   --set Leave_Opening = leave_Bal.Leave_Opening    
   --From #Emp_Leave_Bal  LB Inner join      
   --( select lt.* From T0140_leave_Transaction LT inner join     
   -- ( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction where For_date >= @From_Date AND Cmp_ID = @Cmp_ID  --Change by Jaina 24-01-2019    
   -- AND LEave_ID in (select Leave_ID from #Leave_ID) --= @Leave_ID     
   -- Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID AND lt.For_Date = Q.For_Date AND lt.Leave_ID = Q.LEave_ID    
   -- )Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID AND LB.Emp_ID = leave_Bal.Emp_ID     
       
   UPDATE #Emp_Leave_Bal SET Leave_Opening = NULL      
    
   update #Emp_Leave_Bal     
   set  Leave_Opening = case when LT1.FOR_DATE = @From_date then  LT.Leave_Opening else Lt.Leave_Closing end    
   From #Emp_Leave_Bal  LB     
     INNER JOIN T0140_LEAVE_TRANSACTION LT ON LB.Emp_ID=LT.Emp_ID AND LB.Leave_ID=LT.Leave_ID    
     INNER JOIN (    
        SELECT EMP_ID, LEAVE_ID, MAX(FOR_DATE) AS FOR_DATE    
        FROM (    
          SELECT LT1.EMP_ID, LT1.LEAVE_ID, MAX(LT1.FOR_DATE) FOR_DATE    
          FROM T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)    
          WHERE LT1.For_Date = @From_Date    
          GROUP BY LT1.EMP_ID, LT1.LEAVE_ID    
          UNION ALL    
          SELECT LT1.EMP_ID, LT1.LEAVE_ID, MAX(LT1.FOR_DATE) FOR_DATE    
          FROM T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)    
          WHERE LT1.For_Date < @From_Date    
          GROUP BY LT1.EMP_ID, LT1.LEAVE_ID              
          ) T    
        GROUP BY EMP_ID, LEAVE_ID    
        ) LT1 ON LT.Emp_ID=LT1.Emp_ID AND LT.For_Date=LT1.FOR_DATE AND LT.Leave_ID=LT1.Leave_ID    
        
   update #Emp_Leave_Bal     
   set  Leave_Opening = IsNull(LT.Leave_Opening,0)    
   From #Emp_Leave_Bal  LB     
     LEFT OUTER JOIN (SELECT  LT.*     
         FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)    
           INNER JOIN (SELECT LT1.EMP_ID, LT1.LEAVE_ID, MIN(LT1.FOR_DATE) FOR_DATE    
              FROM T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)    
              WHERE LT1.For_Date > @From_Date    
              GROUP BY LT1.EMP_ID, LT1.LEAVE_ID              
              ) LT1 ON LT.Emp_ID=LT1.Emp_ID AND LT.For_Date=LT1.FOR_DATE AND LT.Leave_ID=LT1.Leave_ID    
         ) LT ON LB.Emp_ID=LT.Emp_ID AND LB.Leave_ID=LT.Leave_ID    
   WHERE LB.Leave_Opening IS NULL    
    
       
       
   update #Emp_Leave_Bal     
   set Leave_Credit = Q.Leave_Credit    
   From #Emp_Leave_Bal  LB Inner join      
   ( select Emp_ID , Leave_ID ,Sum(Leave_Credit) AS Leave_Credit From T0140_LEave_Transaction WITH (NOLOCK)    
    Where Cmp_ID = @Cmp_ID  and (Leave_Posting IS NULL OR Leave_Posting <> 0) AND LEave_ID in (select Leave_ID from #Leave_ID) --= @Leave_ID    --Change by Jaina 24-01-2019    
    AND For_Date >=@From_date AND For_Date <=@To_Date    
    Group by Emp_ID ,LEave_ID)Q on    
    lb.LEave_ID = Q.LEave_ID AND Lb.emp_ID = Q.Emp_ID    
       
   update #Emp_Leave_Bal     
   set Leave_Used = Q.Leave_Used + Q.Half_Payment_Days + Q.Backdated_Leave + Q.Leave_Adj_L_Mark    
   From #Emp_Leave_Bal  LB Inner join      
   ( select Emp_ID , Leave_ID ,Sum(Leave_Used) AS Leave_Used, Sum(Half_Payment_Days) AS Half_Payment_Days      
      ,IsNull(SUM(BACK_DATED_LEAVE),0) AS BACKDATED_LEAVE --added by jimit 01122016    
      ,IsNull(Sum(Leave_Adj_L_Mark),0) AS Leave_Adj_L_Mark --added by Hardik 15/02/2018 for BMA    
   From T0140_LEave_Transaction WITH (NOLOCK)    
    Where Cmp_ID = @Cmp_ID AND LEave_ID in (select Leave_ID from #Leave_ID) --= @Leave_ID     
    AND For_Date >=@From_date AND For_Date <=@To_Date    
    Group by Emp_ID ,LEave_ID)Q on    
    lb.LEave_ID = Q.LEave_ID AND Lb.emp_ID = Q.Emp_ID    
    
   update #Emp_Leave_Bal     
   set Leave_Closing = leave_Bal.Leave_Closing     
   From #Emp_Leave_Bal  LB Inner join      
   ( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join     
    ( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) WHERE CAST(CAST(For_date AS VARCHAR(11))AS DateTime) <= @To_Date AND Cmp_ID = @Cmp_ID    
    AND LEave_ID in (select Leave_ID from #Leave_ID)--= @Leave_ID     
    Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID AND lt.For_Date = Q.For_Date AND lt.Leave_ID = Q.LEave_ID    
    )Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID AND LB.Emp_ID = leave_Bal.Emp_ID     
        
  end    
    
     
 DECLARE @COMP_OFF_LEAVE_ID  AS NUMERIC    
     
 SELECT @COMP_OFF_LEAVE_ID = leave_id     
 FROM T0040_LEAVE_MASTER WITH (NOLOCK)    
 WHERE Default_Short_Name = 'COMP' and Cmp_ID = @CMP_ID    
     
	 --select * from #Emp_Leave_Bal where LEAVE_ID=@COMP_OFF_LEAVE_ID
 IF EXISTS(SELECT 1 FROM #Emp_Leave_Bal WHERE LEAVE_ID=@COMP_OFF_LEAVE_ID)    
  BEGIN      
  
   --CREATE TABLE #temp_CompOff    
   --(    
   -- Emp_ID   NUMERIC,    
   -- Leave_opening decimal(18,2),    
   -- Leave_Used  decimal(18,2),    
   -- Leave_Closing decimal(18,2),    
   -- Leave_Code  VARCHAR(max),    
   -- Leave_Name  VARCHAR(max),    
   -- Leave_ID  NUMERIC,    
   -- CompOff_String  VARCHAR(max) default NULL -- Added by Gadriwala 18022015    
   --)   
    CREATE TABLE #temp_CompOff            
      (            
    Emp_ID   Numeric,    
    Leave_ID  numeric ,       
    Leave_Code  VARCHAR(max),     
    Leave_Name  VARCHAR(max),       
    Leave_opening decimal(18,2),            
    Leave_Used  decimal(18,2),            
    Leave_Closing decimal(18,2),            
    CompOff_String  VARCHAR(max) default null     
      )       
       
   SET @Constraint = NULL    
   SELECT @Constraint = COALESCE(@Constraint + '#', '') + CAST(EMP_ID AS VARCHAR(10))    
   FROM #EMP_CONS    
     --select @To_Date,@Cmp_ID,@Constraint, @COMP_OFF_LEAVE_ID,2     
   INSERT INTO #temp_CompOff    
   EXEC GET_COMPOFF_DETAILS_ALL @To_Date,@Cmp_ID,@Constraint, @COMP_OFF_LEAVE_ID,2     
     
   UPDATE L    
   SET  Leave_Used = CO.Leave_Used,    
     Leave_opening = CO.leave_opening, --Added by Yogesh on 29-12-2023   
     Leave_Closing = CO.Leave_Closing    
   FROM #Emp_Leave_Bal L     
     INNER JOIN #temp_CompOff CO ON L.EMP_ID=CO.EMP_ID AND L.LEAVE_ID=CO.LEAVE_ID    
   WHERE L.Leave_ID=@COMP_OFF_LEAVE_ID 
   --select * from #Emp_Leave_Bal

  END    
           
    -- select * from #Emp_Leave_Bal
 SELECT el.*,Leave_Name,Emp_Full_Name,Emp_Code,Alpha_Emp_Code,Emp_First_Name,g.Grd_Name,b.BRanch_Address,b.Comp_name    
  ,b.Branch_Name,d.Dept_Name,Desig_Name,Cmp_Name,Cmp_Address     
  ,@From_Date P_From_Date ,@To_Date P_To_Date,b.Branch_ID    
  ,t.type_name    --added jimit 10062015      
  ,dgm.Desig_Dis_No  --added jimit 24082015     
  ,VS.Vertical_Name,SV.SubVertical_Name,SB.SubBranch_Name    
  ,l.Leave_Code    
  ,e.Gender    
 Into #Leave_Balance    
 From #Emp_Leave_Bal el     
 INNER JOIN T0040_LEAVE_MASTER AS l WITH (NOLOCK) on el.Leave_ID = l.Leave_ID     
 INNER JOIN T0080_EMP_MASTER e  WITH (NOLOCK) on el.Emp_ID =e.Emp_ID     
 INNER JOIN     
  (    
  SELECT I.Emp_Id ,I.Grd_ID,I.Branch_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID     
  FROM T0095_Increment I WITH (NOLOCK)    
  INNER JOIN     
     (     
      SELECT max(I2.Increment_ID) AS Increment_ID , I2.Emp_ID from T0095_Increment I2 WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment    
      INNER JOIN (    
         SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID    
         FROM T0095_INCREMENT I3 WITH (NOLOCK)    
         WHERE I3.Increment_Effective_Date <= @To_Date    
         GROUP BY I3.Emp_ID    
         ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID      
      where I2.Increment_Effective_date <= @To_Date    
      AND Cmp_ID = @Cmp_ID    
      group by I2.emp_ID      
     ) Qry on    
     I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID    
  )IQ on el.Emp_ID =iq.Emp_ID     
 INNER JOIN T0040_GRADE_MASTER  g WITH (NOLOCK) on iq.Grd_ID =g.Grd_ID     
 INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LD.Leave_ID = EL.Leave_ID AND LD.Grd_ID = IQ.Grd_ID --ADDED BY RAMIZ ON 13/09/2017    
 INNER JOIN T0030_Branch_Master b WITH (NOLOCK) on iq.Branch_ID = b.Branch_ID     
 LEFT OUTER JOIN  T0040_Department_Master d WITH (NOLOCK) on iq.dept_ID =d.Dept_ID      
 LEFT OUTER JOIN  T0040_TYPE_MASTER t WITH (NOLOCK) ON IQ.Type_ID = t.Type_ID     
 LEFT OUTER JOIN  T0040_Designation_Master dgm WITH (NOLOCK) on iq.desig_ID =dgm.Desig_ID --added jimit 10062015    
 INNER JOIN T0010_Company_master AS CM WITH (NOLOCK) on e.cmp_ID = cm.Cmp_ID     
 LEFT JOIN T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=IQ.vertical_ID    
 LEFT JOIN T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=IQ.SubVertical_ID    
 LEFT JOIN T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=IQ.subBranch_ID    
 ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)     
    
 delete from #Leave_Balance    
 where (Gender = 'M' AND Leave_Type = 'Maternity Leave')    
   or     
    (Gender = 'F' AND Leave_Type = 'Paternity Leave')    
	
 IF OBJECT_ID('tempdb..#LeaveMonthlyBalance') IS NOT NULL    
  BEGIN    
  
   INSERT INTO #LeaveMonthlyBalance    
   SELECT Cmp_ID,Emp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing,Leave_ID,Leave_Type,    
   Leave_Name,Emp_Full_Name,Emp_Code,Alpha_Emp_Code,Emp_First_Name,Grd_Name,Branch_Address,Comp_Name ,Branch_Name,    
   Dept_Name,Desig_Name,Cmp_Name,Cmp_Address,P_From_Date,P_To_Date,Branch_Id,Type_Name,Desig_Dis_No,    
   Vertical_Name,SubVertical_Name,SubBranch_Name,Leave_Code,Gender      
   FROM #Leave_Balance    
  END    
 ELSE    
  BEGIN     
   SELECT * FROM #Leave_Balance    
  END    
 RETURN     
    
    
    