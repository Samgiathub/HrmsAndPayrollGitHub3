    
    
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE  PROCEDURE [dbo].[p0040_GRADE_MASTER]     
  @Grd_ID   Numeric(9) output    
 ,@Cmp_ID   Numeric(9)    
 ,@Cat_ID   Numeric(9)    
 ,@Grd_Name   varchar(100)    
 ,@Grd_Description varchar(100)    
 ,@Grd_Dis_No  Numeric(9)    
 ,@tran_type   varchar(1)    
 ,@Short_Fall_Days   numeric(18,0)=0    
 ,@Short_Fall_W_Days numeric(18,0)=0    
 ,@Basic_Percentage Numeric(18,2)    
 ,@Basic_Calc_On  Varchar(20)    
 ,@min_basic numeric(18,2) = 0 -- added by mitesh on 09052012    
 ,@User_Id numeric(18,0)= 0 -- added By Paras 04-10-2012    
    ,@IP_Address varchar(30)= '' -- addd By Paras 04-10-2012    
    ,@Grd_BasicFrom numeric(18,2) = 0 -- Added by Ali 01042014     
    ,@Grd_BasicTo numeric(18,2) = 0 -- Added by Ali 01042014    
    ,@Eligibility_Amount numeric(18,2) = 0 -- Added by Nilay 06-06-2014    
    ,@Signature nvarchar(max)='' --Added by sumit 15102014    
    ,@OT_Applicable tinyint = 1 --Hardik 13/03/2015 for Bhasker    
    ,@IsActive tinyint=1    
    ,@InEffeDate datetime=null --Added by Sumit 09042015    
    ,@FixBSalary  NUMERIC(18,2) = 0 --Ankit 07082015    
    ,@FixBSalary_Night NUMERIC(18,2) = 0 --Ankit 07082015    
    ,@GUID Varchar(2000) = '' -- Added by nilesh patel on 13062016    
    ,@Desig_ID varchar(max)='' --Added by Mukti(08032017)    
 ,@Wages_Type Varchar(max) ='' -- Added by Nilesh patel on 20022019    
AS    
    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
    
