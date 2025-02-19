 ---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[P0040_HOLIDAY_MASTER]    
  @Hday_ID AS NUMERIC output    
 ,@cmp_Id  as numeric     
 ,@Hday_Name as varchar(100)    
 ,@H_From_Date as datetime    
 ,@H_To_Date as datetime    
 ,@Is_Fix as char(1)    
 ,@Hday_Ot_setting as numeric(9,1)    
 --,@Branch_ID numeric(18,0) -- Comment by nilesh patel on 05112014    
 ,@Branch_ID varchar(max) = 'ALL' -- Added by nilesh patel on 05112014    
 ,@tran_type varchar(1)    
 ,@Is_Half  tinyint = 0    
 ,@Is_P_Comp  tinyint = 0    
 ,@Message_Text  Varchar(100) = ''    
 ,@Sms           Int=0      
 ,@is_National_Holiday tinyint = 0     
 ,@User_Id numeric(18,0) = 0    
    ,@IP_Address varchar(30)= '' --Add By Paras 18-10-2012    
    ,@Is_Optional  tinyint    
    ,@Multiple_Holiday tinyint =0 --add jimit 13042015    
    ,@Is_Unpaid_Holiday tinyint =0 --add chetan 18112017    
    ,@Branch_Limit varchar(max) = '' --Mukti(22112017)for Optional Holiday    
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
declare @OldValue as varchar(MAx)    
declare @OldHday_Name as varchar(100)    
declare @oldH_From_Date as varchar(20)    
declare @oldH_To_Date as varchar(20)    
declare @oldIs_Fix as varchar(1)    
declare @oldHday_Ot_setting as varchar(10)    
declare @oldIs_Half as varchar(1)    
declare @oldIs_P_Comp as varchar(1)    
declare @oldMessage_Text as varchar(100)    
declare @oldSms  as varchar(4)    
declare @oldis_National_Holiday  as varchar(1)    
declare @Trans_ID Numeric(18,0) --added by nilesh patel on 05112014    
declare @Holiday_Branch Numeric(18,0) --added by nilesh patel on 05112014    
declare @oldMultiple_Holiday as varchar(1) -- added jimit 14042015    
declare @Tran_ID Numeric(18,0)    
declare @MaxLimit Numeric(18,0)=0    
    
