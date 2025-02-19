

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Select_DESIG_Chart_Export]     
@Cmp_Id numeric(18,0),  
@Emp_Type_Id numeric(18,0)        
As  
  
Begin  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
   
 CREATE table #Emp_Info  
 (    
    Desig_Id  Numeric(18,0),  
    Desig_Name nVarchar(50),      
    Emp_Code nvarchar(MAX),  
    Emp_Full_Name nvarchar(MAX),  
    Date_of_Birth nvarchar(50),  
    Date_Of_Join nvarchar(50),  
    Emp_Left_Date nvarchar(50),  
    Branch_Name nvarchar(100)            
 )   
  
 Declare @Desig_Id As Numeric(18,0)  
 Declare @Desig_Name As Nvarchar(30)  
 Declare @Emp_Code nvarchar(MAX)  
 Declare @Emp_Full_Name nvarchar(MAX)  
 Declare @Date_of_Birth nvarchar(50)  
 Declare @Date_Of_Join nvarchar(50)    
   
   
   
 If @Emp_Type_Id=0   
  Begin  
   set @Emp_Type_Id=null  
  End  
   
 Declare @Inti As Numeric(10)   
   
 Set @Inti=0   
   
   
 DECLARE Cur_Emp_Info CURSOR FOR   
 select Desig_ID,Desig_Name  from T0040_DESIGNATION_MASTER WITH (NOLOCK) Where Cmp_ID =@Cmp_ID   
 OPEN Cur_Emp_Info  
  Fetch Next From Cur_Emp_Info Into @Desig_Id,@Desig_Name    
  While @@Fetch_Status = 0  
   Begin   
     Insert Into #Emp_Info  
      Select DM.Desig_ID,DM.Desig_Name ,T0080_EMP_MASTER.Alpha_Emp_Code,T0080_EMP_MASTER.Emp_First_Name,  
      CONVERT(varchar(10),T0080_EMP_MASTER.Date_Of_Birth,103), CONVERT(varchar(10),T0080_EMP_MASTER.Date_Of_Join,103),CONVERT(varchar(10),T0080_EMP_MASTER.Emp_Left_Date,103),T0030_BRANCH_MASTER.Branch_Name   
    FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN  
    dbo.T0095_INCREMENT WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID AND   
    dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0095_INCREMENT.Emp_ID   
    Left Outer Join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On  
    T0080_EMP_MASTER.Desig_Id=DM.Desig_ID  INNER JOIN  
    dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID AND   
    dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID  
    Where T0080_EMP_MASTER.Desig_Id =@Desig_Id and T0095_INCREMENT.Emp_ID in (select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join   
    ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)  
    where Increment_Effective_date <= GETDATE()  
    and Cmp_ID = @Cmp_ID  
    group by emp_ID  ) Qry on  
    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  
    Where Cmp_ID = @Cmp_ID   
    and Isnull(Type_ID,0) = isnull(@Emp_Type_Id ,Isnull(Type_ID,0))  
    and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
	and I.Emp_ID in       
			( select Emp_Id from      
			(select emp_id, cmp_ID, join_Date, isnull(left_Date, getdate()) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry      
			where cmp_ID = @Cmp_ID   and        
			(( getdate()  >= join_Date  and  getdate() <= left_date )       
			or ( getdate()  >= join_Date  and getdate() <= left_date )      
			or Left_date is null and getdate() >= Join_Date)      
			or getdate() >= left_date  and  getdate() <= left_date ) )   
   Fetch Next From Cur_Emp_Info Into @Desig_Id,@Desig_Name  
   End  
 Close Cur_Emp_Info   
 Deallocate Cur_Emp_Info     
  
 Select ROW_NUMBER() OVER(ORDER BY desig_id ) as Srno ,Desig_Name,Emp_Code,Emp_Full_Name,  
 CONVERT(VARCHAR(11), Date_of_Birth, 106) as Date_of_Birth,CONVERT(VARCHAR(11), Date_Of_Join, 106) as Date_Of_Join,  
 CONVERT(VARCHAR(11), Emp_Left_Date, 106) as Emp_Left_Date,  
 Branch_Name  
  from #Emp_Info --order by Desig_Id   
   
Drop Table #Emp_Info  
  
  
End  

