    
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[P0050_SubBranch]        
    @SubBranch_ID  numeric(9) output      
   ,@Cmp_ID   numeric(9)       
   ,@Branch_ID numeric(9)    
   ,@SubBranch_Code varchar(50)      
   ,@SubBranch_Name varchar(100)      
   ,@SubBranch_Description varchar(250)      
   ,@tran_type  varchar(1)     
   ,@User_Id numeric(18,0) = 0    
   ,@IP_Address varchar(30)= ''     
     ,@IsActive tinyint = 1    ----added by aswini 21/12/2023
 ,@InEffeDate datetime=null    ----added by aswini 21/12/2023
 ,@city_Id as numeric(18,0)=0
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
 

 declare @OldValue as varchar(max)    
 declare @OldCode as varchar(50)    
 declare @OldSubBranchName as varchar(100)    
 declare @BranchName as varchar(100)    
 declare @OldBranchName as varchar(100)    
 declare @OldSubBranchDescription as varchar(250)    
 declare @Old_Branch_Id as numeric(9)    
  declare @OldActive as varchar(20)    ----added by aswini 21/12/2023
 declare @OldEffDate as varchar(50)   ----added by aswini 21/12/2023   
     
  set @OldValue = ''    
  set @OldCode = ''    
  Set @BranchName = ''    
  set @OldBranchName = ''    
  set @OldSubBranchName = ''    
  set @OldSubBranchDescription = ''    
  set @Old_Branch_Id = 0    
   set @OldActive=1    
 set @OldEffDate=''    
  --------    
    set @SubBranch_Name = dbo.fnc_ReverseHTMLTags(@SubBranch_Name)  --added by mansi 061021  
	 set @SubBranch_Code = dbo.fnc_ReverseHTMLTags(@SubBranch_Code)  --added by mansi 061021 
	  set @SubBranch_Description = dbo.fnc_ReverseHTMLTags(@SubBranch_Description)  --added by mansi 061021  
      
 If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'    
  BEGIN    
   If @SubBranch_Name = ''    
    BEGIN    
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Sub Branch Name is not Properly Inserted',0,'Enter Proper Sub Branch Name',GetDate(),'SubBranch Master', '')          
     Return    
    END    
        
  END    
      --select @city_Id = City_Cat_ID from T0030_CITY_MASTER where City_ID = @city_Id
 If Upper(@tran_type) ='I'    
     
   begin    
       
    if exists (Select SubBranch_ID  from T0050_SubBranch WITH (NOLOCK) Where Upper(subBranch_Name) = Upper(@SubBranch_Name) and Cmp_ID = @Cmp_ID)     
     begin    
      set @SubBranch_ID = 0    
      Return     
     end    
     if exists (Select SubBranch_ID  from T0050_SubBranch WITH (NOLOCK) Where Upper(SubBranch_Code) = Upper(@SubBranch_Code) and Cmp_ID = @Cmp_ID)     
     begin    
      set @SubBranch_ID = 0    
      Return     
     end    
        
    select @SubBranch_ID = isnull(max(SubBranch_ID),0) + 1 from T0050_SubBranch WITH (NOLOCK)    
        
    INSERT INTO T0050_SubBranch (SubBranch_Id, Cmp_Id,Branch_Id,SubBranch_Code, SubBranch_Name, SubBranch_Description,IsActive,InActive_EffeDate,City_id)    
     VALUES     (@SubBranch_Id,@Cmp_Id,@Branch_ID,@SubBranch_Code,@SubBranch_Name, @SubBranch_Description,
	 @IsActive,@InEffedate,@city_Id)  ----added by aswini 21/12/2023    
         
    select @BranchName = Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_ID = @Branch_ID    
    set @OldValue = 'New Value' + '#'+ 'SubBranch Name :' +ISNULL( @SubBranch_Name,'') + '#' + 'Branch Name :' + @BranchName + '#' + 'SubBranch Code :' + ISNULL( @SubBranch_Code,'') + '#' + 'SubBranch_Description :' + ISNULL(@SubBranch_Description,'')  + 
  
            '#'+'IsActive :' +  CAST(ISNULL(@IsActive,1) AS VARCHAR(18))  + '#' 
			+'InActive_EffeDate :' + CAST(@InEffeDate AS VARCHAR(18))  + '#'      ---added by aswini 21/12/2023
     ----    
         
   end     
 Else If  Upper(@tran_type) ='U'     
   begin    
    if exists (Select SubBranch_ID  from T0050_SubBranch WITH (NOLOCK) Where Upper(SubBranch_Name) = Upper(@SubBranch_Name) and SubBranch_ID <> @SubBranch_ID and Cmp_ID = @cmp_ID )     
     begin    
      set @SubBranch_ID = 0    
      Return    
     end    
    if exists (Select SubBranch_ID  from T0050_SubBranch WITH (NOLOCK) Where Upper(SubBranch_Code) = Upper(@SubBranch_Code) and SubBranch_ID <> @SubBranch_ID and Cmp_ID = @cmp_ID )     
     begin    
      set @SubBranch_ID = 0    
      Return    
     end    
         
         
          select  @Old_Branch_Id = Branch_ID , @OldSubBranchName = ISNULL(SubBranch_Name,'') ,@OldSubBranchDescription  =ISNULL(SubBranch_Description,''),@OldCode  =isnull(SubBranch_Code,''),
		  @OldActive=isnull(IsActive,0),@OldEffDate=isnull(InActive_EffeDate,'')  --added by aswini 21/12/2023
		  From dbo.T0050_SubBranch WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and SubBranch_ID = @SubBranch_ID      
    select @OldBranchName = Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_ID = @Old_Branch_Id    
        
        
    UPDATE    T0050_SubBranch    
    SET       SubBranch_Name = @SubBranch_Name, SubBranch_Code = @SubBranch_Code,     
        SubBranch_Description = @SubBranch_Description , Branch_ID = @Branch_ID ,
		IsActive=@IsActive,InActive_EffeDate =@InEffedate,City_id=@city_Id   ----added by aswini 21/12/2023
    WHERE     SubBranch_Id = @SubBranch_ID    
        
        
        
    select @BranchName = Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_ID = @Branch_ID    
    set @OldValue = 'old Value' + '#'+ 'SubBranch Name :' + @OldSubBranchName  + '#' + 'BranchName :' + @OldBranchName + '#' + 'SubBranch Code:' + @OldCode  + '#' + 'SubBranch Description :' + @OldSubBranchDescription   + '#' +  'IsActive :'+ @OldActive +'#' + 'InActive_EffeDate :' + @OldEffDate + '#'
               + 'New Value' + '#'+ 'SubBranch Name :' +ISNULL( @SubBranch_Name,'') + '#' + 'BranchName :' + @BranchName + '#' + 'SubBranch Code :' + ISNULL( @SubBranch_Code,'') + '#' + 'SubBranch Description :' + ISNULL(@SubBranch_Description,'')  + '#'  
  
    
               -----    
    end    
       
 Else If  Upper(@tran_type) ='D'    
   Begin    
      --Added by nilesh patel on 09042016 --start    
    if Exists(SELECT 1 From T0095_INCREMENT WITH (NOLOCK) Where subBranch_ID = @SubBranch_ID)    
     BEGIN    
      Set @SubBranch_ID = 0    
      Return    
     END    
    --Added by nilesh patel on 09042016 --End    
         
    select @Old_Branch_Id = Branch_ID , @OldSubBranchName = ISNULL(SubBranch_Name,'') ,@OldSubBranchDescription  =ISNULL(SubBranch_Description,''),@OldCode  =isnull(SubBranch_Code,'')
	,@OldActive= isnull(IsActive,0),@OldEffDate=isnull(InActive_EffeDate,'') ----added by aswini 21/12/2023

	From T0050_SubBranch WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and SubBranch_ID = @SubBranch_ID      
    DELETE FROM T0050_SubBranch WHERE SubBranch_Id = @SubBranch_ID    
    select @OldBranchName = Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_ID = @Old_Branch_Id     
        
    set @OldValue = 'old Value' + '#'+ 'SubBranch Name :' +ISNULL( @OldSubBranchName,'') +'#' +'BranchName :' + @OldBranchName + '#' + 'SubBranch Code :' + ISNULL( @OldCode,'') + '#' + 'SubBranch Description :' + ISNULL(@OldSubBranchDescription,'')  + '#'
	+  'IsActive :'+ISNULL( @OldActive,0) +'#' + 'InActive_EffeDate :' +ISNULL( @OldEffDate,'') + '#'    ----added by aswini 21/12/2023
  
      
    -----    
   End    
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'SubBranch Master',@OldValue,@SubBranch_ID,@User_Id,@IP_Address     
 RETURN    
    