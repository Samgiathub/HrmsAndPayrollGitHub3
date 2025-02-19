



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LEAVE_STATUS]  
  @Cmp_ID  Numeric  
 ,@From_Date  Datetime  
 ,@To_Date  Datetime  
 ,@Emp_ID  Numeric  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
 
  declare @Encash as numeric(18,1)	--Ankit 10052013
  declare @Closing as numeric(18,1)  
  declare @Opening as numeric(18,1)  
  declare @Earn as numeric(18,1)  
  declare @Adj_LMark as numeric(18,1)  
  declare @Adj_Absent as numeric(18,1)   
  declare @Total_Adj as numeric(18,1)  
    
  
  
 if @Emp_ID = 0  
  set @Emp_ID = null  
    
    
insert into  #Emp_Leave_Bal 
SELECT @Cmp_ID,@Emp_ID,@To_Date ,0,0,0,0,0,LT.LEAVE_ID FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN  
		( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
			WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@To_DATE
		GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
		LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID and isnull(LM.Default_Short_Name,'') <> 'COMP' -- Changed By Gadriwala Muslim 01102014
		WHERE LEAVE_TYPE <>'Company Purpose'

		Declare @Leave_ID numeric(18,0)
		Declare curleavestaus cursor for
		select Leave_ID from #Emp_Leave_Bal where Emp_ID=@Emp_ID
		open curleavestaus
				fetch next from curleavestaus into @Leave_ID
				while @@fetch_status = 0
					begin
					
							update #Emp_Leave_Bal   
						   set Leave_Opening = leave_Bal.Leave_Closing  
						   From #Emp_Leave_Bal  LB Inner join    
						   ( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join   
							( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date <= @From_Date and Cmp_ID = @Cmp_ID  
							and LEave_ID = @Leave_ID   
							Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID  
							)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID   where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID
						  
						   update #Emp_Leave_Bal   
						   set Leave_Opening = leave_Bal.Leave_Opening  
						   From #Emp_Leave_Bal  LB Inner join    
						   ( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join   
							( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date = @From_Date and Cmp_ID = @Cmp_ID  
							and LEave_ID = @Leave_ID   
							Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID  
							)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID  
						  
						     
						   update #Emp_Leave_Bal   
						   set Leave_Credit = Q.Leave_Credit  
						   From #Emp_Leave_Bal  LB Inner join    
						   ( select Emp_ID , Leave_ID ,Sum(Leave_Credit) as Leave_Credit From T0140_LEave_Transaction WITH (NOLOCK)  
							Where Cmp_ID = @Cmp_ID and LEave_ID = @Leave_ID and For_Date >=@From_date and For_Date <=@To_Date  
							Group by Emp_ID ,LEave_ID)Q on  
							lb.LEave_ID = Q.LEave_ID and Lb.emp_ID = Q.Emp_ID where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID 
						     
						   update #Emp_Leave_Bal   
						   set Leave_Used = Q.Leave_Used  
						   From #Emp_Leave_Bal  LB Inner join    
						   ( select Emp_ID , Leave_ID ,Sum(Leave_Used) as Leave_Used From T0140_LEave_Transaction WITH (NOLOCK)  
							Where Cmp_ID = @Cmp_ID and LEave_ID = @Leave_ID and For_Date >=@From_date and For_Date <=@To_Date  
							Group by Emp_ID ,LEave_ID)Q on  
							lb.LEave_ID = Q.LEave_ID and Lb.emp_ID = Q.Emp_ID  where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID
						  
						  update #Emp_Leave_Bal   --Ankit 10052013
							   set @Encash = leave_Bal.Leave_encash_days
							   From #Emp_Leave_Bal  LB Inner join    
							   ( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join   
								( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date <= @To_Date and Cmp_ID = @Cmp_ID  
								and LEave_ID = @Leave_ID   
								Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID  
								)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID   
						  
						   update #Emp_Leave_Bal   
						   set Leave_Closing = leave_Bal.Leave_Closing   
						   From #Emp_Leave_Bal  LB Inner join    
						   ( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join   
							( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date <= @To_Date and Cmp_ID = @Cmp_ID  
							and LEave_ID = @Leave_ID   
							Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID  
							)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID where LB.Leave_ID=@Leave_ID And LB.Emp_Id=@Emp_ID   
						  
			  fetch next from curleavestaus into @Leave_ID
			end 
			close curleavestaus
			deallocate curleavestaus
 
    
  
 RETURN   
  
  
  

