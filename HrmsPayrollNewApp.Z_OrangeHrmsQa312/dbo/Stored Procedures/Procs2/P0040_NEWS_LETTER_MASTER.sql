  
  
CREATE PROCEDURE [dbo].[P0040_NEWS_LETTER_MASTER]  
 @News_Letter_ID AS NUMERIC OUTPUT  
,@Cmp_ID   AS NUMERIC  
,@News_Title  AS Varchar(50)  
,@News_Description  AS Varchar(250)  
,@Start_Date  AS Datetime  
,@End_Date   AS Datetime  
,@Is_Visible  AS Tinyint  
,@Flag_T   AS Tinyint  
,@Tran_Type   AS Char  
,@User_Id   Numeric(18,0) = 0  
,@IP_Address  Varchar(30)= '' --Add By Paras 19-10-2012  
,@Flag_P   AS Tinyint = 0  --Added By Hiral 19 April,2013  
,@Login_Notification as tinyint = 0 -- Added by Gadriwala Muslim 15122016  
,@Is_Member_Flag As Tinyint = 0   
,@Manager_EmpID As Numeric = 0  
,@Announce_EmpList As Varchar(max) = ''  
,@Branch_Wise_News_Announ As Varchar(max) = ''  
,@flag as varchar(10) ='web'  
  
AS  
  
        SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
declare @OldValue as  varchar(max)  
declare @OldNews_Title as varchar(50)  
declare @OldNews_Description as varchar(250)  
declare @OldStart_Date as varchar(20)  
declare @OldEnd_Date  as varchar(20)  
declare @OldIs_Visible as  varchar(1)  
declare @OldFlag_T as  varchar(1)  
declare @OldFlag_P  as  varchar(1)  
Declare @oldLogin_Notification as varchar(1)  -- Added by Gadriwala Muslim 15122016  
set @OldNews_Title = ''  
set @OldNews_Description = ''  
set @OldStart_Date = ''  
set @OldEnd_Date  = ''  
set @OldIs_Visible = ''  
set @OldFlag_T = ''  
set @OldFlag_P = ''  
set @oldLogin_Notification = ''  
  
if @Manager_EmpID = 0  
 Set @Manager_EmpID = NULL  
  
if @Branch_Wise_News_Announ = '0'  
 Set @Branch_Wise_News_Announ = NULL  
   set @News_Title = dbo.fnc_ReverseHTMLTags(@News_Title)--added by Ronak 251021  
    set @News_Description = dbo.fnc_ReverseHTMLTags(@News_Description)  --added by Ronak 251021  
  
If  @Tran_Type = 'I'  
 begin  
   
 if @flag='web'  
  begin  
   if exists(select  News_Letter_ID from  T0040_NEWS_LETTER_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and  upper(News_Title) = upper(@News_Title) and Start_Date = @Start_Date and End_Date = @End_Date)  
     
    begin   
     set @News_Letter_ID = 0  
     return  
    end  
  end  
     
  select  @News_Letter_ID = isnull(max(News_Letter_ID),0)+1 from  T0040_NEWS_LETTER_MASTER WITH (NOLOCK)  
   
  INSERT INTO T0040_NEWS_LETTER_MASTER  
     (News_Letter_ID,Cmp_ID,News_Title,News_Description,Start_Date,End_Date,Is_Visible,Flag_T,Flag_P,Login_Notification,Is_Member_Flag,News_Announ_EmpID,News_Announ_For,Branch_Wise_News_Announ,flag)  
   VALUES (@News_Letter_ID,@Cmp_ID,@News_Title,@News_Description,@Start_Date,@End_Date,@Is_Visible,@Flag_T,@Flag_P,@Login_Notification,@Is_Member_Flag,@Manager_EmpID,@Announce_EmpList,@Branch_Wise_News_Announ,@flag) -- Added by Gadriwala Muslim 15122016  
      
     
   set @OldValue = 'New Value' + '#'+ 'News Title :' +ISNULL( @News_Title,'') + '#' + 'News Description :' + ISNULL( @News_Description,'') + '#' + 'Start Date :' + CAST(ISNULL(@Start_Date,0) AS VARCHAR(20)) + '#' + 'End Date :' +CAST( ISNULL( @End_Date,0)
AS VARCHAR(20)) + '#' + 'Is Visible :' +CAST(ISNULL( @Is_Visible,0)AS VARCHAR(2)) + ' #'+ 'Flag T :' +CAST(ISNULL(@Flag_T,0)AS VARCHAR(2)) + '#' + 'Flag P :' + CAST(ISNULL(@Flag_P,0)AS VARCHAR(2)) + '#' + 'Login Notification :' + CAST(ISNULL(@Login_Notification,0)AS VARCHAR(2)) + '#' + 'Branch Wise News Announcement :' + @Branch_Wise_News_Announ  
 END  
