using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsResumeHealth
{
    public decimal RowId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal ResumeId { get; set; }

    public string? BloodGroup { get; set; }

    public string? Height { get; set; }

    public string? Weight { get; set; }

    public string? FileName { get; set; }

    public string? EmpFileName { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0055ResumeMaster Resume { get; set; } = null!;

    public virtual ICollection<T0091HrmsResumeHealthDetail> T0091HrmsResumeHealthDetails { get; set; } = new List<T0091HrmsResumeHealthDetail>();
}
