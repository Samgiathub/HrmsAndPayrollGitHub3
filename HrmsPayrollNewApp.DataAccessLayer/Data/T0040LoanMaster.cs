using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040LoanMaster
{
    public decimal LoanId { get; set; }

    public decimal CmpId { get; set; }

    public string LoanName { get; set; } = null!;

    public decimal LoanMaxLimit { get; set; }

    public string LoanComments { get; set; } = null!;

    public byte? CompanyLoan { get; set; }

    public byte MaxLimitOnBasicGross { get; set; }

    public string? AllowanceIdStringMaxLimit { get; set; }

    public decimal? NoOfTimes { get; set; }

    public byte LoanGuarantor { get; set; }

    public byte? DesigMaxLimit { get; set; }

    public byte IsInterestSubsidyLimit { get; set; }

    public decimal InterestRecoveryPer { get; set; }

    public string? SubsidyDesigIdString { get; set; }

    public string? LoanInterestType { get; set; }

    public decimal LoanInterestPer { get; set; }

    public byte IsAttachment { get; set; }

    public byte IsEligible { get; set; }

    public decimal EligibleDays { get; set; }

    public decimal SubsidyBondDays { get; set; }

    public byte IsGpf { get; set; }

    public decimal GpfEligibleMonth { get; set; }

    public decimal GpfDaysDiffApplication { get; set; }

    public decimal GpfMaxLoanPer { get; set; }

    public byte IsPrincipalFirstThanInt { get; set; }

    public decimal LoanGuarantor2 { get; set; }

    public decimal IsGradeWise { get; set; }

    public string? GradeDetails { get; set; }

    public string? LoanShortName { get; set; }

    public byte IsSubsidyLoan { get; set; }

    public decimal SubsidyBondMonth { get; set; }

    public byte? IsIntrestAmountAsPerquisiteIt { get; set; }

    public string? GujaratiAlias { get; set; }

    public decimal HideLoanMaxAmount { get; set; }

    public bool LoanApplicationReasonRequired { get; set; }

    public decimal MaxInstallment { get; set; }

    public int? IsContractDue { get; set; }

    public int? ContractDueDays { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0100LoanApplication> T0100LoanApplications { get; set; } = new List<T0100LoanApplication>();

    public virtual ICollection<T0115LoanLevelApproval> T0115LoanLevelApprovals { get; set; } = new List<T0115LoanLevelApproval>();

    public virtual ICollection<T0120LoanApproval> T0120LoanApprovals { get; set; } = new List<T0120LoanApproval>();

    public virtual ICollection<T0140LoanTransaction> T0140LoanTransactions { get; set; } = new List<T0140LoanTransaction>();
}