declare @OldValue as  varchar(max)    
declare @OldGrdName as varchar(100)    
declare @OldGrd_Description as varchar(100)    
declare @OldGrd_Dis_No as varchar(9)    
declare @OldShort_Fall_Days  as varchar(18)    
declare @OldShort_Fall_W_Days as  varchar(18)    
declare @OldBasic_Percentage as  varchar(18)    
declare @OldBasic_Calc_On as  Varchar(20)    
declare @Oldmin_basic  as varchar(18)     
declare @Old_Eligibility_Amount as varchar(10)    
declare @old_Signature as nvarchar(max)    
declare @Old_Eligibility_designationwise as nvarchar(max)    
DECLARE @Old_FixBSalary   AS VARCHAR(18)     
DECLARE @Old_FixBSalary_Night AS VARCHAR(18)     
Declare @Old_Wages_Type As Varchar(20)    
    
    
  set @Grd_Name = dbo.fnc_ReverseHTMLTags(@Grd_Name)   ---added by mansi 061021
  set @Grd_Description = dbo.fnc_ReverseHTMLTags(@Grd_Description)   ---added by mansi 121021  
  
  set @OldValue = ''    
  set @OldGrdName = ''    
  set @OldGrd_Description = ''    
  set @OldGrd_Dis_No = ''    
  set @OldShort_Fall_Days = ''    
  set @OldShort_Fall_W_Days = ''    
  set @OldBasic_Percentage = ''    
  set @OldBasic_Calc_On = ''    
  set @Oldmin_basic = ''    
  set @Old_Eligibility_Amount = ''    
  set @old_Signature=''      
  set @Old_Eligibility_designationwise =''          
  SET @Old_FixBSalary = ''    
  SET @Old_FixBSalary_Night = ''    
  SET @Old_Wages_Type = ''    
              
 IF @Cat_ID = 0    
  SET @Cat_ID = NULL    
 if @InEffeDate=''    
  set @InEffeDate=null     
      
 If @tran_type  = 'I' Or @tran_type = 'U'    
  BEGIN     
   If @Grd_Name = ''    
    BEGIN    
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Grade Name is not Properly Inserted',0,'Enter Proper Grade Name',GetDate(),'Grade Master',@GUID)          
     Return    
    END    
  END    
      
 If @tran_type  = 'I'     
  Begin    
   Set @Grd_Name = LTRIM(@Grd_Name)    
   Set @Grd_Name = RTRIM(@Grd_Name)    
    
  
   If Exists(select Grd_ID From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Grd_Name) = upper(@Grd_Name)) -- Modified by Mitesh 04/08/2011 for different collation db.    
    begin    
     Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Grade already exists.please Enter Valid Grade Name',0,'Same Grade already exists.please Enter Valid Grade Name "'+ @Grd_Name +'"',GetDate(),'Grade Master',@GUID)          
     set @Grd_ID = 0    
     return     
    end    
       
   select @Grd_ID = Isnull(max(Grd_ID),0) + 1  From T0040_GRADE_MASTER WITH (NOLOCK)    
       
   INSERT INTO T0040_GRADE_MASTER    
           (    
       Grd_ID     
      ,Cmp_ID     
      ,Cat_ID     
      ,Grd_Name     
      ,Grd_Description     
      ,Grd_Dis_No    
      ,Short_Fall_Days     
      ,Short_Fall_W_Days    
      ,Basic_Percentage    
      ,Basic_Calc_On    
      ,min_basic     
      ,Grd_basicfrom -- Added by Ali 01042014    
      ,Grd_basicTo -- Added by Ali 01042014    
      ,Eligibility_Amount    
      ,Signature     
      ,OT_Applicable    
      ,IsActive    
      ,InActive_EffeDate    
      ,Fix_Basic_Salary    
      ,Fix_Basic_Salary_Night    
      ,Desig_ID    
      ,Grd_WAGES_TYPE    
           )    
    VALUES         
     (       
       @Grd_ID     
      ,@Cmp_ID     
      ,@Cat_ID     
      ,@Grd_Name     
      ,@Grd_Description     
      ,@Grd_Dis_No    
      ,@Short_Fall_Days    
      ,@Short_Fall_W_Days    
      ,@Basic_Percentage    
      ,@Basic_Calc_On    
      ,@min_basic     
      ,@Grd_BasicFrom -- Added by Ali 01042014    
      ,@Grd_BasicTo -- Added by Ali 01042014    
      ,@Eligibility_Amount    
      ,@Signature    
      ,@OT_Applicable    
      ,@IsActive    
      ,@InEffeDate    
      ,@FixBSalary    
      ,@FixBSalary_Night    
      ,@Desig_ID    
      ,@Wages_Type    
     )      
         
    --Alpesh 28-Apr-2012    
    Declare @Leave_ID numeric(18,0)       
        
    If exists(Select 1 from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Leave_Code='LWP')    
     Begin          
      Select @Leave_ID = Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Leave_Code='LWP'    
      exec [P0050_LEAVE_DETAIL] 0,@Leave_ID,@Grd_ID,@Cmp_ID,0,'Ins'       
     End     
         
    If exists(Select 1 from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Leave_Code='COMP')    
    Begin         
     Select @Leave_ID = Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Leave_Code='COMP'    
     exec [P0050_LEAVE_DETAIL] 0,@Leave_ID,@Grd_ID,@Cmp_ID,0,'Ins'       
    End     
    --End    
    --Add By Paras 12-10-2012    
    set @OldValue = 'New Value' + '#'+ 'Grade Name :' +ISNULL( @Grd_Name,'') + '#' + 'Grade Discription :' + ISNULL( @Grd_Description,'') + '#' + 'Grade Dis No :' + CAST(ISNULL(@Grd_Dis_No,0) AS VARCHAR(20)) + '#' + 'Short Fall Days :' +CAST( ISNULL( @Short_Fall_Days,0)AS VARCHAR(20)) + '#' + 'Short Fall W Days :' +CAST(ISNULL( @Short_Fall_W_Days,0)AS VARCHAR(20)) + ' #'+ 'Base Percentage :' +CAST(ISNULL(@Basic_Percentage,0)AS VARCHAR(20)) + ' #'+ 'Base Calc On :' + ISNULL( @Basic_Calc_On,'') + ' #'+ 'Min
  
 Base :' + CAST(ISNULL(@min_basic,0)AS VARCHAR(20))  + ' #' + 'Eligibility_Amount :' + CAST(ISNULL(@Eligibility_Amount,0)AS VARCHAR(20))  + ' #' + 'Signature :' + ISNULL( @Signature,'')  + ' #' + 'Monthly Fix Basic Salary Day Shift :' + CAST(ISNULL(@FixBSalary,0) AS VARCHAR(20))  + ' #' + 'Monthly Fix Basic Salary Night Shift :' + CAST(ISNULL(@FixBSalary_Night,0) AS VARCHAR(20))  + ' #' + 'Wages Type : ' + @Wages_Type    
    ---    
  End    
 Else if @Tran_Type = 'U'    
   begin    
   If Exists(select Grd_ID From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Grd_Name) = upper(@Grd_Name) and Grd_ID <> @Grd_ID )    
    begin    
     set @Grd_ID = 0    
     return     
    end    
    --Add By Paras 12-10-2012    
      select @OldGrdName  =ISNULL(Grd_Name,'') ,@OldGrd_Description  =ISNULL(Grd_Description,''),@OldGrd_Dis_No  =isnull(Grd_Dis_No,0),@OldShort_Fall_Days  =isnull(Short_Fall_Days,0),@OldShort_Fall_W_Days =isnull(Short_Fall_W_Days,0),@OldBasic_Percentage 
  
 =isnull(Basic_Percentage,0),@OldBasic_Calc_On  = isnull(Basic_Calc_On,''),@Oldmin_basic  =isnull(min_basic ,0) ,@Old_FixBSalary  =isnull(Fix_Basic_Salary,0),@Old_FixBSalary_Night  =isnull(Fix_Basic_Salary_Night,0),@Old_Wages_Type = Isnull(@Wages_Type,'')
  
    
      From dbo.T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID    
      ---    
    UPDATE    T0040_GRADE_MASTER    
    SET                  
     Cat_ID = @Cat_ID    
     ,Grd_Name = @Grd_Name    
     ,Grd_Description  = @Grd_Description    
     ,Grd_Dis_No = @Grd_Dis_No    
     ,Short_Fall_Days=@Short_Fall_Days    
     ,Short_Fall_W_Days=@Short_Fall_W_Days    
     ,Basic_Percentage = @Basic_Percentage    
     ,Basic_Calc_On = @Basic_Calc_On    
     ,min_basic =@min_basic     
     ,Grd_BasicFrom = @Grd_BasicFrom -- Added by Ali 01042014    
     ,Grd_BasicTo = @Grd_BasicTo  -- Added by Ali 01042014    
     ,Eligibility_amount =@Eligibility_Amount    
     ,OT_Applicable=@OT_Applicable    
     ,Signature=@Signature --Signature Added by sumit 15102014    
     ,IsActive=@IsActive    
     ,InActive_EffeDate=@InEffeDate    
     ,Fix_Basic_Salary = @FixBSalary    
     ,Fix_Basic_Salary_Night = @FixBSalary_Night    
     ,Desig_ID=@Desig_ID    
     ,Grd_WAGES_TYPE = @Wages_Type    
    where Grd_ID = @Grd_ID    
    ----Add By Paras 12-10-2012    
    set @OldValue = 'old Value' + '#'+ 'Grade Name :' + @OldGrdName  + '#' + 'Grade Discription :' + @OldGrd_Description  + '#' + 'Grade Dis No :' + @OldGrd_Dis_No + '#' + 'Short Fall Days :' +@OldShort_Fall_Days   + '#' + 'Short Fall W Days :' + @OldShort_Fall_W_Days  + ' #'+ 'Base Percentage :' + @OldBasic_Percentage  + ' #'+ 'Base Calc On :' + @OldBasic_Calc_On  + ' #'+ 'Min Base :' + @Oldmin_basic    + ' #'+ 'Monthly Fix Basic Salary Day Shift :' + @Old_FixBSalary + ' #' + 'Monthly Fix Basic Salary Ni
  
