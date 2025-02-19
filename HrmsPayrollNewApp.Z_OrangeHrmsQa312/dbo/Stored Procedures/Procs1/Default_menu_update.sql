


-- Created By rohit for update privilege setting auto to all company on 31012013
-- created date :-11072015
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Default_menu_update]        
	@cmp_id numeric(18,0) = 0,
	@priviledge_id numeric(18,0) = 0
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
--Added by sumit as per nimesh bhai guideline  
	BEGIN

		if @cmp_id=0
			set @cmp_id = null
		if @priviledge_id = 0
			set @priviledge_id = null	

		declare @curCMP_ID numeric
		declare @curPrivilege_id numeric
		declare @tran_id as numeric(18,0)
			
		Declare CusrCompanyMST cursor for	                  
		select PM.CMP_ID,privilege_id from t0010_company_master CM WITH (NOLOCK) inner join T0020_PRIVILEGE_MASTER  PM WITH (NOLOCK) on CM.cmp_id = PM.cmp_id where cm.cmp_id = isnull(@cmp_id,cm.cmp_id) and privilege_id = isnull(@priviledge_id,privilege_id)  
		Open CusrCompanyMST
		Fetch next from CusrCompanyMST into @curCMP_ID,@curPrivilege_id
		While @@fetch_status = 0                    
			Begin     

			declare @form_id as numeric(18,0)
			declare @is_view as numeric
			declare @under_form_id as numeric(18,0)

			Declare CusrprMST cursor for	                  
			select form_id,is_view,under_form_id FROM V0020_PRIVILEGE_MASTER_DETAILS where Cmp_ID= @curCMP_ID and Privilege_ID = @curPrivilege_id Order By Sort_Id,sort_id_check 
			Open CusrprMST
			Fetch next from CusrprMST into @form_id,@is_view,@under_form_id
			While @@fetch_status = 0                    
				Begin 
					
					ABC:	
					if (@is_view = 1 and @under_form_id <> -1)
					begin
						
						if exists( select 1 from T0050_PRIVILEGE_DETAILS WITH (NOLOCK) where Form_Id=@under_form_id and cmp_id=@curCMP_ID and Privilage_ID =@curPrivilege_id)
							begin
								update T0050_PRIVILEGE_DETAILS set Is_View = 1 ,Is_Edit=1,Is_Delete=1,Is_Save=1 
								where  Form_Id=@under_form_id and cmp_id=@curCMP_ID and Privilage_ID =@curPrivilege_id
							
								select @under_form_id = under_form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID=@under_form_id
								
								Goto ABC;
								
							end
						else
							begin
							
								set @tran_id=0
								select @tran_id = isnull(max(Trans_Id),0) + 1 from  T0050_PRIVILEGE_DETAILS WITH (NOLOCK)
							
								insert into T0050_PRIVILEGE_DETAILS (Trans_Id,Privilage_ID,Cmp_Id,Form_Id,Is_View,Is_Edit,Is_Save,Is_Delete,Is_Print)
								values(@tran_id,@curPrivilege_id,@curCMP_ID,@under_form_id,1,1,1,1,0)
								
								select @under_form_id = under_form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID=@under_form_id
								
								Goto ABC;
							end
					
					end
				
					fetch next from CusrprMST into @form_id,@is_view,@under_form_id
				end
				close CusrprMST                    
				deallocate CusrprMST
			
				fetch next from CusrCompanyMST into @curCMP_ID,@curPrivilege_id	
			end
			close CusrCompanyMST                    
			deallocate CusrCompanyMST
		return
	end

