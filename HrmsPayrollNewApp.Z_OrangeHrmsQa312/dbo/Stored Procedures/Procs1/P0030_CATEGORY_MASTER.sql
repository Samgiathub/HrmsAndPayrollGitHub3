    
    
    
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[P0030_CATEGORY_MASTER]    
      
   @Cat_ID numeric(18) output    
  ,@Cat_Name varchar(255)    
  ,@Cmp_ID numeric(18,0)    
  ,@Cat_Desc varchar(250)     
  ,@tran_type char    
  ,@User_Id numeric(18,0) = 0 --Add By Paras 12-10-2012    
     ,@IP_Address varchar(30)= '' --Add By Paras 12-10-2012    
     ,@Cate_Code VARCHAR(30) = ''    
     ,@chk_birth numeric(18,0)=1    
     ,@NewJoin_Employee TINYINT = 1 --Ankit 01102015  
	 ,@IsActive tinyint = 1    ----added by aswini 16/12/2023
 ,@InEffeDate datetime=null     ----added by aswini 16/12/2023
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
--Add By Paras 18-10-2012    
declare @OldValue as  varchar(max)    
declare @OldCatName as varchar(255)    
declare @OldCat_Description as varchar(250)    
Declare @Oldchk_birth as numeric(18,0)    
Declare @OldNewJoin_Employee as TINYINT  
 declare @OldActive as varchar(20)    ----added by aswini 16/12/2023
 declare @OldEffDate as varchar(50)   ----added by aswini 16/12/2023
------    
    
