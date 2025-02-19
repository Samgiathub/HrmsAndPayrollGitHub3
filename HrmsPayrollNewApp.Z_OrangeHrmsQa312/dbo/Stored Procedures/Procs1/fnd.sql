--- exec fnd '@Table'  
--- Drop PROCEDURE [dbo].[fnd]    
CREATE PROCEDURE [dbo].[fnd]    
@StringToSearch varchar(500)    
AS    
begin     
   SELECT Distinct SO.Name    
   FROM sysobjects SO (NOLOCK)    
   INNER JOIN syscomments SC (NOLOCK) on SO.Id = SC.ID and  
   (SO.Type = 'P'   or  SO.type = 'FN')  
   AND SC.Text LIKE '%' + @StringToSearch + '%'  
   ORDER BY SO.Name  
end