
  
CREATE PROCEDURE [dbo].[Get_Rpt_Claim_Details_format4_for_Conveyance_Expenses_Detail]                    
   @Cmp_ID NUMERIC                                        
  ,@From_Date  DATETIME                                    
  ,@To_Date   DATETIME                                    
  ,@Branch_ID  VARCHAR                           
  ,@Grade_ID   VARCHAR                               
  ,@Type_ID   VARCHAR                                    
  ,@Dept_ID   VARCHAR                            
  ,@Desig_ID   VARCHAR                          
  ,@Emp_ID   VARCHAR                        
  ,@Constraint VARCHAR(MAX)                         
  ,@Cat_ID   VARCHAR=0                                            
 ,@Segment_ID VARCHAR = 0                         
 ,@Vertical VARCHAR = 0                         
 ,@SubVertical VARCHAR = 0                         
                                  
AS                               
begin                              
SET NOCOUNT ON                                     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED                                    
SET ARITHABORT ON                                  
                                
                              
IF @Branch_ID = 0                          
  SET @Branch_ID = NULL                        
                          
 IF @Grade_ID = 0                          
   SET @Grade_ID = NULL                          
                           
 IF @Emp_ID = 0                          
  SET @Emp_ID = NULL                          
                          
 IF @Desig_ID = 0                          
  SET @Desig_ID = NULL                          
                          
    IF @Dept_ID = 0                          
  SET @Dept_ID = NULL                         
                          
 IF @Type_ID = 0                          
  SET @Type_ID = NULL                          
                          
    IF @Cat_ID = 0                        
        SET @Cat_ID = NULL                        
                                            
 If @Segment_ID = 0                        
  set @Segment_ID = null                        
                                
     If @Vertical = 0                        
  set @Vertical = null                        
                      
      If @SubVertical = 0                        
  set @SubVertical = null                        
              
 IF @Constraint= '0' OR @Constraint=''  --Added By Jaina 21-09-2015                              
  SET @Constraint = NULL                              
                                
  CREATE table #Emp_Cons                               
 (                                    
  Emp_ID NUMERIC ,                                   
  Branch_ID NUMERIC,                              
  Increment_ID NUMERIC                              
 )                               
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @cmp_id,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,0,0,0,0,0,0,0,0,0,0  --Check and verify the above parameter                              
                               
   --added by mansi start 29-7-21                                  
    IF @Constraint <> ''                              
  Begin                                
   INSERT INTO #Emp_Cons                           
   SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T                                
  End                              
                                
  IF @Constraint <> ''                                    
      BEGIN                                                  
   select distinct cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code,                        
      em.Alpha_Emp_Code,cd.Claim_DateOfPurchase,cd.Claim_ID,                        
      cd.Curr_Rate,cd.Claim_Age,cd.Claim_ActualPrice,
	  --sum(cd.Claim_App_Amount)as Claim_App_Amount,sum(Cd.Claim_App_Ttl_Amount)as Claim_App_Ttl_Amount,sum(cd.Claim_Apr_Amount)as Claim_Apr_Amount,                  
      (cd.Claim_App_Amount)as Claim_App_Amount,(Cd.Claim_App_Ttl_Amount)as Claim_App_Ttl_Amount,(cd.Claim_Apr_Amount)as Claim_Apr_Amount,               
	  dbo.F_Number_TO_Word(cd.Claim_Apr_Amount) as Claim_Apr_Amount_In_Word,                  
      dbo.F_Number_TO_Word(cd.Claim_App_Amount) as Claim_App_Amount_In_Word,                    
      dbo.F_Number_TO_Word(cd.Claim_App_Ttl_Amount) as Claim_App_Ttl_Amount_In_Word ,
	  cm.Claim_Terms_Condition                     
      ,cd.Claim_Apr_Dtl_ID,cd.Claim_NoofPerson,cd.Claim_Apr_Date            
      ,[dbo].[F_GET_FINANCIAL_YEAR](cd.Claim_Apr_Date) as financial_yr           
     ,dbo.F_GET_Quarter(MONTH(cd.Claim_Apr_Date)) as Claim_Apr_Quar            
      ,bm.Branch_Address,bm.Branch_Name,com.Cmp_Name,com.Cmp_Address,bm.Comp_Name
	  ,@From_Date as P_From_date ,@To_Date as P_To_Date 
      ,cd.Claim_App_ID,cd.Petrol_KM as No_Of_Litrs,
	  CAST(DATENAME(month, cd.Claim_Apr_Date) AS varCHAR(3)) as Claim_Apr_Month 
   ,(Year(cd.Claim_Apr_Date)) as Claim_Apr_Year      
         ,cmd.Rate_Per_Km,cd.Claim_Limit,isnull(cad.Claim_ConversionRate,'')as Claim_ConversionRate 
		 ,Inc_Qry.Emp_ID,Inc_Qry.Claim_Name--,inc_qry.Claim_App_Amount
		 ,inc_qry.Driver_Amt
		 -- , (case when (inc_qry.Driver_Amt)=0 then (cd.Claim_App_Amount) else ((inc_qry.Driver_Amt)) end) as Driver_Amt
		 --, (case when sum(inc_qry.Driver_Amt)=0 then sum(cd.Claim_App_Amount) else (sum(inc_qry.Driver_Amt)) end) as Driver_Amt
       from T0080_EMP_MASTER EM    
	    left join (
			  select distinct cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,em.Emp_code,                        
			  em.Alpha_Emp_Code,--sum(cd.Claim_App_Amount)as Driver_Amt,
			  isnull(cd.Claim_App_Amount,0)as Driver_Amt,
			  cd.Claim_DateOfPurchase,
			  cd.Claim_ID,  cd.Claim_App_ID,
			  CAST(DATENAME(month, cd.Claim_Apr_Date) AS varCHAR(3)) as Claim_Apr_Month 
		   ,(Year(cd.Claim_Apr_Date)) as Claim_Apr_Year       
			  from T0080_EMP_MASTER EM    
			   Inner join #Emp_Cons EC on EC.Emp_ID=EM.Emp_ID         
			  inner join T0130_CLAIM_APPROVAL_DETAIL CD with (NoLock) on CD.Emp_ID=EM.Emp_ID  
			   inner join T0110_CLAIM_APPLICATION_DETAIL CAD with (nolock) on Cd.Claim_App_ID=CAD.Claim_App_ID   
			  inner join T0040_CLAIM_MASTER CM with (NoLock) on CM.Claim_ID=cd.Claim_ID                      
			  LEFT OUTER JOIN   dbo.T0010_COMPANY_MASTER COM WITH (NOLOCK)  ON COM.CMP_ID = Em.CMP_ID             
			  where   cd.Claim_Status='A' and EM.Cmp_ID=@Cmp_ID                          
			  and cd.Claim_Apr_Date between    @From_Date and @To_Date -- and cm.Claim_Report_Def_Id=12    
			  and Claim_Name like '%Expenditure on Driver%' --or Claim_Name like '%Conveyance Expenses%'          
			 -- order by em.Alpha_Emp_Code 
			  --group by cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,em.Emp_code,                        
			  --em.Alpha_Emp_Code,cd.Claim_DateOfPurchase,cd.Claim_ID,cd.Claim_Apr_Date, cd.Claim_App_ID
       ) Inc_Qry ON EM.Emp_ID = Inc_Qry.Emp_ID 
   Inner join #Emp_Cons EC on EC.Emp_ID=EM.Emp_ID         
   inner join T0040_GRADE_MASTER GD with (NoLock) on Gd.Grd_ID=Em.Grd_ID      
   inner join T0130_CLAIM_APPROVAL_DETAIL CD with (NoLock) on CD.Emp_ID=EM.Emp_ID     
   inner join T0110_CLAIM_APPLICATION_DETAIL CAD with (nolock) on Cd.Claim_App_ID=CAD.Claim_App_ID
   left join T0041_Claim_Maxlimit_Design CMD with (Nolock) on CMD.Grade_ID=gd.Grd_ID and cmd.Claim_ID=cd.Claim_ID       
   inner join T0040_CLAIM_MASTER CM with (NoLock) on CM.Claim_ID=cd.Claim_ID                      
   inner join T0040_DEPARTMENT_MASTER DM with(Nolock) on DM.Dept_Id=EM.Dept_ID                            
   INNER JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON EM.Desig_Id = DS.Desig_Id                                       
   --LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_Id = BN.Bank_Id            
   inner join  dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON em.BRANCH_ID = BM.BRANCH_ID               
   LEFT OUTER JOIN   dbo.T0010_COMPANY_MASTER COM WITH (NOLOCK)  ON COM.CMP_ID = Em.CMP_ID             
   where   cd.Claim_Status='A' and EM.Cmp_ID=@Cmp_ID                          
   and cd.Claim_Apr_Date between    @From_Date and @To_Date   and cm.Claim_Report_Def_Id=12    
   --and Claim_Name like '%15_Conveyance Expenses%' or Claim_Name like '%Conveyance Expenses%'      
   --  group by cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code,                        
   --   em.Alpha_Emp_Code,cd.Claim_App_Amount,cd.Claim_DateOfPurchase,cd.Claim_ID,                        
   --   cd.Curr_Rate,cd.Claim_Age,cd.Claim_ActualPrice,cm.Claim_Terms_Condition                     
   --   ,cd.Claim_Apr_Dtl_ID,cd.Claim_NoofPerson,cd.Claim_Apr_Date,          
   --   bm.Branch_Address,bm.Branch_Name,com.Cmp_Name,com.Cmp_Address,bm.Comp_Name ,
	  --cd.Claim_App_ID,cmd.Rate_Per_Km,cd.Claim_Limit,cad.Claim_ConversionRate,cd.Claim_Apr_Amount,Claim_App_Ttl_Amount,
	  --Inc_Qry.Emp_ID,Inc_Qry.Claim_Name,Inc_Qry.Driver_Amt
    order by em.Alpha_Emp_Code                              
  END                                
  ELSE               
    BEGIN                            
  --     select distinct cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code,                        
  --    em.Alpha_Emp_Code,cd.Claim_Model,cd.Claim_IMEI,cd.Claim_App_Amount,cd.Claim_DateOfPurchase,cd.Claim_ID,                        
  --    cd.Curr_Rate,cd.Claim_Age,cd.Claim_ActualPrice,Cd.Claim_App_Ttl_Amount                  
  --    ,cd.Claim_Apr_Amount,                  
  --    dbo.F_Number_TO_Word(cd.Claim_Apr_Amount) as Claim_Apr_Amount_In_Word,                  
  --    dbo.F_Number_TO_Word(cd.Claim_App_Amount) as Claim_App_Amount_In_Word,                    
  --    dbo.F_Number_TO_Word(cd.Claim_App_Ttl_Amount) as Claim_App_Ttl_Amount_In_Word ,cm.Claim_Terms_Condition                     
  --    ,cd.Claim_Apr_Dtl_ID,cd.Claim_NoofPerson,cd.Claim_Apr_Date            
  --    ,[dbo].[F_GET_FINANCIAL_YEAR](cd.Claim_Apr_Date) as financial_yr           
  --   ,dbo.F_GET_Quarter(MONTH(cd.Claim_Apr_Date)) as Claim_Apr_Quar            
  --    ,bm.Branch_Address,bm.Branch_Name,com.Cmp_Name,com.Cmp_Address,bm.Comp_Name      
  --    --,@From_Date as P_From_date ,@To_Date as P_To_Date           
  --    ,cd.Claim_App_ID,cd.Petrol_KM as No_Of_Litrs, 
	 -- --format((cd.Claim_Apr_Date),'MMMM') as Claim_Apr_Month  
	 -- CAST(DATENAME(month, cd.Claim_Apr_Date) AS varCHAR(3)) as Claim_Apr_Month 
  ---- (MONTH(cd.Claim_Apr_Date)) as Claim_Apr_Month  
  -- ,(Year(cd.Claim_Apr_Date)) as Claim_Apr_Year      
  --       ,cmd.Rate_Per_Km,cd.Claim_Limit,isnull(cad.Claim_ConversionRate,'')as Claim_ConversionRate        
  --    from T0080_EMP_MASTER EM         
  --    inner join T0040_GRADE_MASTER GD with (NoLock) on Gd.Grd_ID=Em.Grd_ID      
  --    inner join T0130_CLAIM_APPROVAL_DETAIL CD with (NoLock) on CD.Emp_ID=EM.Emp_ID  
	 --  inner join T0110_CLAIM_APPLICATION_DETAIL CAD with (nolock) on Cd.Claim_App_ID=CAD.Claim_App_ID
  --    left join T0041_Claim_Maxlimit_Design CMD with (Nolock) on CMD.Grade_ID=gd.Grd_ID and cmd.Claim_ID=cd.Claim_ID       
  --    inner join T0040_CLAIM_MASTER CM with (NoLock) on CM.Claim_ID=cd.Claim_ID                      
  --    inner join T0040_DEPARTMENT_MASTER DM with(Nolock) on DM.Dept_Id=EM.Dept_ID                            
  --    INNER JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON EM.Desig_Id = DS.Desig_Id                                       
  --    --LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_Id = BN.Bank_Id             
  --    inner join  dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON em.BRANCH_ID = BM.BRANCH_ID               
  --    LEFT OUTER JOIN   dbo.T0010_COMPANY_MASTER COM WITH (NOLOCK)  ON COM.CMP_ID = Em.CMP_ID             
  --    where   cd.Claim_Status='A' and EM.Cmp_ID=@Cmp_ID                          
  --    and cd.Claim_Apr_Date between    @From_Date and @To_Date   and cm.Claim_Report_Def_Id=12    
  --    --and Claim_Name like '%15_Conveyance Expenses%' or Claim_Name like '%Conveyance Expenses%'          
  --    order by em.Alpha_Emp_Code  
	  
	      
	select distinct cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code,                        
      em.Alpha_Emp_Code,cd.Claim_DateOfPurchase,cd.Claim_ID,                        
      cd.Curr_Rate,cd.Claim_Age,cd.Claim_ActualPrice,                 
      --sum(cd.Claim_App_Amount)as Claim_App_Amount,sum(Cd.Claim_App_Ttl_Amount)as Claim_App_Ttl_Amount,sum(cd.Claim_Apr_Amount)as Claim_Apr_Amount,                  
      (cd.Claim_App_Amount)as Claim_App_Amount,(Cd.Claim_App_Ttl_Amount)as Claim_App_Ttl_Amount,(cd.Claim_Apr_Amount)as Claim_Apr_Amount,                    
      dbo.F_Number_TO_Word(cd.Claim_Apr_Amount) as Claim_Apr_Amount_In_Word,                  
      dbo.F_Number_TO_Word(cd.Claim_App_Amount) as Claim_App_Amount_In_Word,                    
      dbo.F_Number_TO_Word(cd.Claim_App_Ttl_Amount) as Claim_App_Ttl_Amount_In_Word ,
	  cm.Claim_Terms_Condition                     
      ,cd.Claim_Apr_Dtl_ID,cd.Claim_NoofPerson,cd.Claim_Apr_Date            
      ,[dbo].[F_GET_FINANCIAL_YEAR](cd.Claim_Apr_Date) as financial_yr           
     ,dbo.F_GET_Quarter(MONTH(cd.Claim_Apr_Date)) as Claim_Apr_Quar            
      ,bm.Branch_Address,bm.Branch_Name,com.Cmp_Name,com.Cmp_Address,bm.Comp_Name     
	  ,@From_Date as P_From_date ,@To_Date as P_To_Date           
      ,cd.Claim_App_ID,cd.Petrol_KM as No_Of_Litrs,
	  CAST(DATENAME(month, cd.Claim_Apr_Date) AS varCHAR(3)) as Claim_Apr_Month 
   ,(Year(cd.Claim_Apr_Date)) as Claim_Apr_Year      
         ,cmd.Rate_Per_Km,cd.Claim_Limit,isnull(cad.Claim_ConversionRate,'')as Claim_ConversionRate 
		 ,Inc_Qry.Emp_ID,Inc_Qry.Claim_Name--,inc_qry.Claim_App_Amount
		 ,inc_qry.Driver_Amt
		-- , (case when (inc_qry.Driver_Amt)=0 then (cd.Claim_App_Amount) else ((inc_qry.Driver_Amt)) end) as Driver_Amt
		 --, (case when sum(inc_qry.Driver_Amt)=0 then sum(cd.Claim_App_Amount) else (sum(inc_qry.Driver_Amt)) end) as Driver_Amt
      from T0080_EMP_MASTER EM
	  left join (
			  select distinct cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,em.Emp_code,                        
			  em.Alpha_Emp_Code,--sum(cd.Claim_App_Amount)as Driver_Amt,
			    isnull(cd.Claim_App_Amount,0)as Driver_Amt,
			  cd.Claim_DateOfPurchase,
			  cd.Claim_ID,  cd.Claim_App_ID,
			  CAST(DATENAME(month, cd.Claim_Apr_Date) AS varCHAR(3)) as Claim_Apr_Month 
		   ,(Year(cd.Claim_Apr_Date)) as Claim_Apr_Year       
			  from T0080_EMP_MASTER EM    
			  inner join T0130_CLAIM_APPROVAL_DETAIL CD with (NoLock) on CD.Emp_ID=EM.Emp_ID  
			   inner join T0110_CLAIM_APPLICATION_DETAIL CAD with (nolock) on Cd.Claim_App_ID=CAD.Claim_App_ID   
			  inner join T0040_CLAIM_MASTER CM with (NoLock) on CM.Claim_ID=cd.Claim_ID                      
			  LEFT OUTER JOIN   dbo.T0010_COMPANY_MASTER COM WITH (NOLOCK)  ON COM.CMP_ID = Em.CMP_ID             
			  where   cd.Claim_Status='A' and EM.Cmp_ID=@Cmp_ID                          
			  and cd.Claim_Apr_Date between    @From_Date and @To_Date -- and cm.Claim_Report_Def_Id=12    
			  and Claim_Name like '%Expenditure on Driver%' --or Claim_Name like '%Conveyance Expenses%'          
			 -- order by em.Alpha_Emp_Code 
			  --group by cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,em.Emp_code,                        
			  --em.Alpha_Emp_Code,cd.Claim_DateOfPurchase,cd.Claim_ID,cd.Claim_Apr_Date, cd.Claim_App_ID
       ) Inc_Qry ON EM.Emp_ID = Inc_Qry.Emp_ID 
      inner join T0040_GRADE_MASTER GD with (NoLock) on Gd.Grd_ID=Em.Grd_ID      
      inner join T0130_CLAIM_APPROVAL_DETAIL CD with (NoLock) on CD.Emp_ID=EM.Emp_ID  
	  inner join T0110_CLAIM_APPLICATION_DETAIL CAD with (nolock) on Cd.Claim_App_ID=CAD.Claim_App_ID
      inner join T0041_Claim_Maxlimit_Design CMD with (Nolock) on CMD.Grade_ID=gd.Grd_ID and cmd.Claim_ID=cd.Claim_ID       
      inner join T0040_CLAIM_MASTER CM with (NoLock) on CM.Claim_ID=cd.Claim_ID                      
      left join T0040_DEPARTMENT_MASTER DM with(Nolock) on DM.Dept_Id=EM.Dept_ID                            
      left JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON EM.Desig_Id = DS.Desig_Id                                       
      left join  dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON em.BRANCH_ID = BM.BRANCH_ID               
      LEFT OUTER JOIN   dbo.T0010_COMPANY_MASTER COM WITH (NOLOCK)  ON COM.CMP_ID = Em.CMP_ID             
      where   cd.Claim_Status='A' and EM.Cmp_ID=@Cmp_ID                          
      and cd.Claim_Apr_Date between   @From_Date and @To_Date   and cm.Claim_Report_Def_Id=12    
      --and Claim_Name like '%Expenditure on Driver%' --or Claim_Name like '%Conveyance Expenses%'          
	  --group by cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code,                        
   --   em.Alpha_Emp_Code,cd.Claim_App_Amount,cd.Claim_DateOfPurchase,cd.Claim_ID,                        
   --   cd.Curr_Rate,cd.Claim_Age,cd.Claim_ActualPrice,cm.Claim_Terms_Condition                     
   --   ,cd.Claim_Apr_Dtl_ID,cd.Claim_NoofPerson,cd.Claim_Apr_Date,          
   --   bm.Branch_Address,bm.Branch_Name,com.Cmp_Name,com.Cmp_Address,bm.Comp_Name ,
	  --cd.Claim_App_ID,cmd.Rate_Per_Km,cd.Claim_Limit,cad.Claim_ConversionRate,cd.Claim_Apr_Amount,Claim_App_Ttl_Amount,
	  --Inc_Qry.Emp_ID,Inc_Qry.Claim_Name,Inc_Qry.Driver_Amt
      order by em.Alpha_Emp_Code    
    END                                    
end 