ght Shift :' + @Old_FixBSalary_Night + ' #' + ' Wages Type : ' + @Old_Wages_Type    
                + 'New Value' + '#'+ 'Grade Name :' +ISNULL( @Grd_Name,'') + '#' + 'Grade Discription :' + ISNULL( @Grd_Description,'') + '#' + 'Grade Dis No :' + CAST(ISNULL(@Grd_Dis_No,0) AS VARCHAR(20)) + '#' + '"Short Fall Days :' +CAST( ISNULL( @Short_Fall_Days,0)AS VARCHAR(20)) + '#' + 'Short Fall W Days :' +CAST(ISNULL( @Short_Fall_W_Days,0)AS VARCHAR(20)) + ' #'+ 'Base Percentage :' +CAST(ISNULL(@Basic_Percentage,0)AS VARCHAR(20)) + ' #'+ 'Base Calc On :' + ISNULL( @Basic_Calc_On,'') + ' #'+ 'Min 
  
Base :' + CAST(ISNULL(@min_basic,0)AS VARCHAR(20))  + ' #' + 'Eligibility_Amount :' + CAST(ISNULL(@Eligibility_Amount,0)AS VARCHAR(20))  + ' #' + 'Signature :' + ISNULL(@Signature,'')  + ' #' + 'Monthly Fix Basic Salary Day Shift :' + CAST(ISNULL(@FixBSalary,0) AS VARCHAR(20))  + ' #' + 'Monthly Fix Basic Salary Night Shift :' + CAST(ISNULL(@FixBSalary_Night,'') AS VARCHAR(20))  + ' #'  + ' Wages Type : ' + @Old_Wages_Type     
                    
                ------    
  end    
 Else If @Tran_Type = 'D'    
  begin    
       --Add By Paras 12-10-2012    
       select @OldGrdName  = Grd_Name ,@OldGrd_Description  =Grd_Description,@OldGrd_Dis_No  =isnull(Grd_Dis_No,''),@OldShort_Fall_Days  = isnull(Short_Fall_Days,''),@OldShort_Fall_W_Days = isnull(Short_Fall_W_Days,''),@OldBasic_Percentage  = isnull(Basic_Percentage,''),@OldBasic_Calc_On  = isnull(Basic_Calc_On,''),@Oldmin_basic  = isnull(min_basic ,'')     
     ,@Old_Eligibility_amount = Eligibility_Amount ,@Old_FixBSalary  =isnull(Fix_Basic_Salary,0),@Old_FixBSalary_Night  =isnull(Fix_Basic_Salary_Night,0)    
       From dbo.T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID    
           
       set @OldValue = 'old Value' + '#'+ 'Grade Name :' + @OldGrdName  + '#' + 'Grade Discription :' + @OldGrd_Description  + '#' + 'Grade Dis No :' + @OldGrd_Dis_No + '#' + '"Short Fall Days :' +@OldShort_Fall_Days   + '#' + 'Short Fall W Days :' + @OldShort_Fall_W_Days  + ' #'+ 'Base Percentage :' + @OldBasic_Percentage  + ' #'+ 'Base Calc On :' + @OldBasic_Calc_On  + ' #'+ 'Min Base :' + @Oldmin_basic  + 'Eligibility Amount :' + @Old_Eligibility_amount   + 'Signature :' + ISNULL(@Signature,'') + 'Mont
  
hly Fix Basic Salary Day Shift :' + ISNULL(@Old_FixBSalary,0)  + ' #' + 'Monthly Fix Basic Salary Night Shift :' + ISNULL(@Old_FixBSalary_Night,0)      
       -----    
   --Added By Mukti 21012015(start)    
    if not exists(select * from V0110_LEAVE_APPLICATION_DETAIL where Grd_ID = @Grd_ID)    
    begin    
     Delete from T0050_Leave_Detail Where Grd_ID = @Grd_ID    
     Delete From T0040_GRADE_MASTER Where Grd_ID = @Grd_ID    
    end    
   else    
    begin    
     Raiserror('Refrence Exist',16,2)    
     return -1    
    end     
  --Added By Mukti 21012015(end)    
  end    
             exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Grade Master',@OldValue,@Grd_ID,@User_Id,@IP_Address    
     
 RETURN    