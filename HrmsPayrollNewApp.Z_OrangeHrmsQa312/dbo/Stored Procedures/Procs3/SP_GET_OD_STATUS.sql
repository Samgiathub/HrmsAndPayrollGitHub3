



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_OD_STATUS]  
  @Cmp_ID  Numeric  
 ,@From_Date  Datetime  
 ,@To_Date  Datetime  
 ,@Emp_ID  Numeric  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
  
  declare @Closing as numeric(18,1)  
  declare @Opening as numeric(18,1)  
  declare @Earn as numeric(18,1)  
  declare @Adj_LMark as numeric(18,1)  
  declare @Adj_Absent as numeric(18,1)   
  declare @Total_Adj as numeric(18,1)  
    
  Declare @Emp_Leave_Bal table  
   (  
    Cmp_ID   numeric,  
    Emp_ID   numeric,  
    For_Date  datetime,  
    Leave_Opening numeric(18,1),  
    Leave_Credit numeric(18,1),  
    Leave_Used  numeric(18,1),  
    Leave_Closing numeric(18,1),  
    Leave_ID  numeric  
   )   
  
    

 if @Emp_ID = 0  
  set @Emp_ID = null  
    
    
insert into  @Emp_Leave_Bal 
SELECT @Cmp_ID,@Emp_ID,@To_Date ,0,0,0,0,LT.LEAVE_ID FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN  
		( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION  WITH (NOLOCK)
			WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@To_DATE
		GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
		LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID and isnull(LM.Default_Short_Name,'') <> 'COMP'  -- changed By Gadriwala 01102014
		WHERE LEAVE_TYPE ='Company Purpose'

		Declare @Leave_ID numeric(18,0)
		Declare curleavestaus cursor for
		select Leave_ID from @Emp_Leave_Bal where Emp_ID=@Emp_ID
		open curleavestaus
				fetch next from curleavestaus into @Leave_ID
				while @@fetch_status = 0
					begin
					
							update @Emp_Leave_Bal   
						   set Leave_Opening = leave_Bal.Leave_Closing  
						   From @Emp_Leave_Bal  LB Inner join    
						   ( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join   
							( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date <= @From_Date and Cmp_ID = @Cmp_ID  
							and LEave_ID = @Leave_ID   
							Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID  
							)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID   where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID
						  
						   update @Emp_Leave_Bal   
						   set Leave_Opening = leave_Bal.Leave_Opening  
						   From @Emp_Leave_Bal  LB Inner join    
						   ( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join   
							( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date = @From_Date and Cmp_ID = @Cmp_ID  
							and LEave_ID = @Leave_ID   
							Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID  
							)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID  
						  
						     
						   update @Emp_Leave_Bal   
						   set Leave_Credit = Q.Leave_Credit  
						   From @Emp_Leave_Bal  LB Inner join    
						   ( select Emp_ID , Leave_ID ,Sum(Leave_Credit) as Leave_Credit From T0140_LEave_Transaction WITH (NOLOCK) 
							Where Cmp_ID = @Cmp_ID and LEave_ID = @Leave_ID and For_Date >=@From_date and For_Date <=@To_Date  
							Group by Emp_ID ,LEave_ID)Q on  
							lb.LEave_ID = Q.LEave_ID and Lb.emp_ID = Q.Emp_ID where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID 
						     
						   update @Emp_Leave_Bal   
						   set Leave_Used = Q.Leave_Used  
						   From @Emp_Leave_Bal  LB Inner join    
						   ( select Emp_ID , Leave_ID ,Sum(Leave_Used) as Leave_Used From T0140_LEave_Transaction WITH (NOLOCK)   
							Where Cmp_ID = @Cmp_ID and LEave_ID = @Leave_ID and For_Date >=@From_date and For_Date <=@To_Date  
							Group by Emp_ID ,LEave_ID)Q on  
							lb.LEave_ID = Q.LEave_ID and Lb.emp_ID = Q.Emp_ID  where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID
						  
						   update @Emp_Leave_Bal   
						   set Leave_Closing = leave_Bal.Leave_Closing   
						   From @Emp_Leave_Bal  LB Inner join    
						   ( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join   
							( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date <= @To_Date and Cmp_ID = @Cmp_ID  
							and LEave_ID = @Leave_ID   
							Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID  
							)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID   
						  
			  fetch next from curleavestaus into @Leave_ID
			end 
			close curleavestaus
			deallocate curleavestaus
 
    
  
 select el.*,Leave_Name,Emp_Full_Name,Emp_Code,g.Grd_Name,b.BRanch_Address,b.Comp_name  
  ,b.Branch_Name,d.Dept_Name,Desig_Name,Cmp_Name,Cmp_Address   
  ,@From_Date P_From_Date ,@To_Date P_To_Date  
    
 From @Emp_Leave_Bal el Inner Join T0040_LEAVE_MASTER as l WITH (NOLOCK) on el.Leave_ID = l.Leave_ID inner join  
  T0080_EMP_MASTER e  WITH (NOLOCK) on el.Emp_ID =e.Emp_ID inner join   
  (select I.Emp_Id ,Grd_ID,Branch_ID,Dept_ID,Desig_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join   
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK) 
     where Increment_Effective_date <= @To_Date  
     and Cmp_ID = @Cmp_ID  
     group by emp_ID  ) Qry on  
   I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date)IQ on el.Emp_ID =iq.Emp_ID Inner join  
  T0040_GRADE_MASTER  g WITH (NOLOCK) on iq.Grd_ID =g.Grd_ID inner join   
  T0030_Branch_Master b WITH (NOLOCK) on iq.Branch_ID = b.Branch_ID left outer join  
  T0040_Department_Master d WITH (NOLOCK) on iq.dept_ID =d.Dept_ID  left outer join   
  T0040_Designation_Master dgm WITH (NOLOCK) on iq.desig_ID =dgm.Desig_ID inner join   
  T0010_Company_master as CM WITH (NOLOCK) on e.cmp_ID = cm.Cmp_ID   
  
  
 RETURN   
  
  
  