else if @Tran_Type = 'U'  
 BEGIN   
  if exists(select  News_Letter_ID from  T0040_NEWS_LETTER_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and  upper(News_Title) = upper(@News_Title) and Start_Date = @Start_Date and End_Date = @End_Date and News_Letter_ID <> @News_Letter_ID)  
   begin   
    set @News_Letter_ID = 0  
    return  
   end  
     
	   select @OldNews_Title =ISNULL(News_Title,'') ,@OldNews_Description  =ISNULL(News_Description,''),@OldStart_Date  =CAST(isnull(@Start_Date,0)as varchar(20)),@OldEnd_Date  =CAST(isnull(@End_Date,0)as varchar(20)),@OldIs_Visible =CAST(isnull(Is_Visible,0)
	as varchar(2)),@OldFlag_T  =CAST( isnull(Flag_T,0)as varchar(1)),@OldFlag_P = CAST(isnull(Flag_P,0)as varchar(1)),@oldLogin_Notification = CAST(Login_Notification AS varchar(1)) From dbo.T0040_NEWS_LETTER_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and News_Letter_ID = @News_Letter_ID       
   
   Update T0040_NEWS_LETTER_MASTER  
    set News_Title = @News_Title ,News_Description = @News_Description,Start_Date=@Start_Date,End_Date=@End_Date,Is_Visible=@Is_Visible,Flag_T = @Flag_T,Flag_P = @Flag_P, Login_Notification = @Login_Notification,  
     Is_Member_Flag = @Is_Member_Flag, News_Announ_EmpID = @Manager_EmpID ,News_Announ_For = @Announce_EmpList,Branch_Wise_News_Announ = @Branch_Wise_News_Announ,  
     SYSTEM_DATE = GETDATE(),flag=@flag  
    where News_Letter_ID = @News_Letter_ID -- Changed by GAdriwala Muslim 15122016  
      
    set @OldValue = 'old Value' + '#'+ 'News Title :' +ISNULL(@OldNews_Title,'') + '#' + 'News Description :' + ISNULL(@OldNews_Description,'') + '#' + 'Start Date :' + CAST(ISNULL(@OldStart_Date,0) AS VARCHAR(20)) + '#' + 'End Date :' +CAST( ISNULL(@OldEnd_Date,0)AS VARCHAR(20)) + '#' + 'Is Visible :' +CAST(ISNULL( @OldIs_Visible,0)AS VARCHAR(2)) + ' #'+ 'Flag T :' +CAST(ISNULL(@OldFlag_T,0)AS VARCHAR(2)) + ' #'+ 'Flag P :' +CAST(ISNULL(@OldFlag_P,0)AS VARCHAR(2)) + ' #'+ 'Login Notification :' +CAST(ISNULL(@oldLogin_Notification,0)AS VARCHAR(1))   
               + 'New Value' + '#'+ 'News Title :' +ISNULL( @News_Title,'') + '#' + 'News Description :' + ISNULL( @News_Description,'') + '#' + 'Start Date :' + CAST(ISNULL(@Start_Date,0) AS VARCHAR(20)) + '#' + 'End Date :' +CAST( ISNULL( @End_Date,0)AS
 VARCHAR(20)) + '#' + 'Is Visible :' +CAST(ISNULL( @Is_Visible,0)AS VARCHAR(2)) + ' #'+ 'Flag T :' +CAST(ISNULL(@Flag_T,0)AS VARCHAR(2)) + ' #'+ 'Flag P :' +CAST(ISNULL(@Flag_P,0)AS VARCHAR(2)) + ' #'+ 'Login Notification :' +CAST(ISNULL(@Login_Notification,0)AS VARCHAR(1))   
    
   
 END   
else if @Tran_Type = 'D'   
begin  
   select @OldNews_Title =ISNULL(News_Title,'') ,@OldNews_Description  =ISNULL(News_Description,''),@OldStart_Date  =CAST(isnull(@Start_Date,0)as varchar(20)),@OldEnd_Date  =CAST(isnull(@End_Date,0)as varchar(20)),@OldIs_Visible =CAST(isnull(Is_Visible,0)
as varchar(2)),@OldFlag_T  =CAST( isnull(Flag_T,0)as varchar(1)),@OldFlag_P  =CAST( isnull(Flag_P,0)as varchar(1)),@oldLogin_Notification = CAST(Login_Notification AS varchar(1)) From dbo.T0040_NEWS_LETTER_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and News_Letter_ID = @News_Letter_ID  
   Delete from T0040_NEWS_LETTER_MASTER where News_Letter_ID = @News_Letter_ID  
   set @OldValue = 'old Value' + '#'+ 'News Title :' +ISNULL(@OldNews_Title,'') + '#' + 'News Description :' + ISNULL(@OldNews_Description,'') + '#' + 'Start Date :' + CAST(ISNULL(@OldStart_Date,0) AS VARCHAR(20)) + '#' + 'End Date :' +CAST( ISNULL(@OldEnd_Date,0)AS VARCHAR(20)) + '#' + 'Is Visible :' +CAST(ISNULL( @OldIs_Visible,0)AS VARCHAR(2)) + ' #'+ 'Flag T :' +CAST(ISNULL(@OldFlag_T,0)AS VARCHAR(2)) + ' #'+ 'Flag P :' +CAST(ISNULL(@OldFlag_P,0)AS VARCHAR(2))+ ' #'+ 'Login Notification :' +CAST(ISNULL(@oldLogin_Notification,0)AS VARCHAR(1))   
   end  
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'News Master',@OldValue,@News_Letter_ID,@User_Id,@IP_Address  
 RETURN  
  
  
  
  