  
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0200_WARNING_GENERATE_MANUAL]  
 @War_Tran_ID NUMERIC OUTPUT,  
 @Emp_Id   NUMERIC,  
 @Cmp_ID   NUMERIC,  
 @War_ID   NUMERIC,  
 @War_Date  DATETIME,  
 @Shift_id  NUMERIC,  
 @Reason   VARCHAR(500),  
 @Issue_By  VARCHAR(50),  
 @Authorised_By VARCHAR(50),  
 @Login_ID  NUMERIC,  
 @tran_type  varchar(1)  
 ,@User_Id numeric(18,0) = 0 -- Added for Audit Trail by Ali 09102013  
    ,@IP_Address varchar(30)= '' -- Added for Audit Trail by Ali 09102013  
    ,@Level_Id  numeric(18,0) = 0  --Added by Jaina 13-03-2018 Start  
    ,@No_Of_Card numeric(18,0) = 0  
    ,@Card_Color varchar(50) = ''  
    ,@Action_Taken_Date datetime = null  
    ,@Action_Detail varchar(500) = ''  --Added by Jaina 13-03-2018 End  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
    
       -- Added for Audit Trail by Ali 09102013 -- Start  
       Declare @Old_Emp_Id as numeric  
       Declare @Old_Emp_Name as varchar(100)  
       Declare @Old_War_ID as NUMERIC         
       Declare @Old_War_Name as varchar(100)  
       Declare @New_War_Name as varchar(100)  
       Declare @Old_War_Date as DATETIME  
       Declare @Old_Reason as VARCHAR(500)  
       Declare @Old_Issue_By as VARCHAR(50)  
       Declare @Old_Authorised_By as VARCHAR(50)  
       Declare @OldValue as varchar(max)  
       --Added by Jaina 13-03-2018 Start  
       DECLARE @Old_Level_Id as numeric(18,0) = 0  
       DECLARE @Old_No_Of_Card as numeric(18,0)= 0  
       Declare @Old_Card_Color as varchar(50)= ''  
       Declare @Old_Action_TakenDate as datetime = null  
       Declare @Old_Action_Detail as varchar(500) = ''  
       --Added by Jaina 13-03-2018 End  
         
         
       Set @Old_Emp_Id = 0  
       Set @Old_Emp_Name = ''  
       Set @Old_War_ID = 0  
       Set @Old_War_Name = ''  
       Set @New_War_Name = ''  
       Set @Old_War_Date = null  
       Set @Old_Reason = ''  
       Set @Old_Issue_By  = ''  
       Set @Old_Authorised_By = ''  
       Set @OldValue = ''  
    
       -- Added for Audit Trail by Ali 09102013 -- End  
     set @Reason = dbo.fnc_ReverseHTMLTags(@Reason)  --added by Ronak 110121 
 if @Action_Taken_Date = '1900-01-01'  
  set @Action_Taken_Date = NULL  
         
 If @tran_type  = 'I'  
  BEGIN  
   IF EXISTS(SELECT War_Tran_ID FROM T0100_WARNING_DETAIL WITH (NOLOCK) WHERE Warr_Date = @War_Date and War_ID = @War_ID and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID)  
    BEGIN  
     SET @War_Tran_ID = 0  
     RETURN   
    END      
   IF EXISTS(SELECT 1 FROM t0200_monthly_salary WITH (NOLOCK) WHERE emp_id = @emp_id and Cmp_ID = @Cmp_ID   
     and @War_Date between Month_St_Date and Month_End_Date)  --Added by Jaina 21-05-2019  
     --and MONTH(Month_End_Date) = MONTH(@War_Date) and YEAR(Month_End_Date) = YEAR(@War_Date))  --Comment by Jaina 21-05-2019  
    BEGIN  
     RAISERROR('@@ Salary Exist for this Month @@',16,2)  
     RETURN  
    END  
         
    select @War_Tran_ID = Isnull(max(War_Tran_ID),0) + 1  From T0100_WARNING_DETAIL WITH (NOLOCK)  
      
    INSERT INTO T0100_WARNING_DETAIL  
                          (War_Tran_ID,  
                          Cmp_ID,  
                          Emp_ID,  
                          War_ID,  
                          Warr_Date,  
                          Shift_ID,  
                          Warr_Reason,  
                          Issue_By,  
                          Authorised_By,  
                          Login_ID,  
                          System_Date,  
                          Level_Id,  
                          No_Of_Card,  
                          Card_Color,  
                          Action_Taken_Date,  
                          Action_Detail)  
    VALUES     (@War_Tran_ID,  
       @Cmp_ID,  
       @Emp_Id,  
       @War_ID,  
       @War_Date,  
       @Shift_id,  
       @Reason,  
       @Issue_By,  
       @Authorised_By,  
       @Login_ID,  
       getdate(),  
       @Level_Id,  
       @No_Of_Card,  
       @Card_Color,  
       @Action_Taken_Date,  
       @Action_Detail)  
      
       -- Added for Audit Trail by Ali 09102013 -- Start  
        Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID)  
        Set @Old_War_Name = (Select War_Name from T0040_WARNING_MASTER WITH (NOLOCK) where Cmp_ID  = @Cmp_ID and War_ID = @War_ID)  
          
        Declare @Level_Name as varchar(50)  
        select  @Level_Name = Level_Name from T0040_Warning_CardMapping WITH (NOLOCK) where Cmp_Id = @Cmp_Id and Level_Id = @Level_Id  
          
        set @OldValue = 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')   
          + '#' + 'Warning :' + ISNULL(@Old_War_Name,'')                         
          + '#' + 'Date :' + cast(ISNULL(@War_Date,'') as nvarchar(11))   
          + '#' + 'Reason :' + ISNULL(@Reason,'')   
          + '#' + 'Issue By :' + ISNULL(@Issue_By,'')   
          + '#' + 'Authorized By :' + ISNULL(@Authorised_By,'')   
          + '#' + 'Level :' + ISNULL(@Level_Name,'')   
          + '#' + 'No Of Card :' + cast(ISNULL(@No_Of_Card,0)AS nvarchar(10))   
          + '#' + 'Card Color :' + ISNULL(@Card_Color,'')   
          + '#' + 'Action Taken Date :' + cast(ISNULL(@Action_Taken_Date,'') AS nvarchar(11))  
          + '#' + 'Action Detail :' + ISNULL(@Action_Detail,'')  
            
        exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Employee Warning',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1   
       -- Added for Audit Trail by Ali 09102013 -- End  
       
         
  End  
   
 Else if @Tran_Type = 'D'  
  begin  
    
  --Added By Ramiz on 25/07/2017  
  IF EXISTS(SELECT 1 FROM t0200_monthly_salary WITH (NOLOCK) WHERE emp_id = @emp_id and Cmp_ID = @Cmp_ID and @War_Date between Month_St_Date and Month_End_Date)  
    BEGIN  
     RAISERROR('@@ Salary Exist for this Month @@',16,2)  
     RETURN  
    END  
       -- Added for Audit Trail by Ali 09102013 -- Start  
        Select   
        @Old_Emp_Id = Emp_Id  
        ,@Old_War_ID = War_ID  
        ,@Old_War_Date = Warr_Date  
        ,@Old_Issue_By = Issue_By  
        ,@Old_Authorised_By = Authorised_By  
        ,@Old_Reason = Warr_Reason   
        ,@Old_Level_ID = Level_Id  
        ,@Old_No_Of_Card = No_Of_Card  
        ,@Old_Card_Color = Card_Color  
        ,@Old_Action_TakenDate =Action_Taken_Date  
        ,@Old_Action_Detail = Action_Detail  
        From T0100_WARNING_DETAIL WITH (NOLOCK)  
        Where War_Tran_ID = @War_Tran_ID  
         
        Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Old_Emp_Id)  
        Set @Old_War_Name = (Select War_Name from T0040_WARNING_MASTER WITH (NOLOCK) where Cmp_ID  = @Cmp_ID and War_ID = @Old_War_ID)  
          
        Declare @Old_Level_Name as varchar(50)  
        select  @Old_Level_Name = Level_Name from T0040_Warning_CardMapping WITH (NOLOCK) where Cmp_Id = @Cmp_Id and Level_Id = @Level_Id  
          
        set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')   
          + '#' + 'Warning :' + ISNULL(@Old_War_Name,'')                         
          + '#' + 'Date :' + cast(ISNULL(@Old_War_Date,'') as nvarchar(11))   
          + '#' + 'Reason :' + ISNULL(@Old_Reason,'')   
          + '#' + 'Issue By :' + ISNULL(@Old_Issue_By,'')   
          + '#' + 'Authorized By :' + ISNULL(@Old_Authorised_By,'')   
          + '#' + 'Level :' + ISNULL(@Old_Level_Name,'')   
          + '#' + 'No Of Card :' + cast(ISNULL(@Old_No_Of_Card,0)AS nvarchar(10))   
          + '#' + 'Card Color :' + ISNULL(@Old_Card_Color,'')   
          + '#' + 'Action Taken Date :' + cast(ISNULL(@Old_Action_TakenDate,'') AS nvarchar(11))  
          + '#' + 'Action Detail :' + ISNULL(@Old_Action_Detail,'')  
            
        exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Employee Warning',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1   
       -- Added for Audit Trail by Ali 09102013 -- End  
         
    DELETE FROM T0100_WARNING_DETAIL WHERE WAR_TRAN_ID = @WAR_TRAN_ID  
  end  
  
 RETURN  
  
  
  
  