set @OldHday_Name = ''    
set @oldH_From_Date =''    
set @oldH_To_Date =''    
set @oldIs_Fix = ''    
set @oldHday_Ot_setting =''    
set @oldIs_Half = ''    
set @oldIs_P_Comp = ''    
set @oldMessage_Text = ''    
set @oldSms  = ''    
set @oldis_National_Holiday  =''    
set @oldMultiple_Holiday = ''    
SET NOCOUNT ON;    
    
    
CREATE TABLE #BRANCH_LIMIT    
 (         
  Branch_ID Numeric(18,0),        
  Max_Limit   Numeric(18,0)    
 )      
     
 --if @Branch_ID = 0 -- Comment by nilesh patel on 06112014     
 if @Branch_ID = 'ALL'    
  set @Branch_ID = null    
     
 insert into #BRANCH_LIMIT    
    select CAST(substring(data,0, CHARINDEX(':',data)) as NUMERIC(18,0)),     
    CAST(substring(data,CHARINDEX(':',data)+1, len(data)) as NUMERIC(18,0))    
    from dbo.split(@Branch_Limit, ',')  where charindex(':',data) > 0     
        
        
    --Added by Jaina 19-01-2018 After discuss with Nimeshbhai( When Insert,update,delete holiday that time need to check Salary Exists)    
 --   If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY where Cmp_ID=@Cmp_ID And          
 --    ((@H_From_Date >= Month_St_Date and @H_From_Date <= Month_End_Date) or     
 --    (@H_To_Date >= Month_St_Date and  @H_To_Date <= Month_End_Date) or     
 --    (Month_St_Date >= @H_From_Date and Month_St_Date <= @H_To_Date) or    
 --    (Month_End_Date >= @H_From_Date and Month_End_Date <= @H_To_Date)))    
 --Begin    
 -- Raiserror('@@This Months Salary Exists@@',18,2)    
 -- return -1    
 --End    
     
  --Added by Jaina 10-07-2018    
 declare @TempDate datetime    
     
 IF Month(@H_To_Date) > month(@H_From_Date)     
  set @TempDate = @H_To_Date    
 else    
  set @TempDate = @H_From_Date   
  
  -- Added By Sajid and Deepal for IFSCA 30-12-2021
    Declare @Setting_Value INT = 0 
   Select @Setting_Value= Setting_Value From T0040_SETTING  WITH (NOLOCK) 
      Where Setting_Name='This Months Salary Exists Validation If Salary Geneated.' and Cmp_ID=@cmp_Id
  if (@Setting_Value = 0)
   begin
     
 if exists (SELECT 1 FROM T0200_MONTHLY_SALARY s WITH (NOLOCK)    
    INNER JOIN dbo.fn_getEmpIncrement(@Cmp_ID,0,@TempDate) as I on s.Emp_ID = I.Emp_ID     
    WHERE s.Cmp_ID = @Cmp_ID     
    and EXISTS (select Data from dbo.Split(@Branch_ID, '#') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))    
    and ((@H_From_Date >= Month_St_Date and @H_From_Date <= Month_End_Date) or     
     (@H_To_Date >= Month_St_Date and  @H_To_Date <= Month_End_Date) or     
     (Month_St_Date >= @H_From_Date and Month_St_Date <= @H_To_Date) or    
     (Month_End_Date >= @H_From_Date and Month_End_Date <= @H_To_Date)))    
 Begin    
  Raiserror('@@This Months Salary Exists@@',18,2)    
  return -1    
 End       
 End
             set @Hday_Name = dbo.fnc_ReverseHTMLTags(@Hday_Name)  --added by mansi 061021     
			  set @Message_Text = dbo.fnc_ReverseHTMLTags(@Message_Text)  --added by mansi 121021   
			  
 If @Tran_Type  = 'I'     
  Begin    
   --If Exists(select HDay_ID From dbo.T0040_HOLIDAY_MASTER Where Cmp_ID = @Cmp_ID and     
   --     upper(HDay_Name) = upper(@HDay_Name) and isnull(Branch_ID,0) = isnull(@Branch_ID,0) ) -- Modified by Mitesh 04/08/2011 for different collation db.    
   -- Begin    
   --  set @Hday_ID = 0      
   --  return    
   -- End    
   --Else  - Commented by Mitesh on 30/01/2012    
   If @Branch_ID is null     
   begin    
    If exists(select HDay_ID From dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and     
         isnull(Branch_ID,0) = isnull(@Branch_ID,0)  and    
        ( (@H_From_Date >= h_from_date and @H_From_Date <= h_to_date) or     
        (@H_To_Date >= h_from_date and  @H_To_Date <= h_to_date) or     
        (h_from_date >= @H_From_Date and h_from_date <= @H_To_Date) or    
        (h_to_date >= @H_From_Date and h_to_date <= @H_To_Date))    
        )    
     Begin    
      set @Hday_ID = 0      
      return    
     End    
   End    
       
   -- Added by nilesh patel on 061120114 -start     
   If @Branch_ID is not null     
   begin    
       declare @All_Holiday as varchar(100) -- For Check in All Holiday Entry Available then can't entry of holiday branch wise.    
       Set @All_Holiday = 0    
       Select @All_Holiday = HDay_ID From dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and     
        isnull(Branch_ID,0) = 0 and    
        ( (@H_From_Date >= h_from_date and @H_From_Date <= h_to_date) or     
        (@H_To_Date >= h_from_date and  @H_To_Date <= h_to_date) or     
        (h_from_date >= @H_From_Date and h_from_date <= @H_To_Date) or    
        (h_to_date >= @H_From_Date and h_to_date <= @H_To_Date))    
           
       if @All_Holiday = 0     
        begin    
         If exists(select HDay_ID From dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and     
          isnull(Branch_ID,0) IN(Select isnull(cast(data as varchar(10)),0)  FROM dbo.Split(@Branch_ID,'#')) and    
          ( (@H_From_Date >= h_from_date and @H_From_Date <= h_to_date) or     
          (@H_To_Date >= h_from_date and  @H_To_Date <= h_to_date) or     
          (h_from_date >= @H_From_Date and h_from_date <= @H_To_Date) or    
          (h_to_date >= @H_From_Date and h_to_date <= @H_To_Date))    
          )    
       Begin    
        set @Hday_ID = 0     
        return    
       End    
      end    
       else    
       Begin    
        set @Hday_ID = 0     
        return    
       End    
   End     
       
       
   -- Added by nilesh patel on 061120114 -End     
   IF @Branch_ID is null    
     begin    
     select @Hday_ID = Isnull(max(Hday_ID),0) + 1  From dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK)    
        
     INSERT INTO dbo.T0040_HOLIDAY_MASTER(Hday_ID,cmp_Id,Hday_Name,H_From_Date ,H_To_Date ,Is_Fix,Hday_Ot_setting,Branch_ID,Is_Half,Is_P_Comp,Message_Text,Sms,is_National_Holiday, Is_optional,Multiple_Holiday,Is_Unpaid_Holiday)   --is national holiday added by mihir 14032011    
          VALUES         
          (@Hday_ID ,@cmp_Id  ,@Hday_Name ,@H_From_Date ,@H_To_Date,@Is_Fix ,@Hday_Ot_setting,@Branch_ID,@Is_Half,@Is_P_Comp,@Message_Text,@Sms,@is_National_Holiday, @Is_Optional,@Multiple_Holiday,@Is_Unpaid_Holiday)    
              
          set @OldValue = 'New Value' + '#'+ 'Hday Name :' +ISNULL( @Hday_Name,'') + '#' + 'H From Date :' +CAST(ISNULL( @H_From_Date,'')as varchar(20)) + '#' + 'H To Date :' +CAST(ISNULL(@H_To_Date,'')as varchar(20)) + '#' + 'Is_Fix :' +CAST( ISNULL( @Is_Fix,0)AS VARCHAR(5)) + '#' + 'Hday Ot setting :' +CAST(ISNULL( @Hday_Ot_setting,0)AS VARCHAR(20)) + ' #'+ 'Is Half :' +CAST(ISNULL(@Is_Half,0)AS VARCHAR(1)) + ' #'+ 'Is P Comp :' +CAST(ISNULL(@Is_P_Comp,0)as varchar(1)) + ' #'+ 'Message Text :' + ISNULL(@Message_Text,'')  + ' #' + 'Sms :' +CAST(ISNULL(@Sms,0)as varchar(4)) + ' #'+ 'National Holiday :' +CAST(ISNULL(@is_National_Holiday,0)as varchar(1))  + ' #' + 'Multiple Holiday :' +CAST(ISNULL(@Multiple_Holiday,0)AS VARCHAR(1)) + ' #'    
     End    
   Else  -- Added by nilesh patel on 061120114 -- Start     
     Begin      
          
        DECLARE Holiday_Cursor CURSOR FOR SELECT CAST(Data as numeric(18,0))  FROM dbo.Split(@Branch_ID,'#')    
                 OPEN Holiday_Cursor     
          fetch next from Holiday_Cursor into @Holiday_Branch    
        while @@fetch_status = 0    
         Begin      
                   
           select @Hday_ID = Isnull(max(Hday_ID),0) + 1 from dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK)    
                
           INSERT INTO dbo.T0040_HOLIDAY_MASTER(Hday_ID,cmp_Id,Hday_Name,H_From_Date ,H_To_Date ,Is_Fix,Hday_Ot_setting,Branch_ID,Is_Half,Is_P_Comp,Message_Text,Sms,is_National_Holiday, Is_optional,Multiple_Holiday,Is_Unpaid_Holiday)       
           VALUES         
           (@Hday_ID ,@cmp_Id ,@Hday_Name ,@H_From_Date ,@H_To_Date,@Is_Fix ,@Hday_Ot_setting,@Holiday_Branch,@Is_Half,@Is_P_Comp,@Message_Text,@Sms,@is_National_Holiday, @Is_Optional,@Multiple_Holiday,@Is_Unpaid_Holiday)    
               
           set @MaxLimit=0    
           --Added by Mukti(22112017)start for Optional Holiday Branchwise Limit    
           select @MaxLimit=Max_Limit from #BRANCH_LIMIT where Branch_ID=@Holiday_Branch    
           select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From dbo.T0050_Optional_Holiday_Limit WITH (NOLOCK)    
               
           if (isnull(@MaxLimit,0) > 0)    
            BEGIN    
             insert into T0050_Optional_Holiday_Limit(Tran_ID,Hday_ID,Cmp_ID,Branch_ID,Max_Limit,System_Date,[User_ID])    
             values(@Tran_ID,@Hday_ID,@Cmp_ID,@Holiday_Branch,@MaxLimit,GETDATE(),@User_ID)    
            END    
           --Added by Mukti(22112017)end for Optional Holiday Branchwise Limit    
           fetch next from Holiday_Cursor into @Holiday_Branch    
         End    
        Close Holiday_Cursor     
        deallocate Holiday_Cursor    
     End -- Added by nilesh patel on 061120114 -- End     
    
   End    
 Else if @Tran_Type = 'U'     
  begin    
   --If Exists(select HDay_ID From dbo.T0040_HOLIDAY_MASTER Where Cmp_ID = @Cmp_ID and     
   --     upper(HDay_Name) = upper(@HDay_Name) and Hday_ID <> @HDay_ID and isnull(Branch_ID,0) = isnull(@Branch_ID,0)  )  -- Modified by Mitesh 04/08/2011 for different collation db.    
   -- Begin    
   --  set @Hday_ID = 0      
   --  return    
   -- End    
   --Else - Commented by Mitesh on 30/01/2012     
       
   If exists(select HDay_ID From dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK) where UPPER(Hday_Name) = UPPER(@Hday_Name) and Cmp_ID = @Cmp_ID and     
        isnull(Branch_ID,0) = isnull(@Branch_ID,0) and Hday_ID <> @HDay_ID and    
       ( (@H_From_Date >= h_from_date and @H_From_Date <= h_to_date) or     
       (@H_To_Date >= h_from_date and  @H_To_Date <= h_to_date) or     
       (h_from_date >= @H_From_Date and h_from_date <= @H_To_Date) or    
       (h_to_date >= @H_From_Date and h_to_date <= @H_To_Date) )    
       )    
    Begin    
     set @Hday_ID = 0      
     return    
    End    
        
    select @OldHday_Name  =ISNULL(Hday_Name,'') ,@OldH_From_Date  =CAST(ISNULL(H_From_Date,'')as varchar(20)),@OldH_To_Date  =CAST(isnull(H_To_Date,'')as varchar(20)),@OldIs_Fix =isnull(Is_Fix ,''),@OldHday_Ot_setting =CAST(isnull(Hday_Ot_setting,0)as varchar(10)),@OldIs_Half  =CAST(isnull(Is_Half,0)as varchar(1)),@OldIs_P_Comp  =CAST(isnull(Is_P_Comp,'')as varchar(1)),@OldMessage_Text  =isnull(Message_Text ,''),@OldSms  =CAST(isnull(Sms,0)as varchar(4)),@Oldis_National_Holiday  =CAST( isnull(is_National_Holiday ,0)as varchar(1)) From dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Hday_ID = @Hday_ID    
    
     Update dbo.T0040_HOLIDAY_MASTER    
     set     
                  Hday_Name  = @Hday_Name    
                  , H_From_Date  = @H_From_Date    
                  , H_To_Date  = @H_To_Date    
                  , Is_Fix   = @Is_Fix    
                  , Hday_Ot_setting  = @Hday_Ot_setting    
                  ,Branch_ID   =  @Branch_ID    
                  ,Is_Half   = @Is_Half    
                  ,Is_P_Comp   = @Is_P_Comp                      
                  ,Message_Text      = @Message_Text    
                  ,Sms               = @Sms       
                  ,is_National_Holiday=@is_National_Holiday    
          ,is_optional = @Is_Optional    
                  ,Multiple_Holiday = @Multiple_Holiday    
                  ,Is_Unpaid_Holiday = @Is_Unpaid_Holiday    
    where Hday_ID = @Hday_ID    
    
   --Added by Mukti(22112017)start for Optional Holiday Branchwise Limit    
    select @MaxLimit=Max_Limit from #BRANCH_LIMIT where Branch_ID=@Branch_ID         
       
    IF EXISTS(select 1 from T0050_Optional_Holiday_Limit WITH (NOLOCK) where Hday_ID = @Hday_ID)    
     BEGIN      
      UPDATE T0050_Optional_Holiday_Limit     
      set Max_Limit=@MaxLimit    
      where Hday_ID = @Hday_ID     
     END     
    ELSE      
     BEGIN         
      select @Tran_ID = Isnull(max(Tran_ID),0) + 1 From dbo.T0050_Optional_Holiday_Limit WITH (NOLOCK)    
      insert into T0050_Optional_Holiday_Limit(Tran_ID,Hday_ID,Cmp_ID,Branch_ID,Max_Limit,System_Date,[User_ID])    
      values(@Tran_ID,@Hday_ID,@Cmp_ID,@Branch_ID,@MaxLimit,GETDATE(),@User_ID)    
     END    
   --Added by Mukti(22112017)end for Optional Holiday Branchwise Limit    
     set @OldValue = 'old Value' + '#'+ 'Hday Name :' +ISNULL( @OldHday_Name,'') + '#' + 'H From Date :' +CAST(ISNULL( @oldH_From_Date,'')as varchar(20)) + '#' + 'H To Date :' +CAST(ISNULL(@oldH_To_Date,'')as varchar(20)) + '#' + 'Is_Fix :' +CAST( ISNULL 
 
( @oldIs_Fix,0)AS VARCHAR(5)) + '#' + 'Hday Ot setting :' +CAST(ISNULL( @oldHday_Ot_setting,0)AS VARCHAR(20)) + ' #'+ 'Is Half :' +CAST(ISNULL(@oldIs_Half,0)AS VARCHAR(1)) + ' #'+ 'Is P Comp :' +CAST(ISNULL(@oldIs_P_Comp,0)as varchar(1)) + ' #'+ 'Message 
  
