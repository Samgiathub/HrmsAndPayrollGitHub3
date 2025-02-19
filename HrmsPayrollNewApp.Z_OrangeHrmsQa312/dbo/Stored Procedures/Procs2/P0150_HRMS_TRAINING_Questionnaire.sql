  
  
-- =============================================  
-- Author:  Hiral   
-- ALTER date: <ALTER Date,,>  
-- Description: <Description,,>  
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P0150_HRMS_TRAINING_Questionnaire]  
  @Training_Que_ID  NUMERIC(18,0)OUT  
 ,@Question    NVARCHAR(500)  
 ,@Training_Id   VARCHAR(MAX)--added on 29 july 2015  
 ,@Cmp_Id    NUMERIC(18,0)  
 ,@Questionniare_Type INT   --added on 29 july 2015  
 ,@Question_Type   VARCHAR(50) --added on 29 july 2015  
 ,@Sorting_No   INT --added on 29 july 2015  
 ,@Question_Option  VARCHAR(800) --added on 29 july 2015  
 ,@Answer    VARCHAR(800) = null --added on 29 july 2015  
 ,@Marks     NUMERIC(18,2) --added on 29 july 2015  
 ,@Question_Row_Option VARCHAR(8000) = '' --Mukti(29072017)  
 ,@Question_Row_Type  INT = null  --Mukit(29072017)  
 ,@Video_Path   VARCHAR(200) = ''  
 ,@Trans_Type   CHAR(1)  
 ,@User_Id numeric(18,0) = 0 -- added By Mukti 19082015  
    ,@IP_Address varchar(30)= '' -- added By Mukti 19082015  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
--Added By Mukti 19082015(start)  
 declare @OldValue as varchar(max)  
 declare @OldQuestion NVARCHAR(500)  
 declare @OldTraining_Id VARCHAR(MAX)  
 declare @OldQuestionniare_Type varchar(15)   
 declare @OldQuestion_Type VARCHAR(50)   
 declare @OldSorting_No varchar(10)   
 declare @OldQuestion_Option VARCHAR(800)  
 declare @OldAnswer VARCHAR(800)  
 declare @OldMarks varchar(15)  
 declare @OldVideo_Path VARCHAR(200)  
