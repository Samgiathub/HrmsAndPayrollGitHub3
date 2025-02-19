


---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE_EMAIL_TEMPLATE]
	 @Cmp_ID						Numeric(18,0)
	,@Travel_Set_App_ID				Numeric(18,0)
	,@Travel_Approval_ID            numeric
	,@Rpt_Level						int
	,@IsFinal						int = 0
	
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @MODE_NAME VARCHAR(50)
	DECLARE @MODE_NO VARCHAR(50)
	DECLARE @FROM_PLACE VARCHAR(50)
	DECLARE @TO_PLACE VARCHAR(50)
	DECLARE @FOR_DATE varchar(20)
	DECLARE @DEP_TIME varchar(20)
	DECLARE @CITY varchar(50)
	DECLARE @NO_OF_PAS varchar(50)
	DECLARE @DESCRIPTION varchar(200)
	
	
	
	DECLARE @HTML_TABLE VARCHAR(MAX)
	SET @HTML_TABLE = ''
	
		
			-- FLIGHT BOOKING DETAIL ( TRAVEL - MODE = 1 )	
			
			IF(@IsFinal = 0)
			
				BEGIN


									IF EXISTS(			SELECT		1
														FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
														LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
														WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 1 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level)
									
					
											BEGIN
											
											
												set @HTML_TABLE='<table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
																	<tr><td colspan=''7'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Flight Booking Detail</td></tr>
																	<tr>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;;''>
																		From
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;;''>
																		To
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Airline Name
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Flight No
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Travel Date
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Dep. Time
																	</td>
																	
																</tr>'
												
											END
											
										DECLARE FLIGHT_BOOKING CURSOR  FAST_FORWARD FOR		
											SELECT		TAD.FROM_PLACE,TAD.TO_PLACE,TAD.MODE_NAME,TAD.MODE_NO,CONVERT(VARCHAR, CONVERT(DATE,TOD.FOR_DATE), 9) AS FOR_DATE,CONVERT(VARCHAR(15),CAST(TOD.FOR_DATE AS TIME),100) AS DEPTIME
											FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
											LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
											WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 1 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level

										OPEN FLIGHT_BOOKING
										FETCH NEXT FROM FLIGHT_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@FOR_DATE,@DEP_TIME
										WHILE @@fetch_status = 0
										BEGIN
										
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NAME + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FOR_DATE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DEP_TIME + '
																</td>
																
																
														   </tr>'			
									
										
										FETCH NEXT FROM FLIGHT_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@FOR_DATE,@DEP_TIME
									END
								CLOSE FLIGHT_BOOKING
								DEALLOCATE FLIGHT_BOOKING
							
							 --- END
							
							
							---- TRAIN BOOKING DETAIL ( TRAVEL - MODE = 2 )
							
							IF EXISTS (	SELECT		1
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 2 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level)
											BEGIN
												
														
									
												set @HTML_TABLE= @HTML_TABLE + '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
														<tr><td colspan=''7'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Train Booking Detail</td></tr>
														<tr>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															From
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															To
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															Train Name
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															Train No
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															Travel Date
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															Dep. Time
														</td>
														
													</tr>'
												
											END
										
							
										
										DECLARE TRAIN_BOOKING CURSOR  FAST_FORWARD FOR		
										SELECT		TAD.FROM_PLACE,TAD.TO_PLACE,TAD.MODE_NAME,TAD.MODE_NO,CONVERT(VARCHAR, CONVERT(DATE,TOD.FOR_DATE), 9) AS FOR_DATE,CONVERT(VARCHAR(15),CAST(TOD.FOR_DATE AS TIME),100) AS DEPTIME
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 2 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level
										OPEN TRAIN_BOOKING
										FETCH NEXT FROM TRAIN_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@FOR_DATE,@DEP_TIME
										WHILE @@fetch_status = 0
										BEGIN
										
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NAME + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FOR_DATE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DEP_TIME + '
																</td>
																
																
														   </tr>'			
									
										
										FETCH NEXT FROM TRAIN_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@FOR_DATE,@DEP_TIME
									END
								CLOSE TRAIN_BOOKING
								DEALLOCATE TRAIN_BOOKING
								
								
							---- HOTEL BOOKING DETAIL ( TRAVEL - MODE = 6 )
							
							IF EXISTS(SELECT		TAD.MODE_NAME,TAD.CITY,CONVERT(VARCHAR, CONVERT(DATE,TAD.CHECK_OUT_DATE), 9) AS CHECK_OUT_DATE
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 6 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level)
										BEGIN
														
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
																	<tr><td colspan=''4'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Hotel Booking Detail</td></tr>
																	<tr>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Hotel Name
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;;''>
																		City
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;;''>
																		Check Out Date
																	</td>
																	
																</tr>'
										END	
											
										DECLARE HOTEL_BOOKING CURSOR  FAST_FORWARD FOR		
										SELECT		TAD.MODE_NAME,TAD.CITY,CONVERT(VARCHAR, CONVERT(DATE,TAD.CHECK_OUT_DATE), 9) AS CHECK_OUT_DATE
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 6 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level
										OPEN HOTEL_BOOKING
										FETCH NEXT FROM HOTEL_BOOKING INTO	@MODE_NAME,@CITY,@FOR_DATE
										WHILE @@fetch_status = 0
										BEGIN
										
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NAME + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @CITY + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FOR_DATE + '
																</td>											
																
																
														   </tr>'			
									
										
										FETCH NEXT FROM HOTEL_BOOKING INTO	@MODE_NAME,@CITY,@FOR_DATE
									END
								CLOSE HOTEL_BOOKING
								DEALLOCATE HOTEL_BOOKING
							
							---- CAR/CAB BOOKING DETAIL ( TRAVEL-MODE = 3 )
							
							IF EXISTS(	SELECT		1
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 3 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level)
										BEGIN
										
											
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
													<tr><td colspan=''6'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Cab Booking Detail</td></tr>
													<tr>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														No Of Passengers
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Booking Date
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Pick Up Address
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Pick Up Time
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Drop Address
													</td>
													
												</tr>'
										
										END
										
										DECLARE CAB_BOOKING CURSOR  FAST_FORWARD FOR
										SELECT		isnull(TAD.NO_PASSENGER,0),CONVERT(VARCHAR, CONVERT(DATE,TAD.BOOKING_DATE), 9) AS BOOKING_DATE,TAD.PICK_UP_ADDRESS,CONVERT(VARCHAR(15),CAST(TAD.PICK_UP_TIME AS TIME),100) AS PICK_UP_TIME,ISNULL(TAD.DROP_ADDRESS,'')
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 3 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level
										OPEN CAB_BOOKING
										FETCH NEXT FROM CAB_BOOKING INTO	@NO_OF_PAS,@FOR_DATE,@FROM_PLACE,@DEP_TIME,@TO_PLACE
										WHILE @@fetch_status = 0
										BEGIN
									
									
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @NO_OF_PAS + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FOR_DATE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DEP_TIME + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																
																
														   </tr>'			
									
										
										FETCH NEXT FROM CAB_BOOKING INTO	@NO_OF_PAS,@FOR_DATE,@FROM_PLACE,@DEP_TIME,@TO_PLACE
									END
								CLOSE CAB_BOOKING
								DEALLOCATE CAB_BOOKING
							
							
							
							---- BUS BOOKING DETAIL ( TRAVEL - MODE = 4 )
							IF EXISTS(	SELECT		1
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 4 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level)
										BEGIN
										
											
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
													<tr><td colspan=''5'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Bus Booking Detail</td></tr>
													<tr>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														From
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														To
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Route Name
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Bus No
													</td>
													
												</tr>'
										
										END
										
										DECLARE BUS_BOOKING CURSOR  FAST_FORWARD FOR
										SELECT		TAD.FROM_PLACE,TAD.TO_PLACE,TAD.MODE_NAME,TAD.MODE_NO
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 4 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level
										OPEN BUS_BOOKING
										FETCH NEXT FROM BUS_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO
										WHILE @@fetch_status = 0
										BEGIN
									
									
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NAME + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>
																
														   </tr>'			
									
										
										FETCH NEXT FROM BUS_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO
									END
								CLOSE BUS_BOOKING
								DEALLOCATE BUS_BOOKING
								
								
							---- AUTO BOOKING DETAIL ( TRAVEL - MODE = 5 )
							IF EXISTS(	SELECT		1
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 5 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level)
										BEGIN
										
											
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
													<tr><td colspan=''5'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Auto Booking Detail</td></tr>
													<tr>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														From
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														To
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Auto No
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Description
													</td>
													
												</tr>'
										
										END
										
										DECLARE		AUTO_BOOKING CURSOR  FAST_FORWARD FOR
										SELECT		TAD.FROM_PLACE,TAD.TO_PLACE,ISNULL(TAD.MODE_NO,''),ISNULL(TAD.[DESCRIPTION],'')
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 5 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level
										OPEN AUTO_BOOKING
										FETCH NEXT FROM AUTO_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NO,@DESCRIPTION
										WHILE @@fetch_status = 0
										BEGIN
									
									
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DESCRIPTION + '
																</td>
																
														   </tr>'			
									
										
										FETCH NEXT FROM AUTO_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NO,@DESCRIPTION
									END
								CLOSE AUTO_BOOKING
								DEALLOCATE AUTO_BOOKING	
								
								
							---- OTHER BOOKING DETAIL ( TRAVEL - MODE = 7 )
							IF EXISTS(	SELECT		1
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 7 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level)
										BEGIN
										
											
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
													<tr><td colspan=''3'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Other Booking Detail</td></tr>
													<tr>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Bill No
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Description
													</td>
													
												</tr>'
										
										END
										
										DECLARE		OTHER_BOOKING CURSOR  FAST_FORWARD FOR
										SELECT		TAD.BILL_NO,ISNULL(TAD.[DESCRIPTION],'')
										FROM		T0115_Travel_Settlement_Level_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0115_Travel_Settlement_Level_Mode_Expense TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 7 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) AND TOD.RPT_LEVEL = @Rpt_Level
										OPEN OTHER_BOOKING
										FETCH NEXT FROM OTHER_BOOKING INTO	@MODE_NO,@DESCRIPTION
										WHILE @@fetch_status = 0
										BEGIN
									
									
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>									
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DESCRIPTION + '
																</td>
																
														   </tr>'			
									
										
										FETCH NEXT FROM OTHER_BOOKING INTO	@MODE_NO,@DESCRIPTION
									END
								CLOSE OTHER_BOOKING
								DEALLOCATE OTHER_BOOKING	
		END
	ELSE IF(@IsFinal = 1)
			
				BEGIN
									IF EXISTS(			SELECT		1
														FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
														LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
														WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 1 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID))
									
					
											BEGIN
											
											
												set @HTML_TABLE='<table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
																	<tr><td colspan=''7'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Flight Booking Detail</td></tr>
																	<tr>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;;''>
																		From
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;;''>
																		To
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Airline Name
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Flight No
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Travel Date
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Dep. Time
																	</td>
																	
																</tr>'
												
											END
											
										DECLARE FLIGHT_BOOKING CURSOR  FAST_FORWARD FOR		
											SELECT		TAD.FROM_PLACE,TAD.TO_PLACE,TAD.MODE_NAME,TAD.MODE_NO,CONVERT(VARCHAR, CONVERT(DATE,TOD.FOR_DATE), 9) AS FOR_DATE,CONVERT(VARCHAR(15),CAST(TOD.FOR_DATE AS TIME),100) AS DEPTIME
											FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
											LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
											WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 1 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) 
										OPEN FLIGHT_BOOKING
										FETCH NEXT FROM FLIGHT_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@FOR_DATE,@DEP_TIME
										WHILE @@fetch_status = 0
										BEGIN
										
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NAME + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FOR_DATE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DEP_TIME + '
																</td>
																
																
														   </tr>'			
									
										
										FETCH NEXT FROM FLIGHT_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@FOR_DATE,@DEP_TIME
									END
								CLOSE FLIGHT_BOOKING
								DEALLOCATE FLIGHT_BOOKING
							
							 --- END
							
							
							---- TRAIN BOOKING DETAIL ( TRAVEL - MODE = 2 )
							
							IF EXISTS (	SELECT		1
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 2 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID))
											BEGIN
												
														
									
												set @HTML_TABLE= @HTML_TABLE + '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
														<tr><td colspan=''7'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Train Booking Detail</td></tr>
														<tr>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															From
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															To
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															Train Name
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															Train No
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															Travel Date
														</td>
														<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
															Dep. Time
														</td>
														
													</tr>'
												
											END
										
							
										
										DECLARE TRAIN_BOOKING CURSOR  FAST_FORWARD FOR		
										SELECT		TAD.FROM_PLACE,TAD.TO_PLACE,TAD.MODE_NAME,TAD.MODE_NO,CONVERT(VARCHAR, CONVERT(DATE,TOD.FOR_DATE), 9) AS FOR_DATE,CONVERT(VARCHAR(15),CAST(TOD.FOR_DATE AS TIME),100) AS DEPTIME
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 2 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) 
										OPEN TRAIN_BOOKING
										FETCH NEXT FROM TRAIN_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@FOR_DATE,@DEP_TIME
										WHILE @@fetch_status = 0
										BEGIN
										
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NAME + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FOR_DATE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DEP_TIME + '
																</td>
																
																
														   </tr>'			
									
										
										FETCH NEXT FROM TRAIN_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@FOR_DATE,@DEP_TIME
									END
								CLOSE TRAIN_BOOKING
								DEALLOCATE TRAIN_BOOKING
								
								
							---- HOTEL BOOKING DETAIL ( TRAVEL - MODE = 6 )
							
							IF EXISTS(SELECT		TAD.MODE_NAME,TAD.CITY,CONVERT(VARCHAR, CONVERT(DATE,TAD.CHECK_OUT_DATE), 9) AS CHECK_OUT_DATE
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 6 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID))
										BEGIN
														
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
																	<tr><td colspan=''4'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Hotel Booking Detail</td></tr>
																	<tr>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
																		Hotel Name
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;;''>
																		City
																	</td>
																	<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;;''>
																		Check Out Date
																	</td>
																	
																</tr>'
										END	
											
										DECLARE HOTEL_BOOKING CURSOR  FAST_FORWARD FOR		
										SELECT		TAD.MODE_NAME,TAD.CITY,CONVERT(VARCHAR, CONVERT(DATE,TAD.CHECK_OUT_DATE), 9) AS CHECK_OUT_DATE
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 6 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) 
										OPEN HOTEL_BOOKING
										FETCH NEXT FROM HOTEL_BOOKING INTO	@MODE_NAME,@CITY,@FOR_DATE
										WHILE @@fetch_status = 0
										BEGIN
										
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NAME + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @CITY + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FOR_DATE + '
																</td>											
																
																
														   </tr>'			
									
										
										FETCH NEXT FROM HOTEL_BOOKING INTO	@MODE_NAME,@CITY,@FOR_DATE
									END
								CLOSE HOTEL_BOOKING
								DEALLOCATE HOTEL_BOOKING
							
							---- CAR/CAB BOOKING DETAIL ( TRAVEL-MODE = 3 )
							
							IF EXISTS(	SELECT		1
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 3 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID))
										BEGIN
										
											
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
													<tr><td colspan=''6'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Cab Booking Detail</td></tr>
													<tr>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														No Of Passengers
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Booking Date
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Pick Up Address
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Pick Up Time
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Drop Address
													</td>
													
												</tr>'
										
										END
										
										DECLARE CAB_BOOKING CURSOR  FAST_FORWARD FOR
										SELECT		isnull(TAD.NO_PASSENGER,0),CONVERT(VARCHAR, CONVERT(DATE,TAD.BOOKING_DATE), 9) AS BOOKING_DATE,TAD.PICK_UP_ADDRESS,CONVERT(VARCHAR(15),CAST(TAD.PICK_UP_TIME AS TIME),100) AS PICK_UP_TIME,ISNULL(TAD.DROP_ADDRESS,'')
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 3 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) 
										OPEN CAB_BOOKING
										FETCH NEXT FROM CAB_BOOKING INTO	@NO_OF_PAS,@FOR_DATE,@FROM_PLACE,@DEP_TIME,@TO_PLACE
										WHILE @@fetch_status = 0
										BEGIN
									
									
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @NO_OF_PAS + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FOR_DATE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DEP_TIME + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																
																
														   </tr>'			
									
										
										FETCH NEXT FROM CAB_BOOKING INTO	@NO_OF_PAS,@FOR_DATE,@FROM_PLACE,@DEP_TIME,@TO_PLACE
									END
								CLOSE CAB_BOOKING
								DEALLOCATE CAB_BOOKING
							
							
							
							---- BUS BOOKING DETAIL ( TRAVEL - MODE = 4 )
							IF EXISTS(	SELECT		1
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 4 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID))
										BEGIN
										
											
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
													<tr><td colspan=''5'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Bus Booking Detail</td></tr>
													<tr>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														From
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														To
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Route Name
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Bus No
													</td>
													
												</tr>'
										
										END
										
										DECLARE BUS_BOOKING CURSOR  FAST_FORWARD FOR
										SELECT		TAD.FROM_PLACE,TAD.TO_PLACE,TAD.MODE_NAME,TAD.MODE_NO
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 4 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) 
										OPEN BUS_BOOKING
										FETCH NEXT FROM BUS_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO
										WHILE @@fetch_status = 0
										BEGIN
									
									
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NAME + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>
																
														   </tr>'			
									
										
										FETCH NEXT FROM BUS_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO
									END
								CLOSE BUS_BOOKING
								DEALLOCATE BUS_BOOKING
								
								
							---- AUTO BOOKING DETAIL ( TRAVEL - MODE = 5 )
							IF EXISTS(	SELECT		1
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 5 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID))
										BEGIN
										
											
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
													<tr><td colspan=''5'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Auto Booking Detail</td></tr>
													<tr>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														From
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														To
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Auto No
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Description
													</td>
													
												</tr>'
										
										END
										
										DECLARE		AUTO_BOOKING CURSOR  FAST_FORWARD FOR
										SELECT		TAD.FROM_PLACE,TAD.TO_PLACE,ISNULL(TAD.MODE_NO,''),ISNULL(TAD.[DESCRIPTION],'')
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 5 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) 
										OPEN AUTO_BOOKING
										FETCH NEXT FROM AUTO_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NO,@DESCRIPTION
										WHILE @@fetch_status = 0
										BEGIN
									
									
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @FROM_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @TO_PLACE + '
																</td>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>											
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DESCRIPTION + '
																</td>
																
														   </tr>'			
									
										
										FETCH NEXT FROM AUTO_BOOKING INTO	@FROM_PLACE,@TO_PLACE,@MODE_NO,@DESCRIPTION
									END
								CLOSE AUTO_BOOKING
								DEALLOCATE AUTO_BOOKING	
								
								
							---- OTHER BOOKING DETAIL ( TRAVEL - MODE = 7 )
							IF EXISTS(	SELECT		1
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 7 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID))
										BEGIN
										
											
											set @HTML_TABLE = @HTML_TABLE +  '</table><table border=''1''  style=''margin-top: 10px;border-collapse: collapse;width:100%;''>
													<tr><td colspan=''3'' style=''background-color: #bcab79f7;padding-left: 5px;color:#fff;''>Other Booking Detail</td></tr>
													<tr>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Bill No
													</td>
													<td style=''font-family: Verdana;font-size: 9pt;text-align: Center;text-decoration: none;background-color: #e6e3da;width:100px;''>
														Description
													</td>
													
												</tr>'
										
										END
										
										DECLARE		OTHER_BOOKING CURSOR  FAST_FORWARD FOR
										SELECT		TAD.BILL_NO,ISNULL(TAD.[DESCRIPTION],'')
										FROM		T0150_Travel_Settlement_Approval_Expense TOD WITH (NOLOCK)
										LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TAD WITH (NOLOCK) ON TOD.INT_ID = TAD.INT_ID AND (TOD.TRAVEL_SETTLEMENT_ID = TAD.TRAVEL_SETTLEMENT_ID OR TOD.TRAVEL_APPROVAL_ID = TAD.TRAVEL_APPROVAL_ID)
										WHERE		TOD.CMP_ID = @CMP_ID AND TAD.TRAVEL_MODE = 7 AND (TAD.TRAVEL_SETTLEMENT_ID = @Travel_Set_App_ID OR TAD.TRAVEL_APPROVAL_ID = @Travel_Set_App_ID) 
										OPEN OTHER_BOOKING
										FETCH NEXT FROM OTHER_BOOKING INTO	@MODE_NO,@DESCRIPTION
										WHILE @@fetch_status = 0
										BEGIN
									
									
										set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @MODE_NO + '
																</td>									
																<td style=''font-family: Verdana;font-size: 8pt;text-align: Center;text-decoration: none;''>
																	' + @DESCRIPTION + '
																</td>
																
														   </tr>'			
									
										
										FETCH NEXT FROM OTHER_BOOKING INTO	@MODE_NO,@DESCRIPTION
									END
								CLOSE OTHER_BOOKING
								DEALLOCATE OTHER_BOOKING	
		END
		
		SELECT @HTML_TABLE AS FLIGHT_BOOKING_STR	
			
			
END


