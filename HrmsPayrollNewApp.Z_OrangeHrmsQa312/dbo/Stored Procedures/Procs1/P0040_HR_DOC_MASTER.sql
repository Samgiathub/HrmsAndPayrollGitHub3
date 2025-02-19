
--zalak --20-sep-2010 -- hr doc for publish diffrent types of doc  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_HR_DOC_MASTER]  
  
  @HR_DOC_ID numeric(18,0) output  
 ,@Doc_Title varchar(100)  
 ,@Cmp_id numeric(18,0)  
 ,@Branch_id numeric(18,0)  
 ,@Grd_id numeric(18,0)  
 ,@Dept_id numeric(18,0)  
 ,@Desig_id numeric(18,0)  
 ,@Doc_content nvarchar(Max)  
 ,@Display_Joinining int  
 ,@gender char(1)  
 ,@tran_type varchar(1)  
 ,@Display_Ess int
 ,@Join_Days varchar(100)
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 if @Branch_id=0   
    set @Branch_id=null  
 if @Grd_id=0  
    set @Grd_id = null  
 if @Dept_id=0  
    set @Dept_id = null  
 if @Desig_id=0  
    set @Desig_id=null  
	set @Doc_Title = dbo.fnc_ReverseHTMLTags(@Doc_Title)  --added by Ronak 221021
 If @tran_type  = 'I'  
  Begin  
    If Exists(Select HR_DOC_ID From T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and (Doc_Title = @Doc_Title or Doc_Title=''))  
     begin  
      set @HR_DOC_ID = 0  
      Return   
     end  
      
    select @HR_DOC_ID= Isnull(max(HR_DOC_ID),0) + 1  From T0040_HR_DOC_MASTER WITH (NOLOCK)  
      
    INSERT INTO T0040_HR_DOC_MASTER  
                          ( HR_DOC_ID  
          ,Doc_Title  
          ,Cmp_id  
          ,Branch_id  
          ,Grd_id  
          ,Dept_id  
          ,Desig_id  
          ,Doc_content  
          ,Display_Joinining  
          ,gender  
		  ,Display_Ess
		  ,Join_Days
          )  
       VALUES     (@HR_DOC_ID  
          ,@Doc_Title  
          ,@Cmp_id  
          ,@Branch_id  
          ,@Grd_id  
          ,@Dept_id  
          ,@Desig_id  
          ,@Doc_content  
          ,@Display_Joinining  
          ,@gender
		  ,@Display_Ess
		  ,@Join_Days)  
            
  End  
 Else if @Tran_Type = 'U'  
  begin  
    If Exists(Select HR_DOC_ID From T0040_HR_DOC_MASTER  WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and HR_DOC_ID <> @HR_DOC_ID and (Doc_Title = @Doc_Title or Doc_Title=''))  
     begin  
      set @HR_DOC_ID = 0  
      Return   
     end  
  
      Update T0040_HR_DOC_MASTER  
      set   
       Doc_Title=@Doc_Title  
       ,Branch_id=@Branch_id  
       ,Grd_id=@Grd_id  
       ,Dept_id=@Dept_id  
       ,Desig_id=@Desig_id  
       ,Doc_content=@Doc_content  
       ,Display_Joinining=@Display_Joinining  
       ,gender=@gender  
	   ,Display_Ess=@Display_Ess
	   ,Join_Days=@Join_Days
      where HR_DOC_ID = @HR_DOC_ID  
      
  end  
 Else if @Tran_Type = 'D'  
  begin  
    Delete From T0040_HR_DOC_MASTER Where HR_DOC_ID= @HR_DOC_ID  
  end  
  
 RETURN  
  
  
  
  