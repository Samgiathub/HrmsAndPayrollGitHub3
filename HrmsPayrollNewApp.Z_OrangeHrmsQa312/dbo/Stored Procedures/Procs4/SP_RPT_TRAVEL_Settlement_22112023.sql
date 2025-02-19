  
  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
Create PROCEDURE [dbo].[SP_RPT_TRAVEL_Settlement_22112023]  
  @Cmp_ID  Numeric  
 ,@From_Date  Datetime  
 ,@To_Date  Datetime  
 ,@Branch_ID  Numeric   
 ,@Cat_ID  Numeric  
 ,@Grd_ID  Numeric  
 ,@Type_ID  Numeric   
 ,@Dept_Id  Numeric  
 ,@Desig_Id  Numeric  
 ,@Emp_ID  Numeric  
 ,@Constraint varchar(MAX)  
 ,@flag   varchar(5)='0'  
 ,@Settlement_ID numeric(18,0)=0  
 ,@is_foreign tinyint=0  
 ,@Report_for    varchar(50) = '' --Added by Jaina 17-02-2018  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
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
   Insert Into @Emp_Cons  
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')   
  end  
 else  
  begin  
   Insert Into @Emp_Cons  
  
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join   
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment   
     where Increment_Effective_date <= @To_Date  
     and Cmp_ID = @Cmp_ID  
     group by emp_ID  ) Qry on  
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID   
         
   Where Cmp_ID = @Cmp_ID   
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))  
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)  
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)  
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))  
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))  
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
   and I.Emp_ID in   
    ( select Emp_Id from  
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry  
    where cmp_ID = @Cmp_ID   and    
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )   
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )  
    or Left_date is null and @To_Date >= Join_Date)  
    or @To_Date >= left_date  and  @From_Date <= left_date )   
  end  
  declare @setting_val as numeric(18,0)  
    
  select @setting_val= Setting_Value from T0040_SETTING WITH (NOLOCK) where Setting_Name='Enable Instruct By Employee Column in Travel Application'  
  and Cmp_ID=@Cmp_ID  
    
  --if (@flag='0')  
  -- Begin  
  if (@is_foreign='1')  
   Begin  
      
    select distinct EMP.Alpha_Emp_Code,EMP.Emp_ID,EMP.Emp_Full_Name  
     ,INC.BRANCH_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)  
        from  T0080_EMP_MASTER EMP WITH (NOLOCK) inner join @Emp_cons EC on Emp.Emp_ID = EC.Emp_ID   
         inner join T0120_TRAVEL_APPROVAL ta WITH (NOLOCK) on ta.Emp_ID=ec.Emp_ID  
         inner join T0130_TRAVEL_APPROVAL_DETAIL TC WITH (NOLOCK) on ta.Travel_Approval_ID =TC.Travel_Approval_ID  
         left join T0001_LOCATION_MASTER lcm WITH (NOLOCK) on lcm.Loc_ID=TC.Loc_ID  
         LEFT OUTER JOIN (  
              SELECT EMP_ID, BRANCH_ID FROM T0095_INCREMENT I WITH (NOLOCK)  
              WHERE Increment_Effective_Date=(SELECT MAX(Increment_Effective_Date)  
                        FROM  T0095_INCREMENT I1 WITH (NOLOCK)  
                        WHERE  I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID  
                         AND I1.Increment_Effective_Date<= @To_Date  
                        )  
                AND I.Cmp_ID=@Cmp_ID                       
             ) INC ON EMP.EMP_ID=INC.EMP_ID  
        where  EMP.Cmp_ID=@Cmp_ID   
         and isnull(tc.Loc_ID,0) <>0  
           
       
     Select TAD.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name  
         ,Dept_Name,DGM.Desig_Name,type_Name,Cmp_Name,Cmp_Address ,comp_name,Branch_address,@From_Date as From_Date,@To_Date as To_Date, BM.Branch_ID  
         ,TAD1.From_Date as TAD_From_Date,TAD1.To_Date as TAD_To_Date,TAd1.Place_Of_Visit   
         ,TAD1.Instruct_Emp_ID as TAD_instruct_EMP_id,TAD1.Leave_Approval_ID,TAD1.Leave_ID,TAD1.Period,TAD1.Remarks as TAD_Remark,TAD1.Travel_Mode_ID,TAD1.Travel_Purpose,TAD1.Travel_Approval_Detail_ID  
         ,IEM.Emp_Full_Name,TMM.Travel_Mode_Name,LM.Leave_Name  
         ,TSA.Travel_Approval_ID,CM.cmp_logo,TSA.Status  
         ,isnull(SEM.Emp_Full_Name,'Admin') as Approved_Emp_Name ,isnull(SDM.Desig_Name,'Admin') as S_Desig_Name  
         ,ta.Tour_Agenda,Ta.IMP_Business_Appoint,TA.KRA_Tour,isnull(Ta.chk_Adv,0) as chk_Adv,isnull(ta.chk_Agenda,0) as chk_Agenda  
         ,SUPR.Emp_Full_Name As Emp_Superior_Name  
         ,SUPD.Desig_Name AS Emp_Superior_DesigName        
         ,isnull(SM.State_Name,'') as State_Name,isnull(CTM.City_Name,'') as City_Name,@setting_val as Set_Val  
         ,ISNULL(LCM.Loc_name,'') as Country  
      from T0150_Travel_Settlement_Approval TAD WITH (NOLOCK)  
      inner join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id  
      inner Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 WITH (NOLOCK) ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id  
      inner Join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) ON TA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TA.Cmp_id =TAD1.Cmp_id  
      inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID   
      inner join T0080_Emp_Master e WITH (NOLOCK) on TAD.Emp_ID = e.emp_ID   
      inner join T0010_Company_Master CM WITH (NOLOCK) on TAD.Cmp_ID= CM.CMP_ID  
      inner join  
        ( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join   
          ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment  
          where Increment_Effective_date <= @To_Date  
          and Cmp_ID = @Cmp_ID  
          group by emp_ID  ) Qry on  
          I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q   
         on E.Emp_ID = I_Q.Emp_ID  inner join  
          T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
          T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
          T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
          T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join   
          T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  left join   
          T0080_EMP_MASTER IEM WITH (NOLOCK) on TAD1.Instruct_Emp_ID =IEm.Emp_ID left join  
          T0030_TRAVEL_MODE_MASTER TMM WITH (NOLOCK) on TAD1.Travel_Mode_ID = TMM.Travel_Mode_ID  left join  
          T0040_LEAVE_MASTER LM WITH (NOLOCK) on TAD1.Leave_ID = LM.Leave_ID   
          left join T0080_EMP_MASTER SEM WITH (NOLOCK) on TAD.manager_emp_id = SEM.Emp_ID  
          left join T0040_DESIGNATION_MASTER SDM WITH (NOLOCK) on SEM.Desig_Id =SDM.Desig_ID    
          left join T0080_EMP_MASTER SUPR WITH (NOLOCK) on e.Emp_Superior = SUPR.Emp_ID  
          left join T0040_DESIGNATION_MASTER SUPD WITH (NOLOCK) on SUPR.Desig_Id =SUPD.Desig_ID    
          left join t0020_State_Master SM WITH (NOLOCK) on SM.State_ID=TAD1.State_ID  
          left join T0030_CITY_MASTER CTM WITH (NOLOCK) on CTM.City_ID=TAD1.City_ID  
          left join T0001_LOCATION_MASTER LCM WITH (NOLOCK) on LCM.Loc_ID=TAD1.Loc_ID  
          --left join T0040_CURRENCY_MASTER CRM on CRM.Curr_ID=TSA.Cu  
            
                  
     where    
     TAd.Cmp_ID = @Cmp_ID and TAD.Approval_date >=@From_Date and  TAD.Approval_date <=@To_Date + 1  
     and  
     --TAd.Cmp_ID = @Cmp_ID and   
       
     --TAD.Approval_date >= case when @Flag ='0' then TAD.Approval_date else  cast(cast(@From_Date as varchar(11)) as datetime) end  
     --and    
     --TAD.Approval_date <= case when @Flag ='0' then TAD.Approval_date else  cast(cast(@To_Date + 1 as varchar(11)) as datetime)  end  
     --and  
     --TSA.Travel_Set_Application_id=case when @Flag ='0' then TSA.Travel_Set_Application_id else @Settlement_ID end   
     --and  
     TAD1.Loc_ID is not null   
     or TAD1.Loc_ID <>0  
     --TAD1.Loc_ID is not null case when @is_foreign='1'  
       
     --(isnull(tad1.Loc_ID,0) > case when @is_foreign = 1 then  0 end  
      --or  
      --not isnull(tad1.Loc_ID,0) > case when @is_foreign = 0 then  0 end  
     -- )  
       
     Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)  
      When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)  
       Else e.Alpha_Emp_Code  
      End       
                  
   End  
  Else  
   Begin  
      
    select distinct EMP.Alpha_Emp_Code,EMP.Emp_ID,EMP.Emp_Full_Name  
     ,INC.BRANCH_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)  
     from  T0080_EMP_MASTER EMP WITH (NOLOCK) inner join @Emp_cons EC on Emp.Emp_ID = EC.Emp_ID   
     inner join T0150_Travel_Settlement_Approval TAD WITH (NOLOCK) on TAD.emp_id=EC.Emp_ID and TAD.cmp_id=Emp.Cmp_ID  
     left join T0120_TRAVEL_APPROVAL ta WITH (NOLOCK) on ta.Emp_ID=ec.Emp_ID  
     left join T0130_TRAVEL_APPROVAL_DETAIL TC WITH (NOLOCK) on ta.Travel_Approval_ID =TC.Travel_Approval_ID  
     left join T0030_CITY_MASTER lcm WITH (NOLOCK) on lcm.City_ID=TC.City_ID  
     LEFT OUTER JOIN (  
         SELECT EMP_ID, BRANCH_ID FROM T0095_INCREMENT I WITH (NOLOCK)  
         WHERE Increment_Effective_Date=(SELECT MAX(Increment_Effective_Date)  
         FROM  T0095_INCREMENT I1 WITH (NOLOCK)  
         WHERE  I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID  
         AND I1.Increment_Effective_Date<= @To_Date  
         )  
     AND I.Cmp_ID=@Cmp_ID                       
     ) INC ON EMP.EMP_ID=INC.EMP_ID  
     where  EMP.Cmp_ID=@Cmp_ID --and isnull(tc.City_ID,0) <> 0   
     and TAD.Approval_date >=@From_Date and  TAD.Approval_date <=@To_Date + 1  
        
     if @Report_for = 'Settlement Status'  
     BEGIN  
	 
      Select DISTINCT TAD.*, e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name  
          ,Dept_Name,DGM.Desig_Name,type_Name,Cmp_Name,Cmp_Address ,comp_name,Branch_address,@From_Date as From_Date,@To_Date as To_Date, BM.Branch_ID            
          ,TAD1.Instruct_Emp_ID as TAD_instruct_EMP_id  
          ,IEM.Emp_Full_Name,TMM.Travel_Mode_Name,LM.Leave_Name  
          ,TSA.Travel_Approval_ID,TSA.Status  
          ,isnull(SEM.Emp_Full_Name,'Admin') as Approved_Emp_Name ,isnull(SDM.Desig_Name,'Admin') as S_Desig_Name  
          ,ta.Tour_Agenda,Ta.IMP_Business_Appoint,TA.KRA_Tour,isnull(Ta.chk_Adv,0) as chk_Adv,isnull(ta.chk_Agenda,0) as chk_Agenda  
          ,SUPR.Emp_Full_Name As Emp_Superior_Name  
          ,SUPD.Desig_Name AS Emp_Superior_DesigName        
          ,@setting_val as Set_Val  
          ,ISNULL(LCM.Loc_name,'') as Country  
       from T0150_Travel_Settlement_Approval TAD WITH (NOLOCK)  
       inner join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id  
       inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID   
       --inner Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id  
       left Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 WITH (NOLOCK) ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id  
       --inner Join T0120_TRAVEL_APPROVAL TA ON TA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TA.Cmp_id =TAD1.Cmp_id  
       Left Join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) ON TA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TA.Cmp_id =TAD1.Cmp_id  
         
       inner join T0080_Emp_Master e WITH (NOLOCK) on TAD.Emp_ID = e.emp_ID   
       inner join T0010_Company_Master CM WITH (NOLOCK) on TAD.Cmp_ID= CM.CMP_ID  
       inner join  
         ( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join   
           ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment  
           where Increment_Effective_date <= @To_Date  
           and Cmp_ID = @Cmp_ID  
           group by emp_ID  ) Qry on  
           I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q   
          on E.Emp_ID = I_Q.Emp_ID  inner join  
           T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
           T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
           T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
           T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join   
           T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  left join   
           T0080_EMP_MASTER IEM WITH (NOLOCK) on TAD1.Instruct_Emp_ID =IEm.Emp_ID left join  
           T0030_TRAVEL_MODE_MASTER TMM WITH (NOLOCK) on TAD1.Travel_Mode_ID = TMM.Travel_Mode_ID  left join  
           T0040_LEAVE_MASTER LM WITH (NOLOCK) on TAD1.Leave_ID = LM.Leave_ID   
           left join T0080_EMP_MASTER SEM WITH (NOLOCK) on TAD.manager_emp_id = SEM.Emp_ID  
           left join T0040_DESIGNATION_MASTER SDM WITH (NOLOCK) on SEM.Desig_Id =SDM.Desig_ID    
           left join T0080_EMP_MASTER SUPR WITH (NOLOCK) on e.Emp_Superior = SUPR.Emp_ID  
           left join T0040_DESIGNATION_MASTER SUPD WITH (NOLOCK) on SUPR.Desig_Id =SUPD.Desig_ID    
           left join t0020_State_Master SM WITH (NOLOCK) on SM.State_ID=TAD1.State_ID  
           left join T0030_CITY_MASTER CTM WITH (NOLOCK) on CTM.City_ID=TAD1.City_ID  
           left join T0001_LOCATION_MASTER LCM WITH (NOLOCK) on LCM.Loc_ID=TAD1.Loc_ID  
           --left join T0040_CURRENCY_MASTER CRM on CRM.Curr_ID=TSA.Cu  
             
                   
      where    
      TAd.Cmp_ID = @Cmp_ID   
      and TAD.Approval_date >=@From_Date and  TAD.Approval_date <=@To_Date + 1              
      --Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)  
      -- When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)  
      --  Else e.Alpha_Emp_Code  
      -- End    
        
  
     End   
     else  
     begin    
          
        IF @Settlement_ID = 0  
       BEGIN  
          
          Select TAD.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name  
            ,Dept_Name,DGM.Desig_Name,type_Name,Cmp_Name,Cmp_Address ,comp_name,Branch_address,@From_Date as From_Date,@To_Date as To_Date, BM.Branch_ID  
            ,TAD1.From_Date as TAD_From_Date,TAD1.To_Date as TAD_To_Date,TAd1.Place_Of_Visit   
            ,TAD1.Instruct_Emp_ID as TAD_instruct_EMP_id,TAD1.Leave_Approval_ID,TAD1.Leave_ID,TAD1.Period,TAD1.Remarks as TAD_Remark,TAD1.Travel_Mode_ID,TAD1.Travel_Purpose,TAD1.Travel_Approval_Detail_ID  
            ,IEM.Emp_Full_Name,TMM.Travel_Mode_Name,LM.Leave_Name  
            ,TSA.Travel_Approval_ID,CM.cmp_logo,TSA.Status  
            ,isnull(SEM.Emp_Full_Name,'Admin') as Approved_Emp_Name ,isnull(SDM.Desig_Name,'Admin') as S_Desig_Name  
            ,ta.Tour_Agenda,Ta.IMP_Business_Appoint,TA.KRA_Tour,isnull(Ta.chk_Adv,0) as chk_Adv,isnull(ta.chk_Agenda,0) as chk_Agenda  
            ,SUPR.Emp_Full_Name As Emp_Superior_Name  
            ,SUPD.Desig_Name AS Emp_Superior_DesigName        
            ,isnull(SM.State_Name,'') as State_Name,isnull(CTM.City_Name,'') as City_Name,@setting_val as Set_Val  
            ,ISNULL(LCM.Loc_name,'') as Country  
           from T0150_Travel_Settlement_Approval TAD WITH (NOLOCK)  
           inner join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id  
           inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID   
           --inner Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id  
           left Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 WITH (NOLOCK) ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id  
           --inner Join T0120_TRAVEL_APPROVAL TA ON TA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TA.Cmp_id =TAD1.Cmp_id  
           Left Join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) ON TA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TA.Cmp_id =TAD1.Cmp_id  
             
           inner join T0080_Emp_Master e WITH (NOLOCK) on TAD.Emp_ID = e.emp_ID   
           inner join T0010_Company_Master CM WITH (NOLOCK) on TAD.Cmp_ID= CM.CMP_ID  
           inner join  
             ( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join   
               ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment  
               where Increment_Effective_date <= @To_Date  
               and Cmp_ID = @Cmp_ID  
               group by emp_ID  ) Qry on  
               I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q   
              on E.Emp_ID = I_Q.Emp_ID  inner join  
               T0040_GRADE_MASTER GM WITH (NOLOCK)  ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
               T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
               T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
               T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join   
               T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  left join   
               T0080_EMP_MASTER IEM WITH (NOLOCK)  on TAD1.Instruct_Emp_ID =IEm.Emp_ID left join  
               T0030_TRAVEL_MODE_MASTER TMM WITH (NOLOCK) on TAD1.Travel_Mode_ID = TMM.Travel_Mode_ID  left join  
               T0040_LEAVE_MASTER LM WITH (NOLOCK) on TAD1.Leave_ID = LM.Leave_ID   
               left join T0080_EMP_MASTER SEM WITH (NOLOCK) on TAD.manager_emp_id = SEM.Emp_ID  
               left join T0040_DESIGNATION_MASTER SDM WITH (NOLOCK) on SEM.Desig_Id =SDM.Desig_ID    
               left join T0080_EMP_MASTER SUPR WITH (NOLOCK) on e.Emp_Superior = SUPR.Emp_ID  
               left join T0040_DESIGNATION_MASTER SUPD WITH (NOLOCK) on SUPR.Desig_Id =SUPD.Desig_ID    
               left join t0020_State_Master SM WITH (NOLOCK) on SM.State_ID=TAD1.State_ID  
               left join T0030_CITY_MASTER CTM WITH (NOLOCK) on CTM.City_ID=TAD1.City_ID  
               left join T0001_LOCATION_MASTER LCM WITH (NOLOCK) on LCM.Loc_ID=TAD1.Loc_ID  
               --left join T0040_CURRENCY_MASTER CRM on CRM.Curr_ID=TSA.Cu  
                 
                       
          where    
          TAd.Cmp_ID = @Cmp_ID   
          and TAD.Approval_date >=@From_Date and  TAD.Approval_date <=@To_Date + 1  
            
            
            
          Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)  
           When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)  
            Else e.Alpha_Emp_Code  
           End    
         
       END  
      ELSE  
       BEGIN  
         
       Select TAD.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name  
          ,Dept_Name,DGM.Desig_Name,type_Name,Cmp_Name,Cmp_Address ,comp_name,Branch_address,@From_Date as From_Date,@To_Date as To_Date, BM.Branch_ID  
          ,TAD1.From_Date as TAD_From_Date,TAD1.To_Date as TAD_To_Date,TAd1.Place_Of_Visit   
          ,TAD1.Instruct_Emp_ID as TAD_instruct_EMP_id,TAD1.Leave_Approval_ID,TAD1.Leave_ID,TAD1.Period,TAD1.Remarks as TAD_Remark,TAD1.Travel_Mode_ID,TAD1.Travel_Purpose,TAD1.Travel_Approval_Detail_ID  
          ,IEM.Emp_Full_Name,TMM.Travel_Mode_Name,LM.Leave_Name  
          ,TSA.Travel_Approval_ID,CM.cmp_logo,TSA.Status  
          ,isnull(SEM.Emp_Full_Name,'Admin') as Approved_Emp_Name ,isnull(SDM.Desig_Name,'Admin') as S_Desig_Name  
          ,ta.Tour_Agenda,Ta.IMP_Business_Appoint,TA.KRA_Tour,isnull(Ta.chk_Adv,0) as chk_Adv,isnull(ta.chk_Agenda,0) as chk_Agenda  
          ,SUPR.Emp_Full_Name As Emp_Superior_Name  
          ,SUPD.Desig_Name AS Emp_Superior_DesigName        
          ,isnull(SM.State_Name,'') as State_Name,isnull(CTM.City_Name,'') as City_Name,@setting_val as Set_Val  
          ,ISNULL(LCM.Loc_name,'') as Country  
       from T0150_Travel_Settlement_Approval TAD WITH (NOLOCK)  
       inner join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id  
       inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID   
       --inner Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id  
       left Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 WITH (NOLOCK) ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id  
       --inner Join T0120_TRAVEL_APPROVAL TA ON TA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TA.Cmp_id =TAD1.Cmp_id  
       Left Join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) ON TA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TA.Cmp_id =TAD1.Cmp_id  
         
       inner join T0080_Emp_Master e WITH (NOLOCK) on TAD.Emp_ID = e.emp_ID   
       inner join T0010_Company_Master CM WITH (NOLOCK) on TAD.Cmp_ID= CM.CMP_ID  
       inner join  
         ( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join   
           ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment  
           where Increment_Effective_date <= @To_Date  
           and Cmp_ID = @Cmp_ID  
           group by emp_ID  ) Qry on  
           I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q   
          on E.Emp_ID = I_Q.Emp_ID  inner join  
           T0040_GRADE_MASTER GM WITH (NOLOCK)  ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
           T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
           T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
           T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join   
           T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  left join   
           T0080_EMP_MASTER IEM WITH (NOLOCK) on TAD1.Instruct_Emp_ID =IEm.Emp_ID left join  
           T0030_TRAVEL_MODE_MASTER TMM WITH (NOLOCK) on TAD1.Travel_Mode_ID = TMM.Travel_Mode_ID  left join  
           T0040_LEAVE_MASTER LM WITH (NOLOCK) on TAD1.Leave_ID = LM.Leave_ID   
           left join T0080_EMP_MASTER SEM WITH (NOLOCK) on TAD.manager_emp_id = SEM.Emp_ID  
           left join T0040_DESIGNATION_MASTER SDM WITH (NOLOCK) on SEM.Desig_Id =SDM.Desig_ID    
           left join T0080_EMP_MASTER SUPR WITH (NOLOCK) on e.Emp_Superior = SUPR.Emp_ID  
           left join T0040_DESIGNATION_MASTER SUPD WITH (NOLOCK) on SUPR.Desig_Id =SUPD.Desig_ID    
           left join t0020_State_Master SM WITH (NOLOCK) on SM.State_ID=TAD1.State_ID  
           left join T0030_CITY_MASTER CTM WITH (NOLOCK) on CTM.City_ID=TAD1.City_ID  
           left join T0001_LOCATION_MASTER LCM WITH (NOLOCK) on LCM.Loc_ID=TAD1.Loc_ID  
           --left join T0040_CURRENCY_MASTER CRM on CRM.Curr_ID=TSA.Cu  
             
                   
      where    
      TAd.Cmp_ID = @Cmp_ID   
      and TAD.Approval_date >=@From_Date and  TAD.Approval_date <=@To_Date + 1  
      AND TAD.Travel_Set_Application_id = @Settlement_ID -- ADDED BY RAJPUT ON 09072019 CASE FROM KICH CLIENT  
        
        
      Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)  
       When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)  
        Else e.Alpha_Emp_Code  
       End    
         
       END  
          
         
         
      End  
    END  
    
     RETURN   
  