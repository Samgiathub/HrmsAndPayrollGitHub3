  
  
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0090_EMP_LICENSE_DETAIL]   
   @Row_ID numeric output  
  ,@Emp_ID numeric  
  ,@Cmp_ID numeric  
  ,@Lic_ID numeric   
  ,@Lic_St_Date datetime  
  ,@Lic_End_Date datetime  
  ,@Lic_Comments varchar(250)   
  ,@Lic_For varchar(50)  = ''  -- Added By Gadriwala 07022014  
  ,@Lic_number varchar(20) = '' -- Added By Gadriwala 07022014  
  ,@Is_Expired tinyint = 0  -- Added By Gadriwala 07022014  
  ,@tran_type varchar(1)  
 AS  
 SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   set @Lic_Comments = dbo.fnc_ReverseHTMLTags(@Lic_Comments)  --added by Ronak 100121  
  if @Lic_ID= 0   
   set @Lic_ID = null  
  if @tran_type ='I'   
   begin  
      
    select @Row_ID = isnull(max(Row_ID),0) +1   from T0090_EMP_LICENSE_DETAIL WITH (NOLOCK)  
          
    INSERT INTO T0090_EMP_LICENSE_DETAIL  
                          (Emp_ID, Row_ID, Cmp_ID, Lic_ID, Lic_St_Date, Lic_End_Date, Lic_Comments,Lic_For,Lic_number,Is_Expired)-- Added By Gadriwala 07022014  
    VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@Lic_ID,@Lic_St_Date,@Lic_End_Date,@Lic_Comments,@Lic_For,@Lic_number,@Is_Expired)  -- Added By Gadriwala 07022014  
         
    end   
 Else If @tran_type ='U'   
    begin  
     UPDATE    T0090_EMP_LICENSE_DETAIL  
     SET              Cmp_ID = @Cmp_ID, Lic_ID = @Lic_ID, Lic_St_Date = @Lic_St_Date, Lic_End_Date = @Lic_End_Date, Lic_Comments = @Lic_Comments,Lic_For = @Lic_For,lic_number = @Lic_number,is_expired = @Is_Expired -- Added By Gadriwala 07022014  
        where Emp_ID = @Emp_ID and Row_ID = @Row_ID  
    end  
 Else If @tran_type ='D'  
     delete  from T0090_EMP_LICENSE_DETAIL where Row_ID = @Row_ID  
 RETURN  
  
  
  
  