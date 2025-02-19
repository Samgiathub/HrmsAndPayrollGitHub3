--Get_Employee_Cuurent_Shift      
        
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---            
CREATE PROCEDURE [dbo].[Get_Employee_Cuurent_Shift]            
    @Cmp_ID numeric,            
    @Branch_ID varchar(max) = '',  --Change by Jaina 28-08-2015            
    @Vertical_ID varchar(max) = '', -- added By Gadriwala 21102013            
    @subVertical_ID varchar(max) = '', -- added By Gadriwala 21102013            
    @Emp_Name varchar(50),            
    @Emp_Code  varchar(50),            
    @Emp_ID_Superior varchar(max) = '',            
    @Empsort_by varchar(50) = '',            
    @Empsort_type varchar(50) = '',            
    @Dept_ID varchar(max) = '',   ---Added By Jaina 16-09-2015            
    @Desig_ID numeric(18,0)=0 ,     --Mukti(20062016)            
    @Cat_ID numeric(18,0)=0 ,       --Mukti(20062016)            
    @Grd_ID numeric(18,0)=0   ,     --Mukti(20062016)            
    @Segment_ID numeric(18,0)=0 ,   --Mukti(20062016)            
    @SubBranch_ID numeric(18,0)=0,  --Mukti(20062016)            
    @EmpType_ID numeric(18,0)=0,  --Mukti(20062016)            
    @Shift_ID numeric(18,0)=0,  --Mukti(20062016)            
    @Emp_ID numeric(18,0)=0  --Mukti(09062017)            
AS            
            
SET NOCOUNT ON             
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED            
SET ARITHABORT ON            
            
BEGIN            
    if @Emp_Name <> ''            
        SET @Emp_Name = @Emp_Name + '%'             
    else            
        SET @Emp_Name = 'NOTHING TO SEARCH'            
    IF @Emp_Code  <> ''            
        SET @Emp_Code = @Emp_Code + '%'             
    ELSE            
        SET @Emp_Code = 'NOTHING TO SEARCH'            
            
    if @Emp_Code = @Emp_Name and @Emp_Name = 'NOTHING TO SEARCH'            
        SET @Emp_Name = '%'             
            
                
     IF @Branch_ID = '0' or @Branch_ID = ''            
        set @Branch_ID = null               
     if @Vertical_ID ='0' or @Vertical_ID = ''      -- added By Gadriwala 21102013            
        set @Vertical_ID = null            
    if @subVertical_ID ='0' or @subVertical_ID = '' -- added By Gadriwala 21102013            
        set @subVertical_ID = null            
     IF @Dept_ID = '0' or @Dept_ID=''   --Added By Jaina 16-09-2015            
        set @Dept_ID = NULL            
     --If @Emp_Name = ''              
        -- set @Emp_Name = '%'             
  --   If @Emp_Code = ''              
        -- set @Emp_Code = '%'            
      if @Emp_ID_Superior =''             
         set @Emp_ID_Superior = null            
      if @Empsort_by =''             
         set @Empsort_by = 'For_Date'            
      if @Empsort_type =''             
         set @Empsort_type = 'Desc'            
                     
      --Added By Mukti(start)20062016            
      IF @Cat_ID = 0                        
         SET @Cat_ID = null                      
                  
      IF @Grd_ID = 0                        
         SET @Grd_ID = null               
                     
      IF @Desig_ID = 0                        
         SET @Desig_ID = null              
                
      IF @SubBranch_Id = 0              
         SET @SubBranch_Id = null                
                     
      IF @Segment_Id = 0                 
        SET @Segment_Id = null               
                    
     IF @EmpType_ID = 0                 
        SET @EmpType_ID = null               
                        
      IF @Shift_ID = 0                 
        SET @Shift_ID = null               
    --Added By Mukti(end)20062016            
     IF @Emp_ID = '0'             
        set @Emp_ID = null               
    set @Empsort_by= @Empsort_by +  ' ' +@Empsort_type            
            
            
    if @Branch_ID is null            
    Begin               
        select   @Branch_ID = COALESCE(@Branch_ID + ',', '') + cast(Branch_ID as nvarchar(5))           
  from T0030_BRANCH_MASTER WITH (NOLOCK) --where Cmp_ID=@Cmp_ID              
        set @Branch_ID = @Branch_ID + ',0'            
    End            
    -- added By Gadriwala 21102013 - Start            
    if @Vertical_ID is null            
    Begin               
        select   @Vertical_ID = COALESCE(@Vertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))           
  from T0040_Vertical_Segment WITH (NOLOCK)  --where Cmp_ID=@Cmp_ID               
                    
        If @Vertical_ID IS NULL            
            set @Vertical_ID = '0';            
        else            
            set @Vertical_ID = @Vertical_ID + ',0'            
    End            
    if @subVertical_ID is null            
    Begin               
        select   @subVertical_ID = COALESCE(@subVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))           
  from T0050_SubVertical WITH (NOLOCK) --where Cmp_ID=@Cmp_ID            
                    
        If @subVertical_ID IS NULL            
            set @subVertical_ID = '0';            
        else            
            set @subVertical_ID = @subVertical_ID + ',0'            
                        
    End            
    -- added By Gadriwala 21102013 - End            
         
    if @Dept_ID is null            
    Begin      
   
        select   @Dept_ID = COALESCE(@Dept_ID + ',', '') + cast(Dept_ID as nvarchar(5))           
  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) --where Cmp_Id=@Cmp_ID             
                    
        If @Dept_ID IS NULL            
            set @Dept_ID = '0';            
        else            
            set @Dept_ID = @Dept_ID + ',0'            
    End            
            
            
    -----Added by Sid 03052014            
    --Comment By Jaina 14-10-2015               
    --Select cast(Data AS numeric) into #branch_id from dbo.split(@Branch_ID,',')            
    --select cast(DATA AS numeric) into #Vertical_ID from dbo.Split(@Vertical_ID,',')            
    --select cast(DATA AS numeric) into #SubVertical_ID from dbo.Split(@subVertical_ID,',')            
    --select cast(Data AS numeric) into #Dept_ID From dbo.Split(@Dept_ID,',')  --Added By Jaina 16-09-2015            
    -----Added by Sid 03052014 -- End          
  
