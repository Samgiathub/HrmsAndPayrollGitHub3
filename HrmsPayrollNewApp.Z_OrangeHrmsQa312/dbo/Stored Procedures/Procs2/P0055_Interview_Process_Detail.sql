




------------------------------------------------------------------
-------  Created by: Pranjal on 15-apr-2010 ------------------------
------------------------------------------------------------------
--------  Modified By : Falak on 19-apr-2010
--------  Modified By : Falak on 1-may-2010 process date REmoved from TAble
--change by pranjal : on 21-dec-2010 for flow of recruitment 
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0055_Interview_Process_Detail]

 @Interview_Process_detail_ID			numeric(18,0) output
,@cmp_id				numeric(18,0)
,@Rec_Post_ID			numeric(18,0)
,@Process_ID			numeric(18,0)
,@S_Emp_ID		        numeric(18,0)
,@S_Emp_Id2             numeric(18,0)
,@S_Emp_Id3             numeric(18,0)
,@S_Emp_Id4             numeric(18,0)
,@From_Date             datetime
,@To_Date               datetime
,@From_Time             varchar(15)
,@To_Time               varchar(15) 
,@Dis_no				numeric(18,0)
,@tran_type				char(1)
           
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @From_Date=''
	  set @From_Date =null
	if @To_Date =''
	  set @To_Date =null
	if @S_Emp_ID = 0
		   set @S_Emp_ID =null

	if @S_Emp_ID=0
	 set @S_Emp_ID= null
	
	if @S_Emp_ID2=0
	 set @S_Emp_ID2= null
	
	if @S_Emp_ID3=0
	 set @S_Emp_ID3= null
	
	if @S_Emp_ID4=0
	 set @S_Emp_ID4= null
	set nocount on
	
	if Upper(@tran_type) ='I' 
		begin		
			if exists (Select Interview_Process_detail_ID  from T0055_Interview_Process_Detail WITH (NOLOCK) Where cmp_id= @CMP_ID AND Process_ID = @Process_ID and Rec_post_Id = @Rec_post_Id)
				begin
					set @Interview_Process_detail_ID=0
					RETURN  
				end 
		
					
					select @Interview_Process_detail_ID = isnull(max(Interview_Process_detail_ID),0) +1 from T0055_Interview_Process_Detail WITH (NOLOCK)  
     
     						
					insert into T0055_Interview_Process_Detail
					(
											Interview_Process_detail_ID
											,cmp_id
											,Rec_Post_ID
											,Process_ID											
											,S_Emp_ID
											,S_Emp_Id2            
											,S_Emp_Id3            
											,S_Emp_Id4            
											,From_Date            
											,To_Date              
											,From_Time            
											,To_Time 
											,Dis_no
											,System_Date            
										) 
											
								values
										(    @Interview_Process_detail_ID
											,@cmp_id
											,@Rec_Post_ID
											,@Process_ID
											,@S_Emp_ID
											,@S_Emp_Id2            
											,@S_Emp_Id3            
											,@S_Emp_Id4            
											,@From_Date            
											,@To_Date              
											,@From_Time            
											,@To_Time 
											,@Dis_no
											,getdate()
																					)

		end 
	else if upper(@tran_type) ='U' 
		begin
					
				Update T0055_Interview_Process_Detail 
				Set 
						Process_ID = @Process_ID						
						,S_Emp_id = @S_Emp_id
						,Rec_Post_Id = @Rec_Post_id
						,S_Emp_Id2=@S_Emp_Id2            
						,S_Emp_Id3=@S_Emp_Id3            
						,S_Emp_Id4=@S_Emp_Id4            
						,From_Date=@From_Date            
						,To_Date=@To_Date              
						,From_Time=@From_Time            
						,To_Time=@To_Time 
						,Dis_no = @Dis_no
						,System_Date=getdate()
						
					where Interview_Process_detail_ID = @Interview_Process_detail_ID  
		end	
	else if upper(@tran_type) ='D'
		Begin
						
			delete  from T0055_Interview_Process_Detail where Interview_Process_detail_ID=@Interview_Process_detail_ID 
						
		end
	RETURN