--Added By Mukti 19082015(end)  
BEGIN  
 SET NOCOUNT ON;  
     set @Question = dbo.fnc_ReverseHTMLTags(@Question)  --added by Ronak 231021
 if @Trans_Type = 'I' or @Trans_Type = 'U'  
  Begin  
   if exists (select 1 from T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK) where Cmp_Id=@Cmp_Id and Sorting_No=@Sorting_No and Training_Que_ID<>@Training_Que_ID and Questionniare_Type=@Questionniare_Type)  
    begin  
     RAISERROR ('Duplicate Sorting Number', 16, 1)  
     set @Training_Que_ID= 0  
     Return  
    end  
   if exists (select 1 from T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK) where Cmp_Id=@Cmp_Id and Question=@Question and Training_Que_ID<>@Training_Que_ID)  
    begin  
     set @Training_Que_ID= 0  
     Return  
    end  
  End  
   
 If @Trans_Type = 'I'  
  Begin  
   Select @Training_Que_ID = ISNULL(MAX(Training_Que_ID),0) + 1 From T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK)  
     
   Insert Into T0150_HRMS_TRAINING_Questionnaire   
     (  
      Training_Que_ID  
      ,Question  
      ,Training_Id  
      ,Cmp_Id  
      ,Questionniare_Type  
      ,Question_Type  
      ,Sorting_No  
      ,Question_Option  
      ,Answer  
      ,Marks  
      ,Question_Row_Option  
      ,Question_Row_Type  
      ,Video_Path  
     )  
   Values(  
      @Training_Que_ID  
      ,@Question  
      ,@Training_Id  
      ,@Cmp_Id  
      ,@Questionniare_Type  
      ,@Question_Type  
      ,@Sorting_No  
      ,@Question_Option  
      ,@Answer  
      ,@Marks  
      ,@Question_Row_Option  
      ,@Question_Row_Type  
      ,@Video_Path  
     )  
       
 --Added By Mukti 19082015(start)  
   set @OldValue = 'New Value' + '#'+ 'Training ID :' + cast(Isnull(@Training_Id,'') as varchar(Max)) + '#' +   
              'Question :' + cast(Isnull(@Question,'') as varchar(500)) + '#' +   
              'Questionniare Type :' + cast(Isnull(@Questionniare_Type,0) as varchar(50)) + '#' +   
              'Question Type :' + cast(Isnull(@Question_Type,'') as varchar(50)) + '#' +   
              'Sorting No :' + cast(Isnull(@Sorting_No,0) as varchar(15)) + '#' +   
              'Question Option :' + cast(Isnull(@Question_Option,'') as varchar(800)) + '#' +   
              'Answer :' + cast(Isnull(@Answer,'') as varchar(800)) + '#' +   
              'Marks :' + cast(Isnull(@Marks,0) as varchar(15))  + '#' +   
              'Video Path :' + cast(Isnull(@Video_Path,0) as varchar(200))  
 --Added By Mukti 19082015(end)  
  End  
   
 Else If @Trans_Type = 'U'  
  Begin   
   --Added By Mukti 19082015(start)  
     select @OldTraining_Id = Training_Id  
      ,@OldQuestion = Question  
      ,@OldQuestionniare_Type = Questionniare_Type  
      ,@OldQuestion_Type = Question_Type  
      ,@OldSorting_No = Sorting_No  
      ,@OldQuestion_Option = Question_Option  
      ,@OldAnswer = Answer  
      ,@OldMarks = Marks   
      ,@OldVideo_Path = Video_Path  
     from T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK)  
     where Training_Que_ID = @Training_Que_ID  
   --Added By Mukti 19082015(end)   
     
   Update T0150_HRMS_TRAINING_Questionnaire   
    SET Training_Id = @Training_Id  
     ,Question = @Question  
     ,Questionniare_Type = @Questionniare_Type  
     ,Question_Type = @Question_Type  
     ,Sorting_No = @Sorting_No  
     ,Question_Option = @Question_Option  
     ,Answer = @Answer  
     ,Marks = @Marks  
     ,Question_Row_Option = @Question_Row_Option  
     ,Question_Row_Type = @Question_Row_Type  
     ,Video_Path = @Video_Path  
    Where Training_Que_ID = @Training_Que_ID   
      
 --Added By Mukti 19082015(start)  
   set @OldValue = 'Old Value' + '#'+ 'Training ID :' + cast(Isnull(@OldTraining_Id,'') as varchar(Max)) + '#' +   
              'Question :' + cast(Isnull(@OldQuestion,'') as varchar(500)) + '#' +   
              'Questionniare Type :' + cast(Isnull(@OldQuestionniare_Type,'') as varchar(50)) + '#' +   
              'Question Type :' + cast(Isnull(@OldQuestion_Type,'') as varchar(50)) + '#' +   
              'Sorting No :' + cast(Isnull(@OldSorting_No,'') as varchar(15)) + '#' +   
              'Question Option :' + cast(Isnull(@OldQuestion_Option,'') as varchar(800)) + '#' +   
              'Answer :' + cast(Isnull(@OldAnswer,'') as varchar(800)) + '#' +   
              'Marks :' + cast(Isnull(@OldMarks,'') as varchar(15))  + '#' +   
              'Video Path :' + cast(Isnull(@OldVideo_Path,'') as varchar(200))  + '#' +   
       'New Value' + '#'+ 'Training ID :' + cast(Isnull(@Training_Id,'') as varchar(Max)) + '#' +   
              'Question :' + cast(Isnull(@Question,'') as varchar(500)) + '#' +   
              'Questionniare Type :' + cast(Isnull(@Questionniare_Type,0) as varchar(50)) + '#' +   
              'Question Type :' + cast(Isnull(@Question_Type,'') as varchar(50)) + '#' +   
              'Sorting No :' + cast(Isnull(@Sorting_No,0) as varchar(15)) + '#' +   
              'Question Option :' + cast(Isnull(@Question_Option,'') as varchar(800)) + '#' +   
              'Answer :' + cast(Isnull(@Answer,'') as varchar(800)) + '#' +   
              'Marks :' + cast(Isnull(@Marks,0) as varchar(15)) + '#' +   
              'Video Path :' + cast(Isnull(@Video_Path,'') as varchar(200))    
     
 --Added By Mukti 19082015(end)  
  End  
   
 Else If @Trans_Type = 'D'  
  Begin  
  --Added By Mukti 19082015(start)  
     select @OldTraining_Id = Training_Id  
      ,@OldQuestion = Question  
      ,@OldQuestionniare_Type = Questionniare_Type  
      ,@OldQuestion_Type = Question_Type  
      ,@OldSorting_No = Sorting_No  
      ,@OldQuestion_Option = Question_Option  
      ,@OldAnswer = Answer  
      ,@OldMarks = Marks   
      ,@OldVideo_Path = Video_Path  
     from T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK)  
     where Training_Que_ID = @Training_Que_ID  
  --Added By Mukti 19082015(end)   
    
   Delete From T0150_HRMS_TRAINING_Questionnaire Where Training_Que_ID = @Training_Que_ID  
     
 --Added By Mukti 19082015(start)  
   set @OldValue = 'Old Value' + '#'+ 'Training ID :' + cast(Isnull(@OldTraining_Id,'') as varchar(Max)) + '#' +   
              'Question :' + cast(Isnull(@OldQuestion,'') as varchar(500)) + '#' +   
              'Questionniare Type :' + cast(Isnull(@OldQuestionniare_Type,'') as varchar(50)) + '#' +   
              'Question Type :' + cast(Isnull(@OldQuestion_Type,'') as varchar(50)) + '#' +   
              'Sorting No :' + cast(Isnull(@OldSorting_No,'') as varchar(15)) + '#' +   
              'Question Option :' + cast(Isnull(@OldQuestion_Option,'') as varchar(800)) + '#' +   
              'Answer :' + cast(Isnull(@OldAnswer,'') as varchar(800)) + '#' +   
              'Marks :' + cast(Isnull(@OldMarks,'') as varchar(15)) + '#' +   
              'Video Path :' + cast(Isnull(@Video_Path,'') as varchar(200))    
 --Added By Mukti 19082015(end)    
  End  
 exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training Questionnaire',@OldValue,@Training_Que_ID,@User_Id,@IP_Address   
END  
  