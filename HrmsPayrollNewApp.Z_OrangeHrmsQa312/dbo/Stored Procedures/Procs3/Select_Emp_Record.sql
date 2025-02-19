

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Select_Emp_Record]     
@Cmp_Id numeric(18,0),  
@Desig_Id numeric(18,0),  
@Emp_Type_Id numeric(18,0)  
        
As  
  
Begin  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
   
if @Emp_Type_Id =0  
 Set @Emp_Type_Id=null   


 CREATE table #Emp_Cons 
 (      
  Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      
         
       
  begin      
   Insert Into #Emp_Cons      
      select emp_id,branch_id,Increment_ID from V_Emp_Cons where 
      cmp_id=@Cmp_ID 
   and Isnull(Type_ID,0) = isnull(@Emp_Type_Id ,Isnull(Type_ID,0))      
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
      and Increment_Effective_Date <= GETDATE() 
      and 
              ( (GETDATE()  >= join_Date  and  GETDATE() <= left_date )      
				or ( GETDATE()  >= join_Date  and GETDATE() <= left_date )      
				or (Left_date is null and GETDATE() >= Join_Date)      
				or (GETDATE() >= left_date  and  GETDATE() <= left_date ))
				order by Emp_ID
				
	delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)
		where  Increment_effective_Date <= GETDATE()
		group by emp_ID)
		end
      
   
 --select Emp_id,Emp_Full_Name as Emp_Full_Name_Old,cast(Emp_Code as varchar) + ' - '+Emp_Full_Name as Emp_Full_Name,  
 --  cast(Emp_Code as varchar) + ' - '+ISNULL(Emp_Name_Russian,Emp_Full_Name) as Emp_Name_Russian from T0080_EMP_MASTER where Emp_ID in(select    
  
  
   
 SELECT DENSE_RANK() OVER   
    (ORDER BY dbo.T0080_EMP_MASTER.Emp_ID asc) AS SrNo,dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Full_Name1, dbo.T0080_EMP_MASTER.Alpha_Emp_Code,   
            dbo.T0080_EMP_MASTER.Alpha_Code,dbo.T0095_INCREMENT.Branch_ID, dbo.T0095_INCREMENT.Desig_Id,   
            dbo.T0030_BRANCH_MASTER.Branch_Name,dbo.T0080_EMP_MASTER.Emp_Full_Name as Emp_Full_Name_Old,cast(dbo.T0080_EMP_MASTER.Alpha_Emp_Code as varchar(30)) + ' - '+dbo.T0080_EMP_MASTER.Emp_Full_Name as Emp_Full_Name, CONVERT(VARCHAR(11), dbo.T0080_EMP_MASTER.Date_Of_Join, 106) as Date_Of_Join,  
   CONVERT(VARCHAR(11), dbo.T0080_EMP_MASTER.Date_Of_Birth, 106) as Date_Of_Birth,  
   dbo.F_GET_AGE(Date_Of_Join,GETDATE(),'Y','N')  as Work_Since,  
   dbo.F_GET_AGE(Date_Of_Birth,GETDATE(),'Y','N') as Age,  
   dbo.T0080_EMP_MASTER.Emp_Left,  
   CONVERT(VARCHAR(11),dbo.T0080_EMP_MASTER.Emp_Left_Date, 106) as Emp_Left_Date    
    
    
     
 FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN  
		#Emp_Cons EC on dbo.T0080_EMP_MASTER.Emp_ID = EC.Emp_ID Inner Join
         dbo.T0095_INCREMENT WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID AND   
         dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0095_INCREMENT.Emp_ID INNER JOIN  
         dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID AND   
         dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID  
     Where T0095_INCREMENT.Emp_ID in (select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join   
     ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK) 
     where Increment_Effective_date <= GETDATE()  
     and Cmp_ID = @Cmp_ID  
     group by emp_ID  ) Qry on  
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date          
   Where Cmp_ID = @Cmp_ID   
   and Isnull(Cat_ID,0) = Isnull(null ,Isnull(Cat_ID,0))  
   and Branch_ID = isnull(null ,Branch_ID)  
   and Grd_ID = isnull(null ,Grd_ID)  
   and isnull(Dept_ID,0) = isnull(null ,isnull(Dept_ID,0))  
   and Isnull(Type_ID,0) = isnull(@Emp_Type_Id ,Isnull(Type_ID,0))  
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
   and I.Emp_ID = isnull(null ,I.Emp_ID) )  
       
     --dbo.T0095_INCREMENT.Emp_ID in (Select emp_id from T0095_Increment where Cmp_ID=@Cmp_Id and emp_id in(select emp_id  from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Emp_Left='N') and Desig_Id=@Desig_Id)  
          --and T0095_INCREMENT.Cmp_ID=@Cmp_Id and T0095_INCREMENT.Desig_Id =@Desig_Id  and T0095_INCREMENT.Type_ID =ISNULL(@Emp_Type_Id,T0095_INCREMENT.Type_ID)      
                
  
End  

