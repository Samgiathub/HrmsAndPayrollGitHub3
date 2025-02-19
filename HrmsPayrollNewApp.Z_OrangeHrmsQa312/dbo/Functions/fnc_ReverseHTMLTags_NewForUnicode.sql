  
--- select dbo.fnc_ReverseHTMLTags('test&amp;amp;amp;t')              
--- Drop function [dbo].[fnc_ReverseHTMLTags]                  
Create FUNCTION [dbo].[fnc_ReverseHTMLTags_NewForUnicode]               
(              
 @StrValue nvarchar(max)              
)              
RETURNS nvarchar(max)              
AS              
BEGIN              
    DECLARE @lValue nvarchar(max) = ''              
              
   select @lValue = Replace(replace(replace(REPLACE(replace(replace(replace(replace(replace(replace(REPLACE(@StrValue,'&amp;','  '),'amp;',''),'&#39;',''''),'&''','&'),'&#13;&#10;',' '),'&amp;#39;','') ,'',''),'&#10;',''),'&#10;',' '),'&quot;','"'),'','');    
              
    RETURN @lValue              
END  
  
  