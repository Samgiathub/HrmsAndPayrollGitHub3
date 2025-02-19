  
  
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE  PROCEDURE [dbo].[P0040_DEPARTMENT_MASTER]  
   @Dept_ID numeric(18,0) output  
  ,@Cmp_ID numeric(18,0)  
  ,@Dept_Name varchar(100)  
  ,@Dept_Dis_no numeric(18,0)  
  ,@Dept_Code_no varchar(50) = NULL --Added by mihir trivedi on 15032012 to add code  
  ,@tran_type varchar(1)  
  ,@User_Id numeric(18,0) = 0 --Add By paras 15-10-2012  
        ,@IP_Address varchar(30)= '' --Add By paras 15-10-2012  
        ,@IsActive numeric (18,0) =1 --Added by Sumit 07042015  
        ,@InEffeDate datetime = null  
        ,@OJT_Applicable  numeric(18,0)=0 --added by sneha on 08082015  
        ,@GUID Varchar(2000) = '' --Added by nilesh Patel on 13062016  
  ,@Minimum_Wages Numeric(18,2) = 0 --added by jimit 15052017  
        ,@Category  tinyint = 0 --added by jimit 15052017  
   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
--Add By paras 15-10-2012  
  
declare @OldValue as  varchar(max)  
declare @OldDept_Name as varchar(100)  
declare @OldDept_Dis_No as varchar(18)  
declare  @OldDept_Code_NO  as varchar(50)  
declare @OldActive as varchar(50)  
declare @OldIneffDate as Varchar(50)  
declare @oldOJT_Applicable as varchar(50) --added by sneha on 08082015  
declare @OldMinimum_Wages as varchar(50)  
declare @OldCategory as varchar(50)  
  
  set @OldValue = ''  
  set @OldDept_Name = ''  
  set @OldDept_Dis_No = ''  
  set @OldDept_Code_NO = ''  
  set @OldActive=''  
  set @OldIneffDate=''  
  set @oldOJT_Applicable='' --added by sneha on 08082015  
  SET @OldMinimum_Wages = ''  
  SET @OldCategory = ''  
    
  if @InEffeDate='' --Added by Sumit 07042015  
 set @InEffeDate=null   
    
  --------  
  set @Dept_Name = dbo.fnc_ReverseHTMLTags(@Dept_Name)  
   set @Dept_Code_no = dbo.fnc_ReverseHTMLTags(@Dept_Code_no)  --mansi 121021
 If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'  
  BEGIN  
   If @Dept_Name = ''  
    BEGIN  
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Department Name is not Properly Inserted',0,'Enter Proper Department Name',GetDate(),'Department Master',@GUID)        
     Return  
    END  
      
  END  
   
 If Upper(@tran_type) ='I'  
   begin  
    Set @Dept_Name = LTRIM(@Dept_Name)  
    Set @Dept_Name = RTRIM(@Dept_Name)  
      
    if exists (Select Dept_ID  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) Where Upper(Dept_Name) = Upper(@Dept_Name) and Cmp_ID = @Cmp_ID)   
     begin  
      set @Dept_ID = 0  
      Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Department already exists.please Enter Valid Department Name',0,'Same Department already exists.please Enter Valid Department Name "'+ @Dept_Name +'"',GetDate(),'Department Master',@GUID)   
     
      Return   
     end  
      
    select @Dept_ID = isnull(max(Dept_ID),0) + 1 from T0040_DEPARTMENT_MASTER WITH (NOLOCK)  
      
    INSERT INTO T0040_DEPARTMENT_MASTER  
                          (Dept_Id, Cmp_Id, Dept_Name, Dept_Dis_no, Dept_Code,IsActive,InActive_effedate,OJT_Applicable,Minimum_Wages,Category)  
    VALUES     (@Dept_Id,@Cmp_Id,@Dept_Name,@Dept_Dis_no, @Dept_Code_no,@IsActive,@InEffeDate,@OJT_Applicable,@Minimum_Wages,@Category)   
        
             --Add by paras 12-10-2012      
     set @OldValue = 'New Value' + '#'+ 'Department Name :' +ISNULL( @Dept_Name,'') + '#' + 'Department Discription No :' + CAST(ISNULL( @Dept_Dis_no,0)as varchar(18)) + '#' + 'Department Code No :' + ISNULL(@Dept_Code_no,'')  + '#' + 'IsActive :' + CAST(
ISNULL(@IsActive,0)as varchar(18))  + '#'  + 'InEffeDate :' + CAST(ISNULL(@InEffeDate,'') as varchar(18))  + '#'   + 'OJT Applicable :' + CAST(ISNULL(@OJT_Applicable,0) as varchar(18))  + '#'  
        + 'Minimum_Wages :' + cast(ISNULL(@Minimum_Wages,0) as VARCHAR(18)) +  '#' + 'Category :'  + cast(ISNULL(@Category,0) as varchar(18)) + '#'  
     ----  
   end   
 Else If  Upper(@tran_type) ='U'   
   begin  
    if exists (Select Dept_ID  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) Where Upper(Dept_Name) = Upper(@Dept_Name) and Dept_ID <> @Dept_ID and Cmp_ID = @cmp_ID )   
     begin  
      set @Dept_ID = 0  
      Return  
     end  
     --Add By PAras 12-10-2012  
          select @OldDept_Name  =ISNULL(Dept_Name,'') ,@OldDept_Dis_No  =ISNULL(Dept_Dis_no,0),@OldDept_Code_NO  =isnull(@Dept_Code_no,0),@oldOJT_Applicable=ISNULL(@OJT_Applicable,0) From dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Dept_ID = @Dept_ID    
       
    UPDATE    T0040_DEPARTMENT_MASTER  
    SET       Dept_Name = @Dept_Name, Dept_Dis_no = @Dept_Dis_no, Dept_Code = @Dept_Code_no --Added by mihir trivedi on 15032012 to add code  
    ,IsActive=@IsActive,InActive_effedate=@InEffeDate,OJT_Applicable=@OJT_Applicable,  
      Minimum_Wages = @Minimum_Wages,Category = @Category  
    WHERE     Dept_Id = @Dept_ID  
      
    set @OldValue = 'old Value' + '#'+ 'Department Name :' + @OldDept_Name  + '#' + 'Department Discription No:' + @OldDept_Dis_No  + '#' + 'Department Code No :' + @OldDept_Code_NO   + '#' + 'OJT Applicable :' + @oldOJT_Applicable   + '#' +  'Minimum_Wag
