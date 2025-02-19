
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_FINAL_SCORE1]  
  @Cmp_ID  Numeric  
 ,@From_Date  Datetime  
 ,@To_Date  Datetime   
 ,@Branch_ID  Numeric    = 0  
 ,@Cat_ID  Numeric    = 0  
 ,@Grd_ID  Numeric    = 0  
 ,@Type_ID  Numeric    = 0  
 ,@Dept_ID  Numeric    = 0  
 ,@Desig_ID  Numeric    = 0  
 ,@Emp_ID  Numeric    
 ,@Appr_Int_ID Numeric
 ,@Constraint Varchar(5000) = ''  
 ,@Flage         Numeric = 0   
 ,@Emp_Identity  Numeric         --1 means superior and 0 means Employee own  
   
AS   

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


  if @Branch_ID = 0  
  set @Branch_ID =  null  
 if @Cat_ID = 0  
  set @Cat_ID =     null     
 if @Type_ID = 0  
  set @Type_ID =    null  
 if @Dept_ID = 0  
  set @Dept_ID =    null  
 if @Grd_ID = 0  
  set @Grd_ID =     null  
 if @Emp_ID = 0  
  set @Emp_ID =     null  
 If @Desig_ID = 0  
  set @Desig_ID =   null    
    
    --Emp_Status  0-Means Employee Give His Own Rating
    --Emp_Status  1-Superior Gives his Rating To Employee
    
    
Declare @Max_Rate Numeric(18)    
Declare @Flag_2 tinyint
Declare @Exits tinyint  
Declare @Row_ID_1 Numeric(18)
Declare @Row_ID_2 Numeric(18)
Declare @Row_ID_3 Numeric(18)
Declare @Row_ID_4 Numeric(18)
Declare @Row_ID_5 Numeric(18)

Declare @appr_detail_id Numeric(18,0) --Ripal 14July2014
    
  CREATE table #Final_Score  
  (  
	Row_Id     numeric(18,0) ,
    Title_Name varchar(25),  
    Total_Score numeric(18,2),  
    Eval_Score numeric(18,2) Default 0,  
    Inspection_Status numeric(18,0) Default 0,          
    Flag tinyint --nikunj  for doing update at form side   
  )    
    --Nikunj Change At 03-June-2010
    --Before this There is only One @Skill table So When Another Value is not available it gives same value as skill
    
    
	Declare @Skill table  
    (  
		Total_Rate numeric(18,2) Default 0,  
        Evaluation_Rate Numeric(18,2) Default 0                  
    )         
    Declare @Training table  
    (  
		Total_no int default 0,
		Total_Rate numeric(18,2) Default 0,  
        Evaluation_Rate numeric(18,2) Default 0
    )     
    Declare @Goal table  
    (  
		Total_Rate numeric(18,2) Default 0,  
        Evaluation_Rate Numeric(18,2) Default 0                 
    )     
    Declare @Introspection table  
    (  
		Total_Rate numeric(18,2) Default 0,  
        Evaluation_Rate Numeric(18,2) Default 0                 
    )     
    Declare @Warning table  
    (  
		Deduction_Rate Numeric(18,2)
    )     
    
   
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
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK) 
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
   and I.Emp_ID in   
    ( select Emp_Id from  
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry  
    where cmp_ID = @Cmp_ID   and    
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )   
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )  
    or Left_date is null and @To_Date >= Join_Date)  
    or @To_Date >= left_date  and  @From_Date <= left_date )      
  end  
    
  Declare @Inspection_Status as numeric(18,0)--  check inspection status -- nikunj    
        Declare @Count as numeric(18,0)  
        Declare @Count_2 as numeric(18,0)  
          
        Declare @Temp table --nikunj  
        (  
          Row_Id              Numeric(18,0),  
          Emp_Id              Numeric(18,0),  
          S_Emp_Id            Numeric(18,0),  
          For_Date            DateTime,  
          Title_Name          Varchar(50),  
          Total_Score         Numeric(18,0),  
          Eval_Score          Numeric(18,0),  
          Percentage          Numeric(18,0),  
          Emp_Status          Numeric(18,0),  
          Inspection_Status   Numeric(18,0),  
          Flag      tinyint         
        )          
  
             
