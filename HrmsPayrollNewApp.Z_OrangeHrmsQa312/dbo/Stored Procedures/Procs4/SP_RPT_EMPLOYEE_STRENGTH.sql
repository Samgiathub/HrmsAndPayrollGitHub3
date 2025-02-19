      
CREATE PROCEDURE [dbo].[SP_RPT_EMPLOYEE_STRENGTH]      
 @Cmp_Id as numeric(18,0)      
 ,@From_Date as datetime      
 ,@To_Date as datetime      
 --,@Branch_ID as numeric(18,0) Comment By nilesh patel      
 --,@Dept_ID as numeric(18,0)      
 --,@Desig_ID as numeric(18,0) Comment By nilesh patel      
 ,@Branch_ID as Varchar(Max) = '' -- Added by nilesh patel      
 ,@Dept_ID as Varchar(Max) = ''      
 ,@Desig_ID as Varchar(Max) = ''      
 ,@Cat_ID as Varchar(Max) = '' --Ankit 06112015      
 ,@Flag_stre  as Varchar(Max) = '' --Ankit 06112015      
AS      
BEGIN      
        
  Declare @Effe_date as datetime      
  Declare @Flag as varchar(3)        
  Set @Effe_date = Getdate() +1      
  Set @Flag = @Flag_stre      
        
  Create Table #EffectiveDate       
  (      
   Effective_Date  datetime      
   ,Flag varchar(3)      
  )      
        
  Create Table #EmployeeSterength      
  (      
    HeaderName  varchar(100)      
   ,InnerHeaderName  varchar(100)      
   ,SectionCount   varchar(10)      
   ,ActualCount  varchar(10)      
   ,Gap  varchar(10)      
   ,Excess varchar(10)       
   ,Branch_Dept_Id numeric(18,0)  --Added By Jaina 8-10-2015      
   ,Eff_Date datetime      
   ,Count_Additional_Opening float      
  )      
        
  Create Table #EmployeeSterengthCount      
  (      
    Desig_Id  Numeric(18,0)      
   ,Desig_Name  varchar(100)      
   ,Strength   Numeric(18,0)      
   ,Actualcnt  Numeric(18,0)      
   ,Gap  nvarchar(max)      
   ,Excess nvarchar(max)      
   ,Exitcnt  Numeric(18,0)      
   ,bgcolor_red  nvarchar(max)      
   ,bgcolor_green  nvarchar(max)      
   ,Gap1  Numeric(18,0)      
   ,Excess1 Numeric(18,0)         
  )      
       
 Create Table #EmployeeSterengthBDCount      
  (      
    Desig_Id  Numeric(18,0)      
   ,Desig_Name  varchar(100)      
   ,Strength   Numeric(18,0)      
   ,Actualcnt  Numeric(18,0)      
   ,Gap  nvarchar(max)      
   ,Excess nvarchar(max)      
   ,Exitcnt  Numeric(18,0)      
   ,bgcolor_red  nvarchar(max)      
   ,bgcolor_green  nvarchar(max)      
   ,Gap1  Numeric(18,0)      
   ,Excess1 Numeric(18,0)      
   ,Eff_Date datetime      
   ,Count_Additional_Opening float      
  )      
  If @Desig_ID =''      
   Begin        
    Select @Desig_ID=COALESCE(@Desig_ID + ',', '') + CAST(desig_id AS VARCHAR) from T0040_DESIGNATION_MASTER TDM Where TDM.Cmp_ID=@Cmp_Id      
    If len(@Desig_ID) > 4       
     Begin      
      Set @Desig_ID=substring(@Desig_ID, 2, len(@Desig_ID)-1)      
     End      
   End      
        
      
  IF @Flag_stre = '' AND @Branch_ID <> '' and @Dept_ID <> ''      
   BEGIN      
   print 500  
     set @Flag_stre='BD'       
          
    insert into #EffectiveDate      
    Select top 1 Max(Effective_Date) as Effective_Date,Flag from T0040_Employee_Strength_Master       
    where Effective_Date <= @To_Date and Cmp_Id = @Cmp_Id AND Flag='BD' group by Effective_Date,Flag      
   END      
  ELSE IF @Flag_stre = ''      
   BEGIN      
    insert into #EffectiveDate      
    Select top 1 Max(Effective_Date) as Effective_Date,Flag from T0040_Employee_Strength_Master       
    where Effective_Date <= @To_Date and Cmp_Id = @Cmp_Id group by Effective_Date,Flag      
   END         
  ELSE      
   BEGIN          
     insert into #EffectiveDate      
     Select Max(Effective_Date) as Effective_Date,Flag from T0040_Employee_Strength_Master       
     where Effective_Date <= @To_Date and Cmp_Id = @Cmp_Id and Flag = @Flag_stre group by Effective_Date,Flag      
   END      
          
  IF EXISTS (select * from #EffectiveDate)         
  BEGIN      
    --select Flag from #EffectiveDate  
 Select @Effe_date = Effective_Date,@Flag = Flag from #EffectiveDate    
  --set @flag='D'  ---mansi
  print @Flag print @Effe_date-- mansi  
  END      
        
      
  IF @Flag = 'B'      
   BEGIN     
   print 300  
    Declare @Bran_Id as numeric      
    Set @Bran_Id = 0      
    Declare @Bran_Name as varchar(150)      
    Set @Bran_Name = ''      
          
    IF @Branch_ID = ''      
     BEGIN      
            
      DECLARE db_cursor CURSOR FOR        
      Select Branch_ID,Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_Id   
   
      OPEN db_cursor        
      FETCH NEXT FROM db_cursor INTO @Bran_Id,@Bran_Name       
      WHILE @@FETCH_STATUS = 0        
      BEGIN             
         -- INSERT INTO #EmployeeSterength VALUES (@Bran_Name,'','','','','',@Bran_Id)  --commented by mansi    
            INSERT INTO #EmployeeSterength VALUES (@Bran_Name,'','','','','',@Bran_Id,'','')    --added by mansi  
             --select * from #EmployeeSterength   
    print 2222  
          INSERT INTO #EmployeeSterengthCount               
          EXEC P0040_Get_Employee_Strength @Cmp_Id,@Effe_date,@Bran_Id,0,@Desig_ID,@Flag,0      
               
     
          INSERT INTO #EmployeeSterength       
          --Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),@Bran_Id from #EmployeeSterengthCount    --commented by mansi  
            
      Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),@Bran_Id,'','' from #EmployeeSterengthCount    --added by mansi  
                
          delete from #EmployeeSterengthCount      
                
          FETCH NEXT FROM db_cursor INTO @Bran_Id,@Bran_Name       
      END              
      CLOSE db_cursor        
      DEALLOCATE db_cursor       
            
     END      
    ELSE      
     BEGIN      
      DECLARE db_cursor CURSOR FOR        
      --Select Branch_ID,Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_Id and Branch_ID = @Branch_ID      
      Select Branch_ID,Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_Id and Branch_ID IN (select  cast(data  as numeric) from dbo.Split (@Branch_ID,','))      
      OPEN db_cursor        
      FETCH NEXT FROM db_cursor INTO @Bran_Id,@Bran_Name       
      WHILE @@FETCH_STATUS = 0        
      BEGIN             
          ---INSERT INTO #EmployeeSterength VALUES (@Bran_Name,'','','','','',@Bran_Id)  --commented by mansi    
      INSERT INTO #EmployeeSterength VALUES (@Bran_Name,'','','','','',@Bran_Id,'','')    --added by mansi  
                
          INSERT INTO #EmployeeSterengthCount               
          EXEC P0040_Get_Employee_Strength @Cmp_Id,@Effe_date,@Bran_Id,0,@Desig_ID,@Flag,0      
                
          INSERT INTO #EmployeeSterength       
          --Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),@Bran_Id from #EmployeeSterengthCount    --commented by mansi  
              Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),@Bran_Id,'','' from #EmployeeSterengthCount   --added by mansi  
      
          delete from #EmployeeSterengthCount      
                
          FETCH NEXT FROM db_cursor INTO @Bran_Id,@Bran_Name       
      END              
      CLOSE db_cursor        
      DEALLOCATE db_cursor       
     END       
   END      
        
  IF @Flag = 'D'      
   BEGIN      
  
    Declare @Dep_Id as numeric      
    Set @Dep_Id = 0      
    Declare @Dep_Name as varchar(150)      
    Set @Dep_Name = ''      
          
    IF @Dept_ID = ''      
     BEGIN      
            
      DECLARE db_cursor CURSOR FOR        
      Select Dept_Id,Dept_Name from T0040_DEPARTMENT_MASTER where Cmp_ID = @Cmp_Id           
      OPEN db_cursor        
      FETCH NEXT FROM db_cursor INTO @Dep_Id,@Dep_Name       
      WHILE @@FETCH_STATUS = 0        
      BEGIN      
     -- delete from #EmployeeSterengthCount    
          --INSERT INTO #EmployeeSterength VALUES (@Dep_Name,'','','','','',@Dep_Id)     --commented by mansi  
          INSERT INTO #EmployeeSterength VALUES (@Dep_Name,'','','','','',@Dep_Id,'','') ---added by mansi  
         
          INSERT INTO #EmployeeSterengthCount               
          EXEC P0040_Get_Employee_Strength @Cmp_Id,@Effe_date,0,@Dep_Id,@Desig_ID,@Flag,0      
          select * from #EmployeeSterengthCount  
    print 230  
            
    INSERT INTO #EmployeeSterength       
          --Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),@Dep_Id from #EmployeeSterengthCount    ---commented by mansi  
                   
          Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),@Dep_Id,'','' from #EmployeeSterengthCount   --added by mansi   
     
          delete from #EmployeeSterengthCount      
                
          FETCH NEXT FROM db_cursor INTO @Dep_Id,@Dep_Name      
      END        
      CLOSE db_cursor        
      DEALLOCATE db_cursor       
            
     END      
    ELSE      
     BEGIN       
      DECLARE db_cursor CURSOR FOR        
      --Select Dept_Id,Dept_Name from T0040_DEPARTMENT_MASTER where Cmp_ID = @Cmp_Id AND Dept_Id = @Dept_ID      
      Select Dept_Id,Dept_Name from T0040_DEPARTMENT_MASTER where Cmp_ID = @Cmp_Id AND Dept_Id IN(select  cast(data  as numeric) from dbo.Split (@Dept_ID,','))      
      OPEN db_cursor        
      FETCH NEXT FROM db_cursor INTO @Dep_Id,@Dep_Name       
      WHILE @@FETCH_STATUS = 0        
      BEGIN             
         -- INSERT INTO #EmployeeSterength VALUES (@Dep_Name,'','','','','',@Dep_Id)    --commented by mansi  
    INSERT INTO #EmployeeSterength VALUES (@Dep_Name,'','','','','',@Dep_Id,'','') ---added by mansi  
                
          INSERT INTO #EmployeeSterengthCount               
          EXEC P0040_Get_Employee_Strength @Cmp_Id,@Effe_date,0,@Dep_Id,@Desig_ID,@Flag,0      
                
          INSERT INTO #EmployeeSterength       
          --Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),@Dep_Id from #EmployeeSterengthCount    --commented by mansi  
     Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),@Dep_Id from #EmployeeSterengthCount  --added by mansi  
                
          delete from #EmployeeSterengthCount      
                
          FETCH NEXT FROM db_cursor INTO @Dep_Id,@Dep_Name      
      END        
      CLOSE db_cursor        
      DEALLOCATE db_cursor      
     END      
   END      
         
  IF @Flag = 'G'      
   BEGIN      
     IF @Desig_ID = ''      
      BEGIN      
             
       INSERT INTO #EmployeeSterengthCount               
       EXEC P0040_Get_Employee_Strength @Cmp_Id,@Effe_date,0,0,@Desig_ID,@Flag,0      
             
       INSERT INTO #EmployeeSterength       
      -- Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),0 from #EmployeeSterengthCount   --commented by mansi   
     Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),0,'','' from #EmployeeSterengthCount  --added by mansi      
             
             
      END      
     ELSE      
      BEGIN      
             
       INSERT INTO #EmployeeSterengthCount               
       EXEC P0040_Get_Employee_Strength @Cmp_Id,@Effe_date,0,0,@Desig_ID,@Flag,0      
             
       INSERT INTO #EmployeeSterength       
      -- Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),0 from #EmployeeSterengthCount      
    Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),0,'','' from #EmployeeSterengthCount  --added by mansi  
             
      END      
   END      
        
  IF @Flag = 'C' --Category - Designation Wise      
   BEGIN      
    DECLARE @Ca_ID AS NUMERIC      
    SET @Ca_ID = 0      
    DECLARE @Cat_Name AS VARCHAR(150)      
    SET @Cat_Name = ''      
          
    IF @Cat_ID = ''      
     BEGIN      
            
      DECLARE db_cursor_ca CURSOR FOR        
      SELECT Cat_ID,Cat_Name FROM T0030_CATEGORY_MASTER WHERE Cmp_ID = @Cmp_Id       
      OPEN db_cursor_ca        
      FETCH NEXT FROM db_cursor_ca INTO @Ca_ID,@Cat_Name       
      WHILE @@FETCH_STATUS = 0        
      BEGIN             
          --INSERT INTO #EmployeeSterength VALUES (@Cat_Name,'','','','','',@Ca_ID)  --commented by mansi    
    INSERT INTO #EmployeeSterength VALUES (@Cat_Name,'','','','','',@Ca_ID,'','')    --added by mansi   
                
          INSERT INTO #EmployeeSterengthCount               
          EXEC P0040_Get_Employee_Strength @Cmp_Id,@Effe_date,0,0,@Desig_ID,@Flag,@Ca_ID      
                
          INSERT INTO #EmployeeSterength       
          SELECT '',Desig_Name,CAST(Strength AS VARCHAR(10)),CAST(Actualcnt AS VARCHAR(10)),CAST(Gap1 AS VARCHAR(10)),CAST(Excess1 AS VARCHAR(10)),@Ca_ID FROM #EmployeeSterengthCount  --commented by mansi  
     SELECT '',Desig_Name,CAST(Strength AS VARCHAR(10)),CAST(Actualcnt AS VARCHAR(10)),CAST(Gap1 AS VARCHAR(10)),CAST(Excess1 AS VARCHAR(10)),@Ca_ID,'','' FROM #EmployeeSterengthCount  --added by mansi  
                
          DELETE FROM #EmployeeSterengthCount      
                
          FETCH NEXT FROM db_cursor_ca INTO @Ca_ID,@Cat_Name      
      END              
      CLOSE db_cursor_ca        
      DEALLOCATE db_cursor_ca       
            
     END      
    ELSE      
     BEGIN      
      DECLARE db_cursor_ca CURSOR FOR        
      SELECT Cat_ID,Cat_Name FROM T0030_CATEGORY_MASTER WHERE Cmp_ID = @Cmp_Id AND Cat_ID IN(SELECT  CAST(DATA  AS NUMERIC) FROM dbo.Split (@Ca_ID,','))      
      OPEN db_cursor_ca        
      FETCH NEXT FROM db_cursor_ca INTO @Ca_ID,@Cat_Name       
      WHILE @@FETCH_STATUS = 0        
      BEGIN             
          --INSERT INTO #EmployeeSterength VALUES (@Cat_Name,'','','','','',@Ca_ID)    --commented by mansi  
            INSERT INTO #EmployeeSterength VALUES (@Cat_Name,'','','','','',@Ca_ID,'','')    --added by mansi   
     
          INSERT INTO #EmployeeSterengthCount               
          EXEC P0040_Get_Employee_Strength @Cmp_Id,@Effe_date,0,0,@Desig_ID,@Flag,@Ca_ID      
                
          INSERT INTO #EmployeeSterength       
         -- SELECT '',Desig_Name,CAST(Strength AS VARCHAR(10)),CAST(Actualcnt AS VARCHAR(10)),CAST(Gap1 AS VARCHAR(10)),CAST(Excess1 AS VARCHAR(10)),@Ca_ID FROM #EmployeeSterengthCount   --commented  by mansi   
           SELECT '',Desig_Name,CAST(Strength AS VARCHAR(10)),CAST(Actualcnt AS VARCHAR(10)),CAST(Gap1 AS VARCHAR(10)),CAST(Excess1 AS VARCHAR(10)),@Ca_ID,'','' FROM #EmployeeSterengthCount   --added by mansi  
       
          DELETE FROM #EmployeeSterengthCount      
                
          FETCH NEXT FROM db_cursor_ca INTO @Ca_ID,@Cat_Name      
      END              
      CLOSE db_cursor_ca        
      DEALLOCATE db_cursor_ca       
     END       
   END      
        
      
  IF @Flag = 'BD'      
   BEGIN          
    Declare @Branch_Name as varchar(150)      
    Set @Bran_Name = ''       
     BEGIN      
      DECLARE db_cursor CURSOR FOR              
      --Select Branch_ID,Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_Id and Branch_ID IN (select  cast(data  as numeric) from dbo.Split (@Branch_ID,','))      
      Select DISTINCT Branch_ID,Branch_Name +'-'+ Dept_Name as Branch_Name from T0030_BRANCH_MASTER BM WITH (NOLOCK)      
      LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON BM.Cmp_ID=DM.Cmp_Id       
      LEFT JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON BM.Cmp_ID=DGM.Cmp_Id       
      WHERE BM.cmp_id = @Cmp_Id and (Branch_ID IN (select  cast(data  as numeric) from dbo.Split (@Branch_ID,','))       
                and Dept_Id IN (select  cast(data  as numeric) from dbo.Split (@Dept_ID,',')))      
              --  OR Desig_ID IN (select  cast(data  as numeric) from dbo.Split (@Desig_ID,',')))      
      OPEN db_cursor        
      FETCH NEXT FROM db_cursor INTO @Branch_ID,@Branch_Name       
      WHILE @@FETCH_STATUS = 0        
      BEGIN              
         -- INSERT INTO #EmployeeSterength VALUES (@Branch_Name,'','','','','',@Branch_ID,'',0)    --commented by mansi  
     INSERT INTO #EmployeeSterength VALUES (@Branch_Name,'','','','','',@Branch_ID,'',0,'','')  --added by mansi  
                
          INSERT INTO #EmployeeSterengthBDCount               
          EXEC P0040_Get_Employee_Strength @Cmp_Id,@Effe_date,@Branch_ID,@Dept_ID,@Desig_ID,@Flag,0      
          --select * from #EmployeeSterengthCount      
               
          INSERT INTO #EmployeeSterength       
          Select '',Desig_Name,CAST(Strength as varchar(10)),CAST(Actualcnt as varchar(10)),CAST(Gap1 as varchar(10)),CAST(Excess1 as varchar(10)),      
          @Branch_ID,Eff_Date,Count_Additional_Opening from #EmployeeSterengthBDCount       
          where (isnull(Strength,0) > 0 or ISNULL(Actualcnt,0)>0 or ISNULL(Gap1,0)>0 or ISNULL(Excess1,0)>0)       
                
          delete from #EmployeeSterengthBDCount      
                
          FETCH NEXT FROM db_cursor INTO @Branch_ID,@Branch_Name       
      END              
      CLOSE db_cursor        
      DEALLOCATE db_cursor       
     END       
   END      
      
 --if @Flag='BD'      
 -- begin      
         
 --  Select *,'Branch Department Wise Employee Strength' WiseReport       
 --  from  #EmployeeSterengthBDCount      
 --  order by Branch_Dept_Id asc,InnerHeaderName asc       
 -- end      
 --else      
 -- begin       
 --select * from #EmployeeSterength      
      
   Select *,CASE WHEN @Flag = 'B' THEN 'Branch Wise Employee Strength'       
        WHEN @Flag = 'D' THEN 'Department Wise Employee Strength'       
        WHEN @Flag = 'G' THEN 'Designation Wise Employee Strength'      
        WHEN @Flag = 'C' THEN 'Category Wise Employee Strength'       
        WHEN @Flag = 'BD' THEN 'Branch Department Wise Employee Strength'       
        ELSE '' END as WiseReport       
   from #EmployeeSterength      
   --order by Branch_Dept_Id asc,InnerHeaderName asc -- Added by Hardik 15/12/2020 for Kataria Automobile      
  --end      
   Drop Table #EffectiveDate      
   Drop Table #EmployeeSterength      
   Drop Table #EmployeeSterengthCount      
   Drop Table #EmployeeSterengthBDCount      
END      
      