es :' + @OldMinimum_Wages +  '#' + 'Category :'  + @OldCategory + '#'  
               + 'New Value' + '#'+ 'Department Name :' +ISNULL( @Dept_Name,'') + '#' + 'Department Discription No :' + CAST(ISNULL( @Dept_Dis_no,0)as varchar(18)) + '#' + 'Department Code No :' + ISNULL(@Dept_Code_no,'')  + '#' + 'IsActive :' + cast(ISNULL(@IsActive,'')as varchar(50))  + '#' + 'InEffeDate :' +CAST(ISNULL(@InEffeDate,'')as varchar(50))  + '#'  + 'OJT Applicable :' + CAST(ISNULL(@OJT_Applicable,0) as varchar(18))  + '#'  
     + 'Minimum_Wages :' + cast(ISNULL(@Minimum_Wages,0) as VARCHAR(18)) +  '#' + 'Category :'  + cast(ISNULL(@Category,0) as VARchar(18))  + '#'  
               -----  
    end  
     
 Else If  Upper(@tran_type) ='D'  
   Begin  
   --Add By PAras 12-10-2012  
   if exists(select 1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Dept_ID = @Dept_ID)  
    BEGIN  
     RAISERROR('@@ Reference Esits @@',16,2)  
     RETURN  
    END  
   else if exists(select 1 from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Dept_ID = @Dept_ID)  
    BEGIN  
     RAISERROR('@@ Reference Esits @@',16,2)  
     RETURN  
    END  
   else  
    BEGIN  
      select @OldDept_Name  =ISNULL(Dept_Name,'') ,@OldDept_Dis_No  =ISNULL(Dept_Dis_no,0),@OldDept_Code_NO  =isnull(@Dept_Code_no,0),@OldActive=isnull(@IsActive,1),@OldIneffDate=CAST(isnull(@InEffeDate,'')as varchar(50)),@oldOJT_Applicable=ISNULL(@OJT_Applicable,0)  
      ,@OldMinimum_Wages = ISNULL(Minimum_Wages,0),@OldCategory = ISNULL(Category,0)  
      From dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Dept_ID = @Dept_ID    
       
      DELETE FROM T0040_DEPARTMENT_MASTER WHERE Dept_Id = @Dept_ID  
       
      set @OldValue = 'old Value' + '#'+ 'Department Name :' +ISNULL( @OldDept_Name,'') + '#' + 'Department Discription No :' + CAST(ISNULL( @OldDept_Dis_No,0)as varchar(18)) + '#' + 'Department Code No :' + ISNULL(@OldDept_Code_NO,'')  + '#' + 'IsActive 
:' + ISNULL(@OldActive,'')  + '#' + 'InEffeDate :' + cast(ISNULL(@OldIneffDate,'') as varchar(50))  + '#' + 'OJT Applicable :' + CAST(ISNULL(@oldOJT_Applicable,0) as varchar(18))  
        + '#' + 'Minimum_Wages :' +  CAST(ISNULl(@OldMinimum_Wages,0) as VARCHAR(18)) + '#' + 'Category :' +  CAST(ISNULL(@OldCategory,0) as VARCHAR(18))   
    -----  
    END  
   
     
      
   End  
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Department Master',@OldValue,@Dept_ID,@User_Id,@IP_Address  
     
 RETURN  
  
  
  
  