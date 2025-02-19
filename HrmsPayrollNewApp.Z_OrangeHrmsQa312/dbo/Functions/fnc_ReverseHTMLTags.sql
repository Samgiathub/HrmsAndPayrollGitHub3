  
--- select dbo.fnc_ReverseHTMLTags('test&amp;amp;amp;t')              
--- Drop function [dbo].[fnc_ReverseHTMLTags]                  
CREATE FUNCTION [dbo].[fnc_ReverseHTMLTags]               
(              
 @StrValue varchar(max)              
)              
RETURNS varchar(max)              
AS              
BEGIN              
    DECLARE @lValue varchar(max) = ''              
              
   select @lValue = Replace(replace(replace(REPLACE(replace(replace(replace(replace(replace(replace(REPLACE(@StrValue,'amp;',''),'amp;',''),'&#39;',''''),'&''','&'),'&#13;&#10;',' '),'amp;#39;','') ,'',''),'&#10;',''),'&#10;',' '),'&quot;','"'),'','');    
              
    RETURN @lValue              
END  
  
  