If @Emp_Identity=1 -- This is for check whether Employee Superior   
   Begin         
           select @Count=count(Row_ID) from dbo.T0090_Hrms_Final_Score WITH (NOLOCK) where cmp_Id=@Cmp_Id And Emp_Id=@Emp_ID and Emp_Status=1 and Inspection_Status=1 and Appr_Int_ID=@Appr_Int_ID  
             
           If @Count>0          
               Begin          
                  insert into @temp                   
                  select Row_Id,Emp_Id,S_Emp_Id,For_Date,Title_Name,Total_Score,Eval_Score,Percentage,Emp_Status,Inspection_Status,1  from dbo.T0090_Hrms_Final_Score WITH (NOLOCK) where cmp_Id=@Cmp_Id And Emp_Id=@Emp_ID and Emp_Status=1  and Appr_Int_ID=@Appr_Int_ID             
                  select * from @temp             
               End  
           Else      
               Begin       
               ---- when Employee Superior Not Enter Final Goal Details                 
               Select @Count_2=count(Row_ID) from dbo.T0090_Hrms_Final_Score WITH (NOLOCK) where cmp_Id=@Cmp_Id And Emp_Id=@Emp_ID and Emp_Status=1 and Appr_Int_ID=@Appr_Int_ID  
               
          if @Count_2>0
             Begin      
				Set @Flag_2=1
				Select @Row_ID_1=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=1 And Title_Name='Skill Score' 
				Select @Row_ID_2=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=1 And Title_Name='Training  Score' 
				Select @Row_ID_3=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=1 And Title_Name='Goal  Score' 
				Select @Row_ID_4=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=1 And Title_Name='Introspection  Score' 
				Select @Row_ID_5=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=1 And Title_Name='Warning Deduction' 												
             End
          Else 
			 Begin
			 	Set @Flag_2=0
			 End  
                                                
                  select @Max_Rate = max(Rate_Value) from T0030_HRMS_RATING_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID  
     
 --------------Skill Details --------------------  
   
 --set @Exits=0  
 --Select @Exits=Count(Inspection_Status) From dbo.T0090_Hrms_Final_Score  
 --if @Exits > 0  
 ---Begin   
 -- select @Inspection_Status=Inspection_Status From dbo.T0090_Hrms_Final_Score   
    
	insert into @Skill(Total_Rate,Evaluation_Rate)  
    --select count(skill_id)*@Max_Rate as Total_Rate,isnull(sum(skilll_Rate_Given),0) as Evaluation_Rate from dbo.V0090_HRMS_EMP_SKILL_SETTING  ES where for_date>=@From_Date and for_date<=@To_Date and cmp_id=@cmp_id and Emp_ID=@Emp_ID       
     select count(skill_id)*@Max_Rate as Total_Rate,isnull(sum(Skill_Rate_Superior),0) as Evaluation_Rate from dbo.V0090_HRMS_EMP_SKILL_SETTING  ES where for_date>=@From_Date and for_date<=@To_Date and cmp_id=@cmp_id and Emp_ID=@Emp_ID     --sneha on 2 Jan 2014 
    insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Inspection_Status,Flag,Row_ID)  
    Select 'Skill Score',Sum(Total_Rate) as Total_Rate, sum(Evaluation_Rate) as Evaluation_Rate,0,@Flag_2,@Row_ID_1 from @Skill   
   
 ---------------Traininig details -------------------------- 
 --zalak  18022011
		Insert into @Training(Total_no,Total_Rate,Evaluation_Rate)    
		select  count(*),count(*)*100 ,sum(isnull(sup_score,0)) from V0140_HRMS_TRAINING_Feedback ES1 where Cmp_ID=@Cmp_ID and es1.sup_feedback=1 and ES1.Emp_ID=@Emp_ID And (@From_Date>=Training_Date And @From_Date<= Training_End_Date Or @To_Date >= Training_Date And @To_Date <=Training_End_Date Or Training_Date>=@From_Date And Training_Date<=@To_Date Or Training_End_Date>=@From_Date And Training_End_Date<=@To_Date)
	--Select count(Skill_ID)*@Max_Rate as Total_Rate, isnull(sum(Sup_Eval_Rate),0) as Evaluation_Rate from dbo.V0130_HRMS_Traininig_Feedback_Super_Details ES1 where Training_date >=@From_Date and Training_date <=@To_Date and Cmp_ID=@Cmp_ID and ES1.Emp_ID=@Emp_ID  
	insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Flag,Row_ID)  
	Select 'Training  Score',Sum(Total_Rate) as Total_Rate, sum(Evaluation_Rate) as Evaluation_Rate,@Flag_2,@Row_ID_2 from @Training  
  
 --------------Goal Setting ------------------------
	select @appr_detail_id = appr_detail_id from T0090_Hrms_Appraisal_Initiation_Detail WITH (NOLOCK) where appr_int_id = @appr_int_id and Emp_ID=@Emp_ID ---Ripal 14July2014
	  
	Insert into @Goal(Total_Rate,Evaluation_Rate)  
	Select count(Emp_goal_ID)*@Max_Rate as Total_Rate,isnull(sum(Goal_Rate),0) as Evaluation_Rate 
	from  dbo.V0091_Employee_Goal_Score  
	where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Emp_Status=1 and appr_detail_id=@appr_detail_id  --change to @appr_detail_id by Ripal 14July2014
	And (@From_Date>=Start_Date And @From_Date<= End_Date Or @To_Date >= Start_Date And @To_Date <=End_Date Or Start_Date>=@From_Date And Start_Date<=@To_Date Or End_Date>=@From_Date And End_Date<=@To_Date)
      
      
	insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Flag,Row_ID)  
	Select 'Goal  Score',Sum(Total_Rate) as Total_Rate, sum(Evaluation_Rate) as Evaluation_Rate,@Flag_2,@Row_ID_3 from @Goal    
    
 -----------------Introspection Setting -------------------------  
	Insert into @introspection(Total_Rate,Evaluation_Rate)  
	Select count(Que_Id)*@Max_Rate as Total_Rate,isnull(sum(Que_Rate),0) as Que_Rate from dbo.V0090_HRMS_Employee_Question ES1 where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Appr_Int_ID=@Appr_Int_Id and Emp_Status=1       
	--Select count(Que_Id)*@Max_Rate as Total_Rate,isnull(sum(Que_Rate),0) as Que_Rate from dbo.V0090_HRMS_Employee_Question ES1 where For_date >=@From_Date and For_date <=@To_Date and Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Emp_Status=1        
    
