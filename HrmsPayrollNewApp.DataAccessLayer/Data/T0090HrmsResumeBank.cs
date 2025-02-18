using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsResumeBank
{
    public decimal ResumeBankId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal BankId { get; set; }

    public string? IfscCode { get; set; }

    public string? AccountNo { get; set; }

    public string? BranchName { get; set; }

    public virtual T0040BankMaster Bank { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;
}
