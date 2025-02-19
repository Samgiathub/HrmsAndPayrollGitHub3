



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0015_Login_Rights]
			 @Login_Rights_ID numeric(18) output
            ,@Login_Type_ID numeric(18,0)
            ,@Branch_ID numeric(18,0)
            ,@Cmp_ID numeric(18,0)
            ,@Login_ID numeric(18,0)
            ,@Is_Save  Numeric(1,0)	
            ,@Is_Edit  Numeric(1,0)	
            ,@Is_Delete  Numeric(1,0)	
            ,@Is_Reports Numeric(1,0)
            ,@Login_Name varchar(50)
            ,@Login_Password varchar(50)
            ,@tran_type char
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @loginname varchar(50)
	Declare @Domain_name varchar(50)
	Declare @count_@ numeric 

   if @Login_Name=''
   set @Login_Name = ''
   
   if @Login_Password =''
   set @Login_Password=''
   
   if @Branch_ID = 0 
	   Set @Branch_ID = null
	   
	   
   
	 	Select @Domain_Name = Domain_Name From T0010_COMPANY_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID
	 	
	 	select @count_@ = dbo.OCCURS ('@',@Login_Name)
	 	
	 	
     	if substring(@Domain_Name,1,1) <> '@'	
			set @Domain_Name = '@' + @Domain_Name

		If @Count_@ >1 or (@Count_@ = 1 and charindex(@Domain_Name,@Login_Name,1)= 0 )
			begin
				raiserror('@@Wrong User Name@@',16,2)
				return
			end 
		Else if charindex(@Domain_Name,@Login_Name,1)> 0 
			set @loginname  = @Login_Name 
		Else 
			set @loginname = cast(@Login_Name as varchar(10)) + @Domain_Name		
	
			
	If @tran_type ='I' 
		begin	  
	      exec p0011_Login @Login_ID output,@Cmp_Id,@loginname,@Login_Password,0,@Branch_ID,null,'I',0
		
		  select @Login_Rights_ID = isnull(max(Login_Rights_ID),0) + 1 from T0015_Login_Rights WITH (NOLOCK)
		  
		  if @Login_ID = 0
			 begin
				raiserror('@@Duplicate User Name@@',16,2)
				return 
			 end

			
		  Insert into T0015_Login_Rights( Login_Rights_ID,Login_Type_ID	,Branch_ID
			,Login_ID,Cmp_ID ,Is_Save  ,Is_Edit,Is_Delete ,Is_Report   )
			values(@Login_Rights_ID	,@Login_Type_ID	,@Branch_ID,@Login_ID
			,@Cmp_ID ,@Is_Save  ,@Is_Edit ,@Is_Delete,@Is_Reports) 	
            end 
	else if @tran_type ='U' 
		begin
		 
				exec p0011_Login @Login_ID ,@Cmp_Id,@loginname,@Login_Password,0,@Branch_ID,null,'U',0
		
				Update T0015_Login_Rights 
				set    Login_Rights_ID = @Login_Rights_ID 
                       ,Login_Type_ID =@Login_Type_ID
                       ,Branch_ID=@Branch_ID
		     	       ,Cmp_ID=@Cmp_ID
                       ,Is_Save=@Is_Save
                       ,Is_Edit=@Is_Edit
                       ,Is_Delete=@Is_Delete
                       ,Is_Report=@Is_Reports
				where Login_Rights_ID = @Login_Rights_ID   
				
				
		end	
	else if @tran_type ='D'
		Begin
			
			select @Login_ID = Login_ID from T0015_Login_Rights WITH (NOLOCK) where Login_Rights_ID=@Login_Rights_ID  
			if exists(select Login_ID from T0011_Login WITH (NOLOCK) Where Login_ID = @Login_ID and Is_Default = 0 )
				begin
					delete  from T0015_Login_Rights where Login_Rights_ID=@Login_Rights_ID 
					delete from T0011_Login Where Login_ID = @Login_ID
				end
			
		end
		
	RETURN


	

