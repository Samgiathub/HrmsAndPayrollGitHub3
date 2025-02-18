using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsAppTraining
{
    public decimal AppTrainingId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? InitiateId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Type { get; set; }

    public string? AttendLastYear { get; set; }

    public string? RecommendedThisYear { get; set; }

    public string? ObservableChanges { get; set; }

    public string? ReasonForRecommend { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0050HrmsInitiateAppraisal? Initiate { get; set; }
}
