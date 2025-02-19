
---28/1/2021 (EDIT BY Yogesh ) 
-- exec [dbo].[SP_Mobile_Canteen_Application] 0,120,'',0,'',0,0,'',0,'','','','','CN',0,'','',0,'',0
CREATE PROCEDURE [dbo].[SP_Mobile_Canteen_Application]
	--@Compoff_App_ID numeric(18,0),
@App_Id numeric (9) OUTPUT  
 ,@Cmp_Id numeric(9)  
 ,@Receive_Date nvarchar(20)=''  
 ,@Emp_Id numeric(9)   
 ,@Emp_Name varchar(max)   
 ,@Designation Numeric(9)  
 ,@Department Numeric(9)   
 ,@Food varchar(100)   
 ,@Duration varchar(100)  
 ,@From_Date nvarchar(20)=''  
 ,@To_Date nvarchar(20)=''    
 ,@Canteen_Name varchar(100)   
 ,@App_No nvarchar(20)=''   
 ,@tran_type  varchar(2)  
 ,@LoginID int 
 ,@Description varchar(max)
 ,@App_Type nvarchar(50)
 ,@Guest_Type_Id int
 ,@Guest_Name nvarchar(200)
 ,@Guest_Count numeric (9)
	
	

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
--select @App_Type


 if @App_Type = 'Self'
 Begin
	--Set @Guest_Count = 1
	set @Guest_Type_Id = null
	set @Guest_Name = null
 end
 
 Else if @App_Type = 'Employee'
 Begin
	set @Guest_Type_Id = null
	set @Guest_Name = null
 end

  Declare  @Durationn  integer

	if @Duration='Unlimited'
	begin
	set @Durationn =0
	end
	else if @Duration='Limited'
	begin
	set @Durationn =1
	end

	If @tran_type  = 'CN'  
	begin
 	Declare  @AppNo  varchar(50)
	set @AppNo=(select App_No from  T0080_CANTEEN_APPLICATION  WITH (NOLOCK) where cmp_id=@cmp_id and App_Id=(select Top 1 App_Id from  T0080_CANTEEN_APPLICATION  WITH (NOLOCK) where cmp_id=@cmp_id order by 1 desc))
		
		set @AppNo= isnull(@AppNo,0)
		

        Set @AppNo =Replace(@AppNo, 'CN','')
		set @AppNo=@AppNo+1
		set @AppNo= CONCAT('CN', @AppNo)
		
		select 1 as 'Appdata' ,@AppNo as App_No,convert(varchar,getdate(),34) as 'Application_Date'
		,(select distinct  Concat(Alpha_Emp_Code,'-',Emp_Full_Name) as Emp_Name from T0080_EMP_MASTER where Emp_ID=@Emp_Id and Cmp_ID=@Cmp_Id) as Emp_Full_Name 
		
