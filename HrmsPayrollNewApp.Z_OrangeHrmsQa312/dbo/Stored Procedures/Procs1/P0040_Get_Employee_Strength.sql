CREATE PROCEDURE [dbo].[P0040_Get_Employee_Strength]  
 @Cmp_ID    numeric  
 ,@Effective_Date datetime  
 ,@Branch_ID   varchar(MAX) ='' --numT0081_CUSTOMIZED_COLUMNeric = 0  
 ,@Dept_ID   varchar(MAX) ='' -- numeric = 0  
 ,@Desig_ID   varchar(MAX) = ''  
 ,@Flag    varchar(2) = ''  
 ,@Cat_ID   numeric = 0 --Ankit 28102015  
AS  
  
        SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
BEGIN  
  
 Set Nocount on   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON  
   
 CREATE table #Emp_Cons   
 (        
  Emp_ID numeric  
  ,Branch_ID numeric  
  ,Dept_ID numeric  
  ,Desig_id numeric  
  ,Cat_ID numeric  
 )     
    
 declare @GapClass as varchar(max)  
 declare @Excessclass as varchar(max)  
  
 set @GapClass='<i class="material-icons iconsm" aria-hidden="true" style="color: red;font-size: 14px;width: 10px;font-weight: bold;">arrow_downward</i>'  
 set @Excessclass='<i class="material-icons iconsm" aria-hidden="true" style="color: green;font-size: 14px;width: 10px;font-weight: bold;">arrow_upward</i>'  
  
   IF @Desig_ID = ''  
     SET @Desig_ID = NULL  
  
   INSERT INTO #Emp_Cons  
   SELECT distinct I.Emp_Id,ISNULL(I.Branch_ID,0) as Branch_ID,ISNULL(I.Dept_ID,0) as Dept_ID  
    ,ISNULL(I.Desig_Id,0) as Desig_id ,ISNULL(I.Cat_ID,0) AS Cat_ID  
   FROM T0095_Increment I WITH (NOLOCK) INNER JOIN   
     ( SELECT MAX(Increment_Effective_date) AS Increment_Effective_date , Emp_ID FROM T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment  
     WHERE Increment_Effective_date <= Getdate() --@Effective_Date  
     AND Cmp_ID = @Cmp_ID  
     GROUP BY emp_ID  ) Qry ON  
     I.Emp_ID = Qry.Emp_ID AND I.Increment_Effective_date = Qry.Increment_Effective_date  
     INNER JOIN T0080_EMP_MASTER e WITH (NOLOCK) ON i.Emp_ID = e.Emp_ID         
   WHERE i.Cmp_ID = @Cmp_ID AND e.Emp_Left = 'N' AND e.Emp_Left_Date IS NULL  
     
   If @Flag = 'B'  
    BEGIN  
    --print @Ga pClass  
      
      Select DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
      CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE '<span class=''spnsmgtzero''>'+ cast((ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) as varchar(500))  + '</span> '+ @GapClass  END GAP,  
      CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE  '<span class=''spnsmgtzero''>'+  cast((ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) as varchar(500)) + '</span> '+ @Excessclass END Excess,  
      ISNULL(Qry1.Exitcnt,0) as Exitcnt,  
      CASE WHEN ISNULL(Qry1.Exitcnt,0) <= 0 THEN 'Text_2 exitscount' ELSE 'Text_2 exitscount bgcolor_red' END bgcolor_red,  
      CASE WHEN ISNULL(Qry.cnt,0)  <= 0 THEN 'Text_2 actualcount' ELSE 'Text_2 actualcount bgcolor_green' END bgcolor_green,  
      CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) END GAP1,  
      CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) END Excess1  
      from T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  
      LEFT JOIN (Select Strength,Desig_Id From T0040_Employee_Strength_Master ES WITH (NOLOCK)  
         Inner Join (Select Max(Effective_Date) As Eff_Date From T0040_Employee_Strength_Master WITH (NOLOCK)   
            Where Cmp_Id=@Cmp_ID And Flag=@Flag And Effective_Date <=@Effective_Date) Qry On ES.Effective_Date=Qry.Eff_Date And Flag=@Flag And Branch_Id = @Branch_ID)ESM ON ESM.Desig_ID = DM.Desig_Id   
      LEFT JOIN   
      (Select COUNT(Emp_ID) as cnt,Desig_id,Branch_ID from #Emp_Cons where Branch_ID=@Branch_ID   
      group by Branch_ID,Desig_id) as Qry   
      on qry.Desig_id = DM.Desig_ID  
      Left JOIN   
      (  
       Select distinct count(E.exit_id) as Exitcnt, d.Desig_ID,B.Branch_ID  
  
        From T0200_Emp_ExitApplication as E WITH (NOLOCK)  
         INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.emp_id  
         INNER JOIN  
         (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID  
          FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK)  
          WHERE      (Increment_ID =       (SELECT     TOP (1) Increment_ID  
                    FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK)  
                    WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)  
                    ORDER BY Increment_Effective_Date DESC, Increment_ID DESC)  
                  )  
         ) AS B ON B.Emp_ID = EM.Emp_ID AND B.Cmp_ID = EM.Cmp_ID  
         INNER JOIN T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = EM.Desig_Id   
         --where   status = 'H'   
         where    ISNULL(EM.Emp_Left,'N') <> 'Y'           
         group by d.Desig_ID,B.Branch_ID  
      )as Qry1   
      on qry1.Desig_id = DM.Desig_ID  and Qry1.Branch_ID=@Branch_ID  
      where  DM.Cmp_ID = @Cmp_ID  
        -- and DM.Desig_ID in (select Isnull(data,DM.Desig_ID) from dbo.split(@Desig_ID,','))-- Commented by Hardik 10/09/2020 for Kataria as taking long time so added below query  
         And 1 = (Case When Isnull(@Desig_ID,'') = '' Then 1   
           When DM.Desig_ID in (select data from dbo.split(@Desig_ID,',')) Then 1 End)  
        
        
  
    -- IF exists (Select 1 from T0040_DESIGNATION_MASTER DM Left join T0040_Employee_Strength_Master ESM   
    --   ON ESM.Desig_ID = DM.Desig_Id where DM.Cmp_ID = @Cmp_ID And Branch_Id = @Branch_ID AND Effective_Date = @Effective_Date And Flag = @Flag)  
    -- BEGIN  
    --   Select DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
    --   CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) END GAP,  
    --   CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) END Excess  
    --   from T0040_DESIGNATION_MASTER DM   
    --   LEFT JOIN T0040_Employee_Strength_Master ESM ON ESM.Desig_ID = DM.Desig_Id   
    --   LEFT JOIN   
    --   (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons where Branch_ID=@Branch_ID group by Desig_id) as Qry   
    --   on qry.Desig_id = DM.Desig_ID  
    --   where DM.Cmp_ID = @Cmp_ID And Branch_Id = @Branch_ID AND Effective_Date = @Effective_Date And Flag = @Flag  
    -- END  
    --ELSE  
    -- BEGIN  
    --   Select DM.Desig_ID,Desig_Name,0 as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
    --   CASE WHEN (ISNULL(0,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(0,0) - ISNULL(Qry.cnt,0)) END GAP,  
    --   CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(0,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(0,0)) END Excess  
    --   from T0040_DESIGNATION_MASTER DM LEFT JOIN  
    --   (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons where Branch_ID=@Branch_ID group by Desig_id) as Qry  
    --   on qry.Desig_id = DM.Desig_ID  
    --   where Cmp_ID = @Cmp_ID  
    -- END   
    END  
     
   If @Flag = 'D'  
    BEGIN  
      
  
      Select   
      --DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
      --CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE '<span class=''spnsmgtzero''>'+ cast((ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) as varchar(500))  + '</span> '+ @GapClass  END GAP,  
      --CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE  '<span class=''spnsmgtzero''>'+  cast((ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) as varchar(500)) + '</span> '+ @Excessclass END Excess, 
 
      Cast(ISNULL(Qry1.Exitcnt,0)  as numeric) as Exitcnt  
	  
	  
      --,  
      --CASE WHEN ISNULL(Qry1.Exitcnt,0) <= 0 THEN 'Text_2 exitscount' ELSE 'Text_2 exitscount bgcolor_red' END bgcolor_red,  
      --CASE WHEN ISNULL(Qry.cnt,0)  <= 0 THEN 'Text_2 actualcount' ELSE 'Text_2 actualcount bgcolor_green' END bgcolor_green,  
      --CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) END GAP1,  
      --CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) END Excess1  
      from T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  
      LEFT JOIN (Select Strength,Desig_Id From T0040_Employee_Strength_Master ES WITH (NOLOCK)  
         Inner Join (Select Max(Effective_Date) As Eff_Date From T0040_Employee_Strength_Master WITH (NOLOCK)   
            Where Cmp_Id=@Cmp_ID And Flag=@Flag And Effective_Date <=@Effective_Date) Qry On ES.Effective_Date=Qry.Eff_Date And Flag=@Flag And Dept_Id = @Dept_ID)ESM ON ESM.Desig_ID = DM.Desig_Id   
      LEFT JOIN   
      (Select COUNT(Emp_ID) as cnt,Desig_id,Dept_ID from #Emp_Cons where Dept_ID = @Dept_ID group by Dept_ID,Desig_id) as Qry --Removed Branch_ID field(Mukti 27052020)  
      on qry.Desig_id = DM.Desig_ID  
      Left JOIN   
      (  
       Select distinct Isnull(count(E.exit_id),0) as Exitcnt, d.Desig_ID,B.Branch_ID  
        From T0200_Emp_ExitApplication as E WITH (NOLOCK)   
         INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.emp_id  
         INNER JOIN  
         (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID  
          FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK)  
          WHERE      (Increment_ID =       (SELECT     TOP (1) Increment_ID  
                    FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK)  
                    WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)  
                    ORDER BY Increment_Effective_Date DESC, Increment_ID DESC)  
                  )  
         ) AS B ON B.Emp_ID = EM.Emp_ID AND B.Cmp_ID = EM.Cmp_ID  
         INNER JOIN T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = EM.Desig_Id   
         --where   status = 'H'                 
          where    ISNULL(EM.Emp_Left,'N') <> 'Y'           
         group by d.Desig_ID,B.Branch_ID  
      )as Qry1   
      on qry1.Desig_id = DM.Desig_ID  and Qry1.Branch_ID=@Branch_ID  
      where DM.Cmp_ID = @Cmp_ID  
        --and DM.Desig_ID in (select Isnull(data,DM.Desig_ID) from dbo.split(@Desig_ID,','))-- Commented by Hardik 10/09/2020 for Kataria as taking long time so added below query  
         And 1 = (Case When Isnull(@Desig_ID,'') = '' Then 1   
           When DM.Desig_ID in (select data from dbo.split(Isnull(@Desig_ID,''),',')) Then 1 End)  
  
  
    -- IF exists (Select 1 from T0040_DESIGNATION_MASTER DM Left join T0040_Employee_Strength_Master ESM   
    --   ON ESM.Desig_ID = DM.Desig_Id where DM.Cmp_ID = @Cmp_ID And Dept_Id = @Dept_ID AND Effective_Date = @Effective_Date and Flag = @Flag)  
    -- BEGIN  
    --   Select DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
    --   CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) END GAP,  
    --   CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) END Excess  
    --   from T0040_DESIGNATION_MASTER DM   
    --   LEFT JOIN T0040_Employee_Strength_Master ESM ON ESM.Desig_ID = DM.Desig_Id   
    --   LEFT JOIN   
    --   (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons where Dept_ID = @Dept_ID group by Desig_id) as Qry   
    --   on qry.Desig_id = DM.Desig_ID  
    --   where DM.Cmp_ID = @Cmp_ID And Dept_Id = @Dept_ID AND Effective_Date = @Effective_Date and Flag = @Flag  
    -- END  
    --ELSE  
    -- BEGIN  
    --   Select DM.Desig_ID,Desig_Name,0 as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
    --   CASE WHEN (ISNULL(0,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(0,0) - ISNULL(Qry.cnt,0)) END GAP,  
    --   CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(0,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(0,0)) END Excess  
    --   from T0040_DESIGNATION_MASTER DM LEFT JOIN  
    --   (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons where Dept_ID=@Dept_ID group by Desig_id) as Qry  
    --   on qry.Desig_id = DM.Desig_ID  
    --   where Cmp_ID = @Cmp_ID  
    -- END   
    END  
     
   IF @Flag = 'G' --For Designation Wise  
    BEGIN  
     --If @Desig_ID = ''  
     -- Set @Desig_ID = Null  
      
      Select DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
      CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE '<span class=''spnsmgtzero''>'+ cast((ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) as varchar(500))  + '</span> '+ @GapClass  END GAP,  
      CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE  '<span class=''spnsmgtzero''>'+  cast((ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) as varchar(500)) + '</span> '+ @Excessclass END Excess,  
      ISNULL(Qry1.Exitcnt,0) as Exitcnt,  
      CASE WHEN ISNULL(Qry1.Exitcnt,0) <= 0 THEN 'Text_2 exitscount' ELSE 'Text_2 exitscount bgcolor_red' END bgcolor_red,  
      CASE WHEN ISNULL(Qry.cnt,0)  <= 0 THEN 'Text_2 actualcount' ELSE 'Text_2 actualcount bgcolor_green' END bgcolor_green,  
      CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) END GAP1,  
      CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) END Excess1  
      FROM T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  
      LEFT JOIN (Select Strength,Desig_Id From T0040_Employee_Strength_Master ES WITH (NOLOCK)  
         Inner Join (Select Max(Effective_Date) As Eff_Date From T0040_Employee_Strength_Master WITH (NOLOCK)  
            Where Cmp_Id=@Cmp_ID And Flag=@Flag And Effective_Date <=@Effective_Date) Qry On ES.Effective_Date=Qry.Eff_Date And Flag=@Flag)ESM ON ESM.Desig_ID = DM.Desig_Id   
      LEFT JOIN   
       (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons group by Desig_id) as Qry on qry.Desig_id = DM.Desig_ID --Removed Branch_ID field(Mukti 27052020)  
      Left JOIN   
      (  
       Select distinct count(E.exit_id) as Exitcnt, d.Desig_ID,B.Branch_ID  
        From T0200_Emp_ExitApplication as E WITH (NOLOCK)   
         INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.emp_id  
         INNER JOIN  
         (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID  
          FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK)  
          WHERE      (Increment_ID =       (SELECT     TOP (1) Increment_ID  
                    FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK)  
                    WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)  
                    ORDER BY Increment_Effective_Date DESC, Increment_ID DESC)  
                  )  
         ) AS B ON B.Emp_ID = EM.Emp_ID AND B.Cmp_ID = EM.Cmp_ID  
         INNER JOIN T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = EM.Desig_Id   
         --where   status = 'H'                 
         where    ISNULL(EM.Emp_Left,'N') <> 'Y'           
         group by d.Desig_ID,B.Branch_ID  
      )as Qry1   
      on qry1.Desig_id = DM.Desig_ID  and Qry1.Branch_ID=@Branch_ID  
      WHERE DM.Cmp_ID = @Cmp_ID  
        --and DM.Desig_ID in (select Isnull(data,DM.Desig_ID) from dbo.split(@Desig_ID,','))-- Commented by Hardik 10/09/2020 for Kataria as taking long time so added below query  
         And 1 = (Case When Isnull(@Desig_ID,'') = '' Then 1   
           When DM.Desig_ID in (select data from dbo.split(@Desig_ID,',')) Then 1 End)  
  
  
    -- IF exists (Select 1 from T0040_DESIGNATION_MASTER DM Left join T0040_Employee_Strength_Master ESM   
    --   ON ESM.Desig_ID = DM.Desig_Id where DM.Cmp_ID = @Cmp_ID AND Effective_Date = @Effective_Date and Flag = @Flag)  
    -- BEGIN  
    --   IF @Desig_ID <> 0  
    --   BEGIN         
    --    Select DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
    --    CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) END GAP,  
    --    CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) END Excess  
    --    from T0040_DESIGNATION_MASTER DM   
    --    LEFT JOIN T0040_Employee_Strength_Master ESM ON ESM.Desig_ID = DM.Desig_Id   
    --    LEFT JOIN   
    --    (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons group by Desig_id) as Qry   
    --    on qry.Desig_id = DM.Desig_ID  
    --    where DM.Cmp_ID = @Cmp_ID AND Effective_Date = @Effective_Date and Flag = @Flag and DM.Desig_ID = @Desig_ID  
    --   END  
    --   ELSE  
    --   BEGIN  
    --    Select DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
    --    CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) END GAP,  
    --    CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) END Excess  
    --    from T0040_DESIGNATION_MASTER DM   
    --    LEFT JOIN T0040_Employee_Strength_Master ESM ON ESM.Desig_ID = DM.Desig_Id   
    --    LEFT JOIN   
    --    (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons group by Desig_id) as Qry   
    --    on qry.Desig_id = DM.Desig_ID  
    --    where DM.Cmp_ID = @Cmp_ID AND Effective_Date = @Effective_Date and Flag = @Flag  
  
  
    --   END  
    -- END  
    --ELSE  
    -- BEGIN  
    --   IF @Desig_ID <> 0  
    --   BEGIN  
    --    Select DM.Desig_ID,Desig_Name,0 as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
    --    CASE WHEN (ISNULL(0,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(0,0) - ISNULL(Qry.cnt,0)) END GAP,  
    --    CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(0,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(0,0)) END Excess  
    --    from T0040_DESIGNATION_MASTER DM LEFT JOIN  
    --    (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons group by Desig_id) as Qry  
    --    on qry.Desig_id = DM.Desig_ID  
    --    where Cmp_ID = @Cmp_ID and DM.Desig_ID = @Desig_ID  
    --   END  
    --   ELSE  
    --   BEGIN  
    --    Select DM.Desig_ID,Desig_Name,0 as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
    --    CASE WHEN (ISNULL(0,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(0,0) - ISNULL(Qry.cnt,0)) END GAP,  
    --    CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(0,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(0,0)) END Excess  
    --    from T0040_DESIGNATION_MASTER DM LEFT JOIN  
    --    (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons group by Desig_id) as Qry  
    --    on qry.Desig_id = DM.Desig_ID  
    --    where Cmp_ID = @Cmp_ID  
    --   END  
         
    -- END   
    END  
      
    
  IF @Flag = 'C' --Category  
    BEGIN  
     IF @Cat_ID = 0  
      SET @Cat_ID = NULL  
  
      Select DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
      CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE '<span class=''spnsmgtzero''>'+ cast((ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) as varchar(500))  + '</span> '+ @GapClass  END GAP,  
      CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE  '<span class=''spnsmgtzero''>'+  cast((ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) as varchar(500)) + '</span> '+ @Excessclass END Excess,  
      ISNULL(Qry1.Exitcnt,0) as Exitcnt,  
      CASE WHEN ISNULL(Qry1.Exitcnt,0) <= 0 THEN 'Text_2 exitscount' ELSE 'Text_2 exitscount bgcolor_red' END bgcolor_red,  
      CASE WHEN ISNULL(Qry.cnt,0)  <= 0 THEN 'Text_2 actualcount' ELSE 'Text_2 actualcount bgcolor_green' END bgcolor_green,  
      CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) END GAP1,  
      CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) END Excess1  
      from T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  
      LEFT JOIN (Select Strength,Desig_Id From T0040_Employee_Strength_Master ES WITH (NOLOCK)  
         Inner Join (Select Max(Effective_Date) As Eff_Date From T0040_Employee_Strength_Master WITH (NOLOCK)  
            Where Cmp_Id=@Cmp_ID And Flag=@Flag And Effective_Date <=@Effective_Date) Qry On ES.Effective_Date=Qry.Eff_Date And Flag=@Flag And Cat_ID = @Cat_ID)ESM ON ESM.Desig_ID = DM.Desig_Id   
      LEFT JOIN   
      (Select COUNT(Emp_ID) as cnt,Desig_id from #Emp_Cons where Cat_ID = @Cat_ID group by Desig_id) as Qry --Removed Branch_ID field(Mukti 27052020)  
      on qry.Desig_id = DM.Desig_ID  
       Left JOIN   
      (  
       Select distinct count(E.exit_id) as Exitcnt, d.Desig_ID,B.Branch_ID  
        From T0200_Emp_ExitApplication as E WITH (NOLOCK)  
         INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.emp_id  
         INNER JOIN  
         (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID  
          FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK)  
          WHERE      (Increment_ID =       (SELECT     TOP (1) Increment_ID  
                    FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK)  
                    WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)  
                    ORDER BY Increment_Effective_Date DESC, Increment_ID DESC)  
                  )  
         ) AS B ON B.Emp_ID = EM.Emp_ID AND B.Cmp_ID = EM.Cmp_ID  
         INNER JOIN T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = EM.Desig_Id   
         --where   status = 'H'                 
          where    ISNULL(EM.Emp_Left,'N') <> 'Y'           
         group by d.Desig_ID,B.Branch_ID  
      )as Qry1   
    on qry1.Desig_id = DM.Desig_ID  and Qry1.Branch_ID=@Branch_ID  
      where DM.Cmp_ID = @Cmp_ID  
        --and DM.Desig_ID in (select Isnull(data,DM.Desig_ID) from dbo.split(@Desig_ID,','))-- Commented by Hardik 10/09/2020 for Kataria as taking long time so added below query  
         And 1 = (Case When Isnull(@Desig_ID,'') = '' Then 1   
           When DM.Desig_ID in (select data from dbo.split(@Desig_ID,',')) Then 1 End)  
  
     
     --IF EXISTS ( SELECT 1 FROM T0030_CATEGORY_MASTER DM LEFT JOIN T0040_Employee_Strength_Master ESM ON ESM.Cat_ID = DM.Cat_ID WHERE DM.Cmp_ID = @Cmp_ID AND ESM.Cat_ID = @Cat_Id AND Effective_Date = @Effective_Date AND Flag = @Flag)  
     -- BEGIN  
     --   SELECT DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) AS Strength,ISNULL(Qry.cnt,0) AS Actualcnt,  
     --   CASE WHEN (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - ISNULL(Qry.cnt,0)) END GAP,  
     --   CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(ESM.Strength,0)) END Excess  
     --   FROM T0040_DESIGNATION_MASTER DM   
     --   LEFT JOIN T0040_Employee_Strength_Master ESM ON ESM.Desig_ID = DM.Desig_Id   
     --   LEFT JOIN   
     --   (SELECT COUNT(Emp_ID) AS cnt,Desig_id FROM #Emp_Cons WHERE Cat_ID = @Cat_Id GROUP BY Desig_id) AS Qry   
     --   ON qry.Desig_id = DM.Desig_ID  
     --   WHERE DM.Cmp_ID = @Cmp_ID AND Cat_ID = @Cat_Id AND Effective_Date = @Effective_Date AND Flag = @Flag  
     -- END  
     --ELSE  
     -- BEGIN  
     --   SELECT DM.Desig_ID,Desig_Name,0 AS Strength,ISNULL(Qry.cnt,0) AS Actualcnt,  
     --   CASE WHEN (ISNULL(0,0) - ISNULL(Qry.cnt,0)) <= 0 THEN 0 ELSE (ISNULL(0,0) - ISNULL(Qry.cnt,0)) END GAP,  
     --   CASE WHEN (ISNULL(Qry.cnt,0) - ISNULL(0,0)) <= 0 THEN 0 ELSE (ISNULL(Qry.cnt,0) - ISNULL(0,0)) END Excess  
     --   FROM T0040_DESIGNATION_MASTER DM LEFT JOIN  
     --   (SELECT COUNT(Emp_ID) AS cnt,Desig_id FROM #Emp_Cons WHERE Cat_ID = @Cat_Id GROUP BY Desig_id) AS Qry  
     --   ON qry.Desig_id = DM.Desig_ID  
     --   WHERE Cmp_ID = @Cmp_ID  
     -- END   
    END   
  
      
    If @Flag = 'BD' --Mukti(05062020)  
    BEGIN      
      Select DISTINCT DM.Desig_ID,Desig_Name,ISNULL(ESM.Strength,0) as Strength,ISNULL(Qry.cnt,0) as Actualcnt,  
      CASE WHEN (ISNULL(ESM.Strength,0) - (ISNULL(Qry.cnt,0) + ISNULL(QryOpening.cnt,0))) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE '<span class=''spnsmgtzero''>'+ cast((ISNULL(ESM.Strength,0) - (ISNULL(Qry.cnt,0) + ISNULL(QryOpening.cnt,0))) as
 varchar(500))  + '</span> '+ @GapClass  END GAP,  
      CASE WHEN ((ISNULL(Qry.cnt,0) + ISNULL(QryOpening.cnt,0)) - ISNULL(ESM.Strength,0)) <= 0 THEN '<span class=''spnsmzero''>0</span>' ELSE  '<span class=''spnsmgtzero''>'+  cast(((ISNULL(Qry.cnt,0) + ISNULL(QryOpening.cnt,0)) - ISNULL(ESM.Strength,0)) 
as varchar(500)) + '</span> '+ @Excessclass END Excess,  
      ISNULL(Qry1.Exitcnt,0) as Exitcnt,  
      CASE WHEN ISNULL(Qry1.Exitcnt,0) <= 0 THEN 'Text_2 exitscount' ELSE 'Text_2 exitscount bgcolor_red' END bgcolor_red,  
      CASE WHEN ISNULL(Qry.cnt,0)  <= 0 THEN 'Text_2 actualcount' ELSE 'Text_2 actualcount bgcolor_green' END bgcolor_green,  
      CASE WHEN (ISNULL(ESM.Strength,0) - (ISNULL(Qry.cnt,0) + ISNULL(QryOpening.cnt,0))) <= 0 THEN 0 ELSE (ISNULL(ESM.Strength,0) - (ISNULL(Qry.cnt,0) + ISNULL(QryOpening.cnt,0))) END GAP1,  
      CASE WHEN ((ISNULL(Qry.cnt,0) + ISNULL(QryOpening.cnt,0)) - ISNULL(ESM.Strength,0)) <= 0 THEN 0 ELSE ((ISNULL(Qry.cnt,0) + ISNULL(QryOpening.cnt,0)) - ISNULL(ESM.Strength,0)) END Excess1,  
      Eff_Date,QryOpening.cnt as Count_Additional_Opening  
      from T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  
      LEFT JOIN (Select Strength,Desig_Id,dept_id,CMP_ID,Eff_Date From T0040_Employee_Strength_Master ES WITH (NOLOCK)  
         Inner Join (Select Max(Effective_Date) As Eff_Date From T0040_Employee_Strength_Master WITH (NOLOCK)  
            Where Cmp_Id=@Cmp_ID And Flag=@Flag And Effective_Date <=@Effective_Date) Qry On ES.Effective_Date=Qry.Eff_Date   
            And Flag=@Flag And   
            Branch_Id IN (select  cast(data  as numeric) from dbo.Split (@Branch_Id,','))   
            and desig_id in (select cast(data  as numeric) from dbo.split(ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),','))  
            And Dept_id IN (select  cast(data  as varchar) from dbo.Split (@Dept_Id,',')))ESM ON ESM.Desig_Id = DM.Desig_ID                   
      LEFT JOIN   
      (Select COUNT(EC.Emp_ID) as cnt,Desig_id,Branch_ID,Dept_ID from #Emp_Cons  EC        
       where Emp_ID NOT IN(SELECT Emp_Id FROM T0082_Emp_Column CZ WITH (NOLOCK) INNER JOIN   
           T0081_CUSTOMIZED_COLUMN CC WITH (NOLOCK) ON CC.Tran_Id=CZ.mst_Tran_Id and [Value]='Yes' and CC.Column_Name='Additional opening')   
      and Branch_ID IN (select  cast(data  as numeric) from dbo.Split (@Branch_Id,','))  
      and desig_id in (select cast(data  as numeric) from dbo.split(ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),','))  
      and Dept_ID IN (select  cast(data  as varchar) from dbo.Split (@Dept_Id,',')) group by Branch_ID,Desig_id,Dept_ID) as Qry   
      on qry.Desig_id = DM.Desig_ID   
      LEFT JOIN   
      (Select COUNT(EC.Emp_ID) as cnt,Desig_id,Branch_ID,Dept_ID from #Emp_Cons EC  
      INNER JOIN T0081_CUSTOMIZED_COLUMN CC WITH (NOLOCK) ON CC.Column_Name='Additional opening'   
      INNER JOIN T0082_Emp_Column CZ WITH (NOLOCK) ON EC.Emp_ID=CZ.Emp_Id AND CC.Tran_Id=CZ.mst_Tran_Id and [Value]='Yes'  
      where Branch_ID IN (select  cast(data  as numeric) from dbo.Split (@Branch_Id,','))  
      and desig_id in (select cast(data  as numeric) from dbo.split(ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),','))  
      and Dept_ID IN (select  cast(data  as varchar) from dbo.Split (@Dept_Id,',')) group by Branch_ID,Desig_id,Dept_ID) as QryOpening   
      on QryOpening.Desig_id = DM.Desig_ID   
      Left JOIN   
      (  
       Select distinct count(E.exit_id) as Exitcnt, d.Desig_ID,B.Branch_ID  
  
        From T0200_Emp_ExitApplication as E WITH (NOLOCK)  
         INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.emp_id  
         INNER JOIN  
         (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID  
          FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK)  
          WHERE      (Increment_ID =       (SELECT     TOP (1) Increment_ID  
                    FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK)  
                    WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)  
                    ORDER BY Increment_Effective_Date DESC, Increment_ID DESC)  
                  )  
         ) AS B ON B.Emp_ID = EM.Emp_ID AND B.Cmp_ID = EM.Cmp_ID  
         INNER JOIN T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = EM.Desig_Id   
         --where   status = 'H' )  
         where    ISNULL(EM.Emp_Left,'N') <> 'Y'           
         group by d.Desig_ID,B.Branch_ID  
      )as Qry1   
      on qry1.Desig_id = DM.Desig_ID  and Qry1.Branch_ID IN (select  cast(data  as numeric) from dbo.Split (@Branch_Id,','))  
      where  DM.Cmp_ID = @Cmp_ID --and esm.dept_id=@dept_id  
         --and  DM.Desig_ID in (select cast(data  as numeric) from dbo.split(ISNULL(@Desig_ID,ISNULL(DM.Desig_ID,0)),','))           
         And 1 = (Case When Isnull(@Desig_ID,'') = '' Then 1   
           When DM.Desig_ID in (select data from dbo.split(@Desig_ID,',')) Then 1 End)  
         ORDER BY ISNULL(Qry.cnt,0) DESC  
        
      
    END  
     
     
END  
  
  
  