------------------------------------------------------------------------  
   
	insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Flag,Row_ID)  
	Select 'Introspection  Score',Sum(Total_Rate) as Total_Rate, sum(Evaluation_Rate) as Evaluation_Rate,@Flag_2,@Row_ID_4 from @introspection 
   
   -----Warning Deduction Rate------------------
   
	insert into @Warning
 	Select Sum(Deduct_Rate) From dbo.V0100_Warning_Details where Warr_date Between @From_Date and @To_Date and Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID            
     
    insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Flag,Row_ID)
    Select 'Warning Deduction',0 As Total_Rate,isnull((Deduction_Rate-(Deduction_Rate*2)),0) as Evaluation_Rate,@Flag_2,@Row_ID_5 from @Warning              
   
	Select * from #Final_Score    
	
	Drop Table #Final_Score	  
    End            
 End             
                 
Else If @Emp_Identity=0   -- This is for that Employee Own  
        Begin  
           select @Count=count(Row_ID) from dbo.T0090_Hrms_Final_Score WITH (NOLOCK) where cmp_Id=@Cmp_Id And Emp_Id=@Emp_ID and Emp_Status=0 and Inspection_Status=1   and Appr_Int_ID=@Appr_Int_ID              
             
           If @Count>0          
               Begin          
                 insert into @temp                   
     select Row_Id,Emp_Id,S_Emp_Id,For_Date,Title_Name,Total_Score,Eval_Score,Percentage,Emp_Status,Inspection_Status,1  from dbo.T0090_Hrms_Final_Score WITH (NOLOCK) where cmp_Id=@Cmp_Id And Emp_Id=@Emp_ID and Emp_Status=0   and Appr_Int_ID=@Appr_Int_ID            
                 select * from @temp             
              End          
          Else                
              Begin  
              ---- when Employee Not Enter Final Goal Details  
              
          Select @Count_2=count(Row_ID) from dbo.T0090_Hrms_Final_Score WITH (NOLOCK) where cmp_Id=@Cmp_Id And Emp_Id=@Emp_ID and Emp_Status=0 and Appr_Int_ID=@Appr_Int_ID  
              
          if @Count_2>0
              Begin              
				Set @Flag_2=1				
				Select @Row_ID_1=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=0 And  Title_Name='Skill Score' 
				Select @Row_ID_2=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=0 And  Title_Name='Training  Score' 
				Select @Row_ID_3=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=0 And  Title_Name='Goal  Score' 
				Select @Row_ID_4=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=0 And  Title_Name='Introspection  Score' 
				Select @Row_ID_5=Row_Id From T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID And cmp_Id=@Cmp_ID And Emp_Status=0 And  Title_Name='Warning Deduction' 								
              End
          Else 
			 Begin
				Set @Flag_2=0
			 End  
              
                               
        select @Max_Rate = max(Rate_Value) from T0030_HRMS_RATING_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID  
     
 --------------Skill Details --------------------  
    
	insert into @Skill(Total_Rate,Evaluation_Rate)  
   -- select count(skill_id)*@Max_Rate as Total_Rate,isnull(sum(skilll_Rate_Given),0)as Evaluation_Rate from dbo.V0090_HRMS_EMP_SKILL_SETTING  ES where for_date>=@From_Date and for_date<=@To_Date and cmp_id=@cmp_id and Emp_ID=@Emp_ID  
          select count(skill_id)*@Max_Rate as Total_Rate,isnull(sum(Skill_Rate_Employee),0)as Evaluation_Rate from dbo.V0090_HRMS_EMP_SKILL_SETTING  ES where for_date>=@From_Date and for_date<=@To_Date and cmp_id=@cmp_id and Emp_ID=@Emp_ID  -- sneha on 2 Jan 2014
     
    insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Inspection_Status,Flag,Row_Id)  
  --  Select 'Skill Score',Sum(Total_Rate) as Total_Rate, sum(Evaluation_Rate) as Evaluation_Rate,0,@Flag_2,@Row_ID_1 from @Skill   
    Select 'Skill Score',Sum(Total_Rate) as Total_Rate, sum(Evaluation_Rate) as Evaluation_Rate,0,@Flag_2,@Row_ID_1 from @Skill   