end
 else If @tran_type  = 'I'    
	 Begin 
	
	 
	if @App_Type = 'Self'
	begin
		--Select *  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food 
		--	and Convert(date,@From_Date,103) between Convert(date,From_Date,103) and  Convert(date,To_Date,103) 
		--	and Canteen_Name = @Canteen_Name
		--return
		if @Duration = 'Limited'
		begin
			If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) 
			Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food 
			and Convert(date,@From_Date,103) between Convert(date,From_Date,103) and  Convert(date,To_Date,103)
			and Canteen_Name = @Canteen_Name and App_Type = @App_Type)
			--and Convert(varchar,To_Date,112) <= Convert(varchar,@To_Date,112))     
			   begin    
				  set @App_Id = 0 
				  select 'Already Exist#False#'+CAST(@App_Id AS varchar(11))
				  --select 'Already Exist'
			   Return    
			   end
		end
		else if @Duration = 'Unlimited'
		begin
			If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food)     
			   begin    
				  set @App_Id = 0    
				  select 'Already Exist#False#'+CAST(@App_Id AS varchar(11))
				  --select 'Already Exist'
			   Return    
			   end
		end

		--If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food)     
	 --  begin 
	   
		--  set @App_Id = 0    
		--  select @App_Id
	 --  Return    
	 --  end
	end
	else if @App_Type = 'Guest'
	begin
	
		If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH  (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food 
		and Guest_Type_Id = @Guest_Type_Id and Guest_Name = @Guest_Name
		and Convert(date,@From_Date,103) between Convert(date,From_Date,103) and  Convert(date,To_Date,103)
			and Canteen_Name = @Canteen_Name and App_Type = @App_Type)     
	   begin 	   
		  set @App_Id = 0  
		  select 'Already Exist#False#'+CAST(@App_Id AS varchar(11))
		  --select 'Already Exist'
	   Return    
	end      
   End   

  else if @App_Type = 'Employee'
	begin
		If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food)     
	   begin    
		  set @App_Id = 0 
		  select 'Already Exist#False#'+CAST(@App_Id AS varchar(11))
		  --select 'Already Exist'
	   Return    
	   end
	end

  If @App_No = ''  
  Begin
    
   select @App_Id = Isnull(max(App_Id),0)+1  From T0080_CANTEEN_APPLICATION  WITH (NOLOCK)   
   set @App_No = 'CN'+CAST(@App_Id as nvarchar)  
  End  
 
   Insert Into T0080_CANTEEN_APPLICATION (App_No,Cmp_Id,Receive_Date,Emp_Id,Emp_Name,Desig_Id,Dept_Id,Cnt_Id,Duration,From_Date,To_Date,Canteen_Name,[User_ID],[Description],
				App_Type,Guest_Type_Id,Guest_Name,Guest_Count)  
   Values (@App_No,@Cmp_Id, convert(datetime, @Receive_Date, 105),@Emp_Id,@Emp_Name,@Designation,@Department,@Food,@Durationn,convert(datetime, @From_Date, 105)
   ,convert(datetime, @To_Date, 105),@Canteen_Name,@LoginID,@Description,
				@App_Type,@Guest_Type_Id,@Guest_Name,@Guest_Count)  
  
   Select @App_Id =Isnull(max(App_Id),0) From T0080_CANTEEN_APPLICATION 
   
  select 'Saved Succesfully#True#'+CAST(@App_Id AS varchar(11))
  --select 'Saved Succesfully#True#'+CAST(@App_Id AS varchar(11))
 End  
  
Else if @tran_type ='U'  
 begin   
 
   If Not Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where App_Id = @App_Id )    
   Begin   
   Set @App_Id = 0
   select @App_Id
   Return  
   End  
     Update T0080_CANTEEN_APPLICATION  
     SET
	 Receive_Date=convert(datetime, @Receive_Date, 105)
	 ,Emp_Id=@Emp_Id
	 ,Emp_Name=@Emp_Name
	 ,Desig_Id=@Designation
	 ,Dept_Id=@Department
	 ,Cnt_Id=@Food  
     ,Duration = @Durationn  
     ,From_Date=convert(datetime, @From_Date, 105)  
     ,To_Date=convert(datetime, @To_Date, 105)
     ,Canteen_Name = @Canteen_Name  
	 ,[User_ID] = @LoginID
	 ,[Description] = @Description
	 ,App_Type = @App_Type
	 ,Guest_Type_Id = @Guest_Type_Id
	 ,Guest_Name = @Guest_Name
	 ,Guest_Count=@Guest_Count
     Where App_Id = @App_Id  
	 select 'Updated Succesfully'
 End  
  
Else If @tran_type = 'D'  
 begin  
 
  If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where App_Id = @App_Id)  
  Begin  
  
    Delete From T0080_CANTEEN_APPLICATION Where App_Id =@App_Id  
	Select 'Successfully Deleted' 
   Return  
  End        
  
   End 
   




