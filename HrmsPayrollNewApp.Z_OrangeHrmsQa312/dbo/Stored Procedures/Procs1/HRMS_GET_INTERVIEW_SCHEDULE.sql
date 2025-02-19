



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[HRMS_GET_INTERVIEW_SCHEDULE]
  @Cmp_ID numeric(18,0),
  @From_Date DateTime,
  @To_date DateTime,
  @Constraint varchar(10) = '',
  @Resume_Status as numeric(1,0)
  
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Resume_cons table
	(
	   Resume_ID numeric(18,0)
	)
	 
	if @Constraint <> ''
	  begin  
		  Insert Into @Resume_cons
		  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')   
	  end   
	 Else
	   Begin
	     
	     Insert Into @Resume_cons  
	     Select IS1.Resume_ID from T0055_HRMS_Interview_Schedule IS1  WITH (NOLOCK) inner join
	      (Select  Max(Process_Dis_No) as Process_Dis_No1,Resume_ID from T0055_HRMS_Interview_Schedule  WITH (NOLOCK)
	        where Schedule_Date <=@To_Date and Cmp_ID=@Cmp_ID   group by Resume_ID)IS2  on
	        IS1.REsume_ID=IS2.REsume_ID  and Cmp_ID=@Cmp_ID and IS1.Process_Dis_No =IS2.Process_Dis_No1 
	        

	   End	
	   
	    Declare @Interview_Detail table
		(
				Schedule varchar(20),
				Resume_ID  numeric(18,0),
				Resume_status numeric(1,0),
				Rec_Post_ID numeric(18,0)
	       
		 )
	   
	   Declare @Status as numeric(1,0)
	   Declare @Schedule_Date as DateTime
	   Declare @Process_dis_No as numeric(1,0)
	   Declare @Rec_Post_ID as Numeric(18,0)
	   Declare @Resume_ID as Numeric(18,0)
	   

   if @Resume_Status = 0 
     Begin 

					  Declare Cur_Resume  cursor for 
					   Select IS2.Resume_ID ,Status,Schedule_Date,Process_dis_No,Rec_Post_ID from T0055_HRMS_Interview_Schedule IS1 WITH (NOLOCK) inner join
						@Resume_cons  IS2 on IS1.Resume_ID= IS2.Resume_ID where Cmp_ID=@Cmp_ID and Status =0

					  open Cur_Resume 
					  Fetch next from Cur_Resume into @Resume_ID,@Status,@Schedule_Date,@Process_dis_No,@Rec_Post_ID
					  while @@fetch_status = 0                    
						begin                    
					       
						   if @Status = 0
							 Begin 
								 --Select @Process_dis_No as process_dis,@Rec_Post_ID as post_ID,@Status as Status1
								 if @Process_dis_No = 1
								   Begin 
										Insert into  @Interview_Detail Values('1st Interview',@Resume_ID,@Status,@Rec_Post_ID)
								   End
								  Else if  @Process_dis_No = 2
								   Begin 
	                  					Insert into  @Interview_Detail Values('2st Interview',@Resume_ID,@Status,@Rec_Post_ID)
								   End
								  Else if @Process_dis_No = 3
								   Begin 
	                 					Insert into  @Interview_Detail Values('3st Interview',@Resume_ID,@Status,@Rec_Post_ID)
								   End
							 end
					      
							 fetch next from Cur_Resume into @Resume_ID,@Status,@Schedule_Date,@Process_dis_No ,@Rec_Post_ID          
						end                    
					close Cur_Resume                    
				deallocate Cur_Resume  
		end
 	 
Else if @Resume_Status =1
	  Begin
				   Declare Cur_Resume  cursor for 
				   Select IS2.Resume_ID ,Status,Schedule_Date,Process_dis_No,Rec_Post_ID from T0055_HRMS_Interview_Schedule IS1 WITH (NOLOCK) inner join
					@Resume_cons  IS2 on IS1.Resume_ID= IS2.Resume_ID where Cmp_ID=@Cmp_ID and Status =1

				  open Cur_Resume 
				  Fetch next from Cur_Resume into @Resume_ID,@Status,@Schedule_Date,@Process_dis_No,@Rec_Post_ID
				  while @@fetch_status = 0                    
					begin                    
				       
					   if @Status = 1
						 Begin 
							 --Select @Process_dis_No as process_dis,@Rec_Post_ID as post_ID,@Status as Status1
							 if @Process_dis_No = 1
							   Begin 
									Insert into  @Interview_Detail Values('1st Interview',@Resume_ID,@Status,@Rec_Post_ID)
							   End
							  Else if  @Process_dis_No = 2
							   Begin 
	                  				Insert into  @Interview_Detail Values('2st Interview',@Resume_ID,@Status,@Rec_Post_ID)
							   End
							  Else if @Process_dis_No = 3
							   Begin 
	                 				Insert into  @Interview_Detail Values('3st Interview',@Resume_ID,@Status,@Rec_Post_ID)
							   End
						 end
				      
						 fetch next from Cur_Resume into @Resume_ID,@Status,@Schedule_Date,@Process_dis_No ,@Rec_Post_ID          
					end                    
				close Cur_Resume                    
			deallocate Cur_Resume  
    End
    
else if  @Resume_Status=2
     Begin
			Declare Cur_Resume  cursor for 
				Select IS2.Resume_ID ,Status,Schedule_Date,Process_dis_No,Rec_Post_ID from T0055_HRMS_Interview_Schedule IS1 WITH (NOLOCK) inner join
					@Resume_cons  IS2 on IS1.Resume_ID= IS2.Resume_ID where Cmp_ID=@Cmp_ID and Status =2

				  open Cur_Resume 
				  Fetch next from Cur_Resume into @Resume_ID,@Status,@Schedule_Date,@Process_dis_No,@Rec_Post_ID
				  while @@fetch_status = 0                    
					begin                    
				       
					   if @Status = 1
						 Begin 
							 --Select @Process_dis_No as process_dis,@Rec_Post_ID as post_ID,@Status as Status1
							 if @Process_dis_No = 1
							   Begin 
									Insert into  @Interview_Detail Values('1st Interview',@Resume_ID,@Status,@Rec_Post_ID)
							   End
							  Else if  @Process_dis_No = 2
							   Begin 
	                  				Insert into  @Interview_Detail Values('2st Interview',@Resume_ID,@Status,@Rec_Post_ID)
							   End
							  Else if @Process_dis_No = 3
							   Begin 
	                 				Insert into  @Interview_Detail Values('3st Interview',@Resume_ID,@Status,@Rec_Post_ID)
							   End
						 end
				      
						 fetch next from Cur_Resume into @Resume_ID,@Status,@Schedule_Date,@Process_dis_No ,@Rec_Post_ID          
					end                    
				close Cur_Resume                    
			deallocate Cur_Resume  
    End
  
  
     Select  ID.*,RM.Initial + RM.Emp_first_name + isnull(RM.Emp_Second_name,'')  + RM.Emp_Last_name as APP_Full_Name,RR.Job_title from @Interview_Detail ID inner join T0055_Resume_Master RM WITH (NOLOCK)
       on ID.Resume_ID = RM.Resume_ID   Inner join T0052_HRMS_Posted_Recruitment HP WITH (NOLOCK) on RM.Rec_Post_ID =HP.Rec_Post_ID inner join T0050_HRMS_Recruitment_Request RR WITH (NOLOCK)
       on RR.Rec_Req_ID = HP.Rec_Req_ID
       where RM.Cmp_ID=@Cmp_Id 
     


RETURN




