
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Get_TravelMode_Desg]
	@Cmp_Id int,
	@Emp_Id int
	,@flag tinyint =0
	,@tran_type char
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF(@tran_type) = 'M'
	BEGIN
				Declare @Desg_ID Numeric(18,0)

	SELECT @Desg_ID =  I.desig_id 
	FROM   t0095_increment I INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
										  FROM   t0095_increment 
										  WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_Id and Emp_ID = @Emp_Id
										  GROUP  BY emp_id) Qry 
										  ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date


	Declare @ModeOfTravel As Varchar(MAX)
	set @ModeOfTravel = ''
	Create table #GetTravelMode
	(
		Travel_Mode_ID numeric(18,0),
		Cmp_ID numeric(18,0),
		Travel_Mode_Name varchar(100),
		Mode_Type INT,
		LoginID numeric(18,0)
	)
	
	select @ModeOfTravel= Mode_of_Travel From T0040_DESIGNATION_MASTER WITH (NOLOCK) where Desig_ID = @Desg_ID
	
	if @flag=1
		Begin
		
		
			insert into #GetTravelMode
			select Travel_mode_ID,Cmp_ID,Travel_Mode_Name,Mode_Type,Login_ID from
				T0030_TRAVEL_MODE_MASTER WITH (NOLOCK) where Travel_Mode_ID in (select items from dbo.Split2(@ModeOfTravel,'#'))
				
				
			insert into #GetTravelMode
				values(99999,0,'Special',0,0)
				
		
			select * from #GetTravelMode	
		
		End
	Else
		Begin	
		
			select * from T0030_TRAVEL_MODE_MASTER WITH (NOLOCK)
			where Travel_Mode_ID in (select items from dbo.Split2(@ModeOfTravel,'#'))
		End	
	--select * from T0030_TRAVEL_MODE_MASTER where Travel_Mode_ID in (select items from dbo.Split2(@ModeOfTravel,'#'))		
	END
	ELSE
	BEGIN

		SELECT 'Boarding,Lodging,Conveyance,Other Miscellaneous' as Travel_Expense_List
		
	END

END


