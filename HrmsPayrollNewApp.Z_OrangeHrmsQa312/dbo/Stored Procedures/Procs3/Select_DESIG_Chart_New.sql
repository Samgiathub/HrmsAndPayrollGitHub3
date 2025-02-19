


--exec Select_DESIG_Chart_New @cmp_id=1,@Employee_Type=0
-- =============================================  
-- Author:  <Chirag Patel>  
-- Do not change this sp  
-- Description: <Description,,>  
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================  
CREATE PROCEDURE [dbo].[Select_DESIG_Chart_New]     
@Cmp_Id numeric(18,0),
@Employee_Type numeric(18,0)  
        
As    
Begin  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
   
 CREATE table #Desig_Chart  
  (         
     Id Numeric(18,0),  
     Desig_Id Numeric(18,0),  
     Desig_Name nVarchar(50),     
     Parent_Desig_Id Numeric(18,0),  
     Emp_Count numeric(18,0)        
  )   
  
 Declare @Desig_Id As Numeric(18,0)  
 Declare @Desig_Name As Nvarchar(30)  
 Declare @Desig_Name_Rus As Nvarchar(30)  
 Declare @Desig_Name_KZK As Nvarchar(30)  
 Declare @Id As Varchar(30)  
 Declare @PID As Numeric(18,0)  
 Declare @Emp_Count as numeric(18,0)  
 Declare @Total_Emp As numeric(18,0)  
   
 Declare @Inti As Numeric(10)  
   
 if @Employee_Type =0  
  set @Employee_Type=null  
----------------------------Root-------------------------  
 Insert Into #Desig_Chart(Id,Desig_Id,Desig_Name,Parent_Desig_Id,Emp_Count)   
     Values(1,0,'Organization-Chart',0,0)  
----------------------------Root-------------------------   
------------------------------------------------- Policies -------------------------------------------------------  
 Set @Inti=2   
   
   
   
 --select @Total_Emp=COUNT(desig_id) from T0095_Increment where Cmp_ID=@Cmp_Id and emp_id in(select emp_id  from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Emp_Left='N')   
   
 Select @Total_Emp = count(I.Emp_ID) from T0095_Increment I WITH (NOLOCK) inner join   
     ( select max(Increment_effective_Date) as For_Date,Emp_ID From T0095_Increment WITH (NOLOCK) 
     where Increment_Effective_date <= getdate()  
     and Cmp_ID = @cmp_id  
     group by emp_ID  ) Qry on  
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date 
      
         
   Where Cmp_ID = @cmp_id   
   and Isnull(Type_ID,0) = isnull(@Employee_Type ,Isnull(Type_ID,0))  
	and I.Emp_ID in       
			( select Emp_Id from      
			(select emp_id, cmp_ID, join_Date, isnull(left_Date, getdate()) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry      
			where cmp_ID = @Cmp_ID   and        
			(( getdate()  >= join_Date  and  getdate() <= left_date )       
			or ( getdate()  >= join_Date  and getdate() <= left_date )      
			or Left_date is null and getdate() >= Join_Date)      
			or getdate() >= left_date  and  getdate() <= left_date )   
  
   
 DECLARE Cur_Policies CURSOR FOR   
 select Desig_ID,Desig_Name,Parent_ID from T0040_DESIGNATION_MASTER WITH (NOLOCK) Where Cmp_ID =@Cmp_ID   
 OPEN Cur_Policies  
  Fetch Next From Cur_Policies Into @Desig_Id,@Desig_Name,@PID
  While @@Fetch_Status = 0  
   Begin   
       set @Emp_Count =0  
        
       select @pid=id from #Desig_Chart where Desig_Id =@pid        
       
      select @Emp_Count=count(I.Emp_ID) from T0095_Increment I WITH (NOLOCK) inner join   
       ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)  
       where Increment_Effective_date <= getdate()  
       and Cmp_ID = @cmp_id  
       group by emp_ID  ) Qry on  
       I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  
        Where Cmp_ID = @cmp_id   
        and Isnull(Type_ID,0) = isnull(@Employee_Type ,Isnull(Type_ID,0))  
        and Isnull(Desig_ID,0) = isnull(@Desig_Id ,Isnull(Desig_ID,0))  
		and I.Emp_ID in       
			( select Emp_Id from      
			(select emp_id, cmp_ID, join_Date, isnull(left_Date, getdate()) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry      
			where cmp_ID = @Cmp_ID   and        
			(( getdate()  >= join_Date  and  getdate() <= left_date )       
			or ( getdate()  >= join_Date  and getdate() <= left_date )      
			or Left_date is null and getdate() >= Join_Date)      
			or getdate() >= left_date  and  getdate() <= left_date )
        
       
       Insert Into #Desig_Chart(Id,Desig_Id,Desig_Name,Parent_Desig_Id,Emp_Count)   
     Values(@Inti,@Desig_Id,@Desig_Name,@PID,ISNULL(@Emp_Count,0))  
        
     Set @Inti=@Inti+1  
       
   Fetch Next From Cur_Policies Into @Desig_Id,@Desig_Name,@PID
   End  
 Close Cur_Policies   
 Deallocate Cur_Policies    
   
 --------------------------------------------  
 Declare @Temp_Id as numeric  
   
 DECLARE Cur_Policies CURSOR FOR   
 select Id,Desig_ID,Parent_Desig_Id  from #Desig_Chart  where Parent_Desig_Id > (select MAX(id) from #Desig_Chart)  
 OPEN Cur_Policies  
  Fetch Next From Cur_Policies Into @Temp_Id,@Desig_Id,@PID  
  While @@Fetch_Status = 0  
   Begin   
    select @Temp_Id=Id  from #Desig_Chart where Desig_Id =@PID       
    update #Desig_Chart set Parent_Desig_Id =@Temp_Id where Desig_Id =@Desig_Id and Parent_Desig_Id=@pid        
   Fetch Next From Cur_Policies Into @Temp_Id,@Desig_Id,@PID  
   End  
 Close Cur_Policies   
 Deallocate Cur_Policies     
   
  
------------------------------------------------- Policies -------------------------------------------------------  
Update #Desig_Chart set Parent_Desig_Id=1 where Desig_Name='MANAGER'  
Update #Desig_Chart set Parent_Desig_Id=1 where Parent_Desig_Id is null  
Update #Desig_Chart set Emp_Count=@Total_Emp where Desig_Name ='Organization-Chart' 
 
   Select Id,Desig_Id,Desig_Name +' ( ' +   
   case   
    when Emp_Count= 0 then CAST(Emp_Count as nvarchar(4))  
    Else   
             cast('<b><font color="blue">'+CAST(Emp_Count as nvarchar(4))+'</font></b>' as nvarchar(max))  
             end    
   +' ) ' as Desig_Name,Parent_Desig_Id,Emp_Count From #Desig_Chart    
 
  
Drop Table #Desig_Chart  
  
  
End  
  