set @OldCatName =''    
set @OldCat_Description =''    
set @Oldchk_birth = 1    
set @OldNewJoin_Employee = 1    
  set @OldActive=1    
 set @OldEffDate=''      
   set @Cat_Name = dbo.fnc_ReverseHTMLTags(@Cat_Name)  --added by mansi 061021  
    set @Cate_Code = dbo.fnc_ReverseHTMLTags(@Cate_Code)  --added by mansi 121021  
	  set @Cat_Desc = dbo.fnc_ReverseHTMLTags(@Cat_Desc)  --added by mansi 121021  
 if Upper(@tran_type) ='I'     
  begin    
      
   if exists (Select Cat_ID  from T0030_Category_Master WITH (NOLOCK) Where Upper(Cat_Name) = Upper(@Cat_Name) and Cmp_ID = @Cmp_ID)     
    begin    
     set @Cat_ID=0    
     RETURN     
    end    
     select @Cat_ID = isnull(max(Cat_ID),0) + 1 from T0030_Category_Master WITH (NOLOCK)    
          
     insert into T0030_Category_Master(Cat_ID,Cat_Name,Cmp_Id,Cat_Description,Cate_Code,chk_Birth,NewJoin_Employee,IsActive,InActive_EffeDate)    
     values(@Cat_ID,@Cat_Name,@Cmp_ID,@Cat_Desc,@Cate_Code, @chk_birth,@NewJoin_Employee,@IsActive,@InEffeDate)   
	 
        --added by aswini 16/12/2023 
     --Add by paras 12-10-2012    
     --set @OldValue = 'New Value' + '#'+ 'Cat Name :' +ISNULL( @Cat_Name,'') + '#' + 'Cat Discription :' + ISNULL( @Cat_Desc,'') + '#'     
    --- set @OldValue = 'New Value' + '#'+ 'Cat Name :' +ISNULL( @Cat_Name,'') + '#' + 'Cat Discription :' + ISNULL( @Cat_Desc,'') + '#' + 'Is Show in Birthday :' + Cast(@chk_birth as Varchar) + '#' + 'Show New Join Employee(Dash Boad) :' + Cast(@NewJoin_Employee as Varchar) + '#'    
     
    set @OldValue = 'New Value' + '#'+ 'Cat Name :' +ISNULL( @Cat_Name,'') + '#' + 'Cat Discription :' + ISNULL( @Cat_Desc,'') + '#' + 'Is Show in Birthday :' + Cast(@chk_birth as Varchar) + '#' + 'Show New Join Employee(Dash Boad) :' + Cast(@NewJoin_Employee as Varchar) + '#' + 'IsActive:' + @OldActive + ' #' + 'InEffDate:' + @OldEffDate + ' #' 
  end     
 else if upper(@tran_type) ='U'     
  begin    
   if exists (Select Cat_ID  from T0030_Category_Master WITH (NOLOCK) Where Upper(Cat_Name )= upper(@Cat_Name) and Cat_ID <> @Cat_ID    
           and Cmp_ID = @Cmp_ID)     
    begin    
     set @Cat_ID=0    
     return     
    end         
      -- Add by paras 12-10-20121    
     -- select @OldCatName  =ISNULL(Cat_Name,'') ,@OldCat_Description  =ISNULL(Cat_Description,'') , @Oldchk_birth = Isnull(Chk_Birth , 0),@OldNewJoin_Employee = NewJoin_Employee From dbo.T0030_Category_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Cat_ID
  ---added by aswini 16/12/2023
  select @OldCatName  =ISNULL(Cat_Name,'') ,@OldCat_Description  =ISNULL(Cat_Description,'') , @Oldchk_birth = Isnull(Chk_Birth , 0),@OldNewJoin_Employee = NewJoin_Employee,@OldActive=IsActive,@OldEffDate=InActive_EffeDate From dbo.T0030_Category_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Cat_ID
  
 = @Cat_ID    
          
    Update T0030_Category_Master     
    Set Cat_Name = @Cat_Name, Cat_Description=@Cat_Desc ,Cate_Code = @Cate_Code , chk_Birth = @chk_birth,NewJoin_Employee = @NewJoin_Employee ,IsActive=@IsActive    
        ,InActive_EffeDate=@InEffeDate     
    where Cat_ID = @Cat_ID     
        
    set @OldValue =  'old Value' + '#'+ 'Category Name :' + @OldCatName  + '#' + 'Categary Discription :' + @OldCat_Description + '#' + 'Is Show in Birthday :' + Cast(@Oldchk_birth as Varchar) + '#' + 'Show New Join Employee(Dash Boad) :' + Cast(@OldNewJoin_Employee as Varchar) + '#' +     
      + 'New Value' + '#'+ 'Categary Name :' +ISNULL( @Cat_Name,'') + '#' + 'Category Discription :' + ISNULL( @Cat_Desc,'') + '#' + 'Is Show in Birthday :' + Cast(@chk_birth as Varchar)  + '#'  + 'Show New Join Employee(Dash Boad) :' + Cast(@NewJoin_Employee as Varchar)  + '#'    
    
        
    -----    
  end     
 else if upper(@tran_type) ='D'    
  begin    
  --Add By Paras 12-10-2012    
    if exists(Select 1 from T0080_EMP_MASTER WITH (NOLOCK) where cmp_ID = @Cmp_ID AND Cat_ID = @Cat_ID)    
     begin    
      RAISERROR('@@ Reference Esits @@',16,2)    
      RETURN    
     end    
    else if exists(Select 1 from T0095_INCREMENT WITH (NOLOCK) where cmp_ID = @Cmp_ID AND Cat_ID = @Cat_ID)    
     begin    
      RAISERROR('@@ Reference Esits @@',16,2)    
      RETURN    
     end    
    ELSE    
     BEGIN    
      select @OldCatName  = Cat_Name ,@OldCat_Description  =Cat_Description ,@Oldchk_birth = Isnull(Chk_Birth , 0), @OldNewJoin_Employee = NewJoin_Employee
	  ,@OldActive=ISNULL(IsActive,1)    
       ,@OldEffDate=InActive_EffeDate
	  From dbo.T0030_Category_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Cat_ID = @Cat_ID    
      delete  from T0030_Category_Master where Cat_ID=@Cat_ID     
       
      set @OldValue = 'old Value' + '#'+ 'Categary Name :' + @OldCatName + '#' + 'Categary Discription :' + @OldCat_Description   + 'Is Show in Birthday :' + Cast(@Oldchk_birth as Varchar)  + '#' + 'Show New Join Employee(Dash Boad) :' + Cast(@OldNewJoin_Employee as Varchar) + '#'
	  + 'IsActive:' + @OldActive + ' #' + 'InEffDate:' + @OldEffDate + ' #'   ---added by aswini 16/12/2023
     END    
         
         
   end    
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Categary Master',@OldValue,@Cat_ID,@User_Id,@IP_Address    
       
      
       
 RETURN    
    
    
    