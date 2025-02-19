
CREATE PROCEDURE [dbo].[Emp_Export_Master_CTC_For_Upload]      
 @Company_id  numeric      
 ,@From_Date  datetime    
 ,@To_Date   datetime    
 ,@Branch_ID  varchar(max)     
 ,@Grade_ID   varchar(max)    
 ,@Type_ID   varchar(max)    
 ,@Dept_ID   varchar(max)    
 ,@Desig_ID   varchar(max)    
 ,@Emp_ID   numeric    
 ,@Constraint varchar(max)    
 ,@Cat_ID        varchar(max)    
 ,@Order_By  varchar(30) = 'Code' --Added by Jimit 28/9/2015 (To sort by Code/Name/Enroll No)    
 ,@Show_Hidden_Allowance  bit = 1   --Added by Jaina 20-12-2016    
AS      
    
   SET NOCOUNT ON     
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
  SET ARITHABORT ON    
    
 set @Show_Hidden_Allowance = 0      
      
 CREATE TABLE #Emp_Cons     
 (          
  Emp_ID NUMERIC ,         
  Branch_ID NUMERIC,    
  Increment_ID NUMERIC    
 )     
 exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0    
    
    
 CREATE TABLE #CTCMast    
 (    
  Emp_ID   numeric(18,0)    
    ,Branch_id       numeric(18,0)     
    ,Emp_Code  Varchar(30)    
    ,Emp_Name  varchar(250)    
    ,Branch_Name  varchar(250)    
    ,Joining_Date nvarchar(20)    
    ,Increment_Type varchar(250)    
    ,Entry_Type  varchar(250)    
    ,Grade   nvarchar(100)    
    ,Designation  nvarchar(100)    
    ,Department  nvarchar(100)    
    ,Basic_Salary numeric(18,2)    
    ,Gross_Salary numeric(18,2)    
    ,CTC    numeric(18,2)    
    ,Desig_dis_No    numeric(18,0) DEFAULT 0  --added jimit 28/9/2015    
    ,Enroll_No       VARCHAR(50) DEFAULT '' --added jimit 28/9/2015    
    ,Reason_Name     varchar(250) DEFAULT ''    
 ,Band_Name    varchar(100)  
	,Remarks varchar(max)  --added by mansi 12-07-2023
  --,Is_Pradhan_Mantri  bit  
  --   ,Is_1time_PF_Member bit  
    ,Increment_Id Numeric --Hardik 21/03/2018 for Optimization    
 )    
      
  Declare @Columns nvarchar(Max)    
  Set @Columns = '#'    
     
   
  INSERT INTO #CTCMAST       
  SELECT e.Emp_ID,BM.Branch_ID , e.Alpha_Emp_Code,    
  ISNULL(e.EmpName_Alias_Salary,e.Emp_Full_Name),Bm.Branch_Name ,    
  convert(nvarchar,e.Date_Of_Join,103) as Joining_Date,     
  CASE WHEN (SELECT COUNT(INCREMENT_ID) FROM T0095_INCREMENT WITH (NOLOCK) WHERE EMP_ID = E.EMP_ID ) > 1 then 'Increment' Else 'Joining' End,    
  'New',ga.Grd_Name,dnm.Desig_Name,dm.Dept_Name,0,0,0,dnm.Desig_Dis_No,e.Enroll_No,Inc_Qry.Reason_Name,  
  B.BandName,
  inc_qry.Remarks,--added by mansi 12-07-2023
  --I.Is_Pradhan_Mantri,I.Is_1time_PF_Member,  
  Inc_Qry.Increment_ID    
  FROM T0080_EMP_MASTER e WITH (NOLOCK)    
  INNER JOIN    
   (     
    select I.Emp_id,I.Basic_Salary,Branch_ID,Grd_ID,Dept_ID,Desig_Id,TYPE_ID, I.Reason_Name, I.Increment_ID 
	,i.Remarks --added by mansi 12-07-2023
    from T0095_Increment I WITH (NOLOCK)    
     INNER JOIN (SELECT MAX(Increment_Id) AS Increment_ID,i2.Emp_ID      
         FROM T0095_Increment I2 WITH (NOLOCK)    
          INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID    
             FROM T0095_INCREMENT I3 WITH (NOLOCK)    
             WHERE I3.Increment_Effective_Date <= @To_Date And I3.Increment_Type <> 'Transfer' And I3.Increment_Type<> 'Deputation'    
             GROUP BY I3.Emp_ID    
             ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                      
         GROUP BY i2.emp_ID     
        ) Qry     
     ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID    
   )Inc_Qry on E.Emp_ID = Inc_Qry.Emp_ID     
  INNER JOIN #EMP_CONS EC ON E.EMP_ID = EC.EMP_ID    
  INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = I.Increment_ID   
  LEFT OUTER JOIN tblBandMaster B WITH (NOLOCK) ON B.BandId=I.Band_Id  
  LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID    
  LEFT OUTER JOIN T0040_GRADE_MASTER GA WITH (NOLOCK) ON I.GRD_ID = GA.GRD_ID    
  LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID    
  LEFT OUTER JOIN T0040_DESIGNATION_MASTER DNM WITH (NOLOCK) ON I.DESIG_ID = DNM.DESIG_ID    
     
  
  
  UPDATE #CTCMAST     
  SET Joining_Date = convert(nvarchar,i.Increment_Effective_Date,106), Basic_Salary = i.Basic_Salary , Gross_Salary=i.Gross_Salary , CTC = i.CTC     
  FROM #CTCMast C     
  INNER JOIN #EMP_CONS EC ON EC.EMP_ID = C.EMP_ID     
  INNER JOIN T0095_INCREMENT I ON C.EMP_ID = I.EMP_ID and EC.Increment_ID = I.Increment_ID     
  --INNER JOIN     
  -- (     
  --  SELECT max(Increment_Id) as Increment_Id , Emp_ID     
  --  FROM T0095_Increment    
  --  WHERE Increment_Effective_date <= @To_Date and cmp_id = @Company_id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'    
  --  GROUP BY emp_ID    
  -- ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
    
  


 -- Added by rohit on 31052016    
 Create table #Tbl_Get_AD    
 (    
  Emp_ID numeric(18,0),    
  Ad_ID numeric(18,0),    
  for_date datetime,    
  E_Ad_Percentage numeric(18,5),    
  E_Ad_Amount numeric(18,2)    
      
 )    
 INSERT INTO #Tbl_Get_AD    
 EXEC dbo.P_Emp_Revised_Allowance_Get @Company_id,@to_date,@Constraint    
 -- Ended by rohit on 31052016    
    
 DECLARE @AD_NAME_DYN nvarchar(100)    
     
 --- Modify Jignesh 30-Dec-2019----    
 --DECLARE @val nvarchar(500)    
 DECLARE @val nvarchar(4000)    
     
 DECLARE Allow_Dedu_Cursor CURSOR FOR    
  select AD_NAME from T0050_AD_MASTER WITH (NOLOCK)    
  where Cmp_id = @Company_id and AD_active = 1     
    AND ((CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND AD_NOT_EFFECT_SALARY = 1 AND Hide_In_Reports = 1  THEN 0 ELSE 1 END) = 1  )--Added by Jaina 21-12-2016    
    --OR (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND AD_NOT_EFFECT_SALARY = 1 AND Hide_In_Reports = 1 AND AD_PART_OF_CTC=1  THEN 1 ELSE 0 END) = 1)    
  order by AD_Level    
 OPEN Allow_Dedu_Cursor    
   fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN    
   while @@fetch_status = 0    
    Begin    
       
     Set @val = 'Alter table   #CTCMast Add ' + '[' + @AD_NAME_DYN + ']' + ' numeric(18,2) default 0'    
    
     exec (@val)     
     Set @val = ''    
         
     --Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'    
     Set @Columns = @Columns + rtrim(ltrim(@AD_NAME_DYN)) + '#'    
    fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN    
    End    
 close Allow_Dedu_Cursor     
 deallocate Allow_Dedu_Cursor    
     
     
    
  
 Declare @CTC_CMP_ID numeric(18,0)    
 Declare @CTC_EMP_ID numeric(18,0)    
 Declare @CTC_BASIC numeric(18,2)    
 DECLARE @Increment_ID NUMERIC(18,0)    
 SET @Increment_ID  = 0    
    
