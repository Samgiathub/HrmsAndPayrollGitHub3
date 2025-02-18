using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsPerformanceAnswer
{
    public decimal PfanswerId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? InitiateId { get; set; }

    public decimal? PerformanceFId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Answer { get; set; }

    public string? HodFeedback { get; set; }

    public string? GhFeedback { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0050HrmsInitiateAppraisal? Initiate { get; set; }

    public virtual T0040PerformanceFeedbackMaster? PerformanceF { get; set; }
}
