
  
CREATE PROCEDURE [dbo].[P0080_CANTEEN_APPLICATION]  
  @App_Id numeric (9) OUTPUT  
 ,@Cmp_Id numeric(9)  
 ,@Receive_Date datetime   
 ,@Emp_Id numeric(9)   
 ,@Emp_Name varchar(max)   
 ,@Designation Numeric(9)  
 ,@Department Numeric(9)   
 ,@Food varchar(100)   
 ,@Duration int   
 ,@From_Date datetime
 ,@To_Date datetime   
 ,@Canteen_Name varchar(100)   
 ,@App_No nvarchar(20)=''   
 ,@tran_type  varchar(1)  
 ,@LoginID int 
 ,@Description varchar(max)
 ,@App_Type nvarchar(50)
 ,@Guest_Type_Id int
 ,@Guest_Name nvarchar(200)
 ,@Guest_Count numeric (9)
 AS  
 
 if @App_Type = 'Self'
 Begin
	set @Guest_Type_Id = null
	set @Guest_Name = null
 end
 
 Else if @App_Type = 'Employee'
 Begin
	set @Guest_Type_Id = null
	set @Guest_Name = null
 end
 


 If @tran_type  = 'I'    
  Begin    

	if @App_Type = 'Self'
	begin
		
		
		if @Duration = 1
		begin
			If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food 
			and Convert(varchar,@From_Date,112) between Convert(varchar,From_Date,112) and  Convert(varchar,To_Date,112)
			and Canteen_Name = @Canteen_Name and App_Type = @App_Type)
			--and Convert(varchar,To_Date,112) <= Convert(varchar,@To_Date,112))     
			   begin    
				  set @App_Id = 0    
			   Return    
			   end
		end
		else if @Duration = 0
		begin
			If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food)     
			   begin    
				  set @App_Id = 0    
			   Return    
			   end
		end

		--If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food)     
		--   begin    
		--	  set @App_Id = 0    
		--   Return    
		--   end
	end
	else if @App_Type = 'Guest'
	begin

																							If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food 
		and Guest_Type_Id = @Guest_Type_Id and Guest_Name = @Guest_Name 
		and Convert(varchar,@From_Date,112) between Convert(varchar,From_Date,112) and  Convert(varchar,To_Date,112)
		and Canteen_Name = @Canteen_Name)     
	   begin 
	   
			  set @App_Id = 0    
	   Return    
	end      
   End   

  else if @App_Type = 'Employee'
	begin		
		if @Duration = 1
		begin
			If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food 
			and Convert(varchar,From_Date,112) between Convert(varchar,@From_Date,112) and  Convert(varchar,@To_Date,112))
			--and Convert(varchar,To_Date,112) <= Convert(varchar,@To_Date,112))     
			   begin    
				  set @App_Id = 0    
			   Return    
			   end
		end
		else if @Duration = 0
		begin
			If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food)     
			   begin    
				  set @App_Id = 0    
			   Return    
			   end
		end

		--If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food)     
		--	   begin    
		--		  set @App_Id = 0    
		--	   Return    
		--	   end
	 --  else if Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Duration = 'Unlimited')
		--begin
			
		--end
	end

  If @App_No = ''  
  Begin  
   select @App_Id = Isnull(max(App_Id),0)+1  From T0080_CANTEEN_APPLICATION  WITH (NOLOCK)   
   set @App_No = 'CN'+CAST(@App_Id as nvarchar)  
  End  
  
   Insert Into T0080_CANTEEN_APPLICATION (App_No,Cmp_Id,Receive_Date,Emp_Id,Emp_Name,Desig_Id,Dept_Id,Cnt_Id,Duration,From_Date,To_Date,Canteen_Name,[User_ID],[Description],
				App_Type,Guest_Type_Id,Guest_Name,Guest_Count)  
   Values (@App_No,@Cmp_Id,@Receive_Date,@Emp_Id,@Emp_Name,@Designation,@Department,@Food,@Duration,@From_Date,@To_Date,@Canteen_Name,@LoginID,@Description,
				@App_Type,@Guest_Type_Id,@Guest_Name,@Guest_Count)  
  
   Select @App_Id =Isnull(max(App_Id),0) From T0080_CANTEEN_APPLICATION   
  
 End  
  
Else if @tran_type ='U'  
 begin   
   If Not Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where App_Id = @App_Id )    
   Begin   
   Set @App_Id = 0  
   Return  
   End  
     Update T0080_CANTEEN_APPLICATION  
     SET
	 Receive_Date=@Receive_Date
	 ,Emp_Id=@Emp_Id
	 ,Emp_Name=@Emp_Name
	 ,Desig_Id=@Designation
	 ,Dept_Id=@Department
	 ,Cnt_Id=@Food  
     ,Duration = @Duration  
     ,From_Date=@From_Date  
     ,To_Date=@To_Date  
     ,Canteen_Name = @Canteen_Name  
	 ,[User_ID] = @LoginID
	 ,[Description] = @Description
	 ,App_Type = @App_Type
	 ,Guest_Type_Id = @Guest_Type_Id
	 ,Guest_Name = @Guest_Name
	 ,Guest_Count=@Guest_Count
     Where App_Id = @App_Id  
 End  
  
Else If @tran_type = 'D'  
 begin  
  If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where App_Id = @App_Id)  
  Begin  
    Delete From T0080_CANTEEN_APPLICATION Where App_Id =@App_Id  
   Return  
  End        
  
   End 
   
																																																															