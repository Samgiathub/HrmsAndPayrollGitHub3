using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100HrmsResumeEarnDeductionLevel
{
    public decimal AdRowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal AdId { get; set; }

    public DateTime? ForDate { get; set; }

    public string? EAdFlag { get; set; }

    public string? EAdMode { get; set; }

    public decimal? EAdPercentage { get; set; }

    public decimal? EAdAmount { get; set; }

    public decimal? EAdMaxLimit { get; set; }

    public decimal? TranId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;

    public virtual T0052ResumeFinalApproval? Tran { get; set; }
}
