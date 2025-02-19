--- select dbo.fnc_ReverseHTMLTags('test&amp;amp;amp;t')        
--- Drop function [dbo].[fnc_ReverseHTMLTags]            
create FUNCTION [dbo].[fnc_ReverseHTMLTags_working_Backup27102021]         
(        
 @StrValue varchar(max)        
)        
RETURNS varchar(max)        
AS        
BEGIN        
    DECLARE @lValue varchar(max) = ''        
        
   select @lValue = REPLACE(replace(replace(replace(replace(REPLACE(@StrValue,'&amp;','&'),'amp;',''),'&#39;',''''),'&''','&'),'&#13;&#10;',' '),'&amp;#39;','')
   
        
    RETURN @lValue        
END