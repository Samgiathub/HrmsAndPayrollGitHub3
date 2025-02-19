
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_AD_Formula]   
 @Cmp_Id numeric(18,0),   
 @In_Formula nvarchar(max),    
 @Out_Formula nvarchar(max) Output ,
 @Actual_OutPut nvarchar(max) output 
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
   
 Declare @AD_ID as numeric(18,0)  
 Declare @AD_NAME as nvarchar(max)   
  
    set @Actual_OutPut= @In_Formula
     
   DECLARE Cur_Get_AD_Formula CURSOR FOR  
	  select AD_ID,AD_NAME from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_Id  
	  OPEN Cur_Get_AD_Formula  
		   fetch next from Cur_Get_AD_Formula into @AD_ID,@AD_NAME  
		   while @@fetch_status = 0  
			Begin  
					Set  @AD_NAME = '{'+ @AD_NAME +'}'   --Added By Hardik on 20/04/2016
				 --If CHARINDEX(@AD_NAME,@In_Formula)>0  --Comment by nilesh patel 
				  If CHARINDEX(@AD_NAME,@In_Formula)>0  -- Added by nilesh patel
				--  If @In_Formula like '%'+@AD_NAME+'%'
					  Begin 	
						   set @In_Formula=REPLACE(@In_Formula,@AD_NAME,'#'+@AD_NAME+'#') 
						   set @Actual_OutPut= REPLACE(@Actual_OutPut,@AD_NAME,'#{'+cast(@AD_ID as nvarchar(10))+'}#')
					  End
			         
			fetch next from Cur_Get_AD_Formula into @AD_ID,@AD_NAME  
			End  
	 close Cur_Get_AD_Formula   
	 deallocate Cur_Get_AD_Formula  
   
   

 set @In_Formula=REPLACE(@In_Formula,'(','#(#');  
 set @In_Formula=REPLACE(@In_Formula,')','#)#');  
 set @In_Formula=REPLACE(@In_Formula,'+','#+#');  
 set @In_Formula=REPLACE(@In_Formula,'-','#-#');  
 set @In_Formula=REPLACE(@In_Formula,'*','#*#');  
 set @In_Formula=REPLACE(@In_Formula,'/','#/#');  
 set @In_Formula=REPLACE(@In_Formula,'=','#=#');  
 set @In_Formula=REPLACE(@In_Formula,'>','#>#');  
 set @In_Formula=REPLACE(@In_Formula,'<','#<#');  
 set @In_Formula=REPLACE(@In_Formula,'&','#&#');  
 set @In_Formula=REPLACE(@In_Formula,'|','#|#');  
 set @In_Formula=REPLACE(@In_Formula,'##','#');
 set @In_Formula=REPLACE(@In_Formula,'case','#case#'); --Added by nilesh patel on 09032015
 set @In_Formula=REPLACE(@In_Formula,'when','#when#'); --Added by nilesh patel on 09032015
 set @In_Formula=REPLACE(@In_Formula,'else','#else#'); --Added by nilesh patel on 09032015
 set @In_Formula=REPLACE(@In_Formula,'end','#end#');   --Added by nilesh patel on 09032015
 set @In_Formula=REPLACE(@In_Formula,'then','#then#'); --Added by nilesh patel on 09032015
 set @In_Formula=REPLACE(@In_Formula,'Between','#Between#'); --Added by Hardik 10/07/2018
 set @In_Formula=REPLACE(@In_Formula,'And','#And#'); --Added by Hardik 10/07/2018



 set @Actual_OutPut=REPLACE(@Actual_OutPut,'(','#(#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,')','#)#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'+','#+#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'-','#-#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'*','#*#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'/','#/#'); 
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'=','#=#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'>','#>#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'<','#<#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'&','#&#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'|','#|#');  
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'##','#'); 
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'case','#case#'); --Added by nilesh patel on 09032015
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'when','#when#'); --Added by nilesh patel on 09032015
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'else','#else#'); --Added by nilesh patel on 09032015
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'end','#end#');   --Added by nilesh patel on 09032015
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'then','#then#'); --Added by nilesh patel on 09032015 
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'Between','#Between#'); --Added by Hardik 10/07/2018
 set @Actual_OutPut=REPLACE(@Actual_OutPut,'And','#And#'); --Added by Hardik 10/07/2018

 set @Out_Formula=@In_Formula  
 set @Actual_OutPut= @Actual_OutPut
 RETURN    