If @Emp_ID_Superior Is Null            
    Begin         
    
        SELECT  Shift_Tran_ID,mytemp.Emp_ID, Cmp_ID,Shift_ID, mytemp.For_Date,              
                      (CASE WHEN Shift_type = 0 THEN 'Regular' WHEN Shift_Type = 1 THEN 'Temporary' END)            
                       AS Shift_Type, Emp_code, Emp_First_Name, Emp_Full_Name,             
                      Shift_Name, Branch_ID, Branch_Name, Vertical_ID,   ---added by aswini     
                      Emp_Superior, Alpha_Emp_Code                                  
         FROM V0100_Emp_shift_Change             
        inner join             
            (SELECT MAX(For_Date) as for_date, emp_id             
                FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) where For_Date<= getdate() and Cmp_ID=@Cmp_ID            
             Group By Emp_ID) mytemp            
         ON V0100_EMP_SHIFT_CHANGE.Emp_ID = mytemp.Emp_ID AND V0100_EMP_SHIFT_CHANGE.For_Date =mytemp.for_date             
                    
         Where           
   --EXISTS (select Data from dbo.Split(@Branch_ID, ',') B Where cast(B.data as numeric)=Isnull(V0100_EMP_SHIFT_CHANGE.Branch_ID,0))   --Added By Jaina 14-10-2015            
   --         and EXISTS (select Data from dbo.Split(@Vertical_ID, ',') V Where cast(v.data as numeric)=Isnull(V0100_EMP_SHIFT_CHANGE.Vertical_ID,0))            
   --         and EXISTS (select Data from dbo.Split(@subVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(V0100_EMP_SHIFT_CHANGE.SubVertical_ID,0))            
   --         and EXISTS (select Data from dbo.Split(@Dept_ID, ',') D Where cast(D.data as numeric)=Isnull(V0100_EMP_SHIFT_CHANGE.Dept_ID,0))             
            --branch_ID in (Select Data from #branch_id)            
            --and IsNull(vertical_ID,0) in (select DATA from #Vertical_ID)      -- added By Gadriwala 17102013            
            --and IsNull(subvertical_ID,0) in (select DATA from #SubVertical_ID)    -- added By Gadriwala 17102013            
            --and IsNull(dept_id,0) in (SELECT Data From #Dept_Id)   -- Added By Jaina 16-09-2015            
            --and  Alpha_Emp_Code like @Emp_Code            
            --and Emp_First_Name like @Emp_Name            
              --Added By Mukti(start)20062016            
             --and          
    (Alpha_Emp_Code like @Emp_Code OR Emp_First_Name like @Emp_Name)  
	 --and Isnull(Branch_ID,0) = isnull(@Branch_ID ,Isnull(Branch_ID,0)) 
	 --and Isnull(Vertical_Id,0) = isnull(@Vertical_Id ,Isnull(Vertical_Id,0))   
             and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))              
             and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))            
             and Grd_ID = isnull(@Grd_ID ,Grd_ID)             
             and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))             
             and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))                 
             and ISNULL([Type_ID],0) = ISNULL(@EmpType_ID,Isnull([Type_ID],0))               
             and ISNULL(Shift_ID,0) = ISNULL(@Shift_ID,Isnull(Shift_ID,0))              
             and ISNULL(mytemp.Emp_ID,0) = ISNULL(@Emp_ID,Isnull(mytemp.Emp_ID,0))      
   -- and Cmp_ID=@Cmp_ID      
             --Added By Mukti(end)20062016              
           ORDER BY                         
           CASE                        
   WHEN @Empsort_by  ='For_Date Asc' THEN V0100_EMP_SHIFT_CHANGE.For_date            
            WHEN @Empsort_by = 'Shift_type Asc' THEN V0100_EMP_SHIFT_CHANGE.Shift_type            
            WHEN @Empsort_by = 'Shift_Name Asc' THEN  CAST(V0100_EMP_SHIFT_CHANGE.Shift_Name  as sql_variant)            
            WHEN @Empsort_by = 'Emp_Full_Name Asc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Emp_Full_Name   as sql_variant)             
            WHEN @Empsort_by = 'Emp_Code Asc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Alpha_Emp_Code   as sql_variant)              
            END ASC,             
                CASE             
            WHEN @Empsort_by = 'For_Date Desc' THEN V0100_EMP_SHIFT_CHANGE.For_date            
            WHEN @Empsort_by = 'Shift_type Desc' THEN V0100_EMP_SHIFT_CHANGE.Shift_type             
            WHEN @Empsort_by = 'Shift_Name Desc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Shift_Name   as sql_variant)              
            WHEN @Empsort_by = 'Emp_Full_Name Desc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Emp_Full_Name   as sql_variant)             
            WHEN @Empsort_by = 'Emp_Code Desc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Alpha_Emp_Code   as sql_variant)                        
            END DESC             
end            
Else            
    Begin            
                    
        Select Data into #Emp_ID_Superior from dbo.split(@Emp_ID_Superior,',') -- added by Sid 03052014            
            
        SELECT  Shift_Tran_ID,mytemp.Emp_ID, Cmp_ID,Shift_ID,mytemp.For_Date,              
                (CASE WHEN Shift_type = 0 THEN 'Regular' WHEN Shift_Type = 1 THEN 'Temporary' END) AS Shift_Type,             
                Emp_code, Emp_First_Name, Emp_Full_Name, Shift_Name, Branch_ID, Branch_Name,             
                Emp_Superior, Alpha_Emp_Code            
        FROM    V0100_Emp_shift_Change             
                inner join (SELECT  MAX(For_Date) as for_date, emp_id             
                            FROM    T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)            
                            where For_Date<= getdate() and Cmp_ID=@Cmp_ID            
                            GROUP BY emp_id          
       ) mytemp ON V0100_EMP_SHIFT_CHANGE.Emp_ID = mytemp.Emp_ID          
       AND V0100_EMP_SHIFT_CHANGE.For_Date =mytemp.for_date             
         WHERE  V0100_EMP_SHIFT_CHANGE.Emp_ID in (Select Data from #Emp_ID_Superior)                     
                --and EXISTS (select Data from dbo.Split(@Branch_ID, ',') B Where cast(B.data as numeric)=Isnull(V0100_EMP_SHIFT_CHANGE.Branch_ID,0))               
                --and EXISTS (select Data from dbo.Split(@Vertical_ID, ',') V Where cast(v.data as numeric)=Isnull(V0100_EMP_SHIFT_CHANGE.Vertical_ID,0))            
                --and EXISTS (select Data from dbo.Split(@subVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(V0100_EMP_SHIFT_CHANGE.SubVertical_ID,0))            
  --and EXISTS (select Data from dbo.Split(@Dept_ID, ',') D Where cast(D.data as numeric)=Isnull(V0100_EMP_SHIFT_CHANGE.Dept_ID,0))             
                and (Alpha_Emp_Code like @Emp_Code OR Emp_First_Name like @Emp_Name)            
                and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))              
                and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))            
                and Grd_ID = isnull(@Grd_ID ,Grd_ID)             
                and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))             
                and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))             
                and ISNULL([Type_ID],0) = ISNULL(@EmpType_ID,Isnull([Type_ID],0))                
                and ISNULL(Shift_ID,0) = ISNULL(@Shift_ID,Isnull(Shift_ID,0))               
                and ISNULL(mytemp.emp_id,0) = ISNULL(@Emp_ID,Isnull(mytemp.emp_id,0))   --Change by Jaina 11-08-2017            
    --and Cmp_ID=@Cmp_ID      
         --Added By Mukti(end)20062016              
          ORDER BY                          
           CASE                        
            WHEN @Empsort_by  ='For_Date Asc' THEN V0100_EMP_SHIFT_CHANGE.For_date            
            WHEN @Empsort_by = 'Shift_type Asc' THEN V0100_EMP_SHIFT_CHANGE.Shift_type            
            WHEN @Empsort_by = 'Shift_Name Asc' THEN  CAST(V0100_EMP_SHIFT_CHANGE.Shift_Name  as sql_variant)            
            WHEN @Empsort_by = 'Emp_Full_Name Asc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Emp_Full_Name   as sql_variant)             
            WHEN @Empsort_by = 'Emp_Code Asc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Alpha_Emp_Code   as sql_variant)              
            END ASC,             
                CASE             
            WHEN @Empsort_by = 'For_Date Desc' THEN V0100_EMP_SHIFT_CHANGE.For_date            
            WHEN @Empsort_by = 'Shift_type Desc' THEN V0100_EMP_SHIFT_CHANGE.Shift_type             
            WHEN @Empsort_by = 'Shift_Name Desc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Shift_Name   as sql_variant)              
            WHEN @Empsort_by = 'Emp_Full_Name Desc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Emp_Full_Name   as sql_variant)             
            WHEN @Empsort_by = 'Emp_Code Desc' THEN CAST(V0100_EMP_SHIFT_CHANGE.Alpha_Emp_Code   as sql_variant)                        
            END DESC                  
    END            
end 