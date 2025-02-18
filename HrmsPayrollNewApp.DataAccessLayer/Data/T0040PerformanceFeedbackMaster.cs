using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040PerformanceFeedbackMaster
{
    public decimal PerformanceFId { get; set; }

    public decimal CmpId { get; set; }

    public string? PerformanceName { get; set; }

    public string? PerformanceDesc { get; set; }

    public int? PerformanceSort { get; set; }

    public byte IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public string EvaluationType { get; set; } = null!;

    public DateTime? EffectiveDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0052HrmsPerformanceAnswer> T0052HrmsPerformanceAnswers { get; set; } = new List<T0052HrmsPerformanceAnswer>();
}
