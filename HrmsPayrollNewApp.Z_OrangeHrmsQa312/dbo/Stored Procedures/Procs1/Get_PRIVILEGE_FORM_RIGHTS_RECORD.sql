

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_PRIVILEGE_FORM_RIGHTS_RECORD]      
  @Cmp_ID  numeric      
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    DECLARE @PRV_ID_CUR AS NUMERIC
	DECLARE @BRN_ID_CUR AS varchar(100)
	DECLARE @CMP_ID_CUR AS varchar(100)
	DECLARE @PRV_NAME_CUR AS varchar(100)
 

	--CREATE table #Prv_table 
	--(
 --   NO  varchar(10),  
	--Privilege_name  varchar(100),
	--Form_Name  varchar(100),
	--is_view  varchar(10),
	--is_edit  varchar(10),
	--is_save  varchar(10),
	--is_delete  varchar(10)

	--)
   
    declare  @Prv_table table
	(
    NOs varchar(100),
	Privilege_name  varchar(100),
	Form_Name  varchar(100),
	Form_Alias  varchar(100),	--Added By Ramiz on 23/03/2017
	is_view  varchar(10),
	is_edit  varchar(10),
	is_save  varchar(10),
	is_delete  varchar(10)

	)


	DECLARE CURPRV CURSOR FOR                    
	SELECT  cmp_id ,Privilege_ID, isnull(Branch_Name,'ALL') as branch_name, isnull(Privilege_Name,'') FROM V0020_PRIVILEGE_MASTER WHERE     Cmp_Id = @Cmp_ID
	OPEN CURPRV    
	declare @intcount int
	set @intcount=1                  
	  FETCH NEXT FROM CURPRV INTO @CMP_ID_CUR,@PRV_ID_CUR,@BRN_ID_CUR,@PRV_NAME_CUR
				 
		WHILE @@FETCH_STATUS = 0                    
			BEGIN
		 
		--	insert into #Prv_table
		
		    insert into @Prv_table
			Select (case when (ROW_NUMBER() OVER(ORDER BY Sort_Id))=1 then @intcount end),
					(case when (ROW_NUMBER() OVER(ORDER BY Sort_Id))=1 then @PRV_NAME_CUR else '' end) AS Privilege_Name,
					Form_Name,Alias,
					(case when Is_View = 1 then 'Yes' else 'No' end) as 'View', 
					(case when Is_Edit = 1 then 'Yes' else 'No' end) as 'Edit', 
					(case when Is_Save = 1 then 'Yes' else 'No' end) as 'Save', 
					(case when Is_Delete = 1 then 'Yes' else 'No' end) as 'Delete'     
					FROM V0020_PRIVILEGE_MASTER_DETAILS where Cmp_ID= @CMP_ID_CUR and Privilege_ID = @PRV_ID_CUR  
					Order By Sort_Id
		    
		    set @intcount=@intcount+1
		    
			FETCH NEXT FROM CURPRV INTO @CMP_ID_CUR,@PRV_ID_CUR,@BRN_ID_CUR,@PRV_NAME_CUR
			
			END
		 
	CLOSE CURPRV
	DEALLOCATE CURPRV

	--select * from #Prv_table
 
    SELECT ISNULL(NOS,'') NO,PRIVILEGE_NAME,FORM_NAME,FORM_ALIAS as ACTUAL_FORM_NAME ,IS_VIEW,IS_EDIT,IS_SAVE,IS_DELETE FROM @PRV_TABLE
	--drop table #Prv_table
	    
 RETURN      
      
      
    

