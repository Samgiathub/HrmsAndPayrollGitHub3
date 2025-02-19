CREATE PROCEDURE [dbo].[P0040_PROFESSIONAL_SETTING_statewise]
	@STATE_ID AS NUMERIC output,
	@CMP_ID AS NUMERIC,
	@STATE_NAME AS VARCHAR(100)	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

begin
    
	If @STATE_NAME  = 'Andaman and Nicobar Islands'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Andhra Pradesh'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,5000,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',5001,6000,60)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',6001,10000,80)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',10001,15000,100)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',15001,20000,150)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',20001,9999999,200)
		end	
		
	Else If @STATE_NAME  = 'Arunachal Pradesh'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Assam'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,3500,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',3501,5000,30)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',5001,7000,75)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',7001,9000,110)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',9001,9999999,208)
		end	
	
	Else If @STATE_NAME  = 'Bihar'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,24999,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',25000,41666,84)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',41667,83333,167)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',83334,9999999,208)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Mar-2013',83334,9999999,212)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-apr-2013',83334,9999999,208)
			
		end	
	
	Else If @STATE_NAME  = 'Chandigarh'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Chhattisgarh'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,12500,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',12501,16667,150)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',16668,20833,180)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',20834,25000,190)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',25001,9999999,200)
		end	
	
	Else If @STATE_NAME  = 'Dadra and Nagar Haveli'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Daman and Diu'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Delhi'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Goa'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Gujarat'
		begin
			if YEAR(GETDATE()) > 2020
			BEGIN
				insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,12000,0)
				insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',12000,9999999,200)
			END
			ELSE
			BEGIN
				insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,2999,0)
				insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',3000,5999,0)
				insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',6000,8999,80)
				insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',9000,11999,150)
				insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',12000,9999999,200)
			END
		end	
	
	Else If @STATE_NAME  = 'Haryana'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Himachal Pradesh'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Jammu and Kashmir'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Jharkhand'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,25000,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',25001,41666,100)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',41667,66666,150)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',66667,83333,175)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',83334,9999999,208)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Mar-2013',83334,9999999,212)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-apr-2013',83334,9999999,208)
		end	
	Else If @STATE_NAME  = 'Karnataka'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',10000,14999,150)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',15000,9999999,200)
		end	
	Else If @STATE_NAME  = 'Kerala'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,1999,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',2000,2999,20)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',3000,4999,30)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',5000,7499,50)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',7500,9999,75)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',10000,12499,100)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',12500,16666,125)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',16667,20833,167)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',20834,9999999,208)
		end		
	
	Else If @STATE_NAME  = 'Lakshadweep'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	

	Else If @STATE_NAME  = 'Madhya Pradesh'
			begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,10000,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',10001,12500,83)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Mar-2013',10001,12500,87)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Apr-2013',10001,12500,83)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',12501,15000,125)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',15000,9999999,208)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Mar-2013',15000,9999999,212)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Apr-2013',15000,9999999,208)
		end	
	
	Else If @STATE_NAME  = 'Maharashtra'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,5000,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',5001,10000,175)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',10001,9999999,200)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Mar-2013',10001,9999999,300)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Apr-2013',10001,9999999,200)
			
		end	
	
	Else If @STATE_NAME  = 'Manipur'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,1250,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',1251,1667,25)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',1668,2500,38)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',2501,3333,50)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',3334,4167,63)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',4168,5000,75)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',5001,6250,92)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',6251,8333,134)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',8334,10417,184)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',10418,9999999,208)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Mar-2013',10418,9999999,210)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-apr-2013',10418,9999999,208)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Sep-2013',10418,9999999,210)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Oct-2013',10418,9999999,208)
		end	
	
	Else If @STATE_NAME  = 'Meghalaya'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,4166,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',4167,6250,17)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',6251,8333,25)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',8334,12500,42)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',12501,16666,63)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',16667,20833,83)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',20834,25000,104)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',25001,29166,125)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',29167,33333,150)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',33334,37500,175)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',37501,41666,200)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',41667,9999999,208)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Mar-2013',41667,9999999,212)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Apr-2013',41667,9999999,208)
		
		end	
	
	Else If @STATE_NAME  = 'Mizoram'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
		
	Else If @STATE_NAME  = 'Nagaland'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	 
		
	Else If @STATE_NAME  = 'Orissa'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,5000,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',5001,6000,30)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',6001,8000,50)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',8001,10000,75)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',10001,15000,100)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',15001,20000,150)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',20001,9999999,200)
		end
	
	Else If @STATE_NAME  = 'Puducherry'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',301,600,1)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',601,1200,2)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',1201,1800,4)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',1801,3000,6)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',3001,4800,12)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',4801,6000,25)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',6001,9000,50)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',9001,12000,75)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',12001,15000,100)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',15000,9999999,125)
		end	
		
	Else If @STATE_NAME  = 'Punjab'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
		
	Else If @STATE_NAME  = 'Rajasthan'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Sikkim'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Tamil Nadu'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,3500,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',3501,5000,17)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',5001,7500,40)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',7501,10000,85)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',10001,12500,127)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',12501,9999999,183)
		end	
		
	Else If @STATE_NAME  = 'Tripura'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,2500,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',2501,3500,55)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',3501,4500,85)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',4501,6500,100)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',6501,10000,140)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',10001,9999999,180)
		end	
	
	Else If @STATE_NAME  = 'Uttarakhand'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'Uttar Pradesh'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,9999999,0)
		end	
	
	Else If @STATE_NAME  = 'West Bengal'
		begin
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',0,5000,0)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',5001,6000,40)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',6001,7000,45)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',7001,8000,50)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',8001,9000,90)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',9001,15000,110)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',15001,25000,130)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',25001,40000,150)
			insert into T0040_PROFESSIONAL_SETTING_StateWise (Cmp_ID,State_ID,For_Date,From_Limit,To_Limit,Amount) values (@CMP_ID,@STATE_ID,'01-Jan-2013',40001,9999999,200)
		end	
End

RETURN


 