---------------Traininig details --------------------------  
	--zalak 18022011
	Insert into @Training(Total_no,Total_Rate,Evaluation_Rate)    
	select  count(*),count(*)* 100 ,sum(isnull(sup_score,0)) from V0140_HRMS_TRAINING_Feedback ES1 where Cmp_ID=@Cmp_ID and es1.emp_feedback=1 and ES1.Emp_ID=@Emp_ID And (@From_Date>=Training_Date And @From_Date<= Training_End_Date Or @To_Date >= Training_Date And @To_Date <=Training_End_Date Or Training_Date>=@From_Date And Training_Date<=@To_Date Or Training_End_Date>=@From_Date And Training_End_Date<=@To_Date)  --sum(isnull(sup_score,0)) change by ripal 15July2014 as we only going to consider admin score
	--select  count(*),count(*)* 100 ,sum(isnull(emp_score,0)) from V0140_HRMS_TRAINING_Feedback ES1 where Cmp_ID=@Cmp_ID and es1.emp_feedback=1 and ES1.Emp_ID=@Emp_ID And (@From_Date>=Training_Date And @From_Date<= Training_End_Date Or @To_Date >= Training_Date And @To_Date <=Training_End_Date Or Training_Date>=@From_Date And Training_Date<=@To_Date Or Training_End_Date>=@From_Date And Training_End_Date<=@To_Date)
    
	insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Flag,Row_ID)  
	Select 'Training  Score',Sum(Total_Rate) as Total_Rate, sum(Evaluation_Rate) as Evaluation_Rate,@Flag_2,@Row_ID_2 from @Training	
	
