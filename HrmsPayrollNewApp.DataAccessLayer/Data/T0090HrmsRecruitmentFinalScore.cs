using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsRecruitmentFinalScore
{
    public decimal TransId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal? CmpId { get; set; }

    public string? RecJobCode { get; set; }

    public decimal? ProcessId { get; set; }

    public decimal? RecPostId { get; set; }

    public decimal? ActualRate { get; set; }

    public decimal? GivenRate { get; set; }

    public string? Notes { get; set; }

    public decimal? Status { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0040HrmsRProcessMaster? Process { get; set; }

    public virtual T0052HrmsPostedRecruitment? RecPost { get; set; }

    public virtual T0055ResumeMaster Resume { get; set; } = null!;
}
