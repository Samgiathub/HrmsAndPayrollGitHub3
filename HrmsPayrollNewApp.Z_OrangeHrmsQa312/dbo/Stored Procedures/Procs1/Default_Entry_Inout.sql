

-- Created By rohit for update default setting to all company on 31012013
CREATE PROCEDURE [dbo].[Default_Entry_Inout]  
@cmp_id Numeric = 0,
@for_date datetime = ''
AS        
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
begin
declare @curCMP_ID numeric
Declare @From_Date Datetime
Declare @To_Date   Datetime

	if @cmp_id = 0
		set @cmp_id = Null
	
	if @for_date = ''
	 Set @for_date =GETDATE()
	 
	 
set @From_Date = REPLACE(CONVERT(VARCHAR(11),DATEADD(dd,-(DAY(@for_date)-1),@for_date),106), ' ','-')
set @To_Date = REPLACE(CONVERT(VARCHAR(11),DATEADD(dd,-(DAY(DATEADD(mm,1,@for_date))),DATEADD(mm,1,@for_date)),106), ' ','-') 
	 
	
	Declare CusrCompany cursor for	                  
	select CMP_ID from t0010_company_master WITH (NOLOCK) where cmp_id=isnull(@cmp_id,cmp_id)
	Open CusrCompany
	Fetch next from CusrCompany into @curCMP_ID
	While @@fetch_status = 0                    
		Begin     
				
			exec SP_RPT_EMP_INOUT_RECORD_GET_New_For_Auto  @Cmp_ID =1,@From_Date =@From_Date,@To_Date =@To_Date,@Branch_ID =0,@Cat_ID  =0,@Grd_ID=0,@Type_ID = 0,@Dept_ID =0,@Desig_ID = 0,@Emp_ID=0
		
			fetch next from CusrCompanyMST into @curCMP_ID	
		end
		close CusrCompany                    
		deallocate CusrCompany
	return
	end


