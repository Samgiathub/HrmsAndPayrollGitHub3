

-- =============================================
-- Author:		<Gadriwala Muslim >
-- Create date: <06/07/2015>
-- Description:	<Leave Name Bind with Grade and Branch Wise>
-- =============================================
CREATE PROCEDURE [dbo].[GET_Leave_Details]
	@Cmp_ID numeric(18,0),
	@Grd_ID	numeric(18,0),
	@Emp_ID numeric(18,0),
	@Branch_ID numeric(18,0),
	@Leave_Type nvarchar(50) = '',
	@Leave_ID	Numeric(18,0) = 0 --Added by Nimesh on 26-Nov-2015 (To get only particular leave balance)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
	
	IF (@Leave_ID = 0)
		SET @Leave_ID = NULL;
	
		Create Table #Leave_Name
		(
			Leave_ID numeric(18,0),
			Leave_Name nvarchar(250),
			Multi_Branch_ID nvarchar(max)
		)
		
		Declare @Cur_Leave_ID numeric(18,0)
		Declare @Cur_Leave_Name nvarchar(250)
		Declare @Cur_Multi_Branch_ID nvarchar(max)
		if @Leave_Type = 'Encashable'	
			begin	
			
				Insert into #Leave_Name(Leave_ID,Leave_Name,Multi_Branch_ID)	
				select Leave_ID,Leave_Name,isnull(Multi_Branch_ID,'') 
				from T0040_Leave_Master WITH (NOLOCK)
				where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end )) and Leave_Type='Encashable' and  Cmp_ID = @Cmp_ID  
						AND Leave_ID = ISNULL(@Leave_ID, Leave_ID)
				order By Leave_Name
			end
		else if @Leave_Type = 'Carry_Forward'	
			begin
				Insert into #Leave_Name(Leave_ID,Leave_Name,Multi_Branch_ID)	
				select Leave_ID,Leave_Name,isnull(Multi_Branch_ID,'') 
				from T0040_Leave_MASTER  WITH (NOLOCK)
				where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end )) and  Cmp_ID = @Cmp_ID  and (leave_cf_type<>'None') 
						AND Leave_ID = ISNULL(@Leave_ID, Leave_ID)
				order by Leave_Name
			end
		else IF @Leave_Type = 'Opening'
			begin
				Insert into #Leave_Name(Leave_ID,Leave_Name,Multi_Branch_ID)	
				select Leave_ID,Leave_Name,isnull(Multi_Branch_ID,'') 
				from V0050_LEAVE_DETAIL  WITH (NOLOCK)
				where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end )) and Cmp_ID = @cmp_ID and Grd_ID = @Grd_ID 
				and isnull(Default_Short_Name,'') <> 'COMP' and isnull(Default_Short_Name,'') <> 'COPH' and isnull(Default_Short_Name,'') <> 'COND'
						AND Leave_ID = ISNULL(@Leave_ID, Leave_ID)
				
			end
		else IF @Leave_Type = 'Attendance' --Mukti(24082017)
			begin
				Insert into #Leave_Name(Leave_ID,Leave_Name,Multi_Branch_ID)	
				select Leave_ID,Leave_Name,isnull(Multi_Branch_ID,'') 
				from V0050_LEAVE_DETAIL  WITH (NOLOCK)
				where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end )) and Cmp_ID = @cmp_ID and Grd_ID = @Grd_ID 
				and isnull(Default_Short_Name,'') <> 'COMP' and ISNULL(Apply_Hourly,0) = 0 AND Leave_ID = ISNULL(@Leave_ID, Leave_ID)
				
			end
		else
			begin
				
				Insert into #Leave_Name(Leave_ID,Leave_Name,Multi_Branch_ID)	
				select Leave_ID,Leave_Name,isnull(Multi_Branch_ID,'') 
				from V0040_LEAVE_DETAILS  WITH (NOLOCK)
				where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end )) and Grd_ID = @Grd_ID	
						AND Leave_ID = ISNULL(@Leave_ID, Leave_ID)
				order by Leave_Name	
			end
	IF isnull(@Branch_ID,0) = 0 
		begin
			--select @branch_id = branch_id from dbo.T0095_INCREMENT
			--		where Emp_ID = @Emp_ID and Increment_ID = 
			--		(select MAX(Increment_ID) from dbo.T0095_INCREMENT where Emp_ID = @Emp_ID and Increment_Effective_Date<=getdate())	

				select	@branch_id = INC.branch_id 
				from	dbo.T0095_INCREMENT INC WITH (NOLOCK) INNER JOIN 
						(
							SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 	
							FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN 
									T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID INNER JOIN 
									(
										SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID	
										FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN 
												T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID 
										WHERE	I3.Increment_effective_Date <= getdate() AND I3.Cmp_ID = @Cmp_ID	
										GROUP BY I3.EMP_ID 
									 ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID	
							GROUP BY I2.Emp_ID 
						) I ON INC.Emp_ID = I.Emp_ID AND INC.Increment_ID = I.Increment_ID
				where INc.Emp_ID = @Emp_ID 
		end
		
		if @Branch_ID > 0
			begin
				Declare CurLeaveName cursor for select * from #Leave_Name
					open CurLeaveName
							Fetch next from CurLeaveName into @Cur_Leave_ID,@Cur_Leave_Name,@Cur_Multi_Branch_ID
							while @@FETCH_STATUS = 0
								begin
										
										
											if @Cur_Multi_Branch_ID  <> '' 
												begin
															
														if not exists (select Data from dbo.Split(@Cur_Multi_Branch_ID,'#') where Data = @Branch_ID)
															begin
																
																delete from #Leave_Name where Leave_ID = @Cur_Leave_ID
															end
														
												end
												
								Fetch next from CurLeaveName into @Cur_Leave_ID,@Cur_Leave_Name,@Cur_Multi_Branch_ID	
								end
									
					close CurLEaveName		
					Deallocate CurLeaveName
			end
			
		IF @Leave_Type = 'Opening'
			begin
				select VL.Leave_ID,VL.Leave_Name,isnull(Leave_Days,'') from V0050_LEAVE_DETAIL VL inner join
						#Leave_Name LN on VL.Leave_ID = LN.Leave_ID  
					where (1=(case isnull(vl.leave_Status,0) when 0 then (case when isnull(vl.InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end )) and Cmp_ID = @cmp_ID and Grd_ID = @Grd_ID
					and isnull(Default_Short_Name,'') <> 'COMP' and isnull(Default_Short_Name,'') <> 'COPH' and isnull(Default_Short_Name,'') <> 'COND'
					order by leave_sorting_no asc
			end
		else IF @Leave_Type = 'Attendance'
			begin
				select VL.Leave_ID,VL.Leave_Name,isnull(Leave_Days,'') from V0050_LEAVE_DETAIL VL inner join
						#Leave_Name LN on VL.Leave_ID = LN.Leave_ID
					where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end )) and Cmp_ID = @cmp_ID and Grd_ID = @Grd_ID
					and isnull(Default_Short_Name,'') <> 'COMP' and ISNULL(Apply_Hourly,0) = 0
					order by leave_sorting_no asc
			end
		else
			begin
				select LN.Leave_ID,LN.LEave_Name from #Leave_Name LN Inner Join
							 T0040_LEAVE_MASTER LD WITH (NOLOCK) on LN.Leave_ID =ld.Leave_ID
				order by ld.leave_sorting_no asc
				
			end
  
END

