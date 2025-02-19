




CREATE PROCEDURE [dbo].[P0100_IT_FORM_DESIGN_DEFAULT_Pak]
	@Cmp_ID				Numeric,
	@Fin_year			Varchar(20)
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
 
	
	Declare @Form_Id Numeric
	Declare @IT_Id Numeric
	
	select @Form_Id = Form_Id from T0040_Form_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID
	
	exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',1,'Basic',0,0,0,1,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,0,0,0,0,@Fin_year		
	exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',101,'Total Earnings',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,0,0,0,0,@Fin_year
	exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',103,'1 Gross Salary',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,0,0,0,@Fin_year
	exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',104,' Salary ',0,0,0,0,1,1,101,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,4,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',105,'b Perquisites Value u/s 17(2)(as per From 12B)',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,4,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',106,'c Profit in lieu of salary u/s 17(3)(as per Form 1)',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,4,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',107,'d Total (a + b + c)',0,0,0,0,1,104,106,'',0,0,0,0,0,1,0,'I',@Form_Id,3,1,4,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',108,'2 Less : Allowance to the extent exempt u/s. 10',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,0,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',109,'HRA',0,0,0,7,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,6,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',110,'Conveyance',0,0,0,9,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,6,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',111,'Education',0,0,0,8,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Medical Allowance' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',112,'Medical',0,0,0,0,3,112,112,'',0,15000,0,1,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',122,'Total Allowance Exemption',0,0,0,0,1,109,112,'',0,0,0,0,0,1,0,'I',@Form_Id,2,1,6,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',123,'3 Balance (1 - 2)',0,0,0,0,2,107,122,'',0,0,0,0,0,1,0,'I',@Form_Id,3,1,0,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',124,'4. Deduction',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,0,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',125,'a. Tax on Employment',0,0,0,10,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,6,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',126,'5. Aggregate of 4',0,0,0,0,1,125,125,'',0,0,0,0,0,1,0,'I',@Form_Id,2,1,0,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',127,'6. Income Chargable under the Head ''Salaries (3-5)',0,0,0,0,2,123,126,'',0,0,0,0,0,1,0,'I',@Form_Id,3,1,0,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',128,'7. Add: Income from other income reported the employee.',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,0,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Capital Gain' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',129,'Capital Gain',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Income From Other Source' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',130,'Income from other source',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',131,'Total',0,0,0,0,1,129,130,'',0,0,0,0,0,1,0,'I',@Form_Id,0,0,10,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Intrest on housing loan (For Tax exemption) Sec 24' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',132,'Interest On Housing Loan (Sec 24)',0,0,0,0,3,132,132,'',0,150000,0,1,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',133,'Final Total of (7)',0,0,0,0,2,131,132,'',0,0,0,0,0,1,0,'I',@Form_Id,2,1,10,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',134,'*',0,0,0,0,2,123,126,'',0,0,0,0,0,1,0,'I',@Form_Id,0,0,10,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',135,'8. Gross Total Income (6 + 7)',0,0,0,0,1,133,134,'',0,0,0,0,0,1,0,'I',@Form_Id,3,1,0,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',136,'9. Deduction under chapter VIA',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,0,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = '80CCC' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',137,'a. 80CCC',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = '80CCD' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',138,'b. 80CCD',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',139,'c. 80C',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Equity Linked Saving Scheme' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',141,'1. Equity Linked Saving Scheme',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,8,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'NSC' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',142,'2. NSC',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,8,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Public Provident Fund' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',143,'3. PPF',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,8,0,0,@Fin_year
	
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',144,'4.(a)  EPF',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,8,0,0,@Fin_year
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',145,'(b) Vol.EPF',0,0,0,0,0,0,0,'',0,0,0,0,0,1,0,'I',@Form_Id,0,1,11,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Housing Loan Principal Repayment' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',146,'5. Housing Loan Principal Repayment',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,8,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'L.I.C.' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',147,'6. L.I.C',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,8,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Bank FD' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',148,'7. Bank FD',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,8,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'School Fees' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',149,'8. School Fees',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,8,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Other' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',150,'9. Other',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,8,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Deduction under pension scheme' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',151,'10. Deduction under pension scheme',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,8,0,0,@Fin_year
		
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',161,'Total (80CCC, 80CCD, 80C (1 To 10))',0,0,0,0,3,137,151,'',0,100000,0,1,0,1,0,'I',@Form_Id,0,1,12,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Infra Bond' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',163,'d. Infra Bond (Sec.80CCF)',0,0,0,0,3,0,0,'',0,20000,0,1,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',169,'Total (80C, 80CCC, 80CCD,80CCF)',0,0,0,0,3,161,163,'',0,120000,0,1,0,1,0,'I',@Form_Id,0,1,12,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Medical Insurance Premium (Sec 80D Self/Family)' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',170,'e. Sec 80D - Mediclaim (Self/Family)',0,0,0,0,3,170,170,'',0,15000,0,1,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Medical Insurance Premium (Parants) (80 D)' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',171,'Sec 80D - Mediclaim (Parents -> Senior Citizen)',0,0,0,0,3,171,171,'',0,20000,0,1,0,1,@IT_ID,'I',@Form_Id,0,1,10,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = '80DD' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',172,'f. 80DD',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Sec.80 G (Donation)' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',173,'g. 80G (Donation)',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--select @IT_ID = IT_ID from T0070_IT_master where IT_Name = 'Sec.80GGC (Contribution To political Party)' and Cmp_ID = @Cmp_ID
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',174,'h. 80GGC (Cont. To Political Party)',0,0,0,0,0,0,0,'',0,0,0,0,0,1,@IT_ID,'I',@Form_Id,0,1,6,0,0,@Fin_year
	
	--exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',181,'10. Aggregate of Chapter VIA (a to h)',0,0,0,0,1,107,174,'',0,0,0,0,0,1,0,'I',@Form_Id,2,1,0,0,0,@Fin_year
	exec P0100_IT_FORM_DESIGN 0,@Cmp_ID,'',182,'2. Total Taxable Income (8 - 10)',2,0,0,0,1,104,104,'',0,0,0,0,0,1,0,'I',@Form_Id,3,1,0,0,0,@Fin_year
	
	
RETURN




