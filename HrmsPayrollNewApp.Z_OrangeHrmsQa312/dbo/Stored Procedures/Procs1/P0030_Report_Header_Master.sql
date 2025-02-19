  
  
  
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE  PROCEDURE [dbo].[P0030_Report_Header_Master]  
   @Report_ID numeric(18) output  
  ,@Report_Header_Name varchar(100)  
  ,@Cmp_ID numeric(18,0)  
   
  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   set @Report_Header_Name = dbo.fnc_ReverseHTMLTags(@Report_Header_Name)  --added by Ronak 081021
 begin  
  if exists (Select Report_ID  from T0030_Report_Header_Master WITH (NOLOCK) Where Upper(Report_Header_Name) = Upper(@Report_Header_Name) and Cmp_ID=@Cmp_ID)   
    begin  
     set @Report_ID=0  
     return  
    end  
   else  
    begin  
     select @Report_ID = isnull(max(Report_ID),0) +1  from T0030_Report_Header_Master WITH (NOLOCK)  
     insert into T0030_Report_Header_Master(Report_ID,Cmp_ID,Report_Header_Name,Systemdate)   
     values(@Report_ID,@Cmp_ID,@Report_Header_Name,GETDATE())  
    end  
  end   
  
 RETURN  
  
  
  
  