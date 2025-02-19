



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0070_IT_MASTER_DEFAULT]    
 @Company_ID Numeric,    
 @Login_ID Numeric = 0    
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'80CCC','80CCC',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'80CCD','80CCD',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'80DD','80DD',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Bank FD','Bank FD',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Capital Gai','Capital Gai',0,'E',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Deduction under pension scheme','Pension Pla',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Equity Linked Saving Scheme','Equity Linked Saving Scheme',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Housing Loan Principal Repayment','Housing Loan Principal',150000,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'HRA','HRA',0,'D',0,1,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Income from House Property','Income from House Property',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Income From Other Source','Income From Other Source',0,'E',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Infra Bond','Infra Bond',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Intrest on housing loan (For Tax exemption) Sec 24','Intrest on housing loan (For Tax exemption) Sec 24',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'L.I.C.','L.I.C.',100000,'D',0,0,0,Null,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Medical Allowance','Medical Allowance',15000,'D',1,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Medical Insurance Premium (Parants) (80 D)','Mediclaim Parants',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Medical Insurance Premium (Sec 80D Self/Family)','Mediclaim Self or Family',15000,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'NSC','NSC',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Other','Other',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Public Provident Fund','PPF',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'School Fees','School Fees',0,'D',0,0,0,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Sec.80 G (Donation)','Sec.80 G (Donation)',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Sec.80GGC (Contribution To political Party)','Sec.80GGC',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
 --EXEC P0070_IT_MASTER 0,@Company_ID,'Voluntry EPF','Vol.EPF',0,'D',0,0,1,NULL,0,0,1,0,1,'I',''    
    
    
 ------------------------------------------------------------------------------------    
 Declare @IT_Parent_ID as numeric     
 SET @IT_Parent_ID = NULL    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80 C', 'A' , 0 , 'I' , 1, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  1, 0, 'I','',0,'', 1, 0, 0    
 SET @IT_Parent_ID = (Select IT_ID From T0070_IT_MASTER WITH (NOLOCK) where IT_Name = '80 C' and Cmp_ID = @Company_ID)    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80CCC', '80CCC' , 0 , 'D' , 2, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', '',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'L.I.C.', 'L.I.C.' , 0 , 'D' , 3, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', 'Life Insurance Premia/Contribution to Jeevan Dhara/Jeevan Akshay Plan (For Self/Spouse/Children)',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Public Provident Fund', 'Public ProvidentFund', 0, 'D' , 4, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', 'Contribution to Public Provident Fund (For Self/Minor Children)',0,'', 0, 0, 1   
 EXEC P0070_IT_MASTER 0, @Company_ID, 'POCTD', 'POCTD' , 0 , 'D' , 5 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Deposit in 10/15 years account with Post Office CTD (For Self/Minor Children)',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'NSC VIII ISSUE', 'NSC VIII ISSUE' , 0, 'D' , 6 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID, 0, 1,'I', 'Deposits In Nation Saving Scheme - 1992',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'NHB DEPOSIT SCHEME', 'NHB DEPOSIT SCHEME' , 0, 'D' , 7, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Subscription to National Housing Bank Deposit Scheme (i.e. Home Loan A/C Scheme) (For Self Only)',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'NSC INTEREST', 'NSC INTEREST' , 0, 'D' , 8, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID, 0, 1, 'I','Interest Received on Nation Saving Scheme - 1992',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'ULIP', 'ULIP' , 0 , 'D' , 9, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Contribution to Unit Link Insurance Plan of UTI and/or LIC MUTUAL FUND (i.e. Dhanraksha 1989)',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'HOUSING LOAN REPAYMENT', 'HOUSINGLOANREPAYMENT', 0, 'D' , 10 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Repayment of Principal Amount of Housing Loan from Housing Agency/LIC/Bank (For Self Only)(No limit)',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'ELSS', 'ELSS' , 0 , 'D' , 11, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Investment in the Unit of Government approved plan framed under equity Linked Saving Scheme',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'EDUCATION FEES', 'EDUCATION FEES' , 0, 'D' , 12, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID, 0, 1,'I', 'Education Fees (School Fees)',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'UTI PENSION PLAN', 'UTI PENSION PLAN' , 0, 'D' , 13, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', 'Contribution to "Retirement Benefit Plan" of UTI',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'NSS', 'NSS' , 0 , 'D' , 14, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','National Saving scheme',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80 CCA(JEEVAN SURAKSHA)', '80 CCA' , 0 , 'D' , 15, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Premium paid for Jeevan Suraksha (for Self Only) Personal pension Plan of LIC or similar plan of other',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80 CCD(PENSION)', '80 CCD' , 0 , 'D' , 16 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Bank FD', 'Bank FD' , 0, 'D' , 17, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', 'Fixed Deposit',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Registration and Stamp duty', 'Reg. Stamp duty' , 0, 'I' , 18 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Registration and Stamp duty',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Equity Linked Saving Scheme', 'Equity Linked Saving' , 0, 'D' , 19 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Investment in the unit of Government Approved plan',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Voluntry EPF', 'Voluntry EPF' , 0, 'D' , 20 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Other', 'Other' , 0 , 'D' , 21 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Sukanya Samriddhi Yojana', 'SukanyaSamriddhi' , 150000 , 'D' , 22 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','',0,'', 0, 0, 0    --ADDED BY RAMIZ ON 25/11/2016
 Set @IT_Parent_ID = NULL   
 EXEC P0070_IT_MASTER 0, @Company_ID, '80 G', 'B' , 0 , 'I' , 101, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  1, 0, 'I','',0,'', 1, 0, 0    
     
 SET @IT_Parent_ID = (Select IT_ID From T0070_IT_MASTER WITH (NOLOCK) where IT_Name = '80 G' and Cmp_ID = @Company_ID )     
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Sec.80 G (Donation)', 'Sec.80 G (Donation)' , 0, 'D' , 102 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', '',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Sec.80GGC (Contribution To Political Party)', 'Sec.80GGC' , 0, 'D' , 103 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Authorized University or Education institution Donation', 'Approved University' , 0, 'D' , 104 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Authorized University or Education institution Donation',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Fund setup by State Government for the medical relief to the poor', 'Medical Relief' , 0, 'D' , 105 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Fund setup by State Government for the medical relief to the poor',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Donation to Institution which satisfies conditions under section 80G(5)', 'Donation in 80G(5)' , 0, 'D' , 106 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Donation to Institution which satisfies conditions under section 80G(5)',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Donation to notified temple, mosque, gurudwara church or other place (for renovation or repair)', 'Repair of temple' , 0, 'D' , 107 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Donation to notified temple, mosque, gurudwara church or other place (for renovation or repair)',0,'', 0, 0, 0    
     
 Set @IT_Parent_ID = NULL    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Chapter VI A', 'C' , 0, 'I' , 201, 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  1, 0,'I', '',0,'', 1, 0, 0    
     
 SET @IT_Parent_ID = (Select IT_ID From T0070_IT_MASTER WITH (NOLOCK) where IT_Name = 'Chapter VI A' and Cmp_ID = @Company_ID )     
 EXEC P0070_IT_MASTER 0, @Company_ID,'80D (Self/Family) - Below 60 Yrs Age', '80D (Self - Family)' , 25000, 'D' , 202 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', 'Payment made for mediclaim Insurance (Max limit Rs 25000 For Self/Spouse/Dependent Children)',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID,'80D (Self/Family) - Above 60 Yrs Age', '80D above 60' , 50000, 'D' , 202 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', 'Payment made for mediclaim Insurance (Max limit Rs 50000 For Self/Spouse/Dependent Children)',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80D (Parents) - Below 60 Yrs Age', '(80 D) (Parents)', 25000, 'D' , 203 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID, 0, 1,'I', 'Payment made for mediclaim Insurance (Max limit Rs 25000 if dependent parent is of the age of 60 year',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80D (Parents) - Above 60 Yrs Age', '80_D_P_Above60', 50000, 'D' , 203 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID, 0, 1,'I', 'Payment made for mediclaim Insurance (Max limit Rs 50000 if dependent parent is of the age above 60 year',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80DD', '80DD' , 0 , 'D' , 204, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Deduction in respect of maintenance including medical',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80 E', '80 E' , 0 , 'I' , 205 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Interest paid on loan taken for higher Education (For Self Only)',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80 EE', '80 EE' , 0 , 'D' , 206 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','80 EE',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80 U', '80 U' , 0 , 'D' , 207, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Deduction in respect of permanent physical disability (80U)',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80 DDB', '80 DDB' , 0 , 'D' , 208, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Deduction in respect of medical treatment',0,'', 0, 0, 1    
 EXEC P0070_IT_MASTER 0, @Company_ID, '80 CCD - 1B', '80 CCD - 1B' , 0 , 'D' , 209, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Receipt of Investment in Notified Pension Fund',0,'', 0, 0, 1
 EXEC P0070_IT_MASTER 0, @Company_ID, '80EEA', '80EEA' , 150000 , 'D' , 218, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Interest on housing loan for purchase of affordable house',0,'', 0, 0, 1
 EXEC P0070_IT_MASTER 0, @Company_ID, '80TTA', '80TTA' , 10000 , 'D' , 218, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Applicable to individuals and HUF except for senior citizens,Interest on savings account only',0,'', 0, 0, 1
 EXEC P0070_IT_MASTER 0, @Company_ID, '80TTB', '80TTB' , 40000 , 'D' , 218, 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Applicable to senior citizens,Interest on all kinds of deposits',0,'', 0, 0, 1

 Set @IT_Parent_ID = NULL    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Exempt. U|S 10', 'D' , 0, 'I' , 251 , 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  1, 0, 'I','',0,'', 1, 0, 0    
     
 SET @IT_Parent_ID = (Select IT_ID From T0070_IT_MASTER WITH (NOLOCK) where IT_Name = 'Exempt. U|S 10' and Cmp_ID = @Company_ID )    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Medical Allowance', 'Medical Allowance' , 0, 'D' , 252 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', '',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'HRA', 'HRA' , 0 , 'D' , 254, 1   , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0 , 1, 'I','',0,'', 0, 0, 0    
     
 Set @IT_Parent_ID = NULL    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Previous Employer Detail', 'E' , 0, 'I' , 351 , 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID, 1, 0, 'I','',0,'', 1, 0, 0    
     
 SET @IT_Parent_ID = (Select IT_ID From T0070_IT_MASTER WITH (NOLOCK) where IT_Name = 'Previous Employer Detail' and Cmp_ID = @Company_ID )    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Previous Employer Gross salary', 'Previ Emplr Gross Sa' , 0, 'I' , 352 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Previous Employer Gross salary',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Previous Employer PT', 'Prev Emp PT' , 5000, 'D' , 353 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID, 0, 1, 'I','Previous Employer Profession tax',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Previous Employer PF', 'Previous Employer PF', 0, 'D' , 354 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', 'Previous Employer PF',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Previous Employer TDS', 'Pre Emp TDS' , 0, 'D' , 355 , 10, 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','TDS (Tax + Surcharge + Education Cess)',0,'', 0, 0, 0    
     
 Set @IT_Parent_ID = NULL    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Other Detail', 'F' , 0, 'I' , 401 , 0 , 1, @IT_Parent_ID, NULL, NULL, @Login_ID,  1, 0,'I', '',0,'', 1, 0, 0    
     
 SET @IT_Parent_ID = (Select IT_ID From T0070_IT_MASTER WITH (NOLOCK) where IT_Name = 'Other Detail' and Cmp_ID = @Company_ID )    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Capital Gain', 'Capital Gain' , 0, 'I' , 402 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1,'I', '',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Income from House Property', 'Income from House Pr' , 0, 'D' , 403 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Income other then salary & House Property',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Income Other than Salary & House Property', 'Income Other than Sa', 0, 'D' , 404 , 0 , 1, @IT_Parent_ID , NULL, NULL, @Login_ID,  0, 1, 'I','Income Other than Salary & House Property',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Interest on housing loan (For Tax exemption) Sec 24', 'Interest on housing l' , 0, 'D' , 410 , 153, 1, @IT_Parent_ID , NULL, NULL, @Login_ID, 0, 1, 'I','Interest on housing loan (For Tax exemption) Sec 24',0,'', 0, 0, 0
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Income from self occupied property', 'Self occupied property' , 0, 'D' , 411 , 0, 1, @IT_Parent_ID , NULL, NULL, @Login_ID, 0, 1, 'I','Rent Aggrement',0,'', 0, 0, 0    
 EXEC P0070_IT_MASTER 0, @Company_ID, 'Health Check Up', 'Health Check Up' , 5000, 'I' , 409 , 170, 1, @IT_Parent_ID , NULL, NULL, @Login_ID, 0, 1, 'I','Health Checkup upto 5000',0,'', 0, 0, 0    
    
 ------------------------------------------------------------------------------------    
     
RETURN    
    