--------------Goal Setting ------------------------  
    select @appr_detail_id = appr_detail_id from T0090_Hrms_Appraisal_Initiation_Detail WITH (NOLOCK)
						where appr_int_id = @appr_int_id and Emp_ID=@Emp_ID ---Ripal 14July2014
    
	Insert into @Goal(Total_Rate,Evaluation_Rate)  
	Select  count(Emp_goal_ID)*@Max_Rate as Total_Rate,isnull(sum(Goal_Rate),0) as Evaluation_Rate 
	from dbo.V0091_Employee_Goal_Score 
	where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Emp_Status=0 and appr_detail_id=@appr_detail_id  --change to @appr_detail_id by Ripal 14July2014 
	And (@From_Date>=Start_Date And @From_Date<= End_Date Or @To_Date >= Start_Date And @To_Date <=End_Date Or Start_Date>=@From_Date And Start_Date<=@To_Date Or End_Date>=@From_Date And End_Date<=@To_Date)	
	--Select  count(Emp_goal_ID)*@Max_Rate as Total_Rate,isnull(sum(Goal_Rate),0) as Evaluation_Rate from dbo.V0091_Employee_Goal_Score where Start_date >=@From_Date and End_Date <=@To_Date and Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Emp_Status=0 
      
	insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Flag,Row_ID)  
	Select 'Goal  Score',Sum(Total_Rate) as Total_Rate, sum(Evaluation_Rate) as Evaluation_Rate,@Flag_2,@Row_ID_3 from @Goal
    
-----------------Introspection Setting -------------------------  

	Insert into @Introspection(Total_Rate,Evaluation_Rate)  
	Select count(Que_Id)*@Max_Rate as Total_Rate,isnull(sum(Que_Rate),0)as Que_Rate from dbo.V0090_HRMS_Employee_Question ES1 where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Emp_Status=0 and Appr_Int_ID=@Appr_Int_ID       
	--Select count(Que_Id)*@Max_Rate as Total_Rate,isnull(sum(Que_Rate),0)as Que_Rate from dbo.V0090_HRMS_Employee_Question ES1 where For_date >=@From_Date and For_date <=@To_Date and Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Emp_Status=0       

       
	insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Flag,Row_ID)  
	Select 'Introspection  Score',isnull(Sum(Total_Rate),0)As Total_Rate,isnull(sum(Evaluation_Rate),0) as Evaluation_Rate,@Flag_2,@Row_ID_4 from @Introspection 
       
--------------------Warning Deduction------3-June-2010
     
    insert into @Warning
    Select Sum(Deduct_Rate) From dbo.V0100_Warning_Details where Warr_date Between @From_Date and @To_Date and Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID            
    
       
	insert into #Final_Score(Title_Name,Total_Score,Eval_Score,Flag,Row_ID)
	Select 'Warning Deduction',0 As Total_Rate,isnull((Deduction_Rate-(Deduction_Rate*2)),0) as Evaluation_Rate,@Flag_2,@Row_ID_5 from @Warning                       
      
	Select * from #Final_Score      
		
	Drop Table #Final_Score	
		 
    End         
End     
          
    
  