--Commented by Hardik 21/03/2018 for Optimization, Added New Code Below side    
/*     
 Declare CTC_UPDATE CURSOR FOR    
  select Emp_Id,Basic from #CTCMast    
 OPEN CTC_UPDATE    
 fetch next from CTC_UPDATE into @CTC_EMP_ID,@CTC_BASIC    
 while @@fetch_status = 0    
  Begin     
    
    
   Declare @CTC_COLUMNS nvarchar(100)    
   Declare @CTC_GROSS numeric(18,2)    
   Declare @Total_Ear numeric(18,2)    
   Declare @Total_Ded numeric(18,2)    
   Declare @CTC_AD_FLAG varchar(1)    
    
   Set @CTC_GROSS = 0    
   Set @Total_Ear = 0    
   Set @Total_Ded = 0    
       
   Declare @Inc_ID  numeric    
   Declare @Allow_Amount numeric(18,2)    
   Declare @Allow_Percentage numeric(18,2)    
   Declare @Ad_Mode varchar(6)    
   Declare @date as datetime    
       
   set @Inc_Id = 0       
       
   select @Inc_Id=MAX(INCREMENT_ID) from T0095_INCREMENT where EMP_ID = @CTC_EMP_ID     
    and Increment_Effective_Date <= @To_Date and (Increment_Type <> 'transfer' and Increment_Type <> 'Deputation')    
   select @date = Increment_Effective_Date from T0095_INCREMENT where Increment_ID = @Inc_Id    
    
   Declare CRU_COLUMNS CURSOR FOR    
    Select data from Split(@Columns,'#') where data <> ''    
   OPEN CRU_COLUMNS    
     fetch next from CRU_COLUMNS into @CTC_COLUMNS    
     while @@fetch_status = 0    
      Begin           
        if @Inc_ID > 0    
        begin    
              
          --Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','
  
_'),'__','_'),'__','_')    
      
          set @Allow_Amount =0     
          set @Allow_Percentage =0     
          set @Ad_Mode =''     
          set @CTC_AD_FLAG = ''    
              
          SELECT @Allow_Amount=E_AD_AMOUNT,@Allow_Percentage = E_AD_PERCENTAGE ,@Ad_Mode = E_Ad_Mode ,@CTC_AD_FLAG=E_AD_FLAG     
          FROM T0100_EMP_EARN_DEDUCTION  DED    
           INNER JOIN T0050_AD_MASTER ad on ded.AD_Id = ad.AD_Id    
          WHERE  ad.Ad_Name = @CTC_COLUMNS and ded.EMP_ID = @CTC_EMP_ID and ded.INCREMENT_ID = @Inc_Id     
              
          /*    
          --Commented By Ramiz on 29/01/2018. If Allowance Added from Revised , then mode was coming Blank--    
          SELECT @Allow_Amount = Isnull(E_AD_AMOUNT,0),@Allow_Percentage = E_ad_Percentage    
          FROM #Tbl_Get_AD  ED    
           INNER JOIN T0050_AD_MASTER ad on ED.AD_Id = ad.AD_Id    
          WHERE  ad.Ad_Name = @CTC_COLUMNS and ED.EMP_ID = @CTC_EMP_ID and cmp_id = @Company_id    
          */    
          --Added By Ramiz on 29/01/2018--    
          SELECT @Allow_Amount = Isnull(ed.E_Ad_Amount,0),@Allow_Percentage = ed.E_Ad_Percentage ,     
            @Ad_Mode = eed.E_AD_MODE , @CTC_AD_FLAG = eed.E_AD_FLAG    
          FROM #Tbl_Get_AD  ED    
           INNER JOIN T0050_AD_MASTER AD ON ED.AD_ID = AD.AD_ID    
           INNER JOIN T0110_EMP_EARN_DEDUCTION_REVISED EED ON EED.AD_ID = ED.AD_ID AND EED.FOR_DATE = ED.FOR_DATE    
          WHERE  AD.AD_NAME = @CTC_COLUMNS    
          and ED.EMP_ID = @CTC_EMP_ID AND AD.CMP_ID = @COMPANY_ID AND EED.INCREMENT_ID = @INC_ID    
                 
          IF @Ad_Mode = '%'    
           BEGIN    
            Set @val = 'update  #CTCMast set ' + '[' + @CTC_COLUMNS + ']' + ' = ' + convert(nvarchar,isnull(@Allow_Percentage,0)) + ' where #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)    
           END    
          ELSE IF @Ad_Mode = 'AMT'    
           BEGIN    
            Set @val = 'update   #CTCMast set ' + '[' + @CTC_COLUMNS + ']' + ' = ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)     
           END    
            
            EXEC (@val)               
                
          Set @Allow_Amount = 0    
          set @Allow_Percentage = 0    
              
        END    
       FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS    
      END    
   CLOSE CRU_COLUMNS     
   DEALLOCATE CRU_COLUMNS    
  FETCH NEXT FROM CTC_UPDATE INTO @CTC_EMP_ID,@CTC_BASIC    
   END    
 CLOSE CTC_UPDATE     
 DEALLOCATE CTC_UPDATE    
 ----------------------------------------------------------------    
 */    
   --- Modify Jignesh 30-Dec-2019--    
   --Declare @CTC_COLUMNS nvarchar(100)    
   Declare @CTC_COLUMNS nvarchar(1000)    
       
       
   Declare CRU_COLUMNS CURSOR FOR    
    Select data from Split(@Columns,'#') where data <> ''    
   OPEN CRU_COLUMNS    
   fetch next from CRU_COLUMNS into @CTC_COLUMNS    
   while @@fetch_status = 0    
    Begin           
      Set @val = 'update  CTC set ' + '[' + @CTC_COLUMNS + ']' + ' = Case When DED.E_AD_MODE= ''%'' Then  isnull(ED.E_Ad_Percentage,0) Else isnull(ED.E_Ad_Amount,0) End    
         From #CTCMast CTC Inner Join     
         #Tbl_Get_AD ED On CTC.Emp_Id=ED.Emp_Id INNER JOIN     
         T0100_EMP_EARN_DEDUCTION  DED On ED.AD_Id=DED.AD_ID     
         And DED.Increment_Id= CTC.Increment_Id     
         And DED.Emp_id = CTC.Emp_Id     
         Inner Join    
         T0050_AD_MASTER AD ON ED.AD_ID = AD.AD_ID And AD.AD_NAME =''' + @CTC_COLUMNS + ''''    
    
      EXEC (@val)     
    
      Set @val = 'update  CTC set ' + '[' + @CTC_COLUMNS + ']' + ' = Case When DED.E_AD_MODE= ''%'' Then  isnull(ED.E_Ad_Percentage,0) Else isnull(ED.E_Ad_Amount,0) End    
         From #CTCMast CTC Inner Join     
         #Tbl_Get_AD ED On CTC.Emp_Id=ED.Emp_Id INNER JOIN     
         T0110_EMP_EARN_DEDUCTION_REVISED  DED On ED.AD_Id=DED.AD_ID     
         And DED.Increment_Id= CTC.Increment_Id     
         And DED.Emp_id = CTC.Emp_Id     
         Inner Join    
         T0050_AD_MASTER AD ON ED.AD_ID = AD.AD_ID And AD.AD_NAME =''' + @CTC_COLUMNS + ''''    
    
      EXEC (@val)     
    
    
     fetch next from CRU_COLUMNS into @CTC_COLUMNS    
    END    
    
 --Added by Hardik 21/03/2018 for Optimization    
 ALTER TABLE #CTCMast    
 DROP COLUMN Increment_Id    
     
 Update #CTCMast set Emp_Code = '="' + Emp_Code + '"'  --added jimit 01102015    
     
 SELECT * FROM #CTCMAST      
 ORDER BY CASE WHEN @Order_By ='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(#CTCMast.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start    
       WHEN @Order_By='Name' THEN #CTCMast.Emp_Name    
       When @Order_By = 'Designation' then (CASE WHEN #CTCMast.Desig_dis_No  = 0 THEN #CTCMast.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(#CTCMast.Desig_dis_No AS VARCHAR), 21)   END)       
       ---ELSE RIGHT(REPLICATE(N' ', 500) + #CTCMast.Emp_Code, 500)     
      End,Case When IsNumeric(Replace(Replace(#CTCMast.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(#CTCMast.Emp_Code,'="',''),'"',''), 20)    
         When IsNumeric(Replace(Replace(#CTCMast.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(#CTCMast.Emp_Code,'="',''),'"','') + Replicate('',21), 20)    
         Else Replace(Replace(#CTCMast.Emp_Code,'="',''),'"','') End     
      --RIGHT(REPLICATE(N' ', 500) + #CTCMast.Emp_Code, 500)     
     
     
     
Return    
    
    
    