Text :' + ISNULL(@oldMessage_Text,'')  + ' #' + 'Sms :' +CAST(ISNULL(@oldSms,0)as varchar(4)) + ' #'+ 'National Holiday :' +CAST(ISNULL(@oldis_National_Holiday,0)as varchar(1))  + ' #' + 'Multiple Holiday :' +CAST(ISNULL(@oldMultiple_Holiday,0)AS VARCHAR(
  
1)) + ' #'     
               + 'New Value' + '#'+ 'Hday Name :' +ISNULL( @Hday_Name,'') + '#' + 'H From Date :' +CAST(ISNULL( @H_From_Date,'')as varchar(20)) + '#' + 'H To Date :' +CAST(ISNULL(@H_To_Date,'')as varchar(20)) + '#' + 'Is_Fix :' +CAST( ISNULL( @Is_Fix,0)AS
  
 VARCHAR(5)) + '#' + 'Hday Ot setting :' +CAST(ISNULL( @Hday_Ot_setting,0)AS VARCHAR(20)) + ' #'+ 'Is Half :' +CAST(ISNULL(@Is_Half,0)AS VARCHAR(1)) + ' #'+ 'Is P Comp :' +CAST(ISNULL(@Is_P_Comp,0)as varchar(1)) + ' #'+ 'Message Text :' + ISNULL(@Message_Text,'')  + ' #' + 'Sms :' +CAST(ISNULL(@Sms,0)as varchar(4)) + ' #'+ 'National Holiday :' +CAST(ISNULL(@is_National_Holiday,0)as varchar(1))  + ' #' + 'Multiple Holiday :' +CAST(ISNULL(@Multiple_Holiday,0)AS VARCHAR(1)) + ' #'    
     
  end    
 Else If @Tran_Type = 'D'    
  Begin    
     --If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY where Cmp_ID=@Cmp_ID And          
     --((@H_From_Date >= Month_St_Date and @H_From_Date <= Month_End_Date) or     
     --(@H_To_Date >= Month_St_Date and  @H_To_Date <= Month_End_Date) or     
     --(Month_St_Date >= @H_From_Date and Month_St_Date <= @H_To_Date) or    
     --(Month_End_Date >= @H_From_Date and Month_End_Date <= @H_To_Date)))    
     --Begin    
     -- Raiserror('@@This Months Salary Exists@@',18,2)    
     -- return -1    
     --End    
        
    IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) WHERE (MONTH =  MONTH(@H_From_Date) and YEAR =  YEAR(@H_From_Date)) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0))    
     Begin    
      Raiserror('@@Month Lock@@',18,2)    
      return -1    
     End    
        
    Delete from T0050_Optional_Holiday_Limit where Hday_ID = @Hday_ID --Added by Mukti(22112017)for Optional Holiday Branchwise Limit    
         
    select @OldHday_Name  =ISNULL(Hday_Name,'') ,@OldH_From_Date  =CAST(ISNULL(H_From_Date,'')as varchar(20)),@OldH_To_Date  =CAST(isnull(H_To_Date,'')as varchar(20)),@OldIs_Fix =isnull(Is_Fix ,''),@OldHday_Ot_setting =CAST(isnull(Hday_Ot_setting,0)as varchar(10)),@OldIs_Half  =CAST(isnull(Is_Half,0)as varchar(1)),@OldIs_P_Comp  =CAST(isnull(Is_P_Comp,'')as varchar(1)),@OldMessage_Text  =isnull(Message_Text ,''),@OldSms  =CAST(isnull(Sms,0)as varchar(4)),@Oldis_National_Holiday  =CAST( isnull(is_National_Holiday ,0)as varchar(1)) From dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Hday_ID = @Hday_ID    
    Delete From dbo.T0040_HOLIDAY_MASTER Where Hday_ID = @Hday_ID    
    set @OldValue ='old Value' + '#'+  'Hday Name :' +ISNULL( @OldHday_Name,'') + '#' + 'H From Date :' +CAST(ISNULL( @oldH_From_Date,'')as varchar(20)) + '#' + 'H To Date :' +CAST(ISNULL(@oldH_To_Date,'')as varchar(20)) + '#' + 'Is_Fix :' +CAST( ISNULL( 
  
@oldIs_Fix,0)AS VARCHAR(5)) + '#' + 'Hday Ot setting :' +CAST(ISNULL( @oldHday_Ot_setting,0)AS VARCHAR(20)) + ' #'+ 'Is Half :' +CAST(ISNULL(@oldIs_Half,0)AS VARCHAR(1)) + ' #'+ 'Is P Comp :' +CAST(ISNULL(@oldIs_P_Comp,0)as varchar(1)) + ' #'+ 'Message Te
  
xt :' + ISNULL(@oldMessage_Text,'')  + ' #' + 'Sms :' +CAST(ISNULL(@oldSms,0)as varchar(4)) + ' #'+ 'National Holiday :' +CAST(ISNULL(@oldis_National_Holiday,0)as varchar(1))  + ' #' + 'Multiple Holiday :' +CAST(ISNULL(@oldMultiple_Holiday,0)AS VARCHAR(1)
  
) + ' #'    
  End    
  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Holiday Master',@OldValue,@Hday_ID,@User_Id,@IP_Address    
      
 RETURN    
    
     
    