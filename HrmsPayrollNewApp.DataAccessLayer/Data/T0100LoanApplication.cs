using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100LoanApplication
{
    public decimal LoanAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LoanId { get; set; }

    public DateTime LoanAppDate { get; set; }

    public string LoanAppCode { get; set; } = null!;

    public decimal LoanAppAmount { get; set; }

    public decimal LoanAppNoOfInsttlement { get; set; }

    public decimal LoanAppInstallmentAmount { get; set; }

    public string LoanAppComments { get; set; } = null!;

    public string LoanStatus { get; set; } = null!;

    public decimal? GuarantorEmpId { get; set; }

    public DateTime? InstallmentStartDate { get; set; }

    public string? LoanInterestType { get; set; }

    public decimal LoanInterestPer { get; set; }

    public DateTime? LoanRequireDate { get; set; }

    public string? AttachmentPath { get; set; }

    public decimal NoOfInstLoanAmt { get; set; }

    public decimal TotalLoanIntAmount { get; set; }

    public decimal LoanIntInstallmentAmount { get; set; }

    public decimal? GuarantorEmpId2 { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LoanMaster Loan { get; set; } = null!;

    public virtual ICollection<T0115LoanLevelApproval> T0115LoanLevelApprovals { get; set; } = new List<T0115LoanLevelApproval>();
}
