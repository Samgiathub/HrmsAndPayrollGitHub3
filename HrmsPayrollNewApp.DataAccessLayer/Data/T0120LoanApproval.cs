using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120LoanApproval
{
    public decimal LoanAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? LoanAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LoanId { get; set; }

    public DateTime LoanAprDate { get; set; }

    public string LoanAprCode { get; set; } = null!;

    public decimal LoanAprAmount { get; set; }

    public decimal LoanAprNoOfInstallment { get; set; }

    public decimal LoanAprInstallmentAmount { get; set; }

    public string LoanAprIntrestType { get; set; } = null!;

    public decimal LoanAprIntrestPer { get; set; }

    public decimal LoanAprIntrestAmount { get; set; }

    public decimal LoanAprDeductFromSal { get; set; }

    public decimal LoanAprPendingAmount { get; set; }

    public string LoanAprBy { get; set; } = null!;

    public DateTime? LoanAprPaymentDate { get; set; }

    public string LoanAprPaymentType { get; set; } = null!;

    public decimal? BankId { get; set; }

    public string LoanAprChequeNo { get; set; } = null!;

    public string? LoanAprStatus { get; set; }

    public string? LoanNumber { get; set; }

    public string? DeductionType { get; set; }

    public decimal? GuarantorEmpId { get; set; }

    public DateTime? InstallmentStartDate { get; set; }

    public string? LoanApprovalRemarks { get; set; }

    public decimal SubsidyRecoverPerc { get; set; }

    public string? AttachmentPath { get; set; }

    public DateTime? ActualSubsidyStartDate { get; set; }

    public decimal OpeningSubsidyAmount { get; set; }

    public decimal NoOfInstLoanAmt { get; set; }

    public decimal TotalLoanIntAmount { get; set; }

    public decimal LoanIntInstallmentAmount { get; set; }

    public decimal LoanAprPendingIntAmount { get; set; }

    public decimal PaidAmount { get; set; }

    public decimal NoOfInstallmentPaid { get; set; }

    public decimal CalculatedInterestAmount { get; set; }

    public decimal? CfLoanAmt { get; set; }

    public decimal? CfLoanAprId { get; set; }

    public decimal? GuarantorEmpId2 { get; set; }

    public decimal SubSidyAmount { get; set; }

    public decimal? AdId { get; set; }

    public virtual T0040BankMaster? Bank { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LoanMaster Loan { get; set; } = null!;

    public virtual ICollection<T0210MonthlyLoanPayment> T0210MonthlyLoanPayments { get; set; } = new List<T0210MonthlyLoanPayment>